'use client';

import { useState } from 'react';
import { Sidebar, TopBar, MobileHeader } from '@/components/layout';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-background">
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <MobileHeader onMenuClick={() => setSidebarOpen(true)} />

      <div className="lg:ml-72">
        <TopBar />
        <main className="p-6 pt-20 lg:pt-6">{children}</main>
      </div>
    </div>
  );
}
