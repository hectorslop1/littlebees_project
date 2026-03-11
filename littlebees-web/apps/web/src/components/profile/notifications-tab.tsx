'use client';

import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { Bell, Check } from 'lucide-react';
import { useNotifications, useMarkAllNotificationsRead } from '@/hooks/use-notifications';

interface NotificationsTabProps {
  userId: string;
}

const notificationColors = {
  info: 'bg-blue-50 border-blue-200',
  success: 'bg-green-50 border-green-200',
  warning: 'bg-orange-50 border-orange-200',
  error: 'bg-red-50 border-red-200',
};

export function NotificationsTab({ userId }: NotificationsTabProps) {
  const { data, isLoading } = useNotifications();
  const markAllAsRead = useMarkAllNotificationsRead();

  const notifications = data?.data || [];
  const unreadCount = notifications.filter(n => !n.read).length;

  const getNotificationType = (type: string): 'info' | 'success' | 'warning' | 'error' => {
    if (['info', 'success', 'warning', 'error'].includes(type)) {
      return type as 'info' | 'success' | 'warning' | 'error';
    }
    return 'info';
  };

  const formatTimestamp = (date: Date | string) => {
    try {
      return formatDistanceToNow(new Date(date), { addSuffix: true, locale: es });
    } catch {
      return 'Hace un momento';
    }
  };

  const handleMarkAllAsRead = () => {
    markAllAsRead.mutate();
  };


  if (isLoading) {
    return (
      <div className="space-y-4">
        <Card className="p-6">
          <Skeleton className="h-8 w-64 mb-6" />
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-24 w-full rounded-lg" />
            ))}
          </div>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <Card className="p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-xl font-semibold font-heading">Notificaciones</h2>
            {unreadCount > 0 && (
              <p className="text-sm text-muted mt-1">
                Tienes {unreadCount} notificación{unreadCount !== 1 ? 'es' : ''} sin leer
              </p>
            )}
          </div>
          {unreadCount > 0 && (
            <Button 
              variant="outline" 
              size="sm"
              onClick={handleMarkAllAsRead}
              disabled={markAllAsRead.isPending}
            >
              <Check className="h-4 w-4 mr-2" />
              Marcar todas como leídas
            </Button>
          )}
        </div>

        <div className="space-y-3">
          {notifications.map((notification) => {
            const notifType = getNotificationType(notification.type);
            return (
              <div
                key={notification.id}
                className={`p-4 rounded-lg border transition-colors ${
                  !notification.read ? notificationColors[notifType] : 'bg-card border-border'
                }`}
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <h3 className="font-medium">{notification.title}</h3>
                      {!notification.read && (
                        <span className="h-2 w-2 rounded-full bg-primary shrink-0" />
                      )}
                    </div>
                    <p className="text-sm text-muted mt-1">{notification.body}</p>
                    <p className="text-xs text-muted mt-2">{formatTimestamp(notification.createdAt)}</p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {notifications.length === 0 && (
          <div className="text-center py-12 text-muted">
            <Bell className="h-12 w-12 mx-auto mb-3 opacity-50" />
            <p>No tienes notificaciones</p>
          </div>
        )}
      </Card>
    </div>
  );
}
