'use client';

import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Pencil, Users, Calendar, DollarSign } from 'lucide-react';
import { ServiceType } from '@kinderspace/shared-types';
import type { ExtraServiceResponse } from '@kinderspace/shared-types';

interface ServiceCardProps {
  service: ExtraServiceResponse;
  onEdit?: (service: ExtraServiceResponse) => void;
}

const typeGradients: Record<ServiceType, string> = {
  [ServiceType.CLASS]: 'from-primary-400 to-primary-600',
  [ServiceType.WORKSHOP]: 'from-secondary-400 to-secondary-600',
  [ServiceType.MARKETPLACE_ITEM]: 'from-amber-400 to-amber-600',
};

const statusLabels: Record<string, { label: string; variant: 'success' | 'warning' | 'danger' | 'secondary' }> = {
  active: { label: 'Activo', variant: 'success' },
  inactive: { label: 'Inactivo', variant: 'secondary' },
  draft: { label: 'Borrador', variant: 'warning' },
  archived: { label: 'Archivado', variant: 'danger' },
};

function formatMXN(price: number): string {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(price);
}

export function ServiceCard({ service, onEdit }: ServiceCardProps) {
  const gradient = typeGradients[service.type] ?? 'from-gray-400 to-gray-600';
  const statusInfo = statusLabels[service.status] ?? {
    label: service.status,
    variant: 'secondary' as const,
  };

  return (
    <Card hover className="overflow-hidden">
      {/* Imagen o gradiente de placeholder */}
      {service.imageUrl ? (
        <div className="relative h-36 w-full overflow-hidden">
          <img
            src={service.imageUrl}
            alt={service.name}
            className="h-full w-full object-cover"
          />
        </div>
      ) : (
        <div
          className={`flex h-36 w-full items-center justify-center bg-gradient-to-br ${gradient}`}
        >
          <span className="text-4xl font-bold text-white/30">
            {service.name.charAt(0).toUpperCase()}
          </span>
        </div>
      )}

      <CardContent className="space-y-3 p-4">
        {/* Nombre y estado */}
        <div className="flex items-start justify-between gap-2">
          <h3 className="text-sm font-semibold text-foreground leading-tight">
            {service.name}
          </h3>
          <Badge variant={statusInfo.variant} size="sm">
            {statusInfo.label}
          </Badge>
        </div>

        {/* Descripcion */}
        {service.description && (
          <p className="text-xs text-muted-foreground line-clamp-2">
            {service.description}
          </p>
        )}

        {/* Detalles */}
        <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
          {service.schedule && (
            <span className="inline-flex items-center gap-1">
              <Calendar className="h-3.5 w-3.5" />
              {service.schedule}
            </span>
          )}
          <span className="inline-flex items-center gap-1 font-semibold text-foreground">
            <DollarSign className="h-3.5 w-3.5" />
            {formatMXN(service.price)}
          </span>
          {service.capacity !== null && (
            <span className="inline-flex items-center gap-1">
              <Users className="h-3.5 w-3.5" />
              {service.capacity} lugares
            </span>
          )}
        </div>

        {/* Boton de editar */}
        {onEdit && (
          <Button
            variant="outline"
            size="sm"
            className="w-full"
            onClick={() => onEdit(service)}
          >
            <Pencil className="h-3.5 w-3.5" />
            Editar
          </Button>
        )}
      </CardContent>
    </Card>
  );
}
