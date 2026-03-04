'use client';

import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { CreditCard } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/data-table';
import { StatusBadge } from '@/components/ui/status-badge';
import { EmptyState } from '@/components/ui/empty-state';
import type { PaymentResponse } from '@kinderspace/shared-types';
import { PaymentStatus } from '@kinderspace/shared-types';

interface PaymentListProps {
  payments: PaymentResponse[];
  onMarkPaid: (payment: PaymentResponse) => void;
  onCancel: (paymentId: string) => void;
  onInvoice?: (paymentId: string) => void;
  isLoading: boolean;
}

const currencyFormatter = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'MXN',
  minimumFractionDigits: 2,
});

function formatDate(isoString: string): string {
  try {
    return format(new Date(isoString), "d 'de' MMM yyyy", { locale: es });
  } catch {
    return '\u2014';
  }
}

function statusToKey(
  status: PaymentStatus,
): 'paid' | 'pending' | 'overdue' | 'cancelled' {
  const map: Record<PaymentStatus, 'paid' | 'pending' | 'overdue' | 'cancelled'> = {
    [PaymentStatus.PAID]: 'paid',
    [PaymentStatus.PENDING]: 'pending',
    [PaymentStatus.OVERDUE]: 'overdue',
    [PaymentStatus.CANCELLED]: 'cancelled',
  };
  return map[status] ?? 'pending';
}

type PaymentRow = PaymentResponse & Record<string, unknown>;

export function PaymentList({
  payments,
  onMarkPaid,
  onCancel,
  onInvoice,
  isLoading,
}: PaymentListProps) {
  const columns: Column<PaymentRow>[] = [
    {
      key: 'concept',
      header: 'Concepto',
      render: (payment) => (
        <div>
          <p className="font-medium text-foreground">{payment.concept}</p>
          <p className="text-xs text-muted-foreground">{payment.childName}</p>
        </div>
      ),
    },
    {
      key: 'amount',
      header: 'Monto',
      render: (payment) => (
        <span className="font-medium">
          {currencyFormatter.format(payment.amount)}
        </span>
      ),
    },
    {
      key: 'dueDate',
      header: 'Fecha L\u00edmite',
      render: (payment) => (
        <span className="text-muted-foreground">
          {formatDate(payment.dueDate)}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      render: (payment) => (
        <StatusBadge status={statusToKey(payment.status)} />
      ),
    },
    {
      key: 'actions',
      header: 'Acciones',
      render: (payment) => {
        const isPending = payment.status === PaymentStatus.PENDING;
        const isOverdue = payment.status === PaymentStatus.OVERDUE;
        const isPaid = payment.status === PaymentStatus.PAID;

        return (
          <div className="flex items-center gap-2">
            {(isPending || isOverdue) && (
              <Button
                size="sm"
                variant="primary"
                onClick={(e) => {
                  e.stopPropagation();
                  onMarkPaid(payment as PaymentResponse);
                }}
              >
                Marcar Pagado
              </Button>
            )}
            {isPending && (
              <Button
                size="sm"
                variant="outline"
                onClick={(e) => {
                  e.stopPropagation();
                  onCancel(payment.id);
                }}
              >
                Cancelar
              </Button>
            )}
            {isPaid && onInvoice && (
              <Button
                size="sm"
                variant="outline"
                onClick={(e) => {
                  e.stopPropagation();
                  onInvoice(payment.id);
                }}
              >
                Facturar
              </Button>
            )}
          </div>
        );
      },
    },
  ];

  const data: PaymentRow[] = payments.map(
    (p) => ({ ...p }) as PaymentRow,
  );

  if (!isLoading && payments.length === 0) {
    return (
      <EmptyState
        icon={<CreditCard />}
        title="Sin pagos registrados"
        description="No se encontraron pagos con los filtros seleccionados."
      />
    );
  }

  return (
    <DataTable<PaymentRow>
      columns={columns}
      data={data}
      isLoading={isLoading}
      emptyMessage="No se encontraron pagos."
    />
  );
}
