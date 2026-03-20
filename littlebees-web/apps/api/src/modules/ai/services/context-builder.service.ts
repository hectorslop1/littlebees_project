import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

interface UserContext {
  userId: string;
  role: string;
  tenantId: string;
  permissions: string[];
  children?: any[];
  groups?: any[];
  recentActivities?: any[];
  stats?: any;
  dataAccessed: string[];
}

@Injectable()
export class ContextBuilderService {
  constructor(private readonly prisma: PrismaService) {}

  async buildContext(
    userId: string,
    role: string,
    tenantId: string,
  ): Promise<UserContext> {
    const context: UserContext = {
      userId,
      role,
      tenantId,
      permissions: this.getPermissions(role),
      dataAccessed: [],
    };

    // Cargar datos según el rol
    switch (role) {
      case 'parent':
        await this.loadParentContext(context);
        break;
      case 'teacher':
        await this.loadTeacherContext(context);
        break;
      case 'admin':
        await this.loadAdminContext(context);
        break;
      case 'director':
      case 'super_admin':
        await this.loadDirectorContext(context);
        break;
    }

    return context;
  }

  private async loadParentContext(context: UserContext) {
    // Obtener hijos del padre
    context.children = await this.prisma.child.findMany({
      where: {
        parents: {
          some: { userId: context.userId },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        dateOfBirth: true,
        gender: true,
        status: true,
      },
    });

    context.dataAccessed.push('children');

    if (context.children.length > 0) {
      const childIds = context.children.map((c) => c.id);

      // Actividades recientes de sus hijos (últimos 7 días)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      context.recentActivities = await this.prisma.dailyLogEntry.findMany({
        where: {
          childId: { in: childIds },
          date: { gte: sevenDaysAgo },
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
        take: 20,
      });

      context.dataAccessed.push('activities');

      // Estadísticas básicas
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const todayActivities = await this.prisma.dailyLogEntry.count({
        where: {
          childId: { in: childIds },
          date: today,
        },
      });

      context.stats = {
        totalChildren: context.children.length,
        todayActivities,
      };
    }
  }

  private async loadTeacherContext(context: UserContext) {
    // Obtener grupos asignados a la maestra
    context.groups = await this.prisma.group.findMany({
      where: {
        teacherId: context.userId,
        tenantId: context.tenantId,
      },
      select: {
        id: true,
        name: true,
        capacity: true,
        children: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            dateOfBirth: true,
            gender: true,
            status: true,
          },
        },
        _count: {
          select: { children: true },
        },
      },
    });

    context.dataAccessed.push('groups', 'children');

    if (context.groups.length > 0) {
      const groupIds = context.groups.map((g) => g.id);
      const childIds = context.groups.flatMap((g) => g.children.map((c) => c.id));

      // Actividades recientes del grupo (últimos 3 días)
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

      context.recentActivities = await this.prisma.dailyLogEntry.findMany({
        where: {
          childId: { in: childIds },
          date: { gte: threeDaysAgo },
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
        take: 30,
      });

      context.dataAccessed.push('activities');

      // Estadísticas del grupo
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const attendance = await this.prisma.attendanceRecord.count({
        where: {
          childId: { in: childIds },
          date: today,
          checkInAt: { not: null },
        },
      });

      context.stats = {
        totalGroups: context.groups.length,
        totalChildren: childIds.length,
        todayAttendance: attendance,
      };
    }
  }

  private async loadAdminContext(context: UserContext) {
    // Estadísticas generales del tenant
    const [totalChildren, totalGroups, totalActivitiesToday] =
      await Promise.all([
        this.prisma.child.count({
          where: { tenantId: context.tenantId, status: 'active' },
        }),
        this.prisma.group.count({
          where: { tenantId: context.tenantId },
        }),
        this.prisma.dailyLogEntry.count({
          where: {
            child: { tenantId: context.tenantId },
            date: new Date(),
          },
        }),
      ]);

    context.stats = {
      totalChildren,
      totalGroups,
      totalActivitiesToday,
    };

    context.dataAccessed.push('stats');

    // Grupos con información básica
    context.groups = await this.prisma.group.findMany({
      where: { tenantId: context.tenantId },
      select: {
        id: true,
        name: true,
        capacity: true,
        _count: {
          select: { children: true },
        },
      },
    });

    context.dataAccessed.push('groups');
  }

  private async loadDirectorContext(context: UserContext) {
    // Directores tienen acceso completo a su tenant
    await this.loadAdminContext(context);

    // Información adicional financiera y operativa
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const monthlyActivities = await this.prisma.dailyLogEntry.count({
      where: {
        child: { tenantId: context.tenantId },
        date: { gte: startOfMonth },
      },
    });

    context.stats = {
      ...context.stats,
      monthlyActivities,
    };

    context.dataAccessed.push('financial_stats');
  }

  private getPermissions(role: string): string[] {
    const permissionMap: Record<string, string[]> = {
      parent: [
        'view_own_children',
        'view_children_activities',
        'view_children_reports',
        'get_recommendations',
      ],
      teacher: [
        'view_group_children',
        'view_group_activities',
        'create_activities',
        'generate_group_reports',
        'get_recommendations',
      ],
      admin: [
        'view_all_children',
        'view_all_groups',
        'view_all_activities',
        'generate_institutional_reports',
        'manage_users',
        'view_stats',
      ],
      director: [
        'full_access_tenant',
        'view_financial',
        'generate_all_reports',
        'manage_all',
      ],
      super_admin: ['full_access_all'],
    };

    return permissionMap[role] || [];
  }

  formatContextForAI(context: UserContext): string {
    let formatted = `Contexto del usuario:\n`;
    formatted += `- Rol: ${this.getRoleLabel(context.role)}\n`;
    formatted += `- Permisos: ${context.permissions.join(', ')}\n\n`;

    if (context.children && context.children.length > 0) {
      formatted += `Hijos del usuario:\n`;
      context.children.forEach((child) => {
        const age = this.calculateAge(child.dateOfBirth);
        formatted += `- ${child.firstName} ${child.lastName} (${age} años)\n`;
      });
      formatted += `\n`;
    }

    if (context.groups && context.groups.length > 0) {
      formatted += `Grupos asignados:\n`;
      context.groups.forEach((group) => {
        const childCount = group._count?.children || group.children?.length || 0;
        formatted += `- ${group.name} (${childCount} niños)`;
        
        // Include children names if available
        if (group.children && group.children.length > 0) {
          formatted += `:\n`;
          group.children.forEach((child) => {
            const age = this.calculateAge(child.dateOfBirth);
            formatted += `  • ${child.firstName} ${child.lastName} (${age} años, ${child.gender})\n`;
          });
        } else {
          formatted += `\n`;
        }
      });
      formatted += `\n`;
    }

    if (context.recentActivities && context.recentActivities.length > 0) {
      formatted += `Actividades recientes:\n`;
      context.recentActivities.slice(0, 5).forEach((activity) => {
        formatted += `- ${activity.type} - ${activity.child.firstName} ${activity.child.lastName} (${this.formatDate(activity.date)})\n`;
      });
      formatted += `\n`;
    }

    if (context.stats) {
      formatted += `Estadísticas:\n`;
      Object.entries(context.stats).forEach(([key, value]) => {
        formatted += `- ${this.formatStatKey(key)}: ${value}\n`;
      });
    }

    return formatted;
  }

  private getRoleLabel(role: string): string {
    const labels: Record<string, string> = {
      parent: 'Padre/Madre',
      teacher: 'Maestra',
      admin: 'Administrador',
      director: 'Director',
      super_admin: 'Super Administrador',
    };
    return labels[role] || role;
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

  private formatDate(date: Date): string {
    return new Date(date).toLocaleDateString('es-MX', {
      day: '2-digit',
      month: 'short',
    });
  }

  private formatStatKey(key: string): string {
    const labels: Record<string, string> = {
      totalChildren: 'Total de niños',
      totalGroups: 'Total de grupos',
      totalUsers: 'Total de usuarios',
      todayActivities: 'Actividades hoy',
      totalActivitiesToday: 'Actividades hoy',
      todayAttendance: 'Asistencia hoy',
      monthlyActivities: 'Actividades del mes',
      activeTeachers: 'Maestras activas',
    };
    return labels[key] || key;
  }
}
