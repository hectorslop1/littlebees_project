import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { Prisma, AttendanceStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { QuickRegisterDto, QuickRegisterType } from './dto/quick-register.dto';
import { DayScheduleResponseDto } from './dto/day-schedule.dto';
import { FilesService } from '../files/files.service';

@Injectable()
export class DailyLogsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly filesService: FilesService,
  ) {}

  async findByChildAndDate(
    tenantId: string,
    childId: string,
    date: string,
    userId: string,
    userRole: string,
  ) {
    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

    const entries = await this.prisma.dailyLogEntry.findMany({
      where: {
        tenantId,
        childId,
        date: targetDate,
        ...this.buildRoleFilter(userId, userRole),
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photoUrl: true,
          },
        },
      },
      orderBy: { time: 'asc' },
    });

    return this.enrichEntries(entries);
  }

  async findByDate(
    tenantId: string,
    date: string,
    userId: string,
    userRole: string,
  ) {
    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

    if (userRole === 'parent') {
      return [];
    }

    const entries = await this.prisma.dailyLogEntry.findMany({
      where: { 
        tenantId, 
        date: targetDate,
        ...this.buildRoleFilter(userId, userRole),
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photoUrl: true,
          },
        },
      },
      orderBy: { time: 'asc' },
    });

    return this.enrichEntries(entries);
  }

  private buildRoleFilter(userId: string, userRole: string) {
    if (userRole === 'parent') {
      return {
        child: {
          parents: {
            some: {
              userId,
            },
          },
        },
      };
    }

    if (userRole === 'teacher') {
      return {
        child: {
          group: {
            teacherId: userId,
          },
        },
      };
    }

    return {};
  }

  async create(tenantId: string, userId: string, data: {
    childId: string;
    date: string;
    type: string;
    title: string;
    description?: string;
    time: string;
    metadata?: Prisma.InputJsonValue;
  }) {
    return this.prisma.dailyLogEntry.create({
      data: {
        tenantId,
        childId: data.childId,
        date: new Date(data.date),
        type: data.type,
        title: data.title,
        description: data.description,
        time: data.time,
        metadata: data.metadata ?? Prisma.JsonNull,
        recordedBy: userId,
      },
    });
  }

  async update(
    id: string,
    tenantId: string,
    data: {
      type?: string;
      title?: string;
      description?: string;
      time?: string;
      metadata?: Prisma.InputJsonValue;
    },
  ) {
    const entry = await this.prisma.dailyLogEntry.findFirst({
      where: { id, tenantId },
    });

    if (!entry) {
      throw new NotFoundException('Entrada de bitácora no encontrada');
    }

    return this.prisma.dailyLogEntry.update({
      where: { id },
      data,
    });
  }

  async delete(id: string, tenantId: string) {
    const entry = await this.prisma.dailyLogEntry.findFirst({
      where: { id, tenantId },
    });

    if (!entry) {
      throw new NotFoundException('Entrada de bitácora no encontrada');
    }

    return this.prisma.dailyLogEntry.delete({
      where: { id },
    });
  }

  // Quick register for daily activities
  async quickRegister(
    tenantId: string,
    userId: string,
    dto: QuickRegisterDto,
  ) {
    const today = this.parseLogicalDate(dto.date);
    const now = new Date();
    const timeStr =
      dto.time?.trim() ||
      `${now.getHours().toString().padStart(2, '0')}:${now
        .getMinutes()
        .toString()
        .padStart(2, '0')}`;

    // Verificar que el niño existe
    const child = await this.prisma.child.findFirst({
      where: { id: dto.childId, tenantId },
    });

    if (!child) {
      throw new NotFoundException('Niño no encontrado');
    }

    const metadata = (dto.metadata ?? {}) as Record<string, any>;
    let attendanceRecord = null;
    let dailyLogEntry = null;

    // Determinar título y descripción según el tipo
    let title = '';
    let description = '';

    switch (dto.type) {
      case QuickRegisterType.CHECK_IN:
        title = metadata['title'] || 'Entrada';
        description =
          metadata['notes'] ||
          metadata['description'] ||
          'Registro de entrada';
        
        // Crear o actualizar registro de asistencia
        attendanceRecord = await this.prisma.attendanceRecord.upsert({
          where: {
            childId_date: {
              childId: dto.childId,
              date: today,
            },
          },
          create: {
            tenantId,
            childId: dto.childId,
            date: today,
            checkInAt: now,
            checkInBy: userId,
            // checkInPhotoUrl: dto.metadata?.photoUrl, // DISABLED: Field doesn't exist
            status: AttendanceStatus.present,
          },
          update: {
            checkInAt: now,
            checkInBy: userId,
            // checkInPhotoUrl: dto.metadata?.photoUrl, // DISABLED: Field doesn't exist
            status: AttendanceStatus.present,
          },
        });
        break;

      case QuickRegisterType.MEAL:
        title = metadata['title'] || 'Comida';
        description =
          metadata['notes'] ||
          metadata['description'] ||
          (metadata['foodEaten'] ? `Comió: ${metadata['foodEaten']}` : 'Registro de comida');
        break;

      case QuickRegisterType.NAP:
        title = metadata['title'] || 'Siesta';
        description =
          metadata['notes'] ||
          metadata['description'] ||
          (metadata['napDuration']
            ? `Duración: ${metadata['napDuration']} minutos`
            : metadata['notes'] || 'Registro de siesta');
        break;

      case QuickRegisterType.ACTIVITY:
        title = metadata['activityTitle'] || metadata['title'] || 'Actividad';
        description =
          metadata['notes'] ||
          metadata['activityDescription'] ||
          metadata['description'] ||
          'Registro de actividad';
        break;

      case QuickRegisterType.CHECK_OUT:
        title = metadata['title'] || 'Salida';
        description =
          metadata['description'] || metadata['notes'] || 'Registro de salida';
        
        // Actualizar registro de asistencia
        const existingAttendance = await this.prisma.attendanceRecord.findUnique({
          where: {
            childId_date: {
              childId: dto.childId,
              date: today,
            },
          },
        });

        if (existingAttendance) {
          attendanceRecord = await this.prisma.attendanceRecord.update({
            where: {
              childId_date: {
                childId: dto.childId,
                date: today,
              },
            },
            data: {
              checkOutAt: now,
              checkOutBy: userId,
              // checkOutPhotoUrl: dto.metadata?.photoUrl, // DISABLED: Field doesn't exist
            },
          });
        }
        break;

      default:
        throw new BadRequestException('Tipo de registro no válido');
    }

    // Crear entrada en daily log
    dailyLogEntry = await this.prisma.dailyLogEntry.create({
      data: {
        tenantId,
        childId: dto.childId,
        date: today,
        type: dto.type,
        title,
        description,
        time: timeStr,
        metadata: dto.metadata ?? Prisma.JsonNull,
        recordedBy: userId,
      },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photoUrl: true,
          },
        },
      },
    });

    const [enrichedDailyLogEntry] = await this.enrichEntries([dailyLogEntry]);

    return {
      dailyLogEntry: enrichedDailyLogEntry,
      attendanceRecord,
      message: `${title} registrado exitosamente`,
    };
  }

  private async enrichEntries<T extends { recordedBy: string; metadata: any }>(
    entries: T[],
  ) {
    if (!entries.length) {
      return entries;
    }

    const userIds = Array.from(new Set(entries.map((entry) => entry.recordedBy)));
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, firstName: true, lastName: true },
    });
    const userNames = new Map(
      users.map((user) => [
        user.id,
        `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
      ]),
    );

    return entries.map((entry) => ({
      ...entry,
      recordedByName: userNames.get(entry.recordedBy) || null,
      metadata: this.resolveEntryMetadata(entry.metadata),
    }));
  }

  private resolveEntryMetadata(metadata: unknown) {
    if (!metadata || typeof metadata !== 'object' || Array.isArray(metadata)) {
      return metadata;
    }

    const resolved = { ...(metadata as Record<string, unknown>) };

    if (typeof resolved['photoUrl'] === 'string') {
      resolved['photoUrl'] = this.filesService.resolveStoredFileUrl(
        resolved['photoUrl'],
      );
    }

    if (Array.isArray(resolved['photoUrls'])) {
      resolved['photoUrls'] = resolved['photoUrls']
        .map((value) =>
          typeof value === 'string'
            ? this.filesService.resolveStoredFileUrl(value)
            : null,
        )
        .filter(Boolean);
    }

    return resolved;
  }

  // Get day schedule for a group
  async getDaySchedule(
    tenantId: string,
    groupId: string,
    date?: string,
  ): Promise<DayScheduleResponseDto> {
    const targetDate = date ? new Date(date) : new Date();
    targetDate.setHours(0, 0, 0, 0);

    // Obtener información del grupo
    const group = await this.prisma.group.findFirst({
      where: { id: groupId, tenantId },
      include: {
        children: {
          where: { status: 'active' },
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photoUrl: true,
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Grupo no encontrado');
    }

    // Obtener plantilla de programación (por ahora hardcoded, luego desde BD)
    const schedule = [
      { time: '07:30', type: 'check_in', label: 'Entrada' },
      { time: '09:00', type: 'activity', label: 'Actividad educativa' },
      { time: '10:00', type: 'activity', label: 'Recreo' },
      { time: '11:00', type: 'meal', label: 'Comida' },
      { time: '12:00', type: 'nap', label: 'Siesta' },
      { time: '14:00', type: 'activity', label: 'Actividad' },
      { time: '16:00', type: 'check_out', label: 'Salida' },
    ];

    // Obtener registros de asistencia del día
    const attendanceRecords = await this.prisma.attendanceRecord.findMany({
      where: {
        tenantId,
        date: targetDate,
        childId: { in: group.children.map((c) => c.id) },
      },
    });

    // Obtener entradas de bitácora del día
    const dailyLogs = await this.prisma.dailyLogEntry.findMany({
      where: {
        tenantId,
        date: targetDate,
        childId: { in: group.children.map((c) => c.id) },
      },
    });

    // Construir estado de cada niño
    const childrenStatus = group.children.map((child) => {
      const attendance = attendanceRecords.find((a) => a.childId === child.id);
      const logs = dailyLogs.filter((l) => l.childId === child.id);

      const hasMeal = logs.some((l) => l.type === QuickRegisterType.MEAL);
      const hasNap = logs.some((l) => l.type === QuickRegisterType.NAP);
      const hasActivity = logs.some((l) => l.type === QuickRegisterType.ACTIVITY);
      
      const lastLog = logs.length > 0 ? logs[logs.length - 1] : null;

      return {
        childId: child.id,
        firstName: child.firstName,
        lastName: child.lastName,
        photoUrl: child.photoUrl,
        hasCheckIn: !!attendance?.checkInAt,
        hasMeal,
        hasNap,
        hasActivity,
        hasCheckOut: !!attendance?.checkOutAt,
        checkInTime: attendance?.checkInAt 
          ? `${attendance.checkInAt.getHours().toString().padStart(2, '0')}:${attendance.checkInAt.getMinutes().toString().padStart(2, '0')}`
          : undefined,
        checkOutTime: attendance?.checkOutAt 
          ? `${attendance.checkOutAt.getHours().toString().padStart(2, '0')}:${attendance.checkOutAt.getMinutes().toString().padStart(2, '0')}`
          : undefined,
        lastActivity: lastLog?.title,
      };
    });

    const presentChildren = attendanceRecords.filter((a) => a.checkInAt).length;

    return {
      groupId: group.id,
      groupName: group.name,
      date: targetDate.toISOString().split('T')[0],
      schedule,
      children: childrenStatus,
      totalChildren: group.children.length,
      presentChildren,
      absentChildren: group.children.length - presentChildren,
    };
  }

  private parseLogicalDate(rawDate?: string) {
    const source = rawDate?.trim();
    if (source) {
      const [year, month, day] = source.split('-').map((value) => Number(value));
      if ([year, month, day].every((value) => Number.isFinite(value))) {
        return new Date(Date.UTC(year, month - 1, day));
      }
    }

    const now = new Date();
    return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  }
}
