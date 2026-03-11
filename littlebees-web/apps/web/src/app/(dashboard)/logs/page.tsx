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
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
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
      ) : filteredEntries.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="rounded-full bg-muted p-3 mb-4">
            <svg className="h-6 w-6 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-semibold mb-2">No hay registros en la bitácora</h3>
          <p className="text-sm text-muted-foreground max-w-sm">
            No se encontraron entradas para la fecha seleccionada ({formattedDate}).
            Intenta seleccionar otra fecha o agrega una nueva entrada.
          </p>
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
