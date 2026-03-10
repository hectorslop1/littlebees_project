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
import { BlobAnimation } from '@/components/blob-animation';

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
    <div className="flex min-h-screen">
      {/* Left Side - Login Form */}
      <div className="flex w-full lg:w-1/2 flex-col justify-center px-8 py-12 lg:px-16 xl:px-24 bg-white">
        <div className="w-full max-w-md mx-auto">
          {/* Logo */}
          <div className="mb-10">
            <img 
              src="/logo.png" 
              alt="Littlebees" 
              className="mb-4 h-20 w-auto"
            />
            <p className="text-base text-[#6B6B6B]">
              Inicia sesión en tu cuenta
            </p>
          </div>

          {/* Dev User Selector */}
          {process.env.NODE_ENV === 'development' && (
            <div className="mb-6 rounded-xl border border-[#D4A853]/30 bg-[#FBF6E9] p-4">
              <div className="mb-3 flex items-center gap-2 text-sm font-semibold text-[#2C2C2C]">
                <Users className="h-4 w-4 text-[#D4A853]" />
                Usuarios de prueba
              </div>
              <div className="flex flex-wrap gap-2">
                {DEV_USERS.map((u) => (
                  <button
                    key={u.email}
                    type="button"
                    onClick={() => selectDevUser(u.email)}
                    className="rounded-full border border-[#D4A853]/30 bg-white px-3 py-1.5 text-xs font-medium text-[#2C2C2C] transition-all hover:bg-[#D4A853] hover:text-white hover:border-[#D4A853]"
                    title={u.email}
                  >
                    {u.name}
                    <span className="ml-1 text-[10px] opacity-70">({u.role})</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* API Error */}
          {apiError && (
            <div className="mb-6 rounded-xl border border-[#D4655E]/20 bg-[#D4655E]/10 px-4 py-3 text-sm text-[#D4655E]">
              {apiError}
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
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
              className="w-full bg-[#D4A853] hover:bg-[#C49743] text-white"
              size="lg"
              loading={isSubmitting}
            >
              Iniciar Sesión
            </Button>
          </form>

          {/* Footer */}
          <p className="mt-8 text-center text-sm text-[#A0A0A0]">
            Plataforma de gestión para kínderes y guarderías
          </p>
        </div>
      </div>

      {/* Right Side - Blob Animation */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-[#FBF6E9]">
        <BlobAnimation />
      </div>
    </div>
  );
}
