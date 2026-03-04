'use client';

import { useState, useCallback } from 'react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

interface NotificationCategory {
  key: string;
  label: string;
  description: string;
}

const NOTIFICATION_CATEGORIES: NotificationCategory[] = [
  {
    key: 'attendance',
    label: 'Asistencia',
    description: 'Notificaciones sobre llegadas, ausencias y retardos.',
  },
  {
    key: 'payments',
    label: 'Pagos',
    description: 'Recordatorios de pago, confirmaciones y vencimientos.',
  },
  {
    key: 'messages',
    label: 'Mensajes',
    description: 'Mensajes de maestros, directivos y otros padres.',
  },
  {
    key: 'system',
    label: 'Sistema',
    description: 'Actualizaciones del sistema, mantenimiento y novedades.',
  },
];

function ToggleSwitch({
  enabled,
  onChange,
}: {
  enabled: boolean;
  onChange: (value: boolean) => void;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={enabled}
      onClick={() => onChange(!enabled)}
      className={`relative inline-flex h-6 w-11 shrink-0 items-center rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 ${
        enabled ? 'bg-primary' : 'bg-gray-300'
      }`}
    >
      <span
        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
          enabled ? 'translate-x-6' : 'translate-x-1'
        }`}
      />
    </button>
  );
}

export function NotificationPreferences() {
  const [preferences, setPreferences] = useState<Record<string, boolean>>({
    attendance: true,
    payments: true,
    messages: true,
    system: false,
  });
  const [isSaving, setIsSaving] = useState(false);

  const handleToggle = useCallback((key: string, value: boolean) => {
    setPreferences((prev) => ({ ...prev, [key]: value }));
  }, []);

  const handleSave = useCallback(async () => {
    setIsSaving(true);
    try {
      // TODO: integrar con API cuando este disponible
      await new Promise((resolve) => setTimeout(resolve, 500));
      toast.success('Preferencias de notificaciones actualizadas');
    } catch {
      toast.error('Error al guardar las preferencias. Intenta de nuevo.');
    } finally {
      setIsSaving(false);
    }
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg font-semibold font-heading">
          Preferencias de Notificaciones
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-4">
          {NOTIFICATION_CATEGORIES.map((category) => (
            <div
              key={category.key}
              className="flex items-center justify-between rounded-xl border border-input p-4"
            >
              <div>
                <p className="text-sm font-medium text-foreground">
                  {category.label}
                </p>
                <p className="mt-0.5 text-xs text-muted">
                  {category.description}
                </p>
              </div>
              <ToggleSwitch
                enabled={preferences[category.key] ?? false}
                onChange={(value) => handleToggle(category.key, value)}
              />
            </div>
          ))}
        </div>

        <div className="flex justify-end">
          <Button variant="primary" onClick={handleSave} loading={isSaving}>
            Guardar Preferencias
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
