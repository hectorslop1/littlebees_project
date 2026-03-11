'use client';

import { useMemo } from 'react';
import { Users, ClipboardCheck, DollarSign, AlertCircle } from 'lucide-react';
import { StatCard } from '@/components/ui/stat-card';
import { Skeleton } from '@/components/ui/skeleton';
import { useChildren } from '@/hooks/use-children';
import { useAttendance } from '@/hooks/use-attendance';
import { usePayments } from '@/hooks/use-payments';
import { AttendanceStatus, PaymentStatus } from '@kinderspace/shared-types';

function getTodayISO(): string {
  return new Date().toISOString().split('T')[0];
}

function getMonthRange(): { from: string; to: string } {
  const now = new Date();
  const from = new Date(now.getFullYear(), now.getMonth(), 1)
    .toISOString()
    .split('T')[0];
  const to = getTodayISO();
  return { from, to };
}

export function StatCardsRow() {
  const today = useMemo(() => getTodayISO(), []);
  const monthRange = useMemo(() => getMonthRange(), []);

  const { data: childrenData, isLoading: childrenLoading } = useChildren();
  const { data: attendanceData, isLoading: attendanceLoading } =
    useAttendance(today);
  const { data: paymentsData, isLoading: paymentsLoading } = usePayments({
    from: monthRange.from,
    to: monthRange.to,
  });

  const totalChildren = childrenData?.meta?.total ?? 0;

  const attendanceRate = useMemo(() => {
    if (!attendanceData?.data?.length) return '0%';
    const present = attendanceData.data.filter(
      (r) =>
        r.status === AttendanceStatus.PRESENT ||
        r.status === AttendanceStatus.LATE,
    ).length;
    const total = attendanceData.data.length;
    return total > 0 ? `${Math.round((present / total) * 100)}%` : '0%';
  }, [attendanceData]);

  const monthlyRevenue = useMemo(() => {
    if (!paymentsData?.data?.length) return '$0';
    const total = paymentsData.data
      .filter((p) => p.status === PaymentStatus.PAID)
      .reduce((sum, p) => sum + p.amount, 0);
    return `$${total.toLocaleString('es-MX')}`;
  }, [paymentsData]);

  const pendingPayments = useMemo(() => {
    if (!paymentsData?.data?.length) return 0;
    return paymentsData.data.filter(
      (p) =>
        p.status === PaymentStatus.PENDING ||
        p.status === PaymentStatus.OVERDUE,
    ).length;
  }, [paymentsData]);

  if (childrenLoading || attendanceLoading || paymentsLoading) {
    return (
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-28 w-full rounded-2xl" />
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
      <StatCard
        title="Total Niños"
        value={totalChildren}
        icon={<Users className="h-5 w-5" />}
        color="bg-primary-50 text-primary"
      />
      <StatCard
        title="Asistencia Hoy"
        value={attendanceRate}
        icon={<ClipboardCheck className="h-5 w-5" />}
        color="bg-green-50 text-success"
      />
      <StatCard
        title="Ingresos del Mes"
        value={monthlyRevenue}
        icon={<DollarSign className="h-5 w-5" />}
        color="bg-accent-50 text-accent-800"
      />
      <StatCard
        title="Pagos Pendientes"
        value={pendingPayments}
        icon={<AlertCircle className="h-5 w-5" />}
        color="bg-secondary-50 text-secondary"
      />
    </div>
  );
}
