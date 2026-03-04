'use client';

import { useMemo } from 'react';
import { DollarSign, CheckCircle, Clock, AlertTriangle } from 'lucide-react';
import { StatCard } from '@/components/ui/stat-card';
import type { PaymentResponse } from '@kinderspace/shared-types';
import { PaymentStatus } from '@kinderspace/shared-types';

interface PaymentStatsProps {
  payments: PaymentResponse[];
}

const currencyFormatter = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'MXN',
  minimumFractionDigits: 2,
});

export function PaymentStats({ payments }: PaymentStatsProps) {
  const stats = useMemo(() => {
    const totalIncome = payments
      .filter((p) => p.status === PaymentStatus.PAID)
      .reduce((sum, p) => sum + p.amount, 0);

    const totalPending = payments
      .filter((p) => p.status === PaymentStatus.PENDING)
      .reduce((sum, p) => sum + p.amount, 0);

    const totalOverdue = payments
      .filter((p) => p.status === PaymentStatus.OVERDUE)
      .reduce((sum, p) => sum + p.amount, 0);

    const paidCount = payments.filter(
      (p) => p.status === PaymentStatus.PAID,
    ).length;

    return { totalIncome, totalPending, totalOverdue, paidCount };
  }, [payments]);

  return (
    <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
      <StatCard
        title="Ingresos"
        value={currencyFormatter.format(stats.totalIncome)}
        icon={<DollarSign className="h-5 w-5" />}
        color="bg-green-50 text-success"
      />
      <StatCard
        title="Pagados"
        value={stats.paidCount}
        icon={<CheckCircle className="h-5 w-5" />}
        color="bg-primary-50 text-primary"
      />
      <StatCard
        title="Pendientes"
        value={currencyFormatter.format(stats.totalPending)}
        icon={<Clock className="h-5 w-5" />}
        color="bg-yellow-50 text-warning"
      />
      <StatCard
        title="Vencidos"
        value={currencyFormatter.format(stats.totalOverdue)}
        icon={<AlertTriangle className="h-5 w-5" />}
        color="bg-red-50 text-destructive"
      />
    </div>
  );
}
