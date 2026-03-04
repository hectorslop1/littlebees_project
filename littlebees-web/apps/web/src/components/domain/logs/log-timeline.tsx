'use client';

import { useMemo } from 'react';
import { ClipboardList } from 'lucide-react';
import type { DailyLogEntryResponse } from '@kinderspace/shared-types';
import { EmptyState } from '@/components/ui/empty-state';
import { LogEntryCard } from './log-entry-card';

interface LogTimelineProps {
  entries: DailyLogEntryResponse[];
}

export function LogTimeline({ entries }: LogTimelineProps) {
  const groupedByChild = useMemo(() => {
    const groups: Record<string, DailyLogEntryResponse[]> = {};

    for (const entry of entries) {
      const name = entry.childName;
      if (!groups[name]) {
        groups[name] = [];
      }
      groups[name].push(entry);
    }

    // Sort entries within each group by time
    for (const name of Object.keys(groups)) {
      groups[name].sort((a, b) => a.time.localeCompare(b.time));
    }

    return groups;
  }, [entries]);

  if (entries.length === 0) {
    return (
      <EmptyState
        icon={<ClipboardList />}
        title="No hay registros para esta fecha"
        description="Agrega un nuevo registro usando el botón de arriba."
      />
    );
  }

  const childNames = Object.keys(groupedByChild).sort((a, b) =>
    a.localeCompare(b, 'es'),
  );

  return (
    <div className="space-y-6">
      {childNames.map((childName) => (
        <div key={childName}>
          <h3 className="mb-3 text-base font-semibold text-foreground">
            {childName}
          </h3>
          <div className="space-y-2">
            {groupedByChild[childName].map((entry) => (
              <LogEntryCard key={entry.id} entry={entry} />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
