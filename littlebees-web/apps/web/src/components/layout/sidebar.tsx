'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  BookOpen,
  TrendingUp,
  MessageCircle,
  CreditCard,
  ShoppingBag,
  BarChart3,
  Settings,
  LogOut,
  X,
  User,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/hooks/use-auth';
import { useNotificationCount } from '@/hooks/use-notifications';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { UserRole } from '@kinderspace/shared-types';

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

const navItems = [
  { label: 'Dashboard', href: '/', icon: LayoutDashboard, roles: 'all' as const },
  { label: 'Niños', href: '/children', icon: Users, roles: 'all' as const },
  { label: 'Asistencia', href: '/attendance', icon: ClipboardCheck, roles: 'all' as const },
  { label: 'Bitácora', href: '/logs', icon: BookOpen, roles: 'all' as const },
  { label: 'Desarrollo', href: '/development', icon: TrendingUp, roles: 'all' as const },
  { label: 'Mensajes', href: '/chat', icon: MessageCircle, roles: 'all' as const },
  { label: 'Pagos', href: '/payments', icon: CreditCard, roles: [UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.PARENT] },
  { label: 'Servicios', href: '/services', icon: ShoppingBag, roles: [UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN] },
  { label: 'Reportes', href: '/reports', icon: BarChart3, roles: [UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN] },
];

export function Sidebar({ open, onClose }: SidebarProps) {
  const pathname = usePathname();
  const { user, role, logout } = useAuth();
  const { data: notifCount } = useNotificationCount();

  const filteredItems = navItems.filter((item) => {
    if (item.roles === 'all') return true;
    return role && item.roles.includes(role);
  });

  const isActive = (href: string) => {
    if (href === '/') return pathname === '/';
    return pathname.startsWith(href);
  };

  return (
    <>
      {/* Mobile overlay */}
      {open && (
        <div
          className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-50 flex w-72 flex-col border-r bg-card transition-transform duration-300 lg:translate-x-0',
          open ? 'translate-x-0' : '-translate-x-full',
        )}
      >
        {/* Logo */}
        <div className="flex h-16 items-center justify-between px-6">
          <Link href="/" className="flex items-center">
            <img 
              src="/logo.png" 
              alt="Littlebees" 
              className="h-10 w-auto"
            />
          </Link>
          <button onClick={onClose} className="lg:hidden rounded-lg p-1 hover:bg-gray-100" title="Cerrar menú">
            <X className="h-5 w-5 text-muted" />
          </button>
        </div>

        {/* Navigation */}
        <nav className="mt-4 flex-1 space-y-1 px-3 overflow-y-auto">
          {filteredItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);
            const unread = item.href === '/chat' ? notifCount?.unread : undefined;
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onClose}
                className={cn(
                  'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors',
                  active
                    ? 'bg-primary-50 text-primary'
                    : 'text-muted hover:bg-primary-50/50 hover:text-primary',
                )}
              >
                <Icon className="h-5 w-5 shrink-0" />
                <span className="flex-1">{item.label}</span>
                {unread && unread > 0 && (
                  <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-secondary px-1.5 text-[10px] font-bold text-white">
                    {unread > 99 ? '99+' : unread}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>

        {/* Bottom section */}
        <div className="border-t p-3">
          <Link
            href="/profile"
            onClick={onClose}
            className={cn(
              'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors',
              pathname.startsWith('/profile')
                ? 'bg-primary-50 text-primary'
                : 'text-muted hover:bg-primary-50/50 hover:text-primary',
            )}
          >
            <User className="h-5 w-5" />
            <span>Mi Perfil</span>
          </Link>

          <Link
            href="/settings"
            onClick={onClose}
            className={cn(
              'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors',
              pathname.startsWith('/settings')
                ? 'bg-primary-50 text-primary'
                : 'text-muted hover:bg-primary-50/50 hover:text-primary',
            )}
          >
            <Settings className="h-5 w-5" />
            <span>Configuración</span>
          </Link>

          <div className="mt-2 flex items-center gap-3 rounded-xl px-3 py-2.5">
            <Avatar size="sm" name={user ? `${user.firstName} ${user.lastName}` : ''}>
              <AvatarFallback>
                {user?.firstName?.[0]}{user?.lastName?.[0]}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate">
                {user?.firstName} {user?.lastName}
              </p>
              <p className="text-xs text-muted truncate">{user?.email}</p>
            </div>
            <button
              onClick={logout}
              className="rounded-lg p-1.5 text-muted hover:bg-red-50 hover:text-destructive transition-colors"
              title="Cerrar sesión"
            >
              <LogOut className="h-4 w-4" />
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
