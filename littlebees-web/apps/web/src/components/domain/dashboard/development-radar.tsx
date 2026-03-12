'use client';

import { useMemo } from 'react';
import {
  RadarChart,
  Radar,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
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
        // Skip if percent is NaN or invalid
        if (!Number.isFinite(cat.percent)) continue;
        
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
        value: count > 0 ? Math.round(totalPercent / count) : 0,
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
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-100">
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
        ) : chartData.length < 3 ? (
          <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">
            Se necesitan al menos 3 áreas de desarrollo con datos válidos
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={300}>
            <RadarChart data={chartData} cx="50%" cy="50%" outerRadius="70%">
              <PolarGrid stroke="#e5e7eb" strokeDasharray="3 3" />
              <PolarAngleAxis 
                dataKey="category" 
                tick={{ fontSize: 11, fill: '#6b7280' }}
              />
              <PolarRadiusAxis 
                angle={90}
                domain={[0, 100]}
                tick={{ fontSize: 10, fill: '#9ca3af' }}
                tickFormatter={(v) => `${v}%`}
                tickCount={5}
              />
              <Tooltip 
                formatter={(value) => [`${value}%`, 'Progreso']}
                contentStyle={{ 
                  fontSize: 12,
                  borderRadius: '8px',
                  border: 'none',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                }}
              />
              <Radar 
                name="Desarrollo"
                dataKey="value" 
                stroke="#4ECDC4" 
                fill="#4ECDC4" 
                fillOpacity={0.6}
                strokeWidth={2}
                isAnimationActive={true}
                animationDuration={800}
                animationBegin={0}
              />
            </RadarChart>
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  );
}
