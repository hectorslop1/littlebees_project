'use client';

import { Camera, FileText, MessageCircle, PlusCircle, TrendingUp, Users } from 'lucide-react';
import type { UserInfo, TenantInfo } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { StatsCard } from './stats-card';
import { QuickActions } from './quick-actions';
import { useRouter } from 'next/navigation';

interface TeacherProfileProps {
  user: UserInfo;
  tenant: TenantInfo | null;
}

export function TeacherProfile({ user, tenant }: TeacherProfileProps) {
  const router = useRouter();

  const teacherStats = [
    {
      title: 'Fotos Subidas',
      value: 24,
      icon: Camera,
      description: 'Esta semana',
      trend: { value: 12, isPositive: true },
      color: 'blue' as const,
    },
    {
      title: 'Reportes Diarios',
      value: 18,
      icon: FileText,
      description: 'Este mes',
      trend: { value: 5, isPositive: true },
      color: 'green' as const,
    },
    {
      title: 'Mensajes con Padres',
      value: 42,
      icon: MessageCircle,
      description: 'Esta semana',
      color: 'orange' as const,
    },
    {
      title: 'Actividades Creadas',
      value: 8,
      icon: PlusCircle,
      description: 'Este mes',
      color: 'purple' as const,
    },
  ];

  const quickActions = [
    {
      label: 'Crear Actividad',
      icon: PlusCircle,
      onClick: () => router.push('/logs?action=create'),
    },
    {
      label: 'Subir Fotos',
      icon: Camera,
      onClick: () => router.push('/logs?action=upload'),
    },
    {
      label: 'Escribir Reporte',
      icon: FileText,
      onClick: () => router.push('/logs?action=report'),
    },
    {
      label: 'Mensajes',
      icon: MessageCircle,
      onClick: () => router.push('/chat'),
    },
    {
      label: 'Ver Progreso',
      icon: TrendingUp,
      onClick: () => router.push('/development'),
    },
    {
      label: 'Ver Niños',
      icon: Users,
      onClick: () => router.push('/children'),
    },
  ];

  return (
    <div className="space-y-6">
      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-4">Información del Maestro</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-muted">Salón Asignado</p>
            <p className="text-base font-medium mt-1">Sala de Lactantes A</p>
          </div>
          <div>
            <p className="text-sm text-muted">Niños Asignados</p>
            <p className="text-base font-medium mt-1">12 niños</p>
          </div>
          <div>
            <p className="text-sm text-muted">Horario de Trabajo</p>
            <p className="text-base font-medium mt-1">8:00 AM - 4:00 PM</p>
          </div>
          <div>
            <p className="text-sm text-muted">Días Laborales</p>
            <p className="text-base font-medium mt-1">Lunes a Viernes</p>
          </div>
        </div>
      </Card>

      <div>
        <h2 className="text-xl font-semibold font-heading mb-4">Métricas del Maestro</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {teacherStats.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>
      </div>

      <QuickActions actions={quickActions} />
    </div>
  );
}
