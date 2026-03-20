'use client';

import { Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';

interface PageLoaderProps {
  message?: string;
  className?: string;
  fullScreen?: boolean;
}

export function PageLoader({ 
  message = 'Cargando...', 
  className,
  fullScreen = false 
}: PageLoaderProps) {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center gap-4',
        fullScreen ? 'min-h-screen' : 'min-h-[400px]',
        className
      )}
    >
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
      {message && (
        <p className="text-sm text-muted-foreground">{message}</p>
      )}
    </div>
  );
}
