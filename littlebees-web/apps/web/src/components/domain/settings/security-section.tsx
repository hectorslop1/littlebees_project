'use client';

import { useState, useCallback } from 'react';
import { toast } from 'sonner';
import { useAuth } from '@/hooks/use-auth';
import { api } from '@/lib/api-client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export function SecuritySection() {
  const { user } = useAuth();

  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateForm = useCallback((): boolean => {
    const newErrors: Record<string, string> = {};

    if (!currentPassword) {
      newErrors.currentPassword = 'La contrasena actual es obligatoria';
    }
    if (!newPassword) {
      newErrors.newPassword = 'La nueva contrasena es obligatoria';
    } else if (newPassword.length < 8) {
      newErrors.newPassword = 'La contrasena debe tener al menos 8 caracteres';
    }
    if (newPassword !== confirmPassword) {
      newErrors.confirmPassword = 'Las contrasenas no coinciden';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [currentPassword, newPassword, confirmPassword]);

  const handleChangePassword = useCallback(async () => {
    if (!validateForm()) return;

    setIsChangingPassword(true);
    try {
      await api.post('/auth/change-password', {
        currentPassword,
        newPassword,
      });
      toast.success('Contrasena actualizada exitosamente');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      setErrors({});
    } catch {
      toast.error('Error al cambiar la contrasena. Verifica tu contrasena actual.');
    } finally {
      setIsChangingPassword(false);
    }
  }, [currentPassword, newPassword, validateForm]);

  return (
    <div className="space-y-6">
      {/* Cambiar contrasena */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Cambiar Contrasena
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="max-w-md space-y-4">
            <Input
              label="Contrasena actual"
              type="password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              error={errors.currentPassword}
              placeholder="Ingresa tu contrasena actual"
            />
            <Input
              label="Nueva contrasena"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              error={errors.newPassword}
              placeholder="Ingresa tu nueva contrasena"
            />
            <Input
              label="Confirmar nueva contrasena"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              error={errors.confirmPassword}
              placeholder="Confirma tu nueva contrasena"
            />
          </div>

          <div className="flex justify-end">
            <Button
              variant="primary"
              onClick={handleChangePassword}
              loading={isChangingPassword}
            >
              Actualizar Contrasena
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* MFA */}
      <Card>
        <CardHeader>
          <CardTitle className="text-lg font-semibold font-heading">
            Autenticacion de Dos Factores (MFA)
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-foreground">
                {user?.mfaEnabled
                  ? 'La autenticacion de dos factores esta activada.'
                  : 'La autenticacion de dos factores no esta activada.'}
              </p>
              <p className="mt-1 text-xs text-muted">
                Agrega una capa extra de seguridad a tu cuenta.
              </p>
            </div>
            <div
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                user?.mfaEnabled ? 'bg-primary' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                  user?.mfaEnabled ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
