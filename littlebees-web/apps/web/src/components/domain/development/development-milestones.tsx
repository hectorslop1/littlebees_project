'use client';

import { useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useDevelopmentReport } from '@/hooks/use-reports';
import { Brain, Hand, Activity, MessageSquare, Users, Heart } from 'lucide-react';
import type { DevelopmentCategory } from '@kinderspace/shared-types';

const CATEGORY_CONFIG: Record<
  DevelopmentCategory,
  { icon: React.ElementType; label: string; color: string }
> = {
  motor_fine: { icon: Hand, label: 'Motor Fino', color: 'text-blue-600' },
  motor_gross: { icon: Activity, label: 'Motor Grueso', color: 'text-green-600' },
  cognitive: { icon: Brain, label: 'Cognitivo', color: 'text-purple-600' },
  language: { icon: MessageSquare, label: 'Lenguaje', color: 'text-orange-600' },
  social: { icon: Users, label: 'Social', color: 'text-pink-600' },
  emotional: { icon: Heart, label: 'Emocional', color: 'text-yellow-600' },
};

function getMonthRange(): { from: string; to: string } {
  const now = new Date();
  const from = new Date(now.getFullYear(), now.getMonth(), 1)
    .toISOString()
    .split('T')[0];
  const to = now.toISOString().split('T')[0];
  return { from, to };
}

export function DevelopmentMilestones() {
  const range = useMemo(() => getMonthRange(), []);
  const { data: report, isLoading } = useDevelopmentReport(range);

  const milestones = useMemo(() => {
    if (!report?.children?.length) return [];

    const allMilestones: Array<{
      id: string;
      childName: string;
      milestone: string;
      category: DevelopmentCategory;
      status: 'achieved' | 'in_progress' | 'not_achieved';
      date: string;
    }> = [];

    for (const child of report.children) {
      for (const cat of child.categoryBreakdown) {
        // Simular milestones basados en el progreso
        const percentage = cat.percent || 0;
        let status: 'achieved' | 'in_progress' | 'not_achieved';
        
        if (percentage >= 80) {
          status = 'achieved';
        } else if (percentage >= 40) {
          status = 'in_progress';
        } else {
          status = 'not_achieved';
        }

        allMilestones.push({
          id: `${child.childId}-${cat.category}`,
          childName: child.childName,
          milestone: `Progreso en ${CATEGORY_CONFIG[cat.category as DevelopmentCategory]?.label || cat.category}`,
          category: cat.category as DevelopmentCategory,
          status,
          date: new Date().toISOString(),
        });
      }
    }

    return allMilestones.slice(0, 10); // Mostrar los primeros 10
  }, [report]);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'achieved':
        return { variant: 'success' as const, label: 'Logrado' };
      case 'in_progress':
        return { variant: 'warning' as const, label: 'En Progreso' };
      default:
        return { variant: 'danger' as const, label: 'No Logrado' };
    }
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Hitos de Desarrollo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <Skeleton key={i} className="h-16 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-150">
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold font-heading">
          Hitos de Desarrollo
        </CardTitle>
        <Select defaultValue="all">
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filtrar categoría" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Todas las categorías</SelectItem>
            {Object.entries(CATEGORY_CONFIG).map(([key, val]) => (
              <SelectItem key={key} value={key}>
                {val.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </CardHeader>
      <CardContent>
        {milestones.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            No hay hitos de desarrollo registrados
          </div>
        ) : (
          <div className="space-y-4">
            {milestones.map((milestone) => {
              const config = CATEGORY_CONFIG[milestone.category];
              const Icon = config?.icon || Brain;
              const statusBadge = getStatusBadge(milestone.status);

              return (
                <div
                  key={milestone.id}
                  className="flex items-center justify-between rounded-xl bg-gray-50 p-4 transition-colors hover:bg-gray-100"
                >
                  <div className="flex items-center gap-4">
                    <div className="rounded-lg bg-white p-2">
                      <Icon className={`h-5 w-5 ${config?.color || 'text-gray-600'}`} />
                    </div>
                    <div>
                      <h4 className="font-medium text-gray-800">
                        {milestone.milestone}
                      </h4>
                      <p className="text-sm text-gray-500">
                        {milestone.childName} • {config?.label || milestone.category}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <span className="text-sm text-gray-500">
                      {new Date(milestone.date).toLocaleDateString('es-MX')}
                    </span>
                    <Badge variant={statusBadge.variant}>
                      {statusBadge.label}
                    </Badge>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
