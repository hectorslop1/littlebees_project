'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowRight } from 'lucide-react';
import { useAnnouncements } from '@/hooks/use-announcements';
import { useMemo } from 'react';

export function AnnouncementsList() {
  const { data: announcementsResponse, isLoading } = useAnnouncements({ limit: 3 });

  const recentAnnouncements = useMemo(() => {
    // La respuesta puede ser un array directo o un objeto con data
    if (!announcementsResponse) return [];
    
    const announcements = Array.isArray(announcementsResponse)
      ? announcementsResponse
      : announcementsResponse.data || [];
    
    if (!Array.isArray(announcements) || announcements.length === 0) return [];
    return announcements.slice(0, 3);
  }, [announcementsResponse]);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Anuncios Recientes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-24 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'border-red-500 bg-red-50';
      case 'medium':
        return 'border-yellow-500 bg-yellow-50';
      default:
        return 'border-blue-500 bg-blue-50';
    }
  };

  const getTypeBadge = (type: string): 'default' | 'secondary' | 'danger' | 'success' | 'warning' | 'info' => {
    switch (type) {
      case 'alert':
        return 'danger';
      case 'event':
        return 'info';
      case 'achievement':
        return 'success';
      default:
        return 'secondary';
    }
  };

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'general':
        return 'General';
      case 'event':
        return 'Evento';
      case 'alert':
        return 'Alerta';
      case 'achievement':
        return 'Logro';
      default:
        return type;
    }
  };

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-300">
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold font-heading">
          Anuncios Recientes
        </CardTitle>
        <Button variant="ghost" size="sm">
          Ver todos <ArrowRight className="ml-1 h-4 w-4" />
        </Button>
      </CardHeader>
      <CardContent>
        {recentAnnouncements.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            No hay anuncios recientes
          </div>
        ) : (
          <div className="space-y-4">
            {recentAnnouncements.map((announcement: any) => (
              <div
                key={announcement.id}
                className={`rounded-xl border-l-4 p-4 ${getPriorityColor(announcement.priority)}`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="font-medium text-gray-800">
                      {announcement.title}
                    </h4>
                    <p className="mt-1 line-clamp-2 text-sm text-gray-600">
                      {announcement.content}
                    </p>
                  </div>
                  <Badge variant={getTypeBadge(announcement.type)} size="sm">
                    {getTypeLabel(announcement.type)}
                  </Badge>
                </div>
                <div className="mt-3 flex items-center gap-4">
                  <span className="text-xs text-gray-500">
                    {announcement.author ? `${announcement.author.firstName} ${announcement.author.lastName}` : 'Administrador'}
                  </span>
                  <span className="text-xs text-gray-400">
                    {new Date(announcement.createdAt).toLocaleDateString('es-MX')}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
