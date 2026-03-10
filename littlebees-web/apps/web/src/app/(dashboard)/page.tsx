'use client';

import { useAuth } from '@/hooks/use-auth';
import { StatCardsRow } from '@/components/domain/dashboard/stat-cards-row';
import { AttendanceChart } from '@/components/domain/dashboard/attendance-chart';
import { DevelopmentRadar } from '@/components/domain/dashboard/development-radar';

export default function DashboardPage() {
  const { user } = useAuth();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold font-heading">
        Bienvenido{user?.firstName ? `, ${user.firstName}` : ''} a Littlebees
      </h1>

      {/* Stats Grid */}
      <StatCardsRow />

      {/* Charts */}
      <div className="grid gap-4 md:grid-cols-2">
        <AttendanceChart />
        <DevelopmentRadar />
      </div>
    </div>
  );
}
