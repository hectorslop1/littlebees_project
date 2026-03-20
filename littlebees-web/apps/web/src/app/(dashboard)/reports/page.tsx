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
  useActivitiesReport,
} from '@/hooks/use-reports';
import { useGroups } from '@/hooks/use-groups';

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
  const activitiesQuery = useActivitiesReport({
    from,
    to,
    groupId: groupIdParam,
  });
  const { data: groupsData } = useGroups();

  // Mapear grupos con friendlyName y subgroup
  const availableGroups = useMemo(() => {
    if (!groupsData || groupsData.length === 0) return [];
    return groupsData.map((g) => ({
      id: g.id,
      name: `${g.friendlyName}${g.subgroup ? ` - Grupo ${g.subgroup}` : ''}`,
    }));
  }, [groupsData]);

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
          <TabsTrigger value="activities">Actividades</TabsTrigger>
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

        <TabsContent value="activities">
          {activitiesQuery.isLoading ? (
            <ReportSkeleton />
          ) : activitiesQuery.data ? (
            <div className="space-y-6">
              <div className="grid gap-4 md:grid-cols-3">
                <div className="rounded-lg border bg-card p-6">
                  <div className="text-sm text-muted-foreground">Total Actividades</div>
                  <div className="text-3xl font-bold mt-2">{activitiesQuery.data.totalActivities}</div>
                </div>
                <div className="rounded-lg border bg-card p-6 md:col-span-2">
                  <div className="text-sm text-muted-foreground mb-4">Por Tipo</div>
                  <div className="flex flex-wrap gap-2">
                    {activitiesQuery.data.activitiesByType?.map((item: any) => (
                      <div key={item.type} className="flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1">
                        <span className="text-sm font-medium capitalize">{item.type}</span>
                        <span className="text-sm text-muted-foreground">{item.count} ({item.percentage}%)</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              
              <div className="rounded-lg border bg-card p-6">
                <h3 className="font-semibold mb-4">Resumen por Niño</h3>
                <div className="space-y-3">
                  {activitiesQuery.data.children?.map((child: any) => (
                    <div key={child.childId} className="flex items-center justify-between border-b pb-3 last:border-0">
                      <div>
                        <p className="font-medium">{child.childName}</p>
                        <p className="text-sm text-muted-foreground">{child.groupName}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">{child.totalActivities} actividades</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
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
