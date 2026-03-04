'use client';

import { useState, useMemo } from 'react';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { LogType } from '@kinderspace/shared-types';
import { Skeleton } from '@/components/ui/skeleton';
import { useDailyLogs } from '@/hooks/use-daily-logs';
import { LogFilters } from '@/components/domain/logs/log-filters';
import { LogTimeline } from '@/components/domain/logs/log-timeline';
import { LogFormDialog } from '@/components/domain/logs/log-form-dialog';

function getTodayISO(): string {
  return new Date().toISOString().split('T')[0];
}

export default function LogsPage() {
  const [date, setDate] = useState(getTodayISO());
  const [childId, setChildId] = useState('all');
  const [type, setType] = useState('all');
  const [showAddDialog, setShowAddDialog] = useState(false);

  const queryParams = useMemo(
    () => ({
      date,
      ...(childId !== 'all' ? { childId } : {}),
    }),
    [date, childId],
  );

  const { data, isLoading } = useDailyLogs(queryParams);

  const filteredEntries = useMemo(() => {
    const entries = data?.data ?? [];
    if (type === 'all') return entries;
    return entries.filter((entry) => entry.type === (type as LogType));
  }, [data, type]);

  const formattedDate = useMemo(() => {
    try {
      const [year, month, day] = date.split('-').map(Number);
      return format(new Date(year, month - 1, day), "EEEE d 'de' MMMM, yyyy", {
        locale: es,
      });
    } catch {
      return date;
    }
  }, [date]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold font-heading">Bitácora</h1>
        <p className="mt-1 text-sm capitalize text-muted-foreground">
          {formattedDate}
        </p>
      </div>

      <LogFilters
        date={date}
        onDateChange={setDate}
        childId={childId}
        onChildIdChange={setChildId}
        type={type}
        onTypeChange={setType}
        onAddClick={() => setShowAddDialog(true)}
      />

      {isLoading ? (
        <div className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="space-y-3">
              <Skeleton className="h-5 w-40" />
              <Skeleton className="h-24 w-full rounded-2xl" />
              <Skeleton className="h-24 w-full rounded-2xl" />
            </div>
          ))}
        </div>
      ) : (
        <LogTimeline entries={filteredEntries} />
      )}

      <LogFormDialog
        open={showAddDialog}
        onOpenChange={setShowAddDialog}
        date={date}
      />
    </div>
  );
}
