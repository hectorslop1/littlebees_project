'use client';

import { useState, useMemo } from 'react';
import { Search, Plus, Briefcase } from 'lucide-react';
import { useServices } from '@/hooks/use-services';
import { useAuth } from '@/hooks/use-auth';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { EmptyState } from '@/components/ui/empty-state';
import { ServicesTabs } from '@/components/domain/services/services-tabs';
import { ServiceFormDialog } from '@/components/domain/services/service-form-dialog';
import type { ExtraServiceResponse } from '@kinderspace/shared-types';

export default function ServicesPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [showFormDialog, setShowFormDialog] = useState(false);
  const [editingService, setEditingService] =
    useState<ExtraServiceResponse | null>(null);

  const { isAdmin, isDirector } = useAuth();
  const canManage = isAdmin || isDirector;

  const params = useMemo(
    () => ({
      search: searchQuery || undefined,
    }),
    [searchQuery],
  );

  const { data, isLoading } = useServices(params);

  const services = data?.data ?? [];

  function handleEdit(service: ExtraServiceResponse) {
    setEditingService(service);
    setShowFormDialog(true);
  }

  function handleCloseDialog(open: boolean) {
    setShowFormDialog(open);
    if (!open) {
      setEditingService(null);
    }
  }

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold font-heading">Servicios</h1>
        <div className="flex items-center gap-3">
          <Input
            placeholder="Buscar servicios..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            icon={<Search className="h-4 w-4" />}
            className="w-full sm:w-64"
          />
          {canManage && (
            <Button onClick={() => setShowFormDialog(true)}>
              <Plus className="h-4 w-4" />
              Agregar Servicio
            </Button>
          )}
        </div>
      </div>

      {/* Contenido */}
      {isLoading ? (
        <div className="space-y-4">
          <Skeleton className="h-10 w-80 rounded-xl" />
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {Array.from({ length: 8 }).map((_, i) => (
              <Skeleton key={i} className="h-64 w-full rounded-2xl" />
            ))}
          </div>
        </div>
      ) : services.length > 0 ? (
        <ServicesTabs
          services={services}
          onAdd={canManage ? () => setShowFormDialog(true) : undefined}
          onEdit={canManage ? handleEdit : undefined}
        />
      ) : (
        <EmptyState
          icon={<Briefcase />}
          title="No se encontraron servicios"
          description="No hay servicios que coincidan con la busqueda. Intenta ajustar los filtros o agrega un nuevo servicio."
        />
      )}

      {/* Dialogo de formulario */}
      <ServiceFormDialog
        open={showFormDialog}
        onOpenChange={handleCloseDialog}
        service={editingService}
        onSuccess={() => setEditingService(null)}
      />
    </div>
  );
}
