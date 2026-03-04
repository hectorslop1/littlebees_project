'use client';

import { useAuth } from '@/hooks/use-auth';
import { UserRole } from '@kinderspace/shared-types';
import { EmptyState } from '@/components/ui/empty-state';
import { ShieldX } from 'lucide-react';

interface RoleGuardProps {
  allowed: UserRole[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function RoleGuard({ allowed, children, fallback }: RoleGuardProps) {
  const { role, isLoading } = useAuth();

  if (isLoading) return null;

  if (!role || !allowed.includes(role)) {
    return (
      fallback ?? (
        <EmptyState
          icon={<ShieldX />}
          title="Acceso restringido"
          description="No tienes permisos para acceder a esta sección."
        />
      )
    );
  }

  return <>{children}</>;
}
