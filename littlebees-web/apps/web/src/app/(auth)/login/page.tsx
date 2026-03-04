'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { loginSchema } from '@kinderspace/shared-validators';
import { useRouter } from 'next/navigation';
import { Mail, Lock, Users } from 'lucide-react';
import type { z } from 'zod';

import { useAuth } from '@/hooks/use-auth';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

type LoginFormData = z.infer<typeof loginSchema>;

const DEV_USERS = [
  { email: 'director@petitsoleil.mx', role: 'Directora', name: 'María González' },
  { email: 'admin@petitsoleil.mx', role: 'Admin', name: 'Roberto Sánchez' },
  { email: 'maestra@petitsoleil.mx', role: 'Maestra', name: 'Ana López' },
  { email: 'maestra2@petitsoleil.mx', role: 'Maestra', name: 'Laura Martínez' },
  { email: 'padre@gmail.com', role: 'Padre', name: 'Carlos Ramírez' },
  { email: 'madre@gmail.com', role: 'Madre', name: 'Patricia López' },
  { email: 'familia@gmail.com', role: 'Padre', name: 'Luis García' },
];

const DEV_PASSWORD = 'Password123!';

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [apiError, setApiError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setApiError(null);
    try {
      await login(data.email, data.password);
      router.push('/');
    } catch (error: unknown) {
      if (error instanceof Error) {
        setApiError(error.message);
      } else {
        setApiError('Ocurrió un error inesperado. Intenta de nuevo.');
      }
    }
  };

  const selectDevUser = (email: string) => {
    setValue('email', email, { shouldValidate: true });
    setValue('password', DEV_PASSWORD, { shouldValidate: true });
  };

  return (
    <div className="w-full max-w-md rounded-card bg-card p-8 shadow-card">
      {/* Logo */}
      <div className="mb-8 text-center">
        <div className="mb-3 flex items-center justify-center gap-2">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-secondary text-lg text-white">
            🐝
          </div>
          <h1 className="text-3xl font-bold text-primary">KinderSpace</h1>
        </div>
        <p className="text-sm text-muted-foreground">
          Inicia sesión en tu cuenta
        </p>
      </div>

      {/* Dev User Selector */}
      {process.env.NODE_ENV === 'development' && (
        <div className="mb-5 rounded-lg border border-accent/30 bg-accent/5 p-3">
          <div className="mb-2 flex items-center gap-1.5 text-xs font-semibold text-accent-700">
            <Users className="h-3.5 w-3.5" />
            Usuarios de prueba
          </div>
          <div className="flex flex-wrap gap-1.5">
            {DEV_USERS.map((u) => (
              <button
                key={u.email}
                type="button"
                onClick={() => selectDevUser(u.email)}
                className="rounded-full border border-primary/20 bg-primary/5 px-2.5 py-1 text-xs font-medium text-primary-700 transition-colors hover:bg-primary/15 hover:border-primary/40"
                title={u.email}
              >
                {u.name}
                <span className="ml-1 text-[10px] text-muted-foreground">({u.role})</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* API Error */}
      {apiError && (
        <div className="mb-4 rounded-lg border border-destructive/20 bg-destructive/10 px-4 py-3 text-sm text-destructive">
          {apiError}
        </div>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <Input
          label="Correo electrónico"
          type="email"
          placeholder="tu@email.com"
          icon={<Mail className="h-4 w-4" />}
          error={errors.email?.message}
          {...register('email')}
        />

        <Input
          label="Contraseña"
          type="password"
          placeholder="••••••••"
          icon={<Lock className="h-4 w-4" />}
          error={errors.password?.message}
          {...register('password')}
        />

        <Button
          type="submit"
          className="w-full"
          size="lg"
          loading={isSubmitting}
        >
          Iniciar Sesión
        </Button>
      </form>

      {/* Footer */}
      <p className="mt-6 text-center text-xs text-muted-foreground">
        Plataforma de gestión para kínderes y guarderías
      </p>
    </div>
  );
}
