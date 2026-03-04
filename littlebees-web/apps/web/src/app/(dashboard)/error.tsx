'use client';

import { useEffect } from 'react';
import { AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Dashboard error:', error);
  }, [error]);

  return (
    <div className="flex min-h-[50vh] flex-col items-center justify-center text-center">
      <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive-50">
        <AlertTriangle className="h-8 w-8 text-destructive" />
      </div>
      <h2 className="mt-4 text-xl font-semibold font-heading">Algo salió mal</h2>
      <p className="mt-2 max-w-md text-sm text-muted">
        Ocurrió un error inesperado. Por favor, intenta de nuevo.
      </p>
      <Button onClick={reset} className="mt-6">
        Intentar de nuevo
      </Button>
    </div>
  );
}
