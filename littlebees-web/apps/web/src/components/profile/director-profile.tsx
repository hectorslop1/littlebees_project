'use client';

import { BarChart3, Camera, CreditCard, MessageCircle, PlusCircle, Settings, Users, BookOpen } from 'lucide-react';
import type { UserInfo, TenantInfo } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { StatsCard } from './stats-card';
import { QuickActions } from './quick-actions';
import { useRouter } from 'next/navigation';

interface DirectorProfileProps {
  user: UserInfo;
  tenant: TenantInfo | null;
}

export function DirectorProfile({ user, tenant }: DirectorProfileProps) {
  const router = useRouter();

  const centerMetrics = [
    {
      title: 'Total Niños',
      value: 48,
      icon: Users,
      description: 'Activos',
      trend: { value: 8, isPositive: true },
      color: 'blue' as const,
    },
    {
      title: 'Total Maestros',
      value: 12,
      icon: Users,
      description: 'Personal activo',
      color: 'green' as const,
    },
    {
      title: 'Total Padres',
      value: 65,
      icon: Users,
      description: 'Registrados',
      color: 'orange' as const,
    },
    {
      title: 'Salones',
      value: 6,
      icon: BookOpen,
      description: 'Activos',
      color: 'purple' as const,
    },
  ];

  const dailyStatus = [
    {
      title: 'Asistencia Hoy',
      value: '92%',
      icon: Users,
      description: '44 de 48 niños',
      color: 'green' as const,
    },
    {
      title: 'Pagos Pendientes',
      value: 8,
      icon: CreditCard,
      description: 'Este mes',
      color: 'red' as const,
    },
    {
      title: 'Fotos Hoy',
      value: 156,
      icon: Camera,
      description: 'Subidas',
      trend: { value: 23, isPositive: true },
      color: 'blue' as const,
    },
    {
      title: 'Chats Activos',
      value: 24,
      icon: MessageCircle,
      description: 'Conversaciones',
      color: 'orange' as const,
    },
  ];

  const quickActions = [
    {
      label: 'Agregar Niño',
      icon: PlusCircle,
      onClick: () => router.push('/children?action=create'),
      variant: 'primary' as const,
    },
    {
      label: 'Agregar Maestro',
      icon: PlusCircle,
      onClick: () => router.push('/settings?tab=staff&action=create'),
    },
    {
      label: 'Ver Reportes',
      icon: BarChart3,
      onClick: () => router.push('/reports'),
    },
    {
      label: 'Gestionar Finanzas',
      icon: CreditCard,
      onClick: () => router.push('/payments'),
    },
    {
      label: 'Configuración',
      icon: Settings,
      onClick: () => router.push('/settings'),
    },
    {
      label: 'Ver Mensajes',
      icon: MessageCircle,
      onClick: () => router.push('/chat'),
    },
  ];

  return (
    <div className="space-y-6">
      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-4">Información del Centro</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-muted">Nombre del Centro</p>
            <p className="text-base font-medium mt-1">{tenant?.name || 'LittleBees'}</p>
          </div>
          <div>
            <p className="text-sm text-muted">Cargo</p>
            <p className="text-base font-medium mt-1">Director General</p>
          </div>
          <div>
            <p className="text-sm text-muted">Años de Experiencia</p>
            <p className="text-base font-medium mt-1">15 años</p>
          </div>
          <div>
            <p className="text-sm text-muted">Licencia</p>
            <p className="text-base font-medium mt-1">SEP-2024-001234</p>
          </div>
        </div>
      </Card>

      <div>
        <h2 className="text-xl font-semibold font-heading mb-4">Métricas del Centro</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {centerMetrics.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>
      </div>

      <div>
        <h2 className="text-xl font-semibold font-heading mb-4">Estado Diario</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {dailyStatus.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>
      </div>

      <QuickActions actions={quickActions} />
    </div>
  );
}
