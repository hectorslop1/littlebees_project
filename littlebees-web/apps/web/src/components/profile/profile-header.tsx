'use client';

import { useState } from 'react';
import { Edit2, Mail, Phone, Building2 } from 'lucide-react';
import { UserRole, type UserInfo, type TenantInfo } from '@kinderspace/shared-types';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

interface ProfileHeaderProps {
  user: UserInfo;
  role: UserRole;
  tenant: TenantInfo | null;
}

const roleLabels: Record<UserRole, string> = {
  [UserRole.SUPER_ADMIN]: 'Super Administrador',
  [UserRole.DIRECTOR]: 'Director',
  [UserRole.ADMIN]: 'Administrador',
  [UserRole.TEACHER]: 'Maestro',
  [UserRole.PARENT]: 'Padre/Tutor',
};

const roleColors: Record<UserRole, string> = {
  [UserRole.SUPER_ADMIN]: 'bg-purple-100 text-purple-700',
  [UserRole.DIRECTOR]: 'bg-blue-100 text-blue-700',
  [UserRole.ADMIN]: 'bg-indigo-100 text-indigo-700',
  [UserRole.TEACHER]: 'bg-green-100 text-green-700',
  [UserRole.PARENT]: 'bg-orange-100 text-orange-700',
};

export function ProfileHeader({ user, role, tenant }: ProfileHeaderProps) {
  const [isEditing, setIsEditing] = useState(false);

  const handleEditProfile = () => {
    setIsEditing(true);
  };

  return (
    <Card className="p-6">
      <div className="flex flex-col lg:flex-row gap-6">
        <div className="flex-shrink-0">
          <Avatar className="h-24 w-24 lg:h-32 lg:w-32">
            <AvatarImage src={user.avatarUrl || undefined} alt={`${user.firstName} ${user.lastName}`} />
            <AvatarFallback className="text-2xl lg:text-3xl">
              {user.firstName?.[0]}{user.lastName?.[0]}
            </AvatarFallback>
          </Avatar>
        </div>

        <div className="flex-1 space-y-4">
          <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
            <div>
              <h1 className="text-2xl lg:text-3xl font-bold font-heading">
                {user.firstName} {user.lastName}
              </h1>
              <Badge className={`mt-2 ${roleColors[role]}`}>
                {roleLabels[role]}
              </Badge>
            </div>
            <Button onClick={handleEditProfile} variant="outline" size="sm">
              <Edit2 className="h-4 w-4 mr-2" />
              Editar Perfil
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div className="flex items-center gap-3 text-sm">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-50">
                <Mail className="h-5 w-5 text-primary" />
              </div>
              <div>
                <p className="text-xs text-muted">Email</p>
                <p className="font-medium">{user.email}</p>
              </div>
            </div>

            {user.phone && (
              <div className="flex items-center gap-3 text-sm">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-50">
                  <Phone className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-muted">Teléfono</p>
                  <p className="font-medium">{user.phone}</p>
                </div>
              </div>
            )}

            {tenant && (
              <div className="flex items-center gap-3 text-sm">
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary-50">
                  <Building2 className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="text-xs text-muted">Centro</p>
                  <p className="font-medium">{tenant.name}</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </Card>
  );
}
