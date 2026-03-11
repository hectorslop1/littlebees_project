'use client';

import { useState, useMemo } from 'react';
import { Users } from 'lucide-react';
import { useChildren } from '@/hooks/use-children';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { EmptyState } from '@/components/ui/empty-state';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { ChildrenFilters } from '@/components/domain/children/children-filters';
import { ChildCard } from '@/components/domain/children/child-card';
import { ChildDetailDialog } from '@/components/domain/children/child-detail-dialog';
import { ChildFormDialog } from '@/components/domain/children/child-form-dialog';
import type { ChildResponse } from '@kinderspace/shared-types';
import { ChildStatus } from '@kinderspace/shared-types';

export default function ChildrenPage() {
  const [search, setSearch] = useState('');
  const [groupId, setGroupId] = useState('all');
  const [statusTab, setStatusTab] = useState<'active' | 'inactive'>('active');
  const [selectedChild, setSelectedChild] = useState<ChildResponse | null>(
    null,
  );
  const [showAddDialog, setShowAddDialog] = useState(false);

  const paramsActive = useMemo(
    () => ({
      search: search || undefined,
      groupId: groupId !== 'all' ? groupId : undefined,
      status: ChildStatus.ACTIVE,
    }),
    [search, groupId],
  );

  const paramsInactive = useMemo(
    () => ({
      search: search || undefined,
      groupId: groupId !== 'all' ? groupId : undefined,
      status: ChildStatus.INACTIVE,
    }),
    [search, groupId],
  );

  const { data: dataActive, isLoading: isLoadingActive } = useChildren(paramsActive);
  const { data: dataInactive, isLoading: isLoadingInactive } = useChildren(paramsInactive);

  const activeChildren = dataActive?.data ?? [];
  const inactiveChildren = dataInactive?.data ?? [];
  const totalActive = dataActive?.meta?.total ?? 0;
  const totalInactive = dataInactive?.meta?.total ?? 0;

  const isLoading = statusTab === 'active' ? isLoadingActive : isLoadingInactive;
  const children = statusTab === 'active' ? activeChildren : inactiveChildren;

  function renderChildrenContent() {
    return isLoading ? (
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
        title={statusTab === 'active' ? 'No hay niños activos' : 'No hay niños inactivos'}
        description={
          statusTab === 'active'
            ? 'No hay niños activos que coincidan con los filtros seleccionados. Intenta ajustar la búsqueda o agrega un nuevo niño.'
            : 'No hay niños inactivos que coincidan con los filtros seleccionados.'
        }
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Encabezado */}
      <div className="flex items-center gap-3">
        <h1 className="text-2xl font-bold font-heading">Niños</h1>
        <Badge variant="secondary">{totalActive + totalInactive}</Badge>
      </div>

      {/* Filtros */}
      <ChildrenFilters
        search={search}
        onSearchChange={setSearch}
        groupId={groupId}
        onGroupIdChange={setGroupId}
        onAddClick={() => setShowAddDialog(true)}
      />

      {/* Tabs */}
      <Tabs value={statusTab} onValueChange={(v) => setStatusTab(v as 'active' | 'inactive')}>
        <TabsList>
          <TabsTrigger value="active" className="gap-2">
            Activos
            <Badge variant="secondary" size="sm">{totalActive}</Badge>
          </TabsTrigger>
          <TabsTrigger value="inactive" className="gap-2">
            Inactivos
            <Badge variant="secondary" size="sm">{totalInactive}</Badge>
          </TabsTrigger>
        </TabsList>

        <TabsContent value="active">
          {renderChildrenContent()}
        </TabsContent>

        <TabsContent value="inactive">
          {renderChildrenContent()}
        </TabsContent>
      </Tabs>

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
