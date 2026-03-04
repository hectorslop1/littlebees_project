'use client';

import { useMemo } from 'react';
import { Users, CheckCircle, XCircle, Clock, Shield } from 'lucide-react';
import { StatCard } from '@/components/ui/stat-card';
import { Progress } from '@/components/ui/progress';
import { AttendanceStatus } from '@kinderspace/shared-types';
import type { AttendanceRecordResponse } from '@kinderspace/shared-types';

interface AttendanceStatsProps {
  records: AttendanceRecordResponse[];
}

export function AttendanceStats({ records }: AttendanceStatsProps) {
  const stats = useMemo(() => {
    const total = records.length;
    const present = records.filter(
      (r) => r.status === AttendanceStatus.PRESENT,
    ).length;
    const absent = records.filter(
      (r) => r.status === AttendanceStatus.ABSENT,
    ).length;
    const late = records.filter(
      (r) => r.status === AttendanceStatus.LATE,
    ).length;
    const excused = records.filter(
      (r) => r.status === AttendanceStatus.EXCUSED,
    ).length;

    const attendanceRate =
      total > 0 ? Math.round(((present + late) / total) * 100) : 0;

    return { total, present, absent, late, excused, attendanceRate };
  }, [records]);

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-5">
        <StatCard
          title="Total"
          value={stats.total}
          icon={<Users className="h-5 w-5" />}
          color="bg-primary-50 text-primary"
        />
        <StatCard
          title="Presentes"
          value={stats.present}
          icon={<CheckCircle className="h-5 w-5" />}
          color="bg-green-50 text-success"
        />
        <StatCard
          title="Ausentes"
          value={stats.absent}
          icon={<XCircle className="h-5 w-5" />}
          color="bg-red-50 text-destructive"
        />
        <StatCard
          title="Tardes"
          value={stats.late}
          icon={<Clock className="h-5 w-5" />}
          color="bg-blue-50 text-info"
        />
        <StatCard
          title="Justificados"
          value={stats.excused}
          icon={<Shield className="h-5 w-5" />}
          color="bg-yellow-50 text-warning"
        />
      </div>

      <div className="rounded-xl bg-card p-4 shadow-card">
        <div className="mb-2 flex items-center justify-between">
          <span className="text-sm font-medium text-muted-foreground">
            Tasa de asistencia
          </span>
          <span className="text-sm font-bold text-foreground">
            {stats.attendanceRate}%
          </span>
        </div>
        <Progress
          value={stats.attendanceRate}
          color={
            stats.attendanceRate >= 80
              ? 'bg-green-500'
              : stats.attendanceRate >= 60
                ? 'bg-yellow-500'
                : 'bg-red-500'
          }
        />
      </div>
    </div>
  );
}
