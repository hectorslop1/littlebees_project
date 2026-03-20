import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

interface FunctionContext {
  userId: string;
  role: string;
  tenantId: string;
  permissions: string[];
}

@Injectable()
export class AiFunctionsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Obtiene las funciones disponibles según el rol del usuario
   */
  getAvailableFunctions(role: string) {
    const allFunctions = {
      query_child_activities: {
        name: 'query_child_activities',
        description: 'Consulta las actividades de un niño en una fecha específica o rango de fechas',
        parameters: {
          type: 'object',
          properties: {
            childId: {
              type: 'string',
              description: 'ID del niño',
            },
            date: {
              type: 'string',
              description: 'Fecha específica en formato YYYY-MM-DD (opcional)',
            },
            startDate: {
              type: 'string',
              description: 'Fecha de inicio del rango (opcional)',
            },
            endDate: {
              type: 'string',
              description: 'Fecha de fin del rango (opcional)',
            },
          },
          required: ['childId'],
        },
      },
      query_child_info: {
        name: 'query_child_info',
        description: 'Obtiene información detallada de un niño específico',
        parameters: {
          type: 'object',
          properties: {
            childId: {
              type: 'string',
              description: 'ID del niño',
            },
          },
          required: ['childId'],
        },
      },
      query_attendance: {
        name: 'query_attendance',
        description: 'Consulta la asistencia de un niño o grupo en una fecha',
        parameters: {
          type: 'object',
          properties: {
            childId: {
              type: 'string',
              description: 'ID del niño (opcional)',
            },
            groupId: {
              type: 'string',
              description: 'ID del grupo (opcional)',
            },
            date: {
              type: 'string',
              description: 'Fecha en formato YYYY-MM-DD',
            },
          },
        },
      },
      generate_summary: {
        name: 'generate_summary',
        description: 'Genera un resumen de actividades para un niño o grupo',
        parameters: {
          type: 'object',
          properties: {
            childId: {
              type: 'string',
              description: 'ID del niño (opcional)',
            },
            groupId: {
              type: 'string',
              description: 'ID del grupo (opcional)',
            },
            period: {
              type: 'string',
              enum: ['today', 'week', 'month'],
              description: 'Período del resumen',
            },
          },
          required: ['period'],
        },
      },
      get_recommendations: {
        name: 'get_recommendations',
        description: 'Obtiene recomendaciones personalizadas basadas en el desarrollo del niño',
        parameters: {
          type: 'object',
          properties: {
            childId: {
              type: 'string',
              description: 'ID del niño',
            },
            category: {
              type: 'string',
              enum: ['nutrition', 'development', 'activities', 'behavior'],
              description: 'Categoría de recomendaciones',
            },
          },
          required: ['childId'],
        },
      },
    };

    // Filtrar funciones según rol
    const allowedFunctions: Record<string, string[]> = {
      parent: ['query_child_activities', 'query_child_info', 'query_attendance', 'generate_summary', 'get_recommendations'],
      teacher: ['query_child_activities', 'query_child_info', 'query_attendance', 'generate_summary', 'get_recommendations'],
      admin: ['query_child_activities', 'query_child_info', 'query_attendance', 'generate_summary'],
      director: Object.keys(allFunctions),
      super_admin: Object.keys(allFunctions),
    };

    const allowed = allowedFunctions[role] || [];
    return allowed.map((name) => allFunctions[name]).filter(Boolean);
  }

  /**
   * Ejecuta una función con validación de permisos
   */
  async executeFunction(
    functionName: string,
    args: any,
    context: FunctionContext,
  ): Promise<any> {
    // Validar que la función está permitida para el rol
    const availableFunctions = this.getAvailableFunctions(context.role);
    const isAllowed = availableFunctions.some((f) => f.name === functionName);

    if (!isAllowed) {
      throw new ForbiddenException(
        `No tienes permiso para ejecutar la función: ${functionName}`,
      );
    }

    // Ejecutar la función correspondiente
    switch (functionName) {
      case 'query_child_activities':
        return this.queryChildActivities(args, context);
      case 'query_child_info':
        return this.queryChildInfo(args, context);
      case 'query_attendance':
        return this.queryAttendance(args, context);
      case 'generate_summary':
        return this.generateSummary(args, context);
      case 'get_recommendations':
        return this.getRecommendations(args, context);
      default:
        throw new Error(`Función no implementada: ${functionName}`);
    }
  }

  private async queryChildActivities(args: any, context: FunctionContext) {
    const { childId, date, startDate, endDate } = args;

    // Validar acceso al niño
    await this.validateChildAccess(childId, context);

    let dateFilter: any = {};
    if (date) {
      dateFilter = { date: new Date(date) };
    } else if (startDate && endDate) {
      dateFilter = {
        date: {
          gte: new Date(startDate),
          lte: new Date(endDate),
        },
      };
    } else {
      // Por defecto, últimos 7 días
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      dateFilter = { date: { gte: sevenDaysAgo } };
    }

    const activities = await this.prisma.dailyLogEntry.findMany({
      where: {
        childId,
        ...dateFilter,
      },
      include: {
        child: {
          select: {
            firstName: true,
            lastName: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return {
      childId,
      activities: activities.map((a) => ({
        type: a.type,
        date: a.date,
        title: a.title,
        description: a.description,
        time: a.time,
        metadata: a.metadata,
      })),
      total: activities.length,
    };
  }

  private async queryChildInfo(args: any, context: FunctionContext) {
    const { childId } = args;

    // Validar acceso al niño
    await this.validateChildAccess(childId, context);

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        dateOfBirth: true,
        gender: true,
        groupId: true,
        status: true,
      },
    });

    if (!child) {
      throw new Error('Niño no encontrado');
    }

    // Información básica del niño
    return {
      id: child.id,
      firstName: child.firstName,
      lastName: child.lastName,
      dateOfBirth: child.dateOfBirth,
      age: this.calculateAge(child.dateOfBirth),
      gender: child.gender,
      groupId: child.groupId,
      status: child.status,
    };
  }

  private async queryAttendance(args: any, context: FunctionContext) {
    const { childId, groupId, date } = args;

    const targetDate = date ? new Date(date) : new Date();
    targetDate.setHours(0, 0, 0, 0);

    let whereClause: any = { date: targetDate };

    if (childId) {
      await this.validateChildAccess(childId, context);
      whereClause.childId = childId;
    } else if (groupId) {
      await this.validateGroupAccess(groupId, context);
      whereClause.child = { groupId };
    } else {
      // Sin filtro específico, aplicar filtro por rol
      if (context.role === 'parent') {
        const children = await this.prisma.child.findMany({
          where: { parents: { some: { userId: context.userId } } },
          select: { id: true },
        });
        whereClause.childId = { in: children.map((c) => c.id) };
      } else if (context.role === 'teacher') {
        const groups = await this.prisma.group.findMany({
          where: { teacherId: context.userId },
          select: { id: true },
        });
        whereClause.child = { groupId: { in: groups.map((g) => g.id) } };
      }
    }

    const attendance = await this.prisma.attendanceRecord.findMany({
      where: whereClause,
      include: {
        child: {
          select: {
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    return {
      date: targetDate,
      total: attendance.length,
      present: attendance.filter((a) => a.checkInAt).length,
      absent: attendance.filter((a) => !a.checkInAt).length,
      records: attendance.map((a) => ({
        childName: `${a.child.firstName} ${a.child.lastName}`,
        checkInTime: a.checkInAt,
        checkOutTime: a.checkOutAt,
        status: a.checkInAt ? 'present' : 'absent',
      })),
    };
  }

  private async generateSummary(args: any, context: FunctionContext) {
    const { childId, groupId, period } = args;

    const now = new Date();
    let startDate: Date;

    switch (period) {
      case 'today':
        startDate = new Date(now.setHours(0, 0, 0, 0));
        break;
      case 'week':
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case 'month':
        startDate = new Date(now.setMonth(now.getMonth() - 1));
        break;
      default:
        startDate = new Date(now.setHours(0, 0, 0, 0));
    }

    let whereClause: any = {
      date: { gte: startDate },
    };

    if (childId) {
      await this.validateChildAccess(childId, context);
      whereClause.childId = childId;
    } else if (groupId) {
      await this.validateGroupAccess(groupId, context);
      whereClause.child = { groupId };
    }

    const activities = await this.prisma.dailyLogEntry.findMany({
      where: whereClause,
      include: {
        child: {
          select: {
            firstName: true,
            lastName: true,
          },
        },
      },
    });

    // Agrupar por tipo
    const summary = {
      period,
      startDate,
      endDate: new Date(),
      totalActivities: activities.length,
      byType: {} as Record<string, number>,
      highlights: [] as string[],
    };

    activities.forEach((a) => {
      summary.byType[a.type] = (summary.byType[a.type] || 0) + 1;
    });

    // Generar highlights
    if (summary.byType['meal']) {
      summary.highlights.push(`${summary.byType['meal']} comidas registradas`);
    }
    if (summary.byType['nap']) {
      summary.highlights.push(`${summary.byType['nap']} siestas registradas`);
    }
    if (summary.byType['activity']) {
      summary.highlights.push(`${summary.byType['activity']} actividades educativas`);
    }

    return summary;
  }

  private async getRecommendations(args: any, context: FunctionContext) {
    const { childId, category } = args;

    await this.validateChildAccess(childId, context);

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      include: {
        medicalInfo: true,
      },
    });

    if (!child) {
      throw new Error('Niño no encontrado');
    }

    const age = this.calculateAge(child.dateOfBirth);

    // Recomendaciones basadas en edad y categoría
    const recommendations: string[] = [];

    if (category === 'nutrition' || !category) {
      if (age < 2) {
        recommendations.push('Asegurar alimentación balanceada con frutas y verduras suaves');
        recommendations.push('Mantener horarios regulares de comida');
      } else if (age < 4) {
        recommendations.push('Introducir variedad de alimentos saludables');
        recommendations.push('Fomentar independencia en la alimentación');
      }
    }

    if (category === 'development' || !category) {
      if (age < 2) {
        recommendations.push('Estimular desarrollo motor con juegos apropiados');
        recommendations.push('Fomentar comunicación verbal y no verbal');
      } else if (age < 4) {
        recommendations.push('Actividades de motricidad fina (dibujo, construcción)');
        recommendations.push('Juegos de socialización con otros niños');
      }
    }

    if (category === 'activities' || !category) {
      recommendations.push('Tiempo de juego libre diario');
      recommendations.push('Actividades al aire libre cuando sea posible');
      recommendations.push('Lectura de cuentos antes de la siesta');
    }

    return {
      childId,
      childName: `${child.firstName} ${child.lastName}`,
      age,
      category: category || 'general',
      recommendations,
    };
  }

  private async validateChildAccess(childId: string, context: FunctionContext) {
    if (context.role === 'parent') {
      const hasAccess = await this.prisma.child.findFirst({
        where: {
          id: childId,
          parents: {
            some: { userId: context.userId },
          },
        },
      });

      if (!hasAccess) {
        throw new ForbiddenException('No tienes acceso a este niño');
      }
    } else if (context.role === 'teacher') {
      const hasAccess = await this.prisma.child.findFirst({
        where: {
          id: childId,
          group: {
            teacherId: context.userId,
          },
        },
      });

      if (!hasAccess) {
        throw new ForbiddenException('No tienes acceso a este niño');
      }
    } else if (['admin', 'director'].includes(context.role)) {
      const hasAccess = await this.prisma.child.findFirst({
        where: {
          id: childId,
          tenantId: context.tenantId,
        },
      });

      if (!hasAccess) {
        throw new ForbiddenException('No tienes acceso a este niño');
      }
    }
    // super_admin tiene acceso a todo
  }

  private async validateGroupAccess(groupId: string, context: FunctionContext) {
    if (context.role === 'teacher') {
      const hasAccess = await this.prisma.group.findFirst({
        where: {
          id: groupId,
          teacherId: context.userId,
        },
      });

      if (!hasAccess) {
        throw new ForbiddenException('No tienes acceso a este grupo');
      }
    } else if (['admin', 'director'].includes(context.role)) {
      const hasAccess = await this.prisma.group.findFirst({
        where: {
          id: groupId,
          tenantId: context.tenantId,
        },
      });

      if (!hasAccess) {
        throw new ForbiddenException('No tienes acceso a este grupo');
      }
    }
    // super_admin tiene acceso a todo
  }

  private calculateAge(dateOfBirth: Date): number {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  }
}
