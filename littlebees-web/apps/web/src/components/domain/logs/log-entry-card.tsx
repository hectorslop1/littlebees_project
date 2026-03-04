import {
  UtensilsCrossed,
  Moon,
  Palette,
  Baby,
  Pill,
  Eye,
  AlertTriangle,
} from 'lucide-react';
import type { DailyLogEntryResponse } from '@kinderspace/shared-types';
import { LogType } from '@kinderspace/shared-types';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

const LOG_TYPE_CONFIG: Record<
  LogType,
  {
    label: string;
    icon: React.ComponentType<{ className?: string }>;
    borderColor: string;
    iconBg: string;
    badgeVariant: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'secondary';
  }
> = {
  [LogType.MEAL]: {
    label: 'Comida',
    icon: UtensilsCrossed,
    borderColor: 'border-l-green-400',
    iconBg: 'bg-green-50 text-green-600',
    badgeVariant: 'success',
  },
  [LogType.NAP]: {
    label: 'Siesta',
    icon: Moon,
    borderColor: 'border-l-purple-400',
    iconBg: 'bg-purple-50 text-purple-600',
    badgeVariant: 'default',
  },
  [LogType.ACTIVITY]: {
    label: 'Actividad',
    icon: Palette,
    borderColor: 'border-l-blue-400',
    iconBg: 'bg-blue-50 text-blue-600',
    badgeVariant: 'info',
  },
  [LogType.DIAPER]: {
    label: 'Pañal',
    icon: Baby,
    borderColor: 'border-l-amber-400',
    iconBg: 'bg-amber-50 text-amber-600',
    badgeVariant: 'warning',
  },
  [LogType.MEDICATION]: {
    label: 'Medicamento',
    icon: Pill,
    borderColor: 'border-l-red-400',
    iconBg: 'bg-red-50 text-red-600',
    badgeVariant: 'danger',
  },
  [LogType.OBSERVATION]: {
    label: 'Observación',
    icon: Eye,
    borderColor: 'border-l-gray-400',
    iconBg: 'bg-gray-50 text-gray-600',
    badgeVariant: 'secondary',
  },
  [LogType.INCIDENT]: {
    label: 'Incidente',
    icon: AlertTriangle,
    borderColor: 'border-l-orange-400',
    iconBg: 'bg-orange-50 text-orange-600',
    badgeVariant: 'warning',
  },
};

interface LogEntryCardProps {
  entry: DailyLogEntryResponse;
}

export function LogEntryCard({ entry }: LogEntryCardProps) {
  const config = LOG_TYPE_CONFIG[entry.type];
  const Icon = config.icon;

  return (
    <Card className={`border-l-4 ${config.borderColor}`}>
      <CardContent className="flex items-start gap-3 p-4">
        <div
          className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${config.iconBg}`}
        >
          <Icon className="h-4 w-4" />
        </div>

        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <Badge variant={config.badgeVariant} size="sm">
              {config.label}
            </Badge>
            <span className="text-xs text-muted-foreground">{entry.time}</span>
          </div>

          <p className="mt-1 text-sm font-medium text-foreground">
            {entry.title}
          </p>

          {entry.description && (
            <p className="mt-0.5 text-sm text-muted-foreground">
              {entry.description}
            </p>
          )}

          <p className="mt-1.5 text-xs text-muted-foreground">
            Registrado por {entry.recordedByName}
          </p>
        </div>
      </CardContent>
    </Card>
  );
}
