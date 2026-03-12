'use client';

import { useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowRight, Clock } from 'lucide-react';
import { useDailyLogs } from '@/hooks/use-daily-logs';

export function RecentActivity() {
  const today = new Date().toISOString().split('T')[0];
  const { data: logsResponse, isLoading, error } = useDailyLogs({ date: today });

  const recentLogs = useMemo(() => {
    // La respuesta puede ser un array directo o un objeto con data
    if (!logsResponse) return [];
    
    const logs = Array.isArray(logsResponse) 
      ? logsResponse 
      : logsResponse.data || [];
    
    if (!Array.isArray(logs) || logs.length === 0) return [];
    return logs.slice(0, 3);
  }, [logsResponse]);

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'meal':
        return 'Alimentación';
      case 'nap':
        return 'Siesta';
      case 'activity':
        return 'Actividad';
      case 'bathroom':
        return 'Baño';
      case 'incident':
        return 'Incidente';
      default:
        return 'Actividad';
    }
  };

  const getTypeBadge = (type: string): 'default' | 'secondary' | 'danger' | 'success' | 'warning' | 'info' => {
    switch (type) {
      case 'meal':
        return 'success';
      case 'nap':
        return 'info';
      case 'incident':
        return 'danger';
      case 'activity':
        return 'default';
      default:
        return 'secondary';
    }
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Actividad Reciente
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-20 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-300">
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold font-heading">
          Actividad Reciente
        </CardTitle>
        <Button variant="ghost" size="sm">
          Ver todas <ArrowRight className="ml-1 h-4 w-4" />
        </Button>
      </CardHeader>
      <CardContent>
        {recentLogs.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            No hay actividad registrada hoy
          </div>
        ) : (
          <div className="space-y-4">
            {recentLogs.map((log) => (
              <div
                key={log.id}
                className="flex items-start gap-4 rounded-xl p-3 transition-colors hover:bg-gray-50"
              >
                <Avatar size="md">
                  <AvatarImage src={log.child?.photoUrl} />
                  <AvatarFallback>
                    {log.child?.firstName?.[0] || 'N'}
                    {log.child?.lastName?.[0] || 'N'}
                  </AvatarFallback>
                </Avatar>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-gray-800">
                      {log.child?.firstName || 'Niño'} {log.child?.lastName || ''}
                    </p>
                    <span className="flex items-center gap-1 text-xs text-gray-400">
                      <Clock className="h-3 w-3" />
                      {log.time}
                    </span>
                  </div>
                  <p className="mt-0.5 text-sm text-gray-600">{log.title}</p>
                  {log.description && (
                    <p className="mt-1 text-xs text-gray-400 line-clamp-1">
                      {log.description}
                    </p>
                  )}
                </div>
                <Badge variant={getTypeBadge(log.type)} size="sm">
                  {getTypeLabel(log.type)}
                </Badge>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
