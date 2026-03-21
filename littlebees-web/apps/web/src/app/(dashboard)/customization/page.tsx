'use client';

import { AlertTriangle, Palette } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export default function CustomizationPage() {
  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Personalizacion</h1>
        <p className="mt-2 text-muted-foreground">
          Este modulo esta oculto temporalmente porque el backend de personalizacion
          sigue deshabilitado.
        </p>
      </div>

      <Card className="border-amber-200 bg-amber-50/60">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="rounded-full bg-amber-100 p-2 text-amber-700">
              <AlertTriangle className="h-5 w-5" />
            </div>
            <CardTitle>Modulo no disponible</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-slate-700">
          <p>
            La interfaz existia en frontend, pero las rutas `/customization` no estan
            activas en la API actual. Se reemplazo esta pantalla para evitar errores
            404 y guardar configuraciones que no persistirian.
          </p>
          <div className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white p-4">
            <Palette className="h-4 w-4 text-slate-500" />
            <span>
              Reactivar este modulo requiere habilitar Prisma + NestJS para
              personalizacion antes de volver a exponerlo en navegacion.
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
