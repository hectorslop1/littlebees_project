'use client';

import React from 'react';
import { Button } from '@/components/ui/button';
import { AlertTriangle } from 'lucide-react';

interface ErrorBoundaryProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="flex min-h-[400px] flex-col items-center justify-center p-8">
          <div className="text-center space-y-4 max-w-md">
            <div className="flex justify-center">
              <div className="rounded-full bg-red-100 p-3">
                <AlertTriangle className="h-8 w-8 text-red-600" />
              </div>
            </div>
            <h2 className="text-2xl font-bold">Algo salió mal</h2>
            <p className="text-muted-foreground">
              Ocurrió un error inesperado. Por favor, intenta recargar la página.
            </p>
            {process.env.NODE_ENV === 'development' && this.state.error && (
              <details className="mt-4 text-left">
                <summary className="cursor-pointer text-sm font-medium">
                  Detalles del error (solo en desarrollo)
                </summary>
                <pre className="mt-2 rounded-md bg-slate-100 p-4 text-xs overflow-auto">
                  {this.state.error.toString()}
                  {'\n\n'}
                  {this.state.error.stack}
                </pre>
              </details>
            )}
            <div className="flex gap-2 justify-center mt-6">
              <Button
                onClick={() => window.location.reload()}
                variant="default"
              >
                Recargar página
              </Button>
              <Button
                onClick={() => this.setState({ hasError: false, error: null })}
                variant="outline"
              >
                Intentar de nuevo
              </Button>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
