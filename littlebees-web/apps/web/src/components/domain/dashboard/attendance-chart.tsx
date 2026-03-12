'use client';

import { useMemo } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { useAttendanceReport } from '@/hooks/use-reports';

function getLast7DaysRange(): { from: string; to: string } {
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - 6);
  return {
    from: from.toISOString().split('T')[0],
    to: to.toISOString().split('T')[0],
  };
}

const DAY_NAMES: Record<number, string> = {
  0: 'Dom',
  1: 'Lun',
  2: 'Mar',
  3: 'Mie',
  4: 'Jue',
  5: 'Vie',
  6: 'Sab',
};

export function AttendanceChart() {
  const range = useMemo(() => getLast7DaysRange(), []);
  const { data: report, isLoading } = useAttendanceReport(range);

  const chartData = useMemo(() => {
    if (!report?.groups?.length) return [];

    // Aggregate daily breakdown across all groups
    const dailyMap = new Map<string, { present: number; total: number }>();

    for (const group of report.groups) {
      for (const day of group.dailyBreakdown) {
        const existing = dailyMap.get(day.date) ?? { present: 0, total: 0 };
        existing.present += day.present;
        existing.total += day.present + day.absent;
        dailyMap.set(day.date, existing);
      }
    }

    return Array.from(dailyMap.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, { present, total }]) => {
        const d = new Date(date + 'T12:00:00');
        return {
          day: DAY_NAMES[d.getDay()] ?? date,
          rate: total > 0 ? Math.round((present / total) * 100) : 0,
        };
      });
  }, [report]);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Tendencia de Asistencia
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Skeleton className="h-64 w-full" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500">
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Tendencia de Asistencia
        </CardTitle>
      </CardHeader>
      <CardContent>
        {chartData.length === 0 ? (
          <div className="flex h-64 items-center justify-center text-muted">
            Sin datos
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={256}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis
                dataKey="day"
                tick={{ fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                domain={[0, 100]}
                tick={{ fontSize: 12 }}
                axisLine={false}
                tickLine={false}
                tickFormatter={(v) => `${v}%`}
              />
              <Tooltip
                formatter={(value: number) => [`${value}%`, 'Asistencia']}
                contentStyle={{
                  borderRadius: '8px',
                  border: 'none',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                }}
              />
              <Bar
                dataKey="rate"
                fill="#4ECDC4"
                radius={[4, 4, 0, 0]}
                maxBarSize={40}
                isAnimationActive={true}
                animationDuration={800}
                animationBegin={0}
              />
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
