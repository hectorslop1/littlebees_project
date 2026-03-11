'use client';

import { Calendar, Camera, CreditCard, MessageCircle, TrendingUp, User } from 'lucide-react';
import type { UserInfo, TenantInfo } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { QuickActions } from './quick-actions';
import { useRouter } from 'next/navigation';

interface ParentProfileProps {
  user: UserInfo;
  tenant: TenantInfo | null;
}

interface Child {
  id: string;
  name: string;
  age: string;
  classroom: string;
  teacher: string;
  avatarUrl?: string;
}

export function ParentProfile({ user, tenant }: ParentProfileProps) {
  const router = useRouter();

  const children: Child[] = [
    {
      id: '1',
      name: 'María López',
      age: '2 años',
      classroom: 'Sala de Lactantes A',
      teacher: 'Maestra Ana García',
    },
    {
      id: '2',
      name: 'Carlos López',
      age: '4 años',
      classroom: 'Preescolar B',
      teacher: 'Maestro Luis Martínez',
    },
  ];

  const quickActions = [
    {
      label: 'Chat con Maestro',
      icon: MessageCircle,
      onClick: () => router.push('/chat'),
      variant: 'primary' as const,
    },
    {
      label: 'Ver Galería',
      icon: Camera,
      onClick: () => router.push('/logs'),
    },
    {
      label: 'Pagar Colegiatura',
      icon: CreditCard,
      onClick: () => router.push('/payments'),
    },
    {
      label: 'Ver Calendario',
      icon: Calendar,
      onClick: () => router.push('/'),
    },
    {
      label: 'Ver Desarrollo',
      icon: TrendingUp,
      onClick: () => router.push('/development'),
    },
  ];

  return (
    <div className="space-y-6">
      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-4">Información Personal</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-muted">Relación</p>
            <p className="text-base font-medium mt-1">Padre/Madre</p>
          </div>
          <div>
            <p className="text-sm text-muted">Contacto de Emergencia</p>
            <p className="text-base font-medium mt-1">{user.phone || 'No registrado'}</p>
          </div>
          <div>
            <p className="text-sm text-muted">Dirección</p>
            <p className="text-base font-medium mt-1">Calle Principal #123, Col. Centro</p>
          </div>
          <div>
            <p className="text-sm text-muted">Ciudad</p>
            <p className="text-base font-medium mt-1">Ciudad de México</p>
          </div>
        </div>
      </Card>

      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-4">Mis Hijos</h2>
        <div className="space-y-4">
          {children.map((child) => (
            <div
              key={child.id}
              className="flex items-start gap-4 p-4 rounded-xl border bg-card hover:bg-primary-50/30 transition-colors cursor-pointer"
              onClick={() => router.push(`/children/${child.id}`)}
            >
              <Avatar className="h-16 w-16">
                <AvatarImage src={child.avatarUrl} alt={child.name} />
                <AvatarFallback className="text-lg">
                  {child.name.split(' ').map(n => n[0]).join('')}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-lg">{child.name}</h3>
                <p className="text-sm text-muted">{child.age}</p>
                <div className="mt-2 space-y-1">
                  <div className="flex items-center gap-2">
                    <Badge variant="default" className="text-xs">
                      {child.classroom}
                    </Badge>
                  </div>
                  <p className="text-xs text-muted">
                    <User className="h-3 w-3 inline mr-1" />
                    {child.teacher}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </Card>

      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-4">Resumen</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-4 rounded-lg bg-blue-50">
            <p className="text-sm text-muted">Próximo Evento</p>
            <p className="text-base font-medium mt-1">Festival de Primavera</p>
            <p className="text-xs text-muted mt-1">15 de Marzo, 2026</p>
          </div>
          <div className="p-4 rounded-lg bg-green-50">
            <p className="text-sm text-muted">Estado de Pago</p>
            <p className="text-base font-medium mt-1 text-green-700">Al Corriente</p>
            <p className="text-xs text-muted mt-1">Próximo pago: 1 Abril</p>
          </div>
          <div className="p-4 rounded-lg bg-purple-50">
            <p className="text-sm text-muted">Último Reporte</p>
            <p className="text-base font-medium mt-1">Hace 2 días</p>
            <p className="text-xs text-muted mt-1">María - Desarrollo positivo</p>
          </div>
          <div className="p-4 rounded-lg bg-orange-50">
            <p className="text-sm text-muted">Última Foto</p>
            <p className="text-base font-medium mt-1">Hace 1 hora</p>
            <p className="text-xs text-muted mt-1">Carlos - Actividad artística</p>
          </div>
        </div>
      </Card>

      <QuickActions actions={quickActions} />
    </div>
  );
}
