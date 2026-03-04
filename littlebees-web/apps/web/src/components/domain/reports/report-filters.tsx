'use client';

import { Input } from '@/components/ui/input';
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
        <Input
          type="date"
          label="Desde"
          value={from}
          onChange={(e) => onFromChange(e.target.value)}
        />
      </div>

      <div className="w-48">
        <Input
          type="date"
          label="Hasta"
          value={to}
          onChange={(e) => onToChange(e.target.value)}
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
