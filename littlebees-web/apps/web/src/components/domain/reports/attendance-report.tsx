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
import type { AttendanceReportResponse } from '@kinderspace/shared-types';

interface AttendanceReportProps {
  data: AttendanceReportResponse;
}

export function AttendanceReport({ data }: AttendanceReportProps) {
  const chartData = useMemo(() => {
    // Agregar desglose diario de todos los grupos
    const dailyMap = new Map<
      string,
      { date: string; presentes: number; ausentes: number; tarde: number }
    >();

    for (const group of data.groups) {
      for (const day of group.dailyBreakdown) {
        const existing = dailyMap.get(day.date) ?? {
          date: day.date,
          presentes: 0,
          ausentes: 0,
          tarde: 0,
        };
        existing.presentes += day.present;
        existing.ausentes += day.absent;
        dailyMap.set(day.date, existing);
      }
    }

    return Array.from(dailyMap.values())
      .sort((a, b) => a.date.localeCompare(b.date))
      .map((entry) => ({
        ...entry,
        label: format(parseISO(entry.date), 'dd MMM', { locale: es }),
      }));
  }, [data]);

  const totalChildren = useMemo(
    () => data.groups.reduce((sum, g) => sum + g.totalChildren, 0),
    [data],
  );

  return (
    <div className="space-y-6">
      {/* Tarjetas de resumen */}
      <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
        <StatCard
          title="Tasa Promedio"
          value={`${Math.round(data.overall.averageAttendanceRate)}%`}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
              <polyline points="22 4 12 14.01 9 11.01" />
            </svg>
          }
          color="bg-green-50 text-green-600"
        />
        <StatCard
          title="Total Dias"
          value={data.overall.totalDays}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
              <line x1="16" y1="2" x2="16" y2="6" />
              <line x1="8" y1="2" x2="8" y2="6" />
              <line x1="3" y1="10" x2="21" y2="10" />
            </svg>
          }
          color="bg-blue-50 text-blue-600"
        />
        <StatCard
          title="Grupos"
          value={data.groups.length}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
              <circle cx="9" cy="7" r="4" />
              <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
              <path d="M16 3.13a4 4 0 0 1 0 7.75" />
            </svg>
          }
          color="bg-purple-50 text-purple-600"
        />
        <StatCard
          title="Total Alumnos"
          value={totalChildren}
          icon={
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
              <circle cx="9" cy="7" r="4" />
            </svg>
          }
          color="bg-amber-50 text-amber-600"
        />
      </div>

      {/* Grafica de barras diaria */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Desglose Diario de Asistencia
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
                />
                <Tooltip
                  contentStyle={{
                    borderRadius: '8px',
                    border: 'none',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                  }}
                />
                <Legend />
                <Bar
                  dataKey="presentes"
                  name="Presentes"
                  fill="#4ECDC4"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={32}
                />
                <Bar
                  dataKey="ausentes"
                  name="Ausentes"
                  fill="#FF6B6B"
                  radius={[4, 4, 0, 0]}
                  maxBarSize={32}
                />
              </BarChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>

      {/* Tabla de grupos */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Resumen por Grupo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-muted">
                  <th className="pb-3 pr-4 font-medium">Grupo</th>
                  <th className="pb-3 pr-4 font-medium">Alumnos</th>
                  <th className="pb-3 font-medium">Tasa Promedio</th>
                </tr>
              </thead>
              <tbody>
                {data.groups.map((group) => (
                  <tr key={group.groupId} className="border-b last:border-0">
                    <td className="py-3 pr-4 font-medium">{group.groupName}</td>
                    <td className="py-3 pr-4">{group.totalChildren}</td>
                    <td className="py-3">
                      <span
                        className={
                          group.averageAttendanceRate >= 80
                            ? 'text-green-600 font-semibold'
                            : group.averageAttendanceRate >= 60
                              ? 'text-amber-600 font-semibold'
                              : 'text-red-600 font-semibold'
                        }
                      >
                        {Math.round(group.averageAttendanceRate)}%
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
