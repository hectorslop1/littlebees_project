'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { useAuth } from '@/hooks/use-auth';
import { Clock, CheckCircle2, Circle, Coffee, Moon, Activity, LogIn, LogOut } from 'lucide-react';
import { cn } from '@/lib/utils';

interface DayScheduleTimelineProps {
  date: Date;
  userRole?: string;
  childId?: string;
  groupId?: string;
}

interface ScheduleItem {
  time: string;
  type: string;
  label: string;
  status: 'completed' | 'pending' | 'skipped';
  completedAt?: string;
  details?: any;
}

interface ChildDaySchedule {
  childId: string;
  childName: string;
  date: string;
  schedule: ScheduleItem[];
  attendance: {
    present: boolean;
    checkInTime?: string;
    checkOutTime?: string;
  };
}

const getIconForType = (type: string) => {
  switch (type) {
    case 'check_in':
      return LogIn;
    case 'check_out':
      return LogOut;
    case 'meal':
      return Coffee;
    case 'nap':
      return Moon;
    case 'activity':
      return Activity;
    default:
      return Circle;
  }
};

const getColorForStatus = (status: string) => {
  switch (status) {
    case 'completed':
      return 'text-success bg-success/10 border-success/20';
    case 'pending':
      return 'text-muted bg-muted/10 border-muted/20';
    case 'skipped':
      return 'text-warning bg-warning/10 border-warning/20';
    default:
      return 'text-muted bg-muted/10 border-muted/20';
  }
};

export function DayScheduleTimeline({ date, userRole, childId, groupId }: DayScheduleTimelineProps) {
  const { user } = useAuth();

  // For now, we'll fetch child schedule if childId is provided or if user is a parent
  const { data: schedule, isLoading } = useQuery({
    queryKey: ['day-schedule', childId, date.toISOString()],
    queryFn: async () => {
      if (!childId) return null;
      
      const response = await api.get<ChildDaySchedule>(
        `/day-schedule/child/${childId}?date=${date.toISOString().split('T')[0]}`
      );
      return response;
    },
    enabled: !!childId,
  });

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(7)].map((_, i) => (
          <div key={i} className="flex items-start gap-4 animate-pulse">
            <div className="w-16 h-16 bg-gray-200 rounded-full" />
            <div className="flex-1 space-y-2">
              <div className="h-4 bg-gray-200 rounded w-1/4" />
              <div className="h-3 bg-gray-200 rounded w-1/2" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (!childId) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">
          Selecciona un niño para ver su programación del día
        </p>
      </div>
    );
  }

  if (!schedule) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">
          No se encontró programación para este día
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Attendance Status */}
      {schedule.attendance && (
        <div className={cn(
          'p-4 rounded-lg border',
          schedule.attendance.present
            ? 'bg-success/5 border-success/20'
            : 'bg-muted/5 border-muted/20'
        )}>
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-semibold">
                {schedule.attendance.present ? '✓ Presente' : 'Ausente'}
              </h3>
              {schedule.attendance.checkInTime && (
                <p className="text-sm text-muted-foreground mt-1">
                  Entrada: {new Date(schedule.attendance.checkInTime).toLocaleTimeString('es-MX', {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </p>
              )}
            </div>
            {schedule.attendance.checkOutTime && (
              <p className="text-sm text-muted-foreground">
                Salida: {new Date(schedule.attendance.checkOutTime).toLocaleTimeString('es-MX', {
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </p>
            )}
          </div>
        </div>
      )}

      {/* Timeline */}
      <div className="relative">
        {/* Vertical line */}
        <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-border" />

        {/* Schedule items */}
        <div className="space-y-6">
          {schedule.schedule.map((item, index) => {
            const Icon = getIconForType(item.type);
            const isCompleted = item.status === 'completed';

            return (
              <div key={index} className="relative flex items-start gap-4">
                {/* Icon */}
                <div
                  className={cn(
                    'relative z-10 flex h-16 w-16 items-center justify-center rounded-full border-2',
                    getColorForStatus(item.status)
                  )}
                >
                  {isCompleted ? (
                    <CheckCircle2 className="h-6 w-6" />
                  ) : (
                    <Icon className="h-6 w-6" />
                  )}
                </div>

                {/* Content */}
                <div className="flex-1 pt-2">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        <Clock className="h-4 w-4 text-muted-foreground" />
                        <span className="text-sm font-medium text-muted-foreground">
                          {item.time}
                        </span>
                      </div>
                      <h3 className="text-lg font-semibold mt-1">{item.label}</h3>
                    </div>

                    {isCompleted && item.completedAt && (
                      <span className="text-xs text-success">
                        Completado a las{' '}
                        {new Date(item.completedAt).toLocaleTimeString('es-MX', {
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </span>
                    )}
                  </div>

                  {item.details && (
                    <div className="mt-2 text-sm text-muted-foreground">
                      {JSON.stringify(item.details)}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
