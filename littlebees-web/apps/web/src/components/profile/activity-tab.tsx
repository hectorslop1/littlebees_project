'use client';

import { UserRole } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { Camera, FileText, MessageCircle, Clock } from 'lucide-react';

interface ActivityTabProps {
  userId: string;
  role: UserRole;
}

interface Activity {
  id: string;
  type: 'photo' | 'report' | 'message' | 'other';
  title: string;
  description: string;
  timestamp: string;
}

const activityIcons = {
  photo: Camera,
  report: FileText,
  message: MessageCircle,
  other: Clock,
};

const activityColors = {
  photo: 'bg-blue-50 text-blue-600',
  report: 'bg-green-50 text-green-600',
  message: 'bg-orange-50 text-orange-600',
  other: 'bg-gray-50 text-gray-600',
};

export function ActivityTab({ userId, role }: ActivityTabProps) {
  const mockActivities: Activity[] = [
    {
      id: '1',
      type: 'photo',
      title: 'Subió 5 fotos nuevas',
      description: 'Actividad de arte - Sala de Lactantes A',
      timestamp: 'Hace 2 horas',
    },
    {
      id: '2',
      type: 'report',
      title: 'Creó un reporte diario',
      description: 'Reporte de desarrollo para María López',
      timestamp: 'Hace 5 horas',
    },
    {
      id: '3',
      type: 'message',
      title: 'Envió un mensaje',
      description: 'Conversación con Ana García',
      timestamp: 'Ayer a las 3:45 PM',
    },
    {
      id: '4',
      type: 'photo',
      title: 'Subió 3 fotos nuevas',
      description: 'Hora de juego - Preescolar B',
      timestamp: 'Hace 2 días',
    },
    {
      id: '5',
      type: 'report',
      title: 'Actualizó un reporte',
      description: 'Reporte de alimentación',
      timestamp: 'Hace 3 días',
    },
  ];

  return (
    <Card className="p-6">
      <h2 className="text-xl font-semibold font-heading mb-6">Actividad Reciente</h2>
      <div className="space-y-4">
        {mockActivities.map((activity) => {
          const Icon = activityIcons[activity.type];
          return (
            <div
              key={activity.id}
              className="flex items-start gap-4 p-4 rounded-lg border hover:bg-primary-50/30 transition-colors"
            >
              <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${activityColors[activity.type]}`}>
                <Icon className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-medium">{activity.title}</h3>
                <p className="text-sm text-muted mt-1">{activity.description}</p>
                <p className="text-xs text-muted mt-2 flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  {activity.timestamp}
                </p>
              </div>
            </div>
          );
        })}
      </div>
      {mockActivities.length === 0 && (
        <div className="text-center py-12 text-muted">
          <Clock className="h-12 w-12 mx-auto mb-3 opacity-50" />
          <p>No hay actividad reciente</p>
        </div>
      )}
    </Card>
  );
}
