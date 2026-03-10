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
import { useDevelopmentReport } from '@/hooks/use-reports';

const CATEGORY_LABELS: Record<string, string> = {
  motor_fine: 'Motriz Fina',
  motor_gross: 'Motriz Gruesa',
  cognitive: 'Cognitivo',
  language: 'Lenguaje',
  social: 'Social',
  emotional: 'Emocional',
};

function getMonthRange(): { from: string; to: string } {
  const now = new Date();
  const from = new Date(now.getFullYear(), now.getMonth(), 1)
    .toISOString()
    .split('T')[0];
  const to = now.toISOString().split('T')[0];
  return { from, to };
}

export function DevelopmentRadar() {
  const range = useMemo(() => getMonthRange(), []);
  const { data: report, isLoading } = useDevelopmentReport(range);

  const chartData = useMemo(() => {
    if (!report?.children?.length) return [];

    // Average category breakdowns across all children
    const categoryTotals = new Map<
      string,
      { totalPercent: number; count: number }
    >();

    for (const child of report.children) {
      for (const cat of child.categoryBreakdown) {
        const existing = categoryTotals.get(cat.category) ?? {
          totalPercent: 0,
          count: 0,
        };
        existing.totalPercent += cat.percent;
        existing.count += 1;
        categoryTotals.set(cat.category, existing);
      }
    }

    return Array.from(categoryTotals.entries()).map(
      ([category, { totalPercent, count }]) => ({
        category: CATEGORY_LABELS[category] ?? category,
        value: Math.round(totalPercent / count),
        fullMark: 100,
      }),
    );
  }, [report]);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Desarrollo Promedio
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Skeleton className="h-64 w-full" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Desarrollo Promedio
        </CardTitle>
      </CardHeader>
      <CardContent>
        {chartData.length === 0 ? (
          <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">
            Sin evaluaciones de desarrollo este mes
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={256}>
            <BarChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis 
                dataKey="category" 
                tick={{ fontSize: 11 }}
                angle={-15}
                textAnchor="end"
                height={60}
              />
              <YAxis 
                domain={[0, 100]}
                tick={{ fontSize: 10 }}
                tickFormatter={(v) => `${v}%`}
              />
              <Tooltip 
                formatter={(value) => [`${value}%`, 'Progreso']}
                contentStyle={{ fontSize: 12 }}
              />
              <Bar 
                dataKey="value" 
                fill="#4ECDC4" 
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
