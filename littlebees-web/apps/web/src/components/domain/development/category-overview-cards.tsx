'use client';

import {
  Hand,
  PersonStanding,
  Brain,
  MessageSquare,
  Users,
  Heart,
} from 'lucide-react';
import { DevelopmentCategory } from '@kinderspace/shared-types';
import type { CategorySummary } from '@kinderspace/shared-types';
import { Card, CardContent } from '@/components/ui/card';
import { CircularProgress } from '@/components/ui/circular-progress';

const CATEGORY_CONFIG: Record<
  DevelopmentCategory,
  {
    label: string;
    icon: React.ComponentType<{ className?: string }>;
    iconBg: string;
  }
> = {
  [DevelopmentCategory.MOTOR_FINE]: {
    label: 'Motriz Fina',
    icon: Hand,
    iconBg: 'bg-violet-50 text-violet-600',
  },
  [DevelopmentCategory.MOTOR_GROSS]: {
    label: 'Motriz Gruesa',
    icon: PersonStanding,
    iconBg: 'bg-blue-50 text-blue-600',
  },
  [DevelopmentCategory.COGNITIVE]: {
    label: 'Cognitivo',
    icon: Brain,
    iconBg: 'bg-amber-50 text-amber-600',
  },
  [DevelopmentCategory.LANGUAGE]: {
    label: 'Lenguaje',
    icon: MessageSquare,
    iconBg: 'bg-green-50 text-green-600',
  },
  [DevelopmentCategory.SOCIAL]: {
    label: 'Social',
    icon: Users,
    iconBg: 'bg-pink-50 text-pink-600',
  },
  [DevelopmentCategory.EMOTIONAL]: {
    label: 'Emocional',
    icon: Heart,
    iconBg: 'bg-red-50 text-red-600',
  },
};

interface CategoryOverviewCardsProps {
  categories: CategorySummary[];
}

export function CategoryOverviewCards({
  categories,
}: CategoryOverviewCardsProps) {
  return (
    <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-6">
      {categories.map((cat) => {
        const config = CATEGORY_CONFIG[cat.category];
        if (!config) return null;

        const Icon = config.icon;

        return (
          <Card key={cat.category}>
            <CardContent className="flex flex-col items-center gap-3 p-4">
              <div
                className={`flex h-10 w-10 items-center justify-center rounded-xl ${config.iconBg}`}
              >
                <Icon className="h-5 w-5" />
              </div>

              <CircularProgress
                value={cat.progressPercent}
                size={64}
                strokeWidth={5}
              />

              <div className="text-center">
                <p className="text-sm font-semibold text-foreground">
                  {config.label}
                </p>
                <p className="text-xs text-muted-foreground">
                  {cat.achieved}/{cat.totalMilestones} logrados
                </p>
              </div>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
