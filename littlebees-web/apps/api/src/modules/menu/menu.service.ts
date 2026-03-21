import { Injectable } from '@nestjs/common';
import { UserRole } from '@kinderspace/shared-types';
import { MenuItemDto } from './dto/menu-config.dto';

@Injectable()
export class MenuService {
  getMenuByRole(role: UserRole): MenuItemDto[] {
    switch (role) {
      case 'teacher':
        return this.getTeacherMenu();
      case 'director':
        return this.getDirectorMenu();
      case 'admin':
      case 'super_admin':
        return this.getAdminMenu();
      case 'parent':
        return this.getParentMenu();
      default:
        return [];
    }
  }

  private getTeacherMenu(): MenuItemDto[] {
    return [
      { id: 'dashboard', label: 'Dashboard', icon: 'home', path: '/', order: 1 },
      { id: 'groups', label: 'Mis Grupos', icon: 'users', path: '/groups', order: 2 },
      { id: 'children', label: 'Alumnos', icon: 'baby', path: '/children', order: 3 },
      { id: 'day', label: 'Día', icon: 'calendar', path: '/day', order: 4 },
      { id: 'activities', label: 'Actividades', icon: 'clipboard-list', path: '/activities', order: 5 },
      { id: 'reports', label: 'Reportes', icon: 'chart-bar', path: '/reports', order: 6 },
      { id: 'messages', label: 'Mensajes', icon: 'message-circle', path: '/chat', order: 7 },
      { id: 'ai-assistant', label: 'Asistente IA', icon: 'sparkles', path: '/ai-assistant', order: 8 },
    ];
  }

  private getDirectorMenu(): MenuItemDto[] {
    return [
      { id: 'dashboard', label: 'Dashboard', icon: 'home', path: '/', order: 1 },
      { id: 'groups', label: 'Grupos', icon: 'users', path: '/groups', order: 2 },
      { id: 'children', label: 'Alumnos', icon: 'baby', path: '/children', order: 3 },
      { id: 'teachers', label: 'Maestras', icon: 'user-check', path: '/teachers', order: 4 },
      { id: 'reports', label: 'Reportes', icon: 'chart-bar', path: '/reports', order: 5 },
      { id: 'payments', label: 'Pagos', icon: 'credit-card', path: '/payments', order: 6 },
      { id: 'messages', label: 'Mensajes', icon: 'message-circle', path: '/chat', order: 7 },
      { id: 'settings', label: 'Configuración', icon: 'settings', path: '/settings', order: 8 },
      { id: 'ai-assistant', label: 'Asistente IA', icon: 'sparkles', path: '/ai-assistant', order: 9 },
    ];
  }

  private getAdminMenu(): MenuItemDto[] {
    return [
      { id: 'dashboard', label: 'Dashboard', icon: 'home', path: '/', order: 1 },
      { id: 'users', label: 'Usuarios', icon: 'users', path: '/users', order: 2 },
      { id: 'groups', label: 'Grupos', icon: 'users', path: '/groups', order: 3 },
      { id: 'children', label: 'Alumnos', icon: 'baby', path: '/children', order: 4 },
      { id: 'payments', label: 'Pagos', icon: 'credit-card', path: '/payments', order: 5 },
      { id: 'reports', label: 'Reportes', icon: 'chart-bar', path: '/reports', order: 6 },
      { id: 'settings', label: 'Configuración', icon: 'settings', path: '/settings', order: 7 },
      { id: 'ai-assistant', label: 'Asistente IA', icon: 'sparkles', path: '/ai-assistant', order: 8 },
    ];
  }

  private getParentMenu(): MenuItemDto[] {
    return [
      { id: 'dashboard', label: 'Dashboard', icon: 'home', path: '/', order: 1 },
      { id: 'children', label: 'Mis Hijos', icon: 'baby', path: '/children', order: 2 },
      { id: 'messages', label: 'Mensajes', icon: 'message-circle', path: '/chat', order: 3 },
      { id: 'ai-assistant', label: 'Asistente IA', icon: 'sparkles', path: '/ai-assistant', order: 4 },
    ];
  }
}
