'use client';

import { useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { CircularProgress } from '@/components/ui/circular-progress';
import { Skeleton } from '@/components/ui/skeleton';
import { useGroups } from '@/hooks/use-groups';

export function GroupsOverview() {
  const { data: groupsResponse, isLoading } = useGroups();

  const groupsWithCapacity = useMemo(() => {
    // La respuesta de la API puede ser un array directamente o un objeto con data
    const groups = Array.isArray(groupsResponse) 
      ? groupsResponse 
      : (groupsResponse as any)?.data || [];
    
    if (!groups || groups.length === 0) return [];
    
    return groups.map((group: any) => ({
      id: group.id,
      name: group.friendlyName || group.name,
      subgroup: group.subgroup,
      color: group.color || '#4ECDC4',
      enrolled: group._count?.children || 0,
      capacity: group.capacity,
      percentage: group.capacity > 0 
        ? Math.round((group._count?.children || 0) / group.capacity * 100)
        : 0,
    }));
  }, [groupsResponse]);

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Grupos
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <Skeleton key={i} className="h-20 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="animate-in fade-in slide-in-from-bottom-4 duration-500 delay-300 flex flex-col">
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Grupos
        </CardTitle>
      </CardHeader>
      <CardContent className="flex-1">
        {groupsWithCapacity.length === 0 ? (
          <div className="flex h-32 items-center justify-center text-sm text-muted-foreground">
            No hay grupos registrados
          </div>
        ) : (
          <div className="space-y-2">
            {groupsWithCapacity.map((group: any) => (
              <div
                key={group.id}
                className="flex items-center justify-between rounded-lg border border-gray-100 bg-white p-3 shadow-sm transition-all hover:shadow-md"
              >
                <div className="flex flex-1 items-center gap-3">
                  <div
                    className="h-3 w-3 rounded-full flex-shrink-0"
                    style={{ backgroundColor: group.color }}
                  />
                  <div className="flex-1 min-w-0">
                    <span className="font-medium text-gray-800 block">
                      {group.name}
                      {group.subgroup && (
                        <span className="ml-1 text-xs font-normal text-gray-500">
                          Grupo {group.subgroup}
                        </span>
                      )}
                    </span>
                    <span className="text-xs text-gray-500">
                      {group.enrolled}/{group.capacity} niños
                    </span>
                  </div>
                </div>
                <div className="flex-shrink-0">
                  <CircularProgress
                    value={group.percentage}
                    size={50}
                    strokeWidth={5}
                    className={
                      group.percentage >= 100
                        ? 'text-yellow-500'
                        : 'text-green-500'
                    }
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
