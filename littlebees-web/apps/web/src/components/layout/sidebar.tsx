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
  Baby,
  UserCheck,
  Palette,
  Sparkles,
  Home,
  FileText,
  Calendar,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/hooks/use-auth';
import { useCustomization } from '@/hooks/use-customization';
import { useMenu } from '@/hooks/use-menu';
import { useNotificationCount } from '@/hooks/use-notifications';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

const iconMap: Record<string, any> = {
  home: Home,
  users: Users,
  baby: Baby,
  'clipboard-list': BookOpen,
  'chart-bar': BarChart3,
  'message-circle': MessageCircle,
  'credit-card': CreditCard,
  settings: Settings,
  'user-check': UserCheck,
  palette: Palette,
  sparkles: Sparkles,
  user: User,
  'file-text': FileText,
  calendar: Calendar,
};

export function Sidebar({ open, onClose }: SidebarProps) {
  const pathname = usePathname();
  const { user, tenant, logout, isAuthenticated } = useAuth();
  const { data: customization } = useCustomization({ enabled: isAuthenticated });
  const { data: menuConfig, isLoading } = useMenu();
  const { data: notifCount } = useNotificationCount();
  const brandName = customization?.systemName || tenant?.name || 'LittleBees';
  const logoUrl = customization?.logoUrl || tenant?.logoUrl || '/logo.png';

  const isActive = (href: string) => {
    if (href === '/') return pathname === '/';
    if (href === '/dashboard') return pathname === '/' || pathname === '/dashboard';
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
          'fixed inset-y-0 left-0 z-50 flex w-72 flex-col transition-transform duration-300 lg:translate-x-0',
          open ? 'translate-x-0' : '-translate-x-full',
        )}
        style={{
          backgroundColor: 'var(--sidebar-bg)',
          borderRight: '1px solid color-mix(in srgb, var(--sidebar-text) 16%, transparent)',
        }}
      >
        {/* Logo */}
        <div
          className="flex h-16 items-center justify-between px-6"
          style={{ borderBottom: '1px solid color-mix(in srgb, var(--sidebar-text) 12%, transparent)' }}
        >
          <Link href="/" className="flex items-center gap-3">
            <img
              src={logoUrl}
              alt={brandName}
              className="h-10 w-10 rounded-2xl object-cover ring-2 ring-white/10"
            />
            <div className="min-w-0">
              <p className="truncate text-sm font-bold" style={{ color: 'var(--sidebar-active-text)' }}>
                {brandName}
              </p>
              <p className="truncate text-xs" style={{ color: 'var(--sidebar-text)' }}>
                Panel institucional
              </p>
            </div>
          </Link>
          <button onClick={onClose} className="lg:hidden rounded-lg p-1 hover:bg-white/10" title="Cerrar menú" style={{ color: 'var(--sidebar-text)' }}>
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Navigation */}
        <nav className="mt-4 flex-1 space-y-1 px-3 overflow-y-auto">
          {isLoading ? (
            <div className="space-y-2">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-10 rounded-xl bg-gray-100 animate-pulse" />
              ))}
            </div>
          ) : (
            menuConfig?.items.map((item) => {
              const Icon = iconMap[item.icon] || Home;
              const active = isActive(item.path);
              const unread = item.path === '/chat' ? notifCount?.unread : undefined;
              return (
                <Link
                  key={item.id}
                  href={item.path}
                  onClick={onClose}
                  className={cn(
                    'group relative flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200',
                    active
                      ? 'bg-primary/30 shadow-sm'
                      : 'hover:bg-white/10',
                  )}
                  style={{ color: active ? 'var(--sidebar-active-text)' : 'var(--sidebar-text)' }}
                >
                  {active && (
                    <span className="absolute left-0 top-1/2 h-6 w-[3px] -translate-y-1/2 rounded-r-full bg-primary-400" />
                  )}
                  <Icon
                    className={cn('h-5 w-5 shrink-0 transition-transform duration-200', active ? 'scale-110' : 'group-hover:scale-105')}
                    style={{ color: active ? 'var(--primary-400)' : 'var(--sidebar-text)' }}
                  />
                  <span className="flex-1">{item.label}</span>
                  {unread && unread > 0 && (
                    <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-secondary px-1.5 text-[10px] font-bold text-white">
                      {unread > 99 ? '99+' : unread}
                    </span>
                  )}
                </Link>
              );
            })
          )}
        </nav>

        {/* Bottom section */}
        <div className="p-3" style={{ borderTop: '1px solid color-mix(in srgb, var(--sidebar-text) 12%, transparent)' }}>
          <Link
            href="/profile"
            onClick={onClose}
            className={cn(
              'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors',
              pathname.startsWith('/profile')
                ? 'bg-primary/30'
                : 'hover:bg-white/10',
            )}
            style={{ color: pathname.startsWith('/profile') ? 'var(--sidebar-active-text)' : 'var(--sidebar-text)' }}
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
                ? 'bg-primary/30'
                : 'hover:bg-white/10',
            )}
            style={{ color: pathname.startsWith('/settings') ? 'var(--sidebar-active-text)' : 'var(--sidebar-text)' }}
          >
            <Settings className="h-5 w-5" />
            <span>Configuración</span>
          </Link>

          <div className="mt-2 flex items-center gap-3 rounded-xl px-3 py-2.5">
            <Avatar
              size="sm"
              name={user ? `${user.firstName} ${user.lastName}` : ''}
              src={user?.avatarUrl ?? undefined}
            >
              <AvatarFallback>
                {user?.firstName?.[0]}{user?.lastName?.[0]}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate" style={{ color: 'var(--sidebar-active-text)' }}>
                {user?.firstName} {user?.lastName}
              </p>
              <p className="text-xs truncate" style={{ color: 'var(--sidebar-text)', opacity: 0.7 }}>{user?.email}</p>
            </div>
            <button
              onClick={logout}
              className="rounded-lg p-1.5 hover:bg-red-500/20 transition-colors"
              style={{ color: 'var(--sidebar-text)' }}
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
