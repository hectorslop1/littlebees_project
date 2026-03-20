'use client';

import { useState } from 'react';
import { useExcuses, useCreateExcuse, useUpdateExcuseStatus, useDeleteExcuse } from '@/hooks/use-excuses';
import { useChildren } from '@/hooks/use-children';
import { useAuth } from '@/hooks/use-auth';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Plus, FileText, Clock, CheckCircle, XCircle, Trash2 } from 'lucide-react';
import { ExcuseFormDialog } from '@/components/domain/excuses/excuse-form-dialog';
import { ExcuseDetailDialog } from '@/components/domain/excuses/excuse-detail-dialog';
import type { Excuse } from '@/hooks/use-excuses';

const EXCUSE_TYPE_LABELS = {
  sick: 'Enfermedad',
  late_arrival: 'Llegada tarde',
  absence: 'Ausencia',
  other: 'Otro',
};

const STATUS_CONFIG = {
  pending: { label: 'Pendiente', color: 'bg-yellow-100 text-yellow-800', icon: Clock },
  approved: { label: 'Aprobado', color: 'bg-green-100 text-green-800', icon: CheckCircle },
  rejected: { label: 'Rechazado', color: 'bg-red-100 text-red-800', icon: XCircle },
};

export default function ExcusesPage() {
  const { user } = useAuth();
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [selectedExcuse, setSelectedExcuse] = useState<Excuse | null>(null);

  const { data: childrenData } = useChildren({ status: 'active' });
  const children = childrenData?.data || [];

  const { data: excuses, isLoading } = useExcuses(
    statusFilter !== 'all' ? { status: statusFilter } : undefined
  );

  const createMutation = useCreateExcuse();
  const updateStatusMutation = useUpdateExcuseStatus();
  const deleteMutation = useDeleteExcuse();

  const isParent = user?.role === 'parent';
  const canApprove = ['teacher', 'director', 'admin', 'super_admin'].includes(user?.role || '');

  const filteredExcuses = excuses || [];

  const handleApprove = async (id: string) => {
    await updateStatusMutation.mutateAsync({ id, data: { status: 'approved' } });
  };

  const handleReject = async (id: string, reason: string) => {
    await updateStatusMutation.mutateAsync({ 
      id, 
      data: { status: 'rejected', rejectionReason: reason } 
    });
  };

  const handleDelete = async (id: string) => {
    if (confirm('¿Estás seguro de eliminar este justificante?')) {
      await deleteMutation.mutateAsync(id);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Cargando justificantes...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Justificantes</h1>
          <p className="text-muted-foreground mt-1">
            {isParent ? 'Gestiona los justificantes de tus hijos' : 'Revisa y aprueba justificantes'}
          </p>
        </div>
        {isParent && (
          <Button onClick={() => setShowCreateDialog(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Nuevo Justificante
          </Button>
        )}
      </div>

      <Tabs value={statusFilter} onValueChange={(v) => setStatusFilter(v as any)}>
        <TabsList>
          <TabsTrigger value="all">Todos</TabsTrigger>
          <TabsTrigger value="pending">Pendientes</TabsTrigger>
          <TabsTrigger value="approved">Aprobados</TabsTrigger>
          <TabsTrigger value="rejected">Rechazados</TabsTrigger>
        </TabsList>

        <TabsContent value={statusFilter} className="mt-6">
          {filteredExcuses.length === 0 ? (
            <Card className="p-12">
              <div className="text-center">
                <FileText className="w-16 h-16 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">No hay justificantes</h3>
                <p className="text-muted-foreground">
                  {statusFilter === 'all' 
                    ? 'No se han creado justificantes aún'
                    : `No hay justificantes ${STATUS_CONFIG[statusFilter]?.label.toLowerCase()}`}
                </p>
              </div>
            </Card>
          ) : (
            <div className="grid gap-4">
              {filteredExcuses.map((excuse) => {
                const StatusIcon = STATUS_CONFIG[excuse.status].icon;
                
                return (
                  <Card key={excuse.id} className="p-6 hover:shadow-lg transition-shadow">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <h3 className="font-semibold text-lg">{excuse.childName}</h3>
                          <Badge className={STATUS_CONFIG[excuse.status].color}>
                            <StatusIcon className="w-3 h-3 mr-1" />
                            {STATUS_CONFIG[excuse.status].label}
                          </Badge>
                          <Badge variant="outline">
                            {EXCUSE_TYPE_LABELS[excuse.type]}
                          </Badge>
                        </div>

                        <p className="text-sm text-muted-foreground mb-3">{excuse.reason}</p>

                        <div className="flex items-center gap-4 text-xs text-muted-foreground">
                          <span>
                            Desde: {new Date(excuse.startDate).toLocaleDateString('es-MX')}
                          </span>
                          {excuse.endDate && (
                            <span>
                              Hasta: {new Date(excuse.endDate).toLocaleDateString('es-MX')}
                            </span>
                          )}
                        </div>

                        {excuse.reviewedByName && (
                          <p className="text-xs text-muted-foreground mt-2">
                            Revisado por {excuse.reviewedByName} el{' '}
                            {new Date(excuse.reviewedAt!).toLocaleDateString('es-MX')}
                          </p>
                        )}

                        {excuse.rejectionReason && (
                          <p className="text-sm text-red-600 mt-2">
                            Motivo de rechazo: {excuse.rejectionReason}
                          </p>
                        )}
                      </div>

                      <div className="flex gap-2 ml-4">
                        <Button
                          variant="secondary"
                          size="sm"
                          onClick={() => setSelectedExcuse(excuse)}
                        >
                          Ver Detalle
                        </Button>

                        {canApprove && excuse.status === 'pending' && (
                          <>
                            <Button
                              variant="primary"
                              size="sm"
                              onClick={() => handleApprove(excuse.id)}
                            >
                              <CheckCircle className="w-4 h-4 mr-1" />
                              Aprobar
                            </Button>
                            <Button
                              variant="danger"
                              size="sm"
                              onClick={() => {
                                const reason = prompt('Motivo del rechazo:');
                                if (reason) handleReject(excuse.id, reason);
                              }}
                            >
                              <XCircle className="w-4 h-4 mr-1" />
                              Rechazar
                            </Button>
                          </>
                        )}

                        {isParent && excuse.status === 'pending' && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(excuse.id)}
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        )}
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </TabsContent>
      </Tabs>

      {showCreateDialog && (
        <ExcuseFormDialog
          children={children}
          onClose={() => setShowCreateDialog(false)}
          onSubmit={async (data) => {
            await createMutation.mutateAsync(data);
            setShowCreateDialog(false);
          }}
        />
      )}

      {selectedExcuse && (
        <ExcuseDetailDialog
          excuse={selectedExcuse}
          onClose={() => setSelectedExcuse(null)}
          canApprove={canApprove}
          onApprove={handleApprove}
          onReject={handleReject}
        />
      )}
    </div>
  );
}
