'use client';

import { useState, useMemo } from 'react';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { LogType } from '@kinderspace/shared-types';
import { Skeleton } from '@/components/ui/skeleton';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useDailyLogs } from '@/hooks/use-daily-logs';
import { useGroups } from '@/hooks/use-groups';
import { LogFilters } from '@/components/domain/logs/log-filters';
import { LogTimeline } from '@/components/domain/logs/log-timeline';
import { LogFormDialog } from '@/components/domain/logs/log-form-dialog';
import { DayScheduleView } from '@/components/domain/activities/day-schedule-view';
import { Calendar, ListChecks } from 'lucide-react';

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
  const [activeTab, setActiveTab] = useState('schedule');
  const [selectedGroupId, setSelectedGroupId] = useState('');

  const queryParams = useMemo(
    () => ({
      date,
      ...(childId !== 'all' ? { childId } : {}),
    }),
    [date, childId],
  );

  const { data, isLoading } = useDailyLogs(queryParams);
  const { data: groups, isLoading: isLoadingGroups } = useGroups();

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
        <h1 className="text-2xl font-bold font-heading">Actividades del Día</h1>
        <p className="mt-1 text-sm capitalize text-muted-foreground">
          {formattedDate}
        </p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full max-w-md grid-cols-2">
          <TabsTrigger value="schedule" className="flex items-center gap-2">
            <ListChecks className="h-4 w-4" />
            Programación del Día
          </TabsTrigger>
          <TabsTrigger value="timeline" className="flex items-center gap-2">
            <Calendar className="h-4 w-4" />
            Bitácora
          </TabsTrigger>
        </TabsList>

        <TabsContent value="schedule" className="mt-6 space-y-4">
          <div className="flex items-center gap-4">
            <label htmlFor="group-select" className="text-sm font-medium">
              Selecciona un grupo:
            </label>
            <select
              id="group-select"
              value={selectedGroupId}
              onChange={(e) => setSelectedGroupId(e.target.value)}
              disabled={isLoadingGroups}
              className="rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
            >
              <option value="">
                {isLoadingGroups ? 'Cargando grupos...' : 'Selecciona un grupo...'}
              </option>
              {groups?.map((group) => (
                <option key={group.id} value={group.id}>
                  {group.friendlyName || group.name}
                  {group.subgroup ? ` - Grupo ${group.subgroup}` : ''}
                </option>
              ))}
            </select>
          </div>

          {selectedGroupId ? (
            <DayScheduleView groupId={selectedGroupId} date={date} />
          ) : (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <div className="rounded-full bg-muted p-3 mb-4">
                <ListChecks className="h-8 w-8 text-muted-foreground" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Selecciona un grupo</h3>
              <p className="text-sm text-muted-foreground max-w-sm">
                Selecciona un grupo arriba para ver la programación del día y el estado de las actividades de cada niño.
              </p>
            </div>
          )}
        </TabsContent>

        <TabsContent value="timeline" className="mt-6 space-y-4">
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
        </TabsContent>
      </Tabs>

      <LogFormDialog
        open={showAddDialog}
        onOpenChange={setShowAddDialog}
        date={date}
      />
    </div>
  );
}
