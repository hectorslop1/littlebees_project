import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { AttendanceStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { BulkCheckInDto, BulkCheckInResponseDto } from './dto/bulk-check-in.dto';

@Injectable()
export class AttendanceService {
  constructor(private readonly prisma: PrismaService) {}

  async getByDate(
    tenantId: string,
    userId: string,
    userRole: string,
    date: string,
    childId?: string,
  ) {
    const targetDate = this.parseLogicalDate(date);

    const where: any = {
      tenantId,
      date: targetDate,
      ...(childId && { childId }),
    };

    if (userRole === 'parent') {
      if (!childId) {
        return [];
      }

      where.child = {
        parents: {
          some: {
            userId,
          },
        },
      };
    } else if (userRole === 'teacher') {
      const teacherGroups = await this.prisma.group.findMany({
        where: { tenantId, teacherId: userId },
        select: { id: true },
      });

      const groupIds = teacherGroups.map((group) => group.id);
      if (groupIds.length === 0) {
        return [];
      }

      where.child = {
        groupId: { in: groupIds },
      };
    }

    const records = await this.prisma.attendanceRecord.findMany({
      where,
      include: {
        child: { select: { id: true, firstName: true, lastName: true, photoUrl: true } },
      },
      orderBy: { checkInAt: 'desc' },
    });

    return this.decorateAttendanceActors(records);
  }

  async checkIn(
    tenantId: string,
    childId: string,
    userId: string,
    method: string,
    userRole: string,
    logicalDate?: string,
  ) {
    const today = await this.resolveAttendanceDate(tenantId, logicalDate);
    await this.assertCanManageAttendance(tenantId, childId, userId, userRole);

    const record = await this.prisma.attendanceRecord.upsert({
      where: { childId_date: { childId, date: today } },
      create: {
        tenantId,
        childId,
        date: today,
        checkInAt: new Date(),
        checkInBy: userId,
        checkInMethod: method,
        status: 'present',
      },
      update: {
        checkInAt: new Date(),
        checkInBy: userId,
        checkInMethod: method,
        status: 'present',
      },
    });

    return (await this.decorateAttendanceActors([record]))[0];
  }

  async markAttendance(
    tenantId: string,
    childId: string,
    userId: string,
    userRole: string,
    status: 'present' | 'absent',
    method?: string,
    observations?: string,
    logicalDate?: string,
  ) {
    const today = await this.resolveAttendanceDate(tenantId, logicalDate);
    const now = new Date();
    const normalizedObservations = observations?.trim();

    await this.assertCanManageAttendance(tenantId, childId, userId, userRole);

    if (status === 'present') {
      const record = await this.prisma.attendanceRecord.upsert({
        where: { childId_date: { childId, date: today } },
        create: {
          tenantId,
          childId,
          date: today,
          checkInAt: now,
          checkInBy: userId,
          checkInMethod: method ?? 'teacher_manual',
          status: AttendanceStatus.present,
          observations: normalizedObservations,
        },
        update: {
          checkInAt: now,
          checkInBy: userId,
          checkInMethod: method ?? 'teacher_manual',
          status: AttendanceStatus.present,
          observations: normalizedObservations,
        },
      });

      return (await this.decorateAttendanceActors([record]))[0];
    }

    const existingRecord = await this.prisma.attendanceRecord.findUnique({
      where: { childId_date: { childId, date: today } },
    });

    if (existingRecord?.checkInAt || existingRecord?.checkOutAt) {
      throw new BadRequestException(
        'No puedes marcar como ausente a un alumno que ya tiene llegada registrada',
      );
    }

    const record = await this.prisma.attendanceRecord.upsert({
      where: { childId_date: { childId, date: today } },
      create: {
        tenantId,
        childId,
        date: today,
        checkInBy: userId,
        checkInMethod: method ?? 'teacher_absence',
        status: AttendanceStatus.absent,
        observations: normalizedObservations || 'No llego a clase',
      },
      update: {
        checkInAt: null,
        checkOutAt: null,
        checkInBy: userId,
        checkOutBy: null,
        checkInMethod: method ?? 'teacher_absence',
        status: AttendanceStatus.absent,
        observations: normalizedObservations || 'No llego a clase',
      },
    });

    return (await this.decorateAttendanceActors([record]))[0];
  }

  async checkOut(
    tenantId: string,
    childId: string,
    userId: string,
    logicalDate?: string,
  ) {
    const today = await this.resolveAttendanceDate(tenantId, logicalDate);

    return this.prisma.attendanceRecord.updateMany({
      where: {
        tenantId,
        childId,
        date: today,
        checkOutAt: null,
      },
      data: {
        checkOutAt: new Date(),
        checkOutBy: userId,
      },
    });
  }

  async bulkCheckIn(
    tenantId: string,
    userId: string,
    dto: BulkCheckInDto,
  ): Promise<BulkCheckInResponseDto> {
    const today = await this.resolveAttendanceDate(tenantId);
    const now = new Date();

    const successIds: string[] = [];
    const failedIds: string[] = [];

    // Procesar cada niño
    for (const childId of dto.childIds) {
      try {
        // Verificar que el niño existe y pertenece al tenant
        const child = await this.prisma.child.findFirst({
          where: { id: childId, tenantId },
        });

        if (!child) {
          failedIds.push(childId);
          continue;
        }

        // Crear o actualizar registro de asistencia
        await this.prisma.attendanceRecord.upsert({
          where: {
            childId_date: {
              childId,
              date: today,
            },
          },
          create: {
            tenantId,
            childId,
            date: today,
            checkInAt: now,
            checkInBy: userId,
            checkInMethod: 'bulk',
            // checkInPhotoUrl: dto.photoUrl, // DISABLED: Field doesn't exist
            status: AttendanceStatus.present,
            observations: dto.observations,
          },
          update: {
            checkInAt: now,
            checkInBy: userId,
            checkInMethod: 'bulk',
            // checkInPhotoUrl: dto.photoUrl, // DISABLED: Field doesn't exist
            status: AttendanceStatus.present,
            observations: dto.observations,
          },
        });

        successIds.push(childId);
      } catch (error) {
        failedIds.push(childId);
      }
    }

    return {
      successCount: successIds.length,
      failedCount: failedIds.length,
      successIds,
      failedIds,
      message: `Check-in masivo completado: ${successIds.length} exitosos, ${failedIds.length} fallidos`,
    };
  }

  private async assertCanManageAttendance(
    tenantId: string,
    childId: string,
    userId: string,
    userRole: string,
  ) {
    const child = await this.prisma.child.findFirst({
      where: { id: childId, tenantId },
      select: {
        id: true,
        group: {
          select: {
            teacherId: true,
          },
        },
      },
    });

    if (!child) {
      throw new NotFoundException('Niño no encontrado');
    }

    if (userRole === 'parent') {
      throw new ForbiddenException(
        'Los padres no pueden registrar asistencia directamente',
      );
    }

    if (userRole === 'teacher' && child.group?.teacherId !== userId) {
      throw new ForbiddenException(
        'No puedes registrar asistencia para este alumno',
      );
    }
  }

  private async resolveAttendanceDate(tenantId: string, rawDate?: string) {
    if (rawDate?.trim()) {
      return this.parseLogicalDate(rawDate);
    }

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: { timezone: true },
    });

    return this.parseLogicalDate(undefined, tenant?.timezone ?? 'America/Mexico_City');
  }

  private parseLogicalDate(rawDate?: string, timeZone = 'America/Mexico_City') {
    const source = rawDate?.trim();
    if (source) {
      const [year, month, day] = source.split('-').map((value) => Number(value));
      if ([year, month, day].every((value) => Number.isFinite(value))) {
        return new Date(Date.UTC(year, month - 1, day));
      }
    }

    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());

    const year = Number(parts.find((part) => part.type == 'year')?.value);
    const month = Number(parts.find((part) => part.type == 'month')?.value);
    const day = Number(parts.find((part) => part.type == 'day')?.value);

    return new Date(Date.UTC(year, month - 1, day));
  }

  private async decorateAttendanceActors<T extends {
    checkInBy: string | null;
    checkOutBy: string | null;
  }>(records: T[]) {
    if (records.length === 0) {
      return records;
    }

    const actorIds = Array.from(
      new Set(
        records
          .flatMap((record) => [record.checkInBy, record.checkOutBy])
          .filter((value): value is string => Boolean(value)),
      ),
    );

    if (actorIds.length === 0) {
      return records.map((record) => ({
        ...record,
        checkInByName: null,
        checkOutByName: null,
      }));
    }

    const users = await this.prisma.user.findMany({
      where: { id: { in: actorIds } },
      select: { id: true, firstName: true, lastName: true },
    });

    const userNames = new Map(
      users.map((user) => [
        user.id,
        `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
      ]),
    );

    return records.map((record) => ({
      ...record,
      checkInByName: record.checkInBy ? userNames.get(record.checkInBy) ?? null : null,
      checkOutByName: record.checkOutBy ? userNames.get(record.checkOutBy) ?? null : null,
    }));
  }
}
