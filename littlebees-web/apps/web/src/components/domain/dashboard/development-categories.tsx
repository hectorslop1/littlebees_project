'use client';

import { useMemo } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { CircularProgress } from '@/components/ui/circular-progress';
import { useDevelopmentReport } from '@/hooks/use-reports';
import { 
  Hand, 
  Activity, 
  Brain, 
  MessageSquare, 
  Users, 
  Heart 
} from 'lucide-react';

const CATEGORY_CONFIG: Record<string, { 
  label: string; 
  icon: React.ElementType;
  color: string;
  bgColor: string;
}> = {
  motor_fine: {
    label: 'Motriz Fina',
    icon: Hand,
    color: 'text-blue-600',
    bgColor: 'bg-blue-50',
  },
  motor_gross: {
    label: 'Motriz Gruesa',
    icon: Activity,
    color: 'text-green-600',
    bgColor: 'bg-green-50',
  },
  cognitive: {
    label: 'Cognitivo',
    icon: Brain,
    color: 'text-purple-600',
    bgColor: 'bg-purple-50',
  },
  language: {
    label: 'Lenguaje',
    icon: MessageSquare,
    color: 'text-orange-600',
    bgColor: 'bg-orange-50',
  },
  social: {
    label: 'Social',
    icon: Users,
    color: 'text-pink-600',
    bgColor: 'bg-pink-50',
  },
  emotional: {
    label: 'Emocional',
    icon: Heart,
    color: 'text-yellow-600',
    bgColor: 'bg-yellow-50',
  },
};

function getMonthRange(): { from: string; to: string } {
  const now = new Date();
  const from = new Date(now.getFullYear(), now.getMonth(), 1)
    .toISOString()
    .split('T')[0];
  const to = now.toISOString().split('T')[0];
  return { from, to };
}

export function DevelopmentCategories() {
  const range = useMemo(() => getMonthRange(), []);
  const { data: report, isLoading } = useDevelopmentReport(range);

  const categoryData = useMemo(() => {
    if (!report?.children?.length) return [];

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
        category,
        value: count > 0 ? Math.round(totalPercent / count) : 0,
        config: CATEGORY_CONFIG[category],
      }),
    );
  }, [report]);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Áreas de Desarrollo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-32 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-150">
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Áreas de Desarrollo
        </CardTitle>
      </CardHeader>
      <CardContent>
        {categoryData.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            Sin evaluaciones de desarrollo este mes
          </div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {categoryData.map(({ category, value, config }, index) => {
              if (!config) return null;
              const Icon = config.icon;
              
              return (
                <div
                  key={category}
                  className="flex flex-col items-center justify-center p-4 rounded-lg border bg-card hover:shadow-md transition-all duration-200 hover:scale-105 animate-in fade-in zoom-in-95"
                  style={{ animationDelay: `${index * 100}ms` }}
                >
                  <div className={`p-3 rounded-full ${config.bgColor} mb-3`}>
                    <Icon className={`w-6 h-6 ${config.color}`} />
                  </div>
                  <CircularProgress 
                    value={value} 
                    size={80} 
                    strokeWidth={6}
                    className="mb-2"
                  />
                  <p className="text-sm font-medium text-center mt-2">
                    {config.label}
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
