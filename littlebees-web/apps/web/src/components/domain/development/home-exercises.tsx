'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { Play, Brain, Hand, Activity, MessageSquare, Users, Heart } from 'lucide-react';
import { useExercises } from '@/hooks/use-exercises';
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

export function HomeExercises() {
  const { data, isLoading } = useExercises({ limit: 6 });

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Ejercicios en Casa
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <Skeleton key={i} className="h-48 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  const exercises = data?.exercises || [];

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-200">
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Ejercicios en Casa
        </CardTitle>
      </CardHeader>
      <CardContent>
        {exercises.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            No hay ejercicios disponibles
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {exercises.map((exercise) => {
              const config = CATEGORY_CONFIG[exercise.category];
              const Icon = config?.icon || Brain;

              return (
                <div
                  key={exercise.id}
                  className="rounded-xl border border-gray-200 p-4 transition-shadow hover:shadow-lg"
                >
                  <div className="mb-3 flex items-start justify-between">
                    <div className="flex items-center gap-2">
                      <Icon className={`h-5 w-5 ${config?.color || 'text-gray-600'}`} />
                      <Badge variant="default" size="sm">
                        {config?.label || exercise.category}
                      </Badge>
                    </div>
                    <Badge
                      variant={(exercise as any).completed ? 'success' : 'warning'}
                      size="sm"
                    >
                      {(exercise as any).completed ? 'Completado' : 'Pendiente'}
                    </Badge>
                  </div>
                  <h4 className="mb-2 font-semibold text-gray-800">
                    {exercise.title}
                  </h4>
                  <p className="mb-3 line-clamp-2 text-sm text-gray-600">
                    {exercise.description}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-gray-500">
                      {exercise.duration} min | {exercise.ageRangeMin}-
                      {exercise.ageRangeMax} meses
                    </span>
                    <Button variant="ghost" size="sm">
                      <Play className="mr-1 h-3 w-3" />
                      Ver
                    </Button>
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
