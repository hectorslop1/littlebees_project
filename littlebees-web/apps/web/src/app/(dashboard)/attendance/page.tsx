'use client';

import { useState, useMemo, useCallback } from 'react';
import { useAttendance, useCheckIn, useCheckOut } from '@/hooks/use-attendance';
import { AttendanceFilters } from '@/components/domain/attendance/attendance-filters';
import { AttendanceStats } from '@/components/domain/attendance/attendance-stats';
import { AttendanceTable } from '@/components/domain/attendance/attendance-table';
import { Skeleton } from '@/components/ui/skeleton';
import { CheckInMethod } from '@kinderspace/shared-types';

function getTodayISO(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export default function AttendancePage() {
  const [date, setDate] = useState<string>(getTodayISO);
  const [groupId, setGroupId] = useState<string>('all');

  const { data, isLoading } = useAttendance(date);
  const checkInMutation = useCheckIn();
  const checkOutMutation = useCheckOut();

  const records = useMemo(() => data?.data ?? [], [data]);

  const handleCheckIn = useCallback(
    (childId: string) => {
      checkInMutation.mutate({
        childId,
        method: CheckInMethod.MANUAL,
      });
    },
    [checkInMutation],
  );

  const handleCheckOut = useCallback(
    (childId: string) => {
      checkOutMutation.mutate({
        childId,
        method: CheckInMethod.MANUAL,
      });
    },
    [checkOutMutation],
  );

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold font-heading">Asistencia</h1>

      <AttendanceFilters
        date={date}
        onDateChange={setDate}
        groupId={groupId}
        onGroupIdChange={setGroupId}
      />

      {isLoading ? (
        <div className="space-y-6">
          {/* Stats skeleton */}
          <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-5">
            {Array.from({ length: 5 }).map((_, i) => (
              <Skeleton key={i} className="h-28 w-full rounded-2xl" />
            ))}
          </div>
          {/* Progress skeleton */}
          <Skeleton className="h-16 w-full rounded-xl" />
          {/* Table skeleton */}
          <Skeleton className="h-64 w-full rounded-xl" />
        </div>
      ) : records.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="rounded-full bg-muted p-3 mb-4">
            <svg className="h-6 w-6 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-semibold mb-2">No hay registros de asistencia</h3>
          <p className="text-sm text-muted-foreground max-w-sm">
            No se encontraron registros para la fecha seleccionada ({new Date(date).toLocaleDateString('es-MX', { day: 'numeric', month: 'long', year: 'numeric' })}).
            Intenta seleccionar otra fecha o registra la asistencia de hoy.
          </p>
        </div>
      ) : (
        <>
          <AttendanceStats records={records} />
          <AttendanceTable
            records={records}
            onCheckIn={handleCheckIn}
            onCheckOut={handleCheckOut}
            isLoading={
              checkInMutation.isPending || checkOutMutation.isPending
            }
          />
        </>
      )}
    </div>
  );
}
