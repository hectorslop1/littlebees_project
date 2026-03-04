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
import { Progress } from '@/components/ui/progress';
import type { DevelopmentReportResponse } from '@kinderspace/shared-types';

const CATEGORY_LABELS: Record<string, string> = {
  motor_fine: 'Motriz Fina',
  motor_gross: 'Motriz Gruesa',
  cognitive: 'Cognitivo',
  language: 'Lenguaje',
  social: 'Social',
  emotional: 'Emocional',
};

interface DevelopmentReportProps {
  data: DevelopmentReportResponse;
}

export function DevelopmentReport({ data }: DevelopmentReportProps) {
  const radarData = useMemo(() => {
    if (!data.children.length) return [];

    const categoryTotals = new Map<
      string,
      { totalPercent: number; count: number }
    >();

    for (const child of data.children) {
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
        valor: Math.round(totalPercent / count),
        fullMark: 100,
      }),
    );
  }, [data]);

  const overallAverage = useMemo(() => {
    if (!data.children.length) return 0;
    const sum = data.children.reduce(
      (acc, child) => acc + child.overallProgress,
      0,
    );
    return Math.round(sum / data.children.length);
  }, [data]);

  return (
    <div className="space-y-6">
      {/* Resumen general */}
      <div className="grid grid-cols-2 gap-4 md:grid-cols-3">
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted">Progreso Promedio General</p>
            <p className="mt-1 text-3xl font-bold text-foreground">
              {overallAverage}%
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted">Alumnos Evaluados</p>
            <p className="mt-1 text-3xl font-bold text-foreground">
              {data.children.length}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted">Categorias</p>
            <p className="mt-1 text-3xl font-bold text-foreground">
              {radarData.length}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Grafica de radar */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Desarrollo Promedio por Categoria
          </CardTitle>
        </CardHeader>
        <CardContent>
          {radarData.length === 0 ? (
            <div className="flex h-64 items-center justify-center text-muted">
              Sin datos para el periodo seleccionado
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={320}>
              <RadarChart cx="50%" cy="50%" outerRadius="70%" data={radarData}>
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
                  dataKey="valor"
                  stroke="#4ECDC4"
                  fill="#4ECDC4"
                  fillOpacity={0.3}
                />
              </RadarChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>

      {/* Tabla de alumnos */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Progreso por Alumno
          </CardTitle>
        </CardHeader>
        <CardContent>
          {data.children.length === 0 ? (
            <div className="flex h-32 items-center justify-center text-muted">
              Sin alumnos evaluados en este periodo
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b text-left text-muted">
                    <th className="pb-3 pr-4 font-medium">Alumno</th>
                    <th className="pb-3 pr-4 font-medium">Edad (meses)</th>
                    <th className="pb-3 pr-4 font-medium">Progreso General</th>
                    <th className="pb-3 font-medium">Categorias</th>
                  </tr>
                </thead>
                <tbody>
                  {data.children.map((child) => (
                    <tr key={child.childId} className="border-b last:border-0">
                      <td className="py-3 pr-4 font-medium">
                        {child.childName}
                      </td>
                      <td className="py-3 pr-4">{child.ageMonths}</td>
                      <td className="py-3 pr-4">
                        <div className="flex items-center gap-2">
                          <Progress
                            value={child.overallProgress}
                            className="h-2 w-20"
                          />
                          <span className="text-xs font-medium">
                            {Math.round(child.overallProgress)}%
                          </span>
                        </div>
                      </td>
                      <td className="py-3">
                        <div className="flex flex-wrap gap-1">
                          {child.categoryBreakdown.map((cat) => (
                            <span
                              key={cat.category}
                              className="inline-flex items-center rounded-full bg-primary-50 px-2 py-0.5 text-xs text-primary"
                              title={`${CATEGORY_LABELS[cat.category] ?? cat.category}: ${cat.achieved}/${cat.total}`}
                            >
                              {CATEGORY_LABELS[cat.category] ?? cat.category}:{' '}
                              {Math.round(cat.percent)}%
                            </span>
                          ))}
                        </div>
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
