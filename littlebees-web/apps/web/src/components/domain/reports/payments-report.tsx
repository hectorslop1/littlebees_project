'use client';

import { useMemo } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { StatCard } from '@/components/ui/stat-card';
import type { PaymentReportResponse } from '@kinderspace/shared-types';

const STATUS_LABELS: Record<string, string> = {
  PENDING: 'Pendiente',
  PAID: 'Pagado',
  OVERDUE: 'Vencido',
  CANCELLED: 'Cancelado',
};

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(value);
}

interface PaymentsReportProps {
  data: PaymentReportResponse;
}

export function PaymentsReport({ data }: PaymentsReportProps) {
  const chartData = useMemo(() => {
    return data.monthlyBreakdown.map((entry) => {
      let label: string;
      try {
        label = format(parseISO(entry.month + '-01'), 'MMM yyyy', {
          locale: es,
        });
      } catch {
        label = entry.month;
      }
      return {
        label,
        cobrado: entry.collected,
        pendiente: entry.pending,
      };
    });
  }, [data]);

  return (
    <div className="space-y-6">
      {/* Tarjetas de resumen */}
      <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
        <StatCard
          title="Ingresos Totales"
          value={formatCurrency(data.totalRevenue)}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="12" y1="1" x2="12" y2="23" />
              <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
            </svg>
          }
          color="bg-green-50 text-green-600"
        />
        <StatCard
          title="Total Pendiente"
          value={formatCurrency(data.totalPending)}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
          }
          color="bg-amber-50 text-amber-600"
        />
        <StatCard
          title="Total Vencido"
          value={formatCurrency(data.totalOverdue)}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <line x1="12" y1="8" x2="12" y2="12" />
              <line x1="12" y1="16" x2="12.01" y2="16" />
            </svg>
          }
          color="bg-red-50 text-red-600"
        />
      </div>

      {/* Grafica de barras mensual */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Desglose Mensual de Ingresos
          </CardTitle>
        </CardHeader>
        <CardContent>
          {chartData.length === 0 ? (
            <div className="flex h-64 items-center justify-center text-muted">
              Sin datos para el periodo seleccionado
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={320}>
              <BarChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis
                  dataKey="label"
                  tick={{ fontSize: 12 }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis
                  tick={{ fontSize: 12 }}
                  axisLine={false}
                  tickLine={false}
                  tickFormatter={(v) => formatCurrency(v)}
                />
                <Tooltip
                  formatter={(value: number, name: string) => [
                    formatCurrency(value),
                    name === 'cobrado' ? 'Cobrado' : 'Pendiente',
                  ]}
                  contentStyle={{
                    borderRadius: '8px',
                    border: 'none',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                  }}
                />
                <Legend
                  formatter={(value: string) =>
                    value === 'cobrado' ? 'Cobrado' : 'Pendiente'
                  }
                />
                <Bar
                  dataKey="cobrado"
                  name="cobrado"
                  fill="#4ECDC4"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={40}
                />
                <Bar
                  dataKey="pendiente"
                  name="pendiente"
                  fill="#FFB347"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={40}
                />
              </BarChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>

      {/* Tabla de pagos por estado */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Pagos por Estado
          </CardTitle>
        </CardHeader>
        <CardContent>
          {data.paymentsByStatus.length === 0 ? (
            <div className="flex h-32 items-center justify-center text-muted">
              Sin datos de pagos
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b text-left text-muted">
                    <th className="pb-3 pr-4 font-medium">Estado</th>
                    <th className="pb-3 pr-4 font-medium">Cantidad</th>
                    <th className="pb-3 font-medium">Monto Total</th>
                  </tr>
                </thead>
                <tbody>
                  {data.paymentsByStatus.map((entry) => (
                    <tr key={entry.status} className="border-b last:border-0">
                      <td className="py-3 pr-4 font-medium">
                        <span
                          className={
                            entry.status === 'PAID'
                              ? 'text-green-600'
                              : entry.status === 'OVERDUE'
                                ? 'text-red-600'
                                : entry.status === 'CANCELLED'
                                  ? 'text-gray-400'
                                  : 'text-amber-600'
                          }
                        >
                          {STATUS_LABELS[entry.status] ?? entry.status}
                        </span>
                      </td>
                      <td className="py-3 pr-4">{entry.count}</td>
                      <td className="py-3 font-semibold">
                        {formatCurrency(entry.amount)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
