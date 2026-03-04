'use client';

import { usePathname } from 'next/navigation';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { Bell, Search, LogOut, Settings, User } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { useNotificationCount, useNotifications, useMarkAllNotificationsRead } from '@/hooks/use-notifications';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuLabel,
} from '@/components/ui/dropdown-menu';

const pageTitles: Record<string, string> = {
  '/': 'Dashboard',
  '/children': 'Niños',
  '/attendance': 'Asistencia',
  '/logs': 'Bitácora',
  '/development': 'Desarrollo',
  '/chat': 'Mensajes',
  '/payments': 'Pagos',
  '/services': 'Servicios',
  '/reports': 'Reportes',
  '/settings': 'Configuración',
};

export function TopBar() {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const { data: notifCount } = useNotificationCount();
  const { data: notifications } = useNotifications({ limit: 5 });
  const markAllRead = useMarkAllNotificationsRead();

  const title = pageTitles[pathname] || pageTitles[`/${pathname.split('/')[1]}`] || 'Dashboard';
  const today = format(new Date(), "EEEE, d 'de' MMMM", { locale: es });

  return (
    <header className="hidden lg:flex h-16 items-center justify-between border-b bg-card px-6">
      <div>
        <h2 className="text-lg font-semibold font-heading">{title}</h2>
        <p className="text-xs text-muted capitalize">{today}</p>
      </div>

      <div className="flex items-center gap-3">
        {/* Search */}
        <div className="relative hidden xl:block">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
          <input
            type="text"
            placeholder="Buscar... (⌘K)"
            className="h-9 w-64 rounded-xl border border-input bg-background pl-9 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>

        {/* Notifications */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="relative rounded-xl p-2 hover:bg-primary-50 transition-colors">
              <Bell className="h-5 w-5 text-muted" />
              {notifCount && notifCount.unread > 0 && (
                <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-secondary px-1 text-[10px] font-bold text-white">
                  {notifCount.unread > 9 ? '9+' : notifCount.unread}
                </span>
              )}
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-80">
            <div className="flex items-center justify-between px-3 py-2">
              <DropdownMenuLabel className="p-0">Notificaciones</DropdownMenuLabel>
              {notifCount && notifCount.unread > 0 && (
                <button
                  onClick={() => markAllRead.mutate()}
                  className="text-xs text-primary hover:underline"
                >
                  Marcar todas como leídas
                </button>
              )}
            </div>
            <DropdownMenuSeparator />
            {notifications?.data && notifications.data.length > 0 ? (
              notifications.data.map((notif) => (
                <DropdownMenuItem key={notif.id} className="flex flex-col items-start gap-1 py-2">
                  <span className="text-sm font-medium">{notif.title}</span>
                  <span className="text-xs text-muted line-clamp-2">{notif.body}</span>
                </DropdownMenuItem>
              ))
            ) : (
              <div className="py-6 text-center text-sm text-muted">
                Sin notificaciones
              </div>
            )}
          </DropdownMenuContent>
        </DropdownMenu>

        {/* Profile */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="flex items-center gap-2 rounded-xl p-1.5 hover:bg-primary-50 transition-colors">
              <Avatar size="sm" name={user ? `${user.firstName} ${user.lastName}` : ''}>
                <AvatarFallback>
                  {user?.firstName?.[0]}{user?.lastName?.[0]}
                </AvatarFallback>
              </Avatar>
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>
              <p className="text-sm font-medium">{user?.firstName} {user?.lastName}</p>
              <p className="text-xs font-normal text-muted">{user?.email}</p>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <User className="mr-2 h-4 w-4" />
              Mi Perfil
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Settings className="mr-2 h-4 w-4" />
              Configuración
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem onClick={logout} className="text-destructive focus:text-destructive">
              <LogOut className="mr-2 h-4 w-4" />
              Cerrar Sesión
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
