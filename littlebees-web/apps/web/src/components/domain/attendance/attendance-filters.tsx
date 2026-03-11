'use client';

import { DatePicker } from '@/components/ui/date-picker';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

interface AttendanceFiltersProps {
  date: string;
  onDateChange: (date: string) => void;
  groupId: string;
  onGroupIdChange: (groupId: string) => void;
}

export function AttendanceFilters({
  date,
  onDateChange,
  groupId,
  onGroupIdChange,
}: AttendanceFiltersProps) {
  return (
    <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
      <div className="w-full sm:w-56">
        <Label>Fecha</Label>
        <DatePicker
          value={date ? new Date(date) : undefined}
          onChange={(date) => {
            if (!date) {
              onDateChange('');
              return;
            }
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            onDateChange(`${year}-${month}-${day}`);
          }}
          placeholder="Selecciona fecha"
          toDate={new Date()}
        />
      </div>

      <div className="w-full sm:w-56">
        <label className="mb-1.5 block text-sm font-medium text-foreground">
          Grupo
        </label>
        <Select value={groupId} onValueChange={onGroupIdChange}>
          <SelectTrigger>
            <SelectValue placeholder="Todos los grupos" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Todos los grupos</SelectItem>
            <SelectItem value="maternal">Maternal</SelectItem>
            <SelectItem value="preescolar-1">Preescolar 1</SelectItem>
            <SelectItem value="preescolar-2">Preescolar 2</SelectItem>
            <SelectItem value="preescolar-3">Preescolar 3</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
}
