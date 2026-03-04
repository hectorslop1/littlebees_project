'use client';

import { Search, Plus } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from '@/components/ui/select';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type { GroupResponse, PaginatedResponse } from '@kinderspace/shared-types';

interface ChildrenFiltersProps {
  search: string;
  onSearchChange: (value: string) => void;
  groupId: string;
  onGroupIdChange: (value: string) => void;
  onAddClick: () => void;
}

export function ChildrenFilters({
  search,
  onSearchChange,
  groupId,
  onGroupIdChange,
  onAddClick,
}: ChildrenFiltersProps) {
  const { data: groupsData } = useQuery({
    queryKey: ['groups'],
    queryFn: () => api.get<PaginatedResponse<GroupResponse>>('/groups'),
  });

  const groups = groupsData?.data ?? [];

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="w-full sm:w-64">
        <Input
          placeholder="Buscar por nombre..."
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          icon={<Search className="h-4 w-4" />}
        />
      </div>

      <div className="w-full sm:w-48">
        <Select value={groupId} onValueChange={onGroupIdChange}>
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

      <div className="ml-auto">
        <Button onClick={onAddClick}>
          <Plus className="h-4 w-4" />
          Agregar Nino
        </Button>
      </div>
    </div>
  );
}
