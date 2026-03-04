'use client';

import { useMemo } from 'react';
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
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
          <div className="flex h-64 items-center justify-center text-muted">
            Sin datos
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={256}>
            <RadarChart cx="50%" cy="50%" outerRadius="70%" data={chartData}>
              <PolarGrid stroke="#e5e7eb" />
              <PolarAngleAxis
                dataKey="category"
                tick={{ fontSize: 11 }}
              />
              <PolarRadiusAxis
                angle={30}
                domain={[0, 100]}
                tick={{ fontSize: 10 }}
                tickFormatter={(v) => `${v}%`}
              />
              <Radar
                name="Promedio"
                dataKey="value"
                stroke="#4ECDC4"
                fill="#4ECDC4"
                fillOpacity={0.3}
              />
            </RadarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
