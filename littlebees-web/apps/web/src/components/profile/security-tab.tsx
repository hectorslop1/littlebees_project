'use client';

import { useState } from 'react';
import { Shield, Key, Smartphone, Lock } from 'lucide-react';
import type { UserInfo } from '@kinderspace/shared-types';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Switch } from '@/components/ui/switch';

interface SecurityTabProps {
  user: UserInfo;
}

export function SecurityTab({ user }: SecurityTabProps) {
  const [mfaEnabled, setMfaEnabled] = useState(user.mfaEnabled);
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [pushNotifications, setPushNotifications] = useState(true);

  return (
    <div className="space-y-6">
      <Card className="p-6">
        <div className="flex items-start gap-4 mb-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-50">
            <Shield className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h2 className="text-xl font-semibold font-heading">Seguridad de la Cuenta</h2>
            <p className="text-sm text-muted mt-1">
              Gestiona la seguridad y privacidad de tu cuenta
            </p>
          </div>
        </div>

        <div className="space-y-6">
          <div className="flex items-center justify-between p-4 rounded-lg border">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-50">
                <Key className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <h3 className="font-medium">Cambiar Contraseña</h3>
                <p className="text-sm text-muted mt-1">
                  Actualiza tu contraseña regularmente para mayor seguridad
                </p>
              </div>
            </div>
            <Button variant="outline" size="sm">
              Cambiar
            </Button>
          </div>

          <div className="flex items-center justify-between p-4 rounded-lg border">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-50">
                <Smartphone className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <h3 className="font-medium">Autenticación de Dos Factores (2FA)</h3>
                <p className="text-sm text-muted mt-1">
                  Agrega una capa extra de seguridad a tu cuenta
                </p>
              </div>
            </div>
            <Switch
              checked={mfaEnabled}
              onCheckedChange={setMfaEnabled}
            />
          </div>

          <div className="flex items-center justify-between p-4 rounded-lg border">
            <div className="flex items-start gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-orange-50">
                <Lock className="h-5 w-5 text-orange-600" />
              </div>
              <div>
                <h3 className="font-medium">Sesiones Activas</h3>
                <p className="text-sm text-muted mt-1">
                  Gestiona los dispositivos donde has iniciado sesión
                </p>
              </div>
            </div>
            <Button variant="outline" size="sm">
              Ver
            </Button>
          </div>
        </div>
      </Card>

      <Card className="p-6">
        <h2 className="text-xl font-semibold font-heading mb-6">Preferencias de Notificación</h2>
        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 rounded-lg border">
            <div>
              <h3 className="font-medium">Notificaciones por Email</h3>
              <p className="text-sm text-muted mt-1">
                Recibe actualizaciones importantes por correo electrónico
              </p>
            </div>
            <Switch
              checked={emailNotifications}
              onCheckedChange={setEmailNotifications}
            />
          </div>

          <div className="flex items-center justify-between p-4 rounded-lg border">
            <div>
              <h3 className="font-medium">Notificaciones Push</h3>
              <p className="text-sm text-muted mt-1">
                Recibe notificaciones en tiempo real en tu dispositivo
              </p>
            </div>
            <Switch
              checked={pushNotifications}
              onCheckedChange={setPushNotifications}
            />
          </div>
        </div>
      </Card>

      <Card className="p-6 border-red-200 bg-red-50/50">
        <h2 className="text-xl font-semibold font-heading text-red-700 mb-4">Zona de Peligro</h2>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-medium text-red-700">Eliminar Cuenta</h3>
              <p className="text-sm text-red-600 mt-1">
                Esta acción es permanente y no se puede deshacer
              </p>
            </div>
            <Button variant="danger" size="sm">
              Eliminar
            </Button>
          </div>
        </div>
      </Card>
    </div>
  );
}
