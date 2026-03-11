'use client';

import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { UserRole } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Camera, FileText, MessageCircle, Clock, Edit, Trash, Plus } from 'lucide-react';
import { useAuditLogs } from '@/hooks/use-audit-logs';

interface ActivityTabProps {
  userId: string;
  role: UserRole;
}

const activityIcons: Record<string, any> = {
  create: Plus,
  update: Edit,
  delete: Trash,
  upload: Camera,
  message: MessageCircle,
  default: Clock,
};

const activityColors: Record<string, string> = {
  create: 'bg-green-50 text-green-600',
  update: 'bg-blue-50 text-blue-600',
  delete: 'bg-red-50 text-red-600',
  upload: 'bg-purple-50 text-purple-600',
  message: 'bg-orange-50 text-orange-600',
  default: 'bg-gray-50 text-gray-600',
};

const actionLabels: Record<string, string> = {
  create: 'Creó',
  update: 'Actualizó',
  delete: 'Eliminó',
  upload: 'Subió',
  message: 'Envió mensaje',
};

const resourceTypeLabels: Record<string, string> = {
  child: 'niño/a',
  attendance: 'asistencia',
  daily_log: 'bitácora diaria',
  development_record: 'evaluación de desarrollo',
  payment: 'pago',
  message: 'mensaje',
  file: 'archivo',
  user: 'usuario',
  service: 'servicio',
};

export function ActivityTab({ userId, role }: ActivityTabProps) {
  const { data, isLoading } = useAuditLogs({ userId, limit: 10 });

  const activities = data?.data || [];

  const getActivityIcon = (action: string) => {
    return activityIcons[action] || activityIcons.default;
  };

  const getActivityColor = (action: string) => {
    return activityColors[action] || activityColors.default;
  };

  const formatActivity = (log: any) => {
    const action = actionLabels[log.action] || log.action;
    const resourceType = resourceTypeLabels[log.resourceType] || log.resourceType;
    return {
      title: `${action} ${resourceType}`,
      description: log.changes?.description || `ID: ${log.resourceId.substring(0, 8)}...`,
    };
  };

  const formatTimestamp = (date: Date | string) => {
    try {
      return formatDistanceToNow(new Date(date), { addSuffix: true, locale: es });
    } catch {
      return 'Hace un momento';
    }
  };

  if (isLoading) {
    return (
      <Card className="p-6">
        <Skeleton className="h-8 w-64 mb-6" />
        <div className="space-y-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="h-20 w-full rounded-lg" />
          ))}
        </div>
      </Card>
    );
  }

  return (
    <Card className="p-6">
      <h2 className="text-xl font-semibold font-heading mb-6">Actividad Reciente</h2>
      <div className="space-y-4">
        {activities.map((log) => {
          const Icon = getActivityIcon(log.action);
          const activity = formatActivity(log);
          return (
            <div
              key={log.id}
              className="flex items-start gap-4 p-4 rounded-lg border hover:bg-primary-50/30 transition-colors"
            >
              <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${getActivityColor(log.action)}`}>
                <Icon className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-medium">{activity.title}</h3>
                <p className="text-sm text-muted mt-1">{activity.description}</p>
                <p className="text-xs text-muted mt-2 flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  {formatTimestamp(log.createdAt)}
                </p>
              </div>
            </div>
          );
        })}
      </div>
      {activities.length === 0 && (
        <div className="text-center py-12 text-muted">
          <Clock className="h-12 w-12 mx-auto mb-3 opacity-50" />
          <p>No hay actividad reciente</p>
        </div>
      )}
    </Card>
  );
}
