'use client';

import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import {
  Hand,
  PersonStanding,
  Brain,
  MessageSquare,
  Users,
  Heart,
} from 'lucide-react';
import { DevelopmentCategory, MilestoneStatus } from '@kinderspace/shared-types';
import type { DevelopmentRecordResponse } from '@kinderspace/shared-types';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { StatusBadge } from '@/components/ui/status-badge';
import { EmptyState } from '@/components/ui/empty-state';

const CATEGORY_LABELS: Record<DevelopmentCategory, string> = {
  [DevelopmentCategory.MOTOR_FINE]: 'Motriz Fina',
  [DevelopmentCategory.MOTOR_GROSS]: 'Motriz Gruesa',
  [DevelopmentCategory.COGNITIVE]: 'Cognitivo',
  [DevelopmentCategory.LANGUAGE]: 'Lenguaje',
  [DevelopmentCategory.SOCIAL]: 'Social',
  [DevelopmentCategory.EMOTIONAL]: 'Emocional',
};

const CATEGORY_BADGE_VARIANT: Record<
  DevelopmentCategory,
  'default' | 'success' | 'warning' | 'danger' | 'info' | 'secondary'
> = {
  [DevelopmentCategory.MOTOR_FINE]: 'default',
  [DevelopmentCategory.MOTOR_GROSS]: 'info',
  [DevelopmentCategory.COGNITIVE]: 'warning',
  [DevelopmentCategory.LANGUAGE]: 'success',
  [DevelopmentCategory.SOCIAL]: 'secondary',
  [DevelopmentCategory.EMOTIONAL]: 'danger',
};

const STATUS_BORDER_COLOR: Record<MilestoneStatus, string> = {
  [MilestoneStatus.ACHIEVED]: 'border-l-green-400',
  [MilestoneStatus.IN_PROGRESS]: 'border-l-amber-400',
  [MilestoneStatus.NOT_ACHIEVED]: 'border-l-red-400',
};

const STATUS_MAP: Record<MilestoneStatus, 'achieved' | 'in_progress' | 'not_achieved'> = {
  [MilestoneStatus.ACHIEVED]: 'achieved',
  [MilestoneStatus.IN_PROGRESS]: 'in_progress',
  [MilestoneStatus.NOT_ACHIEVED]: 'not_achieved',
};

interface MilestonesListProps {
  records: DevelopmentRecordResponse[];
}

export function MilestonesList({ records }: MilestonesListProps) {
  if (records.length === 0) {
    return (
      <EmptyState
        icon={<Brain />}
        title="Sin evaluaciones"
        description="Aún no hay evaluaciones registradas para este niño. Agrega una nueva evaluación para comenzar."
      />
    );
  }

  return (
    <div className="space-y-3">
      {records.map((record) => {
        const borderColor = STATUS_BORDER_COLOR[record.status] ?? 'border-l-gray-300';
        const statusKey = STATUS_MAP[record.status] ?? 'not_achieved';

        let formattedDate = record.evaluatedAt;
        try {
          formattedDate = format(
            new Date(record.evaluatedAt),
            "d 'de' MMM, yyyy",
            { locale: es },
          );
        } catch {
          // keep raw string if parsing fails
        }

        return (
          <Card key={record.id} className={`border-l-4 ${borderColor}`}>
            <CardContent className="flex items-start gap-3 p-4">
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <p className="text-sm font-semibold text-foreground">
                    {record.milestoneTitle}
                  </p>
                  <Badge
                    variant={CATEGORY_BADGE_VARIANT[record.category] ?? 'default'}
                    size="sm"
                  >
                    {CATEGORY_LABELS[record.category] ?? record.category}
                  </Badge>
                  <StatusBadge status={statusKey} />
                </div>

                {record.observations && (
                  <p className="mt-1 text-sm text-muted-foreground">
                    {record.observations}
                  </p>
                )}

                <div className="mt-2 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
                  <span>Evaluado por {record.evaluatedByName}</span>
                  <span>{formattedDate}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
