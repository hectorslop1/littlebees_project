'use client';

import { useState, useMemo } from 'react';
import { Users } from 'lucide-react';
import { useChildren } from '@/hooks/use-children';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { EmptyState } from '@/components/ui/empty-state';
import { ChildrenFilters } from '@/components/domain/children/children-filters';
import { ChildCard } from '@/components/domain/children/child-card';
import { ChildDetailDialog } from '@/components/domain/children/child-detail-dialog';
import { ChildFormDialog } from '@/components/domain/children/child-form-dialog';
import type { ChildResponse } from '@kinderspace/shared-types';

export default function ChildrenPage() {
  const [search, setSearch] = useState('');
  const [groupId, setGroupId] = useState('all');
  const [selectedChild, setSelectedChild] = useState<ChildResponse | null>(
    null,
  );
  const [showAddDialog, setShowAddDialog] = useState(false);

  const params = useMemo(
    () => ({
      search: search || undefined,
      groupId: groupId !== 'all' ? groupId : undefined,
    }),
    [search, groupId],
  );

  const { data, isLoading } = useChildren(params);

  const children = data?.data ?? [];
  const total = data?.meta?.total ?? 0;

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex items-center gap-3">
        <h1 className="text-2xl font-bold font-heading">Ninos</h1>
        <Badge variant="secondary">{total}</Badge>
      </div>

      {/* Filtros */}
      <ChildrenFilters
        search={search}
        onSearchChange={setSearch}
        groupId={groupId}
        onGroupIdChange={setGroupId}
        onAddClick={() => setShowAddDialog(true)}
      />

      {/* Contenido */}
      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-48 w-full rounded-2xl" />
          ))}
        </div>
      ) : children.length > 0 ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {children.map((child) => (
            <ChildCard
              key={child.id}
              child={child}
              onClick={setSelectedChild}
            />
          ))}
        </div>
      ) : (
        <EmptyState
          icon={<Users />}
          title="No se encontraron ninos"
          description="No hay ninos que coincidan con los filtros seleccionados. Intenta ajustar la busqueda o agrega un nuevo nino."
        />
      )}

      {/* Dialogo de detalle */}
      <ChildDetailDialog
        child={selectedChild}
        open={!!selectedChild}
        onOpenChange={(open) => {
          if (!open) setSelectedChild(null);
        }}
      />

      {/* Dialogo de agregar */}
      <ChildFormDialog
        open={showAddDialog}
        onOpenChange={setShowAddDialog}
      />
    </div>
  );
}
