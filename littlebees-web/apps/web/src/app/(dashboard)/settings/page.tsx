'use client';

import { useState } from 'react';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { ProfileSection } from '@/components/domain/settings/profile-section';
import { SecuritySection } from '@/components/domain/settings/security-section';
import { NotificationPreferences } from '@/components/domain/settings/notification-preferences';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('profile');

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold font-heading">Configuracion</h1>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="profile">Perfil</TabsTrigger>
          <TabsTrigger value="security">Seguridad</TabsTrigger>
          <TabsTrigger value="notifications">Notificaciones</TabsTrigger>
        </TabsList>

        <TabsContent value="profile">
          <ProfileSection />
        </TabsContent>

        <TabsContent value="security">
          <SecuritySection />
        </TabsContent>

        <TabsContent value="notifications">
          <NotificationPreferences />
        </TabsContent>
      </Tabs>
    </div>
  );
}
