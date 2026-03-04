'use client';

import { Plus } from 'lucide-react';
import { LogType } from '@kinderspace/shared-types';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useChildren } from '@/hooks/use-children';

const LOG_TYPE_LABELS: Record<LogType, string> = {
  [LogType.MEAL]: 'Comida',
  [LogType.NAP]: 'Siesta',
  [LogType.ACTIVITY]: 'Actividad',
  [LogType.DIAPER]: 'Pañal',
  [LogType.MEDICATION]: 'Medicamento',
  [LogType.OBSERVATION]: 'Observación',
  [LogType.INCIDENT]: 'Incidente',
};

interface LogFiltersProps {
  date: string;
  onDateChange: (date: string) => void;
  childId: string;
  onChildIdChange: (childId: string) => void;
  type: string;
  onTypeChange: (type: string) => void;
  onAddClick: () => void;
}

export function LogFilters({
  date,
  onDateChange,
  childId,
  onChildIdChange,
  type,
  onTypeChange,
  onAddClick,
}: LogFiltersProps) {
  const { data: childrenData } = useChildren();

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:gap-4">
      <div className="w-full sm:w-44">
        <Input
          label="Fecha"
          type="date"
          value={date}
          onChange={(e) => onDateChange(e.target.value)}
        />
      </div>

      <div className="w-full sm:w-52">
        <label className="mb-1.5 block text-sm font-medium text-foreground">
          Niño/a
        </label>
        <Select value={childId} onValueChange={onChildIdChange}>
          <SelectTrigger>
            <SelectValue placeholder="Todos los niños" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Todos los niños</SelectItem>
            {childrenData?.data?.map((child) => (
              <SelectItem key={child.id} value={child.id}>
                {child.firstName} {child.lastName}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="w-full sm:w-48">
        <label className="mb-1.5 block text-sm font-medium text-foreground">
          Tipo
        </label>
        <Select value={type} onValueChange={onTypeChange}>
          <SelectTrigger>
            <SelectValue placeholder="Todos los tipos" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Todos los tipos</SelectItem>
            {Object.entries(LOG_TYPE_LABELS).map(([value, label]) => (
              <SelectItem key={value} value={value}>
                {label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Button onClick={onAddClick} className="shrink-0">
        <Plus className="h-4 w-4" />
        Agregar Registro
      </Button>
    </div>
  );
}
