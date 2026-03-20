'use client';

import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { CheckCircle, XCircle, Clock } from 'lucide-react';
import type { Excuse } from '@/hooks/use-excuses';

interface ExcuseDetailDialogProps {
  excuse: Excuse;
  onClose: () => void;
  canApprove: boolean;
  onApprove: (id: string) => void;
  onReject: (id: string, reason: string) => void;
}

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

export function ExcuseDetailDialog({ excuse, onClose, canApprove, onApprove, onReject }: ExcuseDetailDialogProps) {
  const StatusIcon = STATUS_CONFIG[excuse.status].icon;

  const handleReject = () => {
    const reason = prompt('Motivo del rechazo:');
    if (reason) {
      onReject(excuse.id, reason);
      onClose();
    }
  };

  const handleApprove = () => {
    onApprove(excuse.id);
    onClose();
  };

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>Detalle del Justificante</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <Badge className={STATUS_CONFIG[excuse.status].color}>
              <StatusIcon className="w-3 h-3 mr-1" />
              {STATUS_CONFIG[excuse.status].label}
            </Badge>
            <Badge variant="secondary">
              {EXCUSE_TYPE_LABELS[excuse.type]}
            </Badge>
          </div>

          <div className="space-y-2">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Niño/a</p>
                <p className="text-base font-semibold">{excuse.childName}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-muted-foreground">Tipo</p>
                <p className="text-base">{EXCUSE_TYPE_LABELS[excuse.type]}</p>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Fecha inicio</p>
                <p className="text-base">{new Date(excuse.startDate).toLocaleDateString('es-MX')}</p>
              </div>
              {excuse.endDate && (
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Fecha fin</p>
                  <p className="text-base">{new Date(excuse.endDate).toLocaleDateString('es-MX')}</p>
                </div>
              )}
            </div>

            <div>
              <p className="text-sm font-medium text-muted-foreground mb-1">Motivo</p>
              <p className="text-base bg-muted p-3 rounded-md">{excuse.reason}</p>
            </div>

            {excuse.reviewedByName && (
              <div className="border-t pt-4">
                <p className="text-sm font-medium text-muted-foreground mb-1">Revisión</p>
                <p className="text-sm">
                  Revisado por <span className="font-semibold">{excuse.reviewedByName}</span> el{' '}
                  {new Date(excuse.reviewedAt!).toLocaleDateString('es-MX')} a las{' '}
                  {new Date(excuse.reviewedAt!).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}
                </p>
              </div>
            )}

            {excuse.rejectionReason && (
              <div className="bg-red-50 border border-red-200 p-3 rounded-md">
                <p className="text-sm font-medium text-red-800 mb-1">Motivo del rechazo</p>
                <p className="text-sm text-red-700">{excuse.rejectionReason}</p>
              </div>
            )}

            <div className="text-xs text-muted-foreground border-t pt-2">
              Creado el {new Date(excuse.createdAt).toLocaleDateString('es-MX')} a las{' '}
              {new Date(excuse.createdAt).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}
            </div>
          </div>
        </div>

        <DialogFooter>
          {canApprove && excuse.status === 'pending' ? (
            <>
              <Button variant="secondary" onClick={onClose}>
                Cerrar
              </Button>
              <Button variant="danger" onClick={handleReject}>
                <XCircle className="w-4 h-4 mr-2" />
                Rechazar
              </Button>
              <Button onClick={handleApprove}>
                <CheckCircle className="w-4 h-4 mr-2" />
                Aprobar
              </Button>
            </>
          ) : (
            <Button onClick={onClose}>Cerrar</Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
