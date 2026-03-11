'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/use-auth';
import { UserRole } from '@kinderspace/shared-types';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { ProfileHeader } from '@/components/profile/profile-header';
import { TeacherProfile } from '@/components/profile/teacher-profile';
import { ParentProfile } from '@/components/profile/parent-profile';
import { DirectorProfile } from '@/components/profile/director-profile';
import { ActivityTab } from '@/components/profile/activity-tab';
import { NotificationsTab } from '@/components/profile/notifications-tab';
import { SecurityTab } from '@/components/profile/security-tab';

export default function ProfilePage() {
  const { user, role, tenant } = useAuth();
  const [activeTab, setActiveTab] = useState('profile');

  if (!user || !role) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <p className="text-muted">Cargando perfil...</p>
      </div>
    );
  }

  const renderRoleSpecificContent = () => {
    switch (role) {
      case UserRole.TEACHER:
        return <TeacherProfile user={user} tenant={tenant} />;
      case UserRole.PARENT:
        return <ParentProfile user={user} tenant={tenant} />;
      case UserRole.DIRECTOR:
      case UserRole.ADMIN:
      case UserRole.SUPER_ADMIN:
        return <DirectorProfile user={user} tenant={tenant} />;
      default:
        return (
          <div className="text-center text-muted py-8">
            Perfil no disponible para este rol
          </div>
        );
    }
  };

  return (
    <div className="space-y-6">
      <ProfileHeader user={user} role={role} tenant={tenant} />

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4 lg:w-auto lg:inline-grid">
          <TabsTrigger value="profile">Perfil</TabsTrigger>
          <TabsTrigger value="activity">Actividad</TabsTrigger>
          <TabsTrigger value="notifications">Notificaciones</TabsTrigger>
          <TabsTrigger value="security">Seguridad</TabsTrigger>
        </TabsList>

        <TabsContent value="profile" className="mt-6">
          {renderRoleSpecificContent()}
        </TabsContent>

        <TabsContent value="activity" className="mt-6">
          <ActivityTab userId={user.id} role={role} />
        </TabsContent>

        <TabsContent value="notifications" className="mt-6">
          <NotificationsTab userId={user.id} />
        </TabsContent>

        <TabsContent value="security" className="mt-6">
          <SecurityTab user={user} />
        </TabsContent>
      </Tabs>
    </div>
  );
}
