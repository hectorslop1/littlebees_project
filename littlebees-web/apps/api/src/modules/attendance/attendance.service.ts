import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
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
    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

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

    return this.prisma.attendanceRecord.findMany({
      where,
      include: {
        child: { select: { id: true, firstName: true, lastName: true, photoUrl: true } },
      },
      orderBy: { checkInAt: 'desc' },
    });
  }

  async checkIn(
    tenantId: string,
    childId: string,
    userId: string,
    method: string,
    userRole: string,
  ) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const child = await this.prisma.child.findFirst({
      where: { id: childId, tenantId },
      include: {
        parents: {
          where: { userId },
          select: { userId: true },
        },
      },
    });

    if (!child) {
      throw new NotFoundException('Niño no encontrado');
    }

    if (userRole === 'parent' && child.parents.length == 0) {
      throw new ForbiddenException(
        'No puedes confirmar asistencia para este niño',
      );
    }

    return this.prisma.attendanceRecord.upsert({
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
  }

  async checkOut(tenantId: string, childId: string, userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

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
    const today = new Date();
    today.setHours(0, 0, 0, 0);
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
}
