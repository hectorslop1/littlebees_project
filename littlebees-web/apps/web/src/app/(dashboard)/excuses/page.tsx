'use client';

import { AlertTriangle, FileText } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export default function ExcusesPage() {
  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Justificantes</h1>
        <p className="mt-2 text-muted-foreground">
          Este modulo se desactivo en la interfaz mientras el backend de
          justificantes sigue fuera de servicio.
        </p>
      </div>

      <Card className="border-amber-200 bg-amber-50/60">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="rounded-full bg-amber-100 p-2 text-amber-700">
              <AlertTriangle className="h-5 w-5" />
            </div>
            <CardTitle>Rutas API no disponibles</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-slate-700">
          <p>
            El frontend tenia llamadas a `/excuses`, pero el modulo correspondiente
            no esta habilitado en la API actual. Esta vista evita errores 404 y deja
            el estado del sistema explicito.
          </p>
          <div className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white p-4">
            <FileText className="h-4 w-4 text-slate-500" />
            <span>
              Para restaurar el flujo completo se necesita habilitar el modelo en
              Prisma, registrar el modulo NestJS y volver a exponer la navegacion.
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
