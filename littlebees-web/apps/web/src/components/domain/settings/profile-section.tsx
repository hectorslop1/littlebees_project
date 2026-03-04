'use client';

import { useState, useCallback, useRef } from 'react';
import { toast } from 'sonner';
import { useAuth } from '@/hooks/use-auth';
import { useUpdateProfile } from '@/hooks/use-users';
import { useUploadFile } from '@/hooks/use-files';
import { Avatar } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export function ProfileSection() {
  const { user } = useAuth();
  const updateProfile = useUpdateProfile();
  const uploadFile = useUploadFile();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [firstName, setFirstName] = useState(user?.firstName ?? '');
  const [lastName, setLastName] = useState(user?.lastName ?? '');
  const [phone, setPhone] = useState(user?.phone ?? '');

  const handleSave = useCallback(async () => {
    try {
      await updateProfile.mutateAsync({ firstName, lastName, phone });
      toast.success('Perfil actualizado exitosamente');
    } catch {
      toast.error('Error al actualizar el perfil. Intenta de nuevo.');
    }
  }, [firstName, lastName, phone, updateProfile]);

  const handleAvatarUpload = useCallback(
    async (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];
      if (!file) return;

      try {
        await uploadFile.mutateAsync({ file, purpose: 'avatar' });
        toast.success('Foto de perfil actualizada');
      } catch {
        toast.error('Error al subir la imagen. Intenta de nuevo.');
      }
    },
    [uploadFile],
  );

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Perfil
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Avatar */}
        <div className="flex items-center gap-4">
          <Avatar
            size="xl"
            name={user ? `${user.firstName} ${user.lastName}` : undefined}
            src={user?.avatarUrl ?? undefined}
          />
          <div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => fileInputRef.current?.click()}
              loading={uploadFile.isPending}
            >
              Cambiar foto
            </Button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handleAvatarUpload}
            />
            <p className="mt-1 text-xs text-muted">
              JPG, PNG o GIF. Maximo 2MB.
            </p>
          </div>
        </div>

        {/* Formulario */}
        <div className="grid gap-4 sm:grid-cols-2">
          <Input
            label="Nombre"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            placeholder="Tu nombre"
          />
          <Input
            label="Apellido"
            value={lastName}
            onChange={(e) => setLastName(e.target.value)}
            placeholder="Tu apellido"
          />
          <Input
            label="Telefono"
            type="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+52 000 000 0000"
          />
          <Input
            label="Correo electronico"
            type="email"
            value={user?.email ?? ''}
            disabled
            className="opacity-60"
          />
        </div>

        <div className="flex justify-end">
          <Button
            variant="primary"
            onClick={handleSave}
            loading={updateProfile.isPending}
          >
            Guardar Cambios
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
