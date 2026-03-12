'use client';

import { useAuth } from '@/hooks/use-auth';
import { StatCardsRow } from '@/components/domain/dashboard/stat-cards-row';
import { AttendanceChart } from '@/components/domain/dashboard/attendance-chart';
import { DevelopmentRadar } from '@/components/domain/dashboard/development-radar';
import { DevelopmentEvolution } from '@/components/domain/dashboard/development-evolution';
import { GroupsOverview } from '@/components/domain/dashboard/groups-overview';
import { RecentActivity } from '@/components/domain/dashboard/recent-activity';
import { AnnouncementsList } from '@/components/domain/dashboard/announcements-list';

export default function DashboardPage() {
  const { user } = useAuth();

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold font-heading">
        Bienvenido{user?.firstName ? `, ${user.firstName}` : ''} a Littlebees
      </h1>

      {/* Stats Grid - 4 cards */}
      <StatCardsRow />

      {/* Charts Row - Asistencia y Desarrollo Radar */}
      <div className="grid gap-6 lg:grid-cols-2">
        <AttendanceChart />
        <DevelopmentRadar />
      </div>

      {/* Development Trend & Groups - 2:1 proporción */}
      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <DevelopmentEvolution />
        </div>
        <GroupsOverview />
      </div>

      {/* Recent Activity & Announcements */}
      <div className="grid gap-6 lg:grid-cols-2">
        <RecentActivity />
        <AnnouncementsList />
      </div>
    </div>
  );
}
