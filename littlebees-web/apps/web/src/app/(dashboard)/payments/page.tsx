'use client';

import { useState, useMemo, useCallback } from 'react';
import { toast } from 'sonner';
import { useAuth } from '@/hooks/use-auth';
import { usePayments, useMarkPaid, useCancelPayment } from '@/hooks/use-payments';
import { useChildren } from '@/hooks/use-children';
import { PaymentStats } from '@/components/domain/payments/payment-stats';
import { PaymentList } from '@/components/domain/payments/payment-list';
import { PayDialog } from '@/components/domain/payments/pay-dialog';
import { InvoiceDialog } from '@/components/domain/payments/invoice-dialog';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from '@/components/ui/select';
import type { PaymentResponse } from '@kinderspace/shared-types';
import { PaymentMethodType } from '@kinderspace/shared-types';

export default function PaymentsPage() {
  const { isAdmin, isDirector } = useAuth();
  const canCreate = isAdmin || isDirector;

  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [childFilter, setChildFilter] = useState<string>('all');

  const [paymentForPay, setPaymentForPay] = useState<PaymentResponse | null>(null);
  const [paymentIdForInvoice, setPaymentIdForInvoice] = useState<string | null>(null);

  const params = useMemo(() => {
    const p: Record<string, string> = {};
    if (statusFilter !== 'all') p.status = statusFilter;
    if (childFilter !== 'all') p.childId = childFilter;
    return Object.keys(p).length > 0 ? p : undefined;
  }, [statusFilter, childFilter]);

  const { data: paymentsData, isLoading } = usePayments(params);
  const { data: childrenData } = useChildren();

  const payments = useMemo(
    () => paymentsData?.data ?? [],
    [paymentsData],
  );

  const children = useMemo(
    () => childrenData?.data ?? [],
    [childrenData],
  );

  const markPaidMutation = useMarkPaid(paymentForPay?.id ?? '');
  const cancelPayment = useCancelPayment();

  const handleMarkPaid = useCallback(
    (payment: PaymentResponse) => {
      setPaymentForPay(payment);
    },
    [],
  );

  const handleConfirmPay = useCallback(
    async (paymentMethod: PaymentMethodType) => {
      if (!paymentForPay) return;

      try {
        await markPaidMutation.mutateAsync({ paymentMethod });
        toast.success('Pago registrado exitosamente');
      } catch {
        toast.error('Error al registrar el pago. Intenta de nuevo.');
      } finally {
        setPaymentForPay(null);
      }
    },
    [paymentForPay, markPaidMutation],
  );

  const handleCancel = useCallback(
    async (paymentId: string) => {
      try {
        await cancelPayment.mutateAsync(paymentId);
        toast.success('Pago cancelado exitosamente');
      } catch {
        toast.error('Error al cancelar el pago. Intenta de nuevo.');
      }
    },
    [cancelPayment],
  );

  const handleInvoice = useCallback(
    (paymentId: string) => {
      setPaymentIdForInvoice(paymentId);
    },
    [],
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold font-heading">Pagos</h1>
        {canCreate && (
          <Button variant="primary">Crear Cargo</Button>
        )}
      </div>

      {/* Filtros */}
      <div className="flex flex-wrap gap-4">
        <div className="w-48">
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger>
              <SelectValue placeholder="Estado" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos los estados</SelectItem>
              <SelectItem value="PENDING">Pendiente</SelectItem>
              <SelectItem value="PAID">Pagado</SelectItem>
              <SelectItem value="OVERDUE">Vencido</SelectItem>
              <SelectItem value="CANCELLED">Cancelado</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="w-48">
          <Select value={childFilter} onValueChange={setChildFilter}>
            <SelectTrigger>
              <SelectValue placeholder="Alumno" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos los alumnos</SelectItem>
              {children.map((child) => (
                <SelectItem key={child.id} value={child.id}>
                  {child.firstName} {child.lastName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-28 w-full rounded-2xl" />
            ))}
          </div>
          <Skeleton className="h-64 w-full rounded-xl" />
        </div>
      ) : (
        <>
          <PaymentStats payments={payments} />

          <PaymentList
            payments={payments}
            onMarkPaid={handleMarkPaid}
            onCancel={handleCancel}
            onInvoice={handleInvoice}
            isLoading={isLoading}
          />
        </>
      )}

      <PayDialog
        payment={paymentForPay}
        open={!!paymentForPay}
        onOpenChange={(open) => {
          if (!open) setPaymentForPay(null);
        }}
        onConfirm={handleConfirmPay}
      />

      <InvoiceDialog
        paymentId={paymentIdForInvoice}
        open={!!paymentIdForInvoice}
        onOpenChange={(open) => {
          if (!open) setPaymentIdForInvoice(null);
        }}
      />
    </div>
  );
}
