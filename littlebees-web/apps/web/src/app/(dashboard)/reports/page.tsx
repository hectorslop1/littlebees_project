'use client';

import { useState, useMemo } from 'react';
import { subDays, format } from 'date-fns';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import { ReportFilters } from '@/components/domain/reports/report-filters';
import { AttendanceReport } from '@/components/domain/reports/attendance-report';
import { DevelopmentReport } from '@/components/domain/reports/development-report';
import { PaymentsReport } from '@/components/domain/reports/payments-report';
import {
  useAttendanceReport,
  useDevelopmentReport,
  usePaymentReport,
} from '@/hooks/use-reports';

function getDefaultRange() {
  const to = new Date();
  const from = subDays(to, 30);
  return {
    from: format(from, 'yyyy-MM-dd'),
    to: format(to, 'yyyy-MM-dd'),
  };
}

function ReportSkeleton() {
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-28 w-full rounded-2xl" />
        ))}
      </div>
      <Skeleton className="h-80 w-full rounded-2xl" />
      <Skeleton className="h-48 w-full rounded-2xl" />
    </div>
  );
}

export default function ReportsPage() {
  const defaults = useMemo(() => getDefaultRange(), []);
  const [from, setFrom] = useState(defaults.from);
  const [to, setTo] = useState(defaults.to);
  const [groupId, setGroupId] = useState<string>('all');
  const [activeTab, setActiveTab] = useState('attendance');

  const groupIdParam = groupId === 'all' ? undefined : groupId;

  const attendanceQuery = useAttendanceReport({
    from,
    to,
    groupId: groupIdParam,
  });
  const developmentQuery = useDevelopmentReport({
    from,
    to,
    groupId: groupIdParam,
  });
  const paymentQuery = usePaymentReport({ from, to });

  // Extraer grupos disponibles del reporte de asistencia
  const availableGroups = useMemo(() => {
    if (!attendanceQuery.data?.groups) return [];
    return attendanceQuery.data.groups.map((g) => ({
      id: g.groupId,
      name: g.groupName,
    }));
  }, [attendanceQuery.data]);

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold font-heading">Reportes</h1>

      <ReportFilters
        from={from}
        to={to}
        onFromChange={setFrom}
        onToChange={setTo}
        groupId={groupId}
        onGroupIdChange={setGroupId}
        groups={availableGroups}
      />

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="attendance">Asistencia</TabsTrigger>
          <TabsTrigger value="development">Desarrollo</TabsTrigger>
          <TabsTrigger value="payments">Pagos</TabsTrigger>
        </TabsList>

        <TabsContent value="attendance">
          {attendanceQuery.isLoading ? (
            <ReportSkeleton />
          ) : attendanceQuery.data ? (
            <AttendanceReport data={attendanceQuery.data} />
          ) : (
            <div className="flex h-64 items-center justify-center text-muted">
              Selecciona un rango de fechas para generar el reporte
            </div>
          )}
        </TabsContent>

        <TabsContent value="development">
          {developmentQuery.isLoading ? (
            <ReportSkeleton />
          ) : developmentQuery.data ? (
            <DevelopmentReport data={developmentQuery.data} />
          ) : (
            <div className="flex h-64 items-center justify-center text-muted">
              Selecciona un rango de fechas para generar el reporte
            </div>
          )}
        </TabsContent>

        <TabsContent value="payments">
          {paymentQuery.isLoading ? (
            <ReportSkeleton />
          ) : paymentQuery.data ? (
            <PaymentsReport data={paymentQuery.data} />
          ) : (
            <div className="flex h-64 items-center justify-center text-muted">
              Selecciona un rango de fechas para generar el reporte
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
