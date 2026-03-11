'use client';

import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Bell, Check, Trash2 } from 'lucide-react';

interface NotificationsTabProps {
  userId: string;
}

interface Notification {
  id: string;
  title: string;
  message: string;
  timestamp: string;
  read: boolean;
  type: 'info' | 'success' | 'warning';
}

const notificationColors = {
  info: 'bg-blue-50 border-blue-200',
  success: 'bg-green-50 border-green-200',
  warning: 'bg-orange-50 border-orange-200',
};

export function NotificationsTab({ userId }: NotificationsTabProps) {
  const mockNotifications: Notification[] = [
    {
      id: '1',
      title: 'Nuevo mensaje de Ana García',
      message: 'Te ha enviado un mensaje sobre el desarrollo de María',
      timestamp: 'Hace 1 hora',
      read: false,
      type: 'info',
    },
    {
      id: '2',
      title: 'Pago procesado exitosamente',
      message: 'Tu pago de colegiatura ha sido procesado',
      timestamp: 'Hace 3 horas',
      read: false,
      type: 'success',
    },
    {
      id: '3',
      title: 'Recordatorio de evento',
      message: 'Festival de Primavera - 15 de Marzo',
      timestamp: 'Ayer',
      read: true,
      type: 'warning',
    },
    {
      id: '4',
      title: 'Nuevas fotos disponibles',
      message: 'Se han subido 5 fotos nuevas de tu hijo',
      timestamp: 'Hace 2 días',
      read: true,
      type: 'info',
    },
  ];

  const unreadCount = mockNotifications.filter(n => !n.read).length;

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
            <Button variant="outline" size="sm">
              <Check className="h-4 w-4 mr-2" />
              Marcar todas como leídas
            </Button>
          )}
        </div>

        <div className="space-y-3">
          {mockNotifications.map((notification) => (
            <div
              key={notification.id}
              className={`p-4 rounded-lg border transition-colors ${
                !notification.read ? notificationColors[notification.type] : 'bg-card border-border'
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
                  <p className="text-sm text-muted mt-1">{notification.message}</p>
                  <p className="text-xs text-muted mt-2">{notification.timestamp}</p>
                </div>
                <Button variant="ghost" size="sm" className="shrink-0">
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>
            </div>
          ))}
        </div>

        {mockNotifications.length === 0 && (
          <div className="text-center py-12 text-muted">
            <Bell className="h-12 w-12 mx-auto mb-3 opacity-50" />
            <p>No tienes notificaciones</p>
          </div>
        )}
      </Card>
    </div>
  );
}
