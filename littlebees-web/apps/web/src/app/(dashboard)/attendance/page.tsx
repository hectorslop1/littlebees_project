'use client';

import { useState, useMemo, useCallback } from 'react';
import { useAttendance, useCheckIn, useCheckOut } from '@/hooks/use-attendance';
import { AttendanceFilters } from '@/components/domain/attendance/attendance-filters';
import { AttendanceStats } from '@/components/domain/attendance/attendance-stats';
import { AttendanceTable } from '@/components/domain/attendance/attendance-table';
import { Skeleton } from '@/components/ui/skeleton';
import { CheckInMethod } from '@kinderspace/shared-types';

function getTodayISO(): string {
  return new Date().toISOString().split('T')[0];
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
