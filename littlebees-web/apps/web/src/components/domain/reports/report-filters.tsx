'use client';

import { DatePicker } from '@/components/ui/date-picker';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from '@/components/ui/select';

interface ReportFiltersProps {
  from: string;
  to: string;
  onFromChange: (value: string) => void;
  onToChange: (value: string) => void;
  groupId?: string;
  onGroupIdChange?: (value: string) => void;
  groups?: Array<{ id: string; name: string }>;
}

export function ReportFilters({
  from,
  to,
  onFromChange,
  onToChange,
  groupId,
  onGroupIdChange,
  groups,
}: ReportFiltersProps) {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <div className="w-48">
        <Label>Desde</Label>
        <DatePicker
          value={from ? new Date(from) : undefined}
          onChange={(date) => {
            if (!date) {
              onFromChange('');
              return;
            }
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            onFromChange(`${year}-${month}-${day}`);
          }}
          placeholder="Selecciona fecha inicial"
        />
      </div>

      <div className="w-48">
        <Label>Hasta</Label>
        <DatePicker
          value={to ? new Date(to) : undefined}
          onChange={(date) => {
            if (!date) {
              onToChange('');
              return;
            }
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            onToChange(`${year}-${month}-${day}`);
          }}
          placeholder="Selecciona fecha final"
          toDate={new Date()}
        />
      </div>

      {onGroupIdChange && groups && (
        <div className="w-56">
          <label className="mb-1.5 block text-sm font-medium text-foreground">
            Grupo
          </label>
          <Select value={groupId ?? 'all'} onValueChange={onGroupIdChange}>
            <SelectTrigger>
              <SelectValue placeholder="Todos los grupos" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todos los grupos</SelectItem>
              {groups.map((group) => (
                <SelectItem key={group.id} value={group.id}>
                  {group.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}
    </div>
  );
}
