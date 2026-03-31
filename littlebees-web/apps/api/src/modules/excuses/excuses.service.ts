import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { AttendanceStatus, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateExcuseDto } from './dto/create-excuse.dto';
import { UpdateExcuseStatusDto } from './dto/update-excuse-status.dto';

@Injectable()
export class ExcusesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(
    tenantId: string,
    userId: string,
    userRole: string,
    dto: CreateExcuseDto,
  ) {
    const child = await this.prisma.child.findFirst({
      where: {
        id: dto.childId,
        tenantId,
        ...(userRole === UserRole.parent
            ? {
                parents: {
                  some: { userId },
                },
              }
            : {}),
      },
      include: {
        group: {
          select: {
            id: true,
            name: true,
            teacherId: true,
          },
        },
      },
    });

    if (!child) {
      throw new NotFoundException('Niño no encontrado');
    }

    const excuse = await this.prisma.excuse.create({
      data: {
        tenantId,
        childId: dto.childId,
        submittedBy: userId,
        type: dto.type,
        title: dto.title,
        description: dto.description,
        date: this.parseLogicalDate(dto.date),
        attachments: dto.attachments ?? [],
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    await this.notifyExcuseCreated(tenantId, excuse.id, child, dto, userId);

    const [serialized] = await this.serializeExcuses([excuse]);
    return serialized;
  }

  async findAll(
    tenantId: string,
    userId: string,
    userRole: string,
    filters?: {
      childId?: string;
      status?: string;
      startDate?: string;
      endDate?: string;
    },
  ) {
    const where = await this.buildWhereClause(tenantId, userId, userRole, filters);

    const excuses = await this.prisma.excuse.findMany({
      where,
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
      orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
    });

    return this.serializeExcuses(excuses);
  }

  async findByChild(
    tenantId: string,
    userId: string,
    userRole: string,
    childId: string,
  ) {
    return this.findAll(tenantId, userId, userRole, { childId });
  }

  async findOne(tenantId: string, userId: string, userRole: string, id: string) {
    const where = await this.buildWhereClause(tenantId, userId, userRole, {});
    const excuse = await this.prisma.excuse.findFirst({
      where: {
        ...(where as Record<string, unknown>),
        id,
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    if (!excuse) {
      throw new NotFoundException('Justificante no encontrado');
    }

    const [serialized] = await this.serializeExcuses([excuse]);
    return serialized;
  }

  async updateStatus(
    tenantId: string,
    reviewerId: string,
    id: string,
    dto: UpdateExcuseStatusDto,
  ) {
    if (!['approved', 'rejected'].includes(dto.status)) {
      throw new BadRequestException('Estado de justificante no válido');
    }

    const excuse = await this.prisma.excuse.findFirst({
      where: { id, tenantId },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            group: {
              select: {
                teacherId: true,
                name: true,
              },
            },
          },
        },
      },
    });

    if (!excuse) {
      throw new NotFoundException('Justificante no encontrado');
    }

    const updated = await this.prisma.excuse.update({
      where: { id },
      data: {
        status: dto.status,
        reviewedBy: reviewerId,
        reviewedAt: new Date(),
        reviewNotes: dto.reviewNotes,
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            group: {
              select: {
                teacherId: true,
              },
            },
          },
        },
      },
    });

    if (dto.status === 'approved') {
      await this.applyAttendanceImpact(tenantId, updated);
    }

    await this.notifyExcuseReviewed(tenantId, updated, dto.status);

    const [serialized] = await this.serializeExcuses([updated]);
    return serialized;
  }

  async delete(tenantId: string, userId: string, userRole: string, id: string) {
    const excuse = await this.prisma.excuse.findFirst({
      where: { id, tenantId },
    });

    if (!excuse) {
      throw new NotFoundException('Justificante no encontrado');
    }

    if (excuse.status !== 'pending') {
      throw new BadRequestException(
        'Solo se pueden eliminar justificantes pendientes',
      );
    }

    if (userRole === UserRole.parent && excuse.submittedBy !== userId) {
      throw new ForbiddenException(
        'No puedes eliminar un justificante de otro usuario',
      );
    }

    await this.prisma.excuse.delete({ where: { id } });

    return { success: true };
  }

  private async buildWhereClause(
    tenantId: string,
    userId: string,
    userRole: string,
    filters?: {
      childId?: string;
      status?: string;
      startDate?: string;
      endDate?: string;
    },
  ) {
    const where: Record<string, unknown> = { tenantId };

    if (filters?.childId) {
      where.childId = filters.childId;
    }

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.startDate || filters?.endDate) {
      where.date = {
        ...(filters?.startDate
            ? { gte: this.parseLogicalDate(filters.startDate) }
            : {}),
        ...(filters?.endDate ? { lte: this.parseLogicalDate(filters.endDate) } : {}),
      };
    }

    if (userRole === UserRole.parent) {
      where.child = {
        parents: {
          some: { userId },
        },
      };
    } else if (userRole === UserRole.teacher) {
      where.child = {
        group: {
          teacherId: userId,
        },
      };
    }

    return where;
  }

  private async serializeExcuses(excuses: any[]) {
    const userIds = Array.from(
      new Set(
        excuses
            .flatMap((excuse) => [excuse.submittedBy, excuse.reviewedBy])
            .filter(Boolean),
      ),
    );
    const users = userIds.length
        ? await this.prisma.user.findMany({
            where: { id: { in: userIds } },
            select: { id: true, firstName: true, lastName: true },
          })
        : [];

    const usersMap = new Map(
      users.map((user) => [
        user.id,
        `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
      ]),
    );

    return excuses.map((excuse) => this.serializeExcuse(excuse, usersMap));
  }

  private serializeExcuse(excuse: any, usersMap?: Map<string, string>) {
    return {
      id: excuse.id,
      tenantId: excuse.tenantId,
      childId: excuse.childId,
      childName: excuse.child
          ? `${excuse.child.firstName} ${excuse.child.lastName}`.trim()
          : '',
      submittedBy: excuse.submittedBy,
      submittedByName: usersMap?.get(excuse.submittedBy) ?? '',
      type: excuse.type,
      title: excuse.title,
      description: excuse.description,
      date: excuse.date,
      status: excuse.status,
      reviewedBy: excuse.reviewedBy,
      reviewedByName: excuse.reviewedBy
          ? (usersMap?.get(excuse.reviewedBy) ?? '')
          : null,
      reviewedAt: excuse.reviewedAt,
      reviewNotes: excuse.reviewNotes,
      attachments: excuse.attachments,
      createdAt: excuse.createdAt,
      updatedAt: excuse.updatedAt,
    };
  }

  private async notifyExcuseCreated(
    tenantId: string,
    excuseId: string,
    child: any,
    dto: CreateExcuseDto,
    submittedBy: string,
  ) {
    const childName = `${child.firstName} ${child.lastName}`.trim();
    const dateLabel = dto.date;

    const teacherId = child.group?.teacherId as string | undefined;
    const directors = await this.prisma.userTenant.findMany({
      where: {
        tenantId,
        active: true,
        role: {
          in: [UserRole.director, UserRole.admin, UserRole.super_admin],
        },
      },
      select: { userId: true },
    });

    const recipientIds = Array.from(
      new Set(
        [teacherId, ...directors.map((item) => item.userId)]
            .filter(Boolean)
            .filter((id) => id !== submittedBy),
      ),
    ) as string[];

    await Promise.all(
      recipientIds.map((recipientId) =>
        this.notificationsService.create(tenantId, {
          userId: recipientId,
          type: recipientId === teacherId ? 'excuse_teacher_alert' : 'excuse_submitted',
          title:
              recipientId === teacherId
                  ? 'Aviso familiar para tu grupo'
                  : 'Nuevo justificante pendiente',
          body:
              recipientId === teacherId
                  ? '$childName tiene un justificante enviado para $dateLabel.'
                  : '$childName tiene un justificante pendiente de revisión.',
          data: {
            excuseId,
            childId: child.id,
            groupId: child.group?.id,
            type: dto.type,
          },
        }),
      ),
    );
  }

  private async notifyExcuseReviewed(
    tenantId: string,
    excuse: any,
    status: string,
  ) {
    const childName = `${excuse.child.firstName} ${excuse.child.lastName}`.trim();
    const teacherId = excuse.child.group?.teacherId as string | undefined;

    await this.notificationsService.create(tenantId, {
      userId: excuse.submittedBy,
      type: 'excuse_reviewed',
      title: status === 'approved' ? 'Justificante aprobado' : 'Justificante rechazado',
      body:
          status === 'approved'
              ? 'El justificante de $childName fue aprobado.'
              : 'El justificante de $childName fue rechazado.',
      data: {
        excuseId: excuse.id,
        childId: excuse.childId,
        status,
      },
    });

    if (teacherId) {
      await this.notificationsService.create(tenantId, {
        userId: teacherId,
        type: 'excuse_reviewed',
        title:
            status === 'approved'
                ? 'Justificante aprobado para tu alumno'
                : 'Justificante rechazado',
        body:
            status === 'approved'
                ? '$childName ya cuenta con justificante aprobado.'
                : '$childName tiene un justificante rechazado.',
        data: {
          excuseId: excuse.id,
          childId: excuse.childId,
          status,
        },
      });
    }
  }

  private async applyAttendanceImpact(tenantId: string, excuse: any) {
    const observationPrefix = `[excuse:${excuse.id}] ${excuse.title}`.trim();
    await this.prisma.attendanceRecord.upsert({
      where: {
        childId_date: {
          childId: excuse.childId,
          date: excuse.date,
        },
      },
      create: {
        tenantId,
        childId: excuse.childId,
        date: excuse.date,
        status: this.mapExcuseTypeToAttendanceStatus(excuse.type),
        observations: observationPrefix,
      },
      update: {
        status: this.mapExcuseTypeToAttendanceStatus(excuse.type),
        observations: observationPrefix,
      },
    });
  }

  private mapExcuseTypeToAttendanceStatus(type: string): AttendanceStatus {
    if (type === 'late_arrival') {
      return AttendanceStatus.late;
    }

    return AttendanceStatus.excused;
  }

  private parseLogicalDate(value: string) {
    const [year, month, day] = value.split('-').map(Number);
    return new Date(Date.UTC(year, (month || 1) - 1, day || 1));
  }
}
