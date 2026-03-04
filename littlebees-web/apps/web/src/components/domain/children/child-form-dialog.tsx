'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { useCreateChild } from '@/hooks/use-children';
import { Gender } from '@kinderspace/shared-types';
import type { GroupResponse, PaginatedResponse } from '@kinderspace/shared-types';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from '@/components/ui/select';

const childFormSchema = z.object({
  firstName: z.string().min(1, 'El nombre es obligatorio'),
  lastName: z.string().min(1, 'El apellido es obligatorio'),
  dateOfBirth: z.string().min(1, 'La fecha de nacimiento es obligatoria'),
  gender: z.nativeEnum(Gender, {
    required_error: 'El genero es obligatorio',
  }),
  groupId: z.string().min(1, 'El grupo es obligatorio'),
});

type ChildFormValues = z.infer<typeof childFormSchema>;

interface ChildFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: () => void;
}

export function ChildFormDialog({
  open,
  onOpenChange,
  onSuccess,
}: ChildFormDialogProps) {
  const createChild = useCreateChild();

  const { data: groupsData } = useQuery({
    queryKey: ['groups'],
    queryFn: () => api.get<PaginatedResponse<GroupResponse>>('/groups'),
    enabled: open,
  });

  const groups = groupsData?.data ?? [];

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    reset,
    formState: { errors },
  } = useForm<ChildFormValues>({
    resolver: zodResolver(childFormSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      dateOfBirth: '',
      gender: undefined,
      groupId: '',
    },
  });

  const genderValue = watch('gender');
  const groupIdValue = watch('groupId');

  async function onSubmit(data: ChildFormValues) {
    try {
      await createChild.mutateAsync({
        ...data,
        parentIds: [],
      });
      toast.success('Nino registrado exitosamente');
      reset();
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error('Error al registrar el nino. Intenta de nuevo.');
    }
  }

  function handleClose(value: boolean) {
    if (!value) {
      reset();
    }
    onOpenChange(value);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Agregar Nino</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <Label htmlFor="firstName">Nombre</Label>
            <Input
              id="firstName"
              placeholder="Nombre del nino"
              error={errors.firstName?.message}
              {...register('firstName')}
            />
          </div>

          <div>
            <Label htmlFor="lastName">Apellido</Label>
            <Input
              id="lastName"
              placeholder="Apellido del nino"
              error={errors.lastName?.message}
              {...register('lastName')}
            />
          </div>

          <div>
            <Label htmlFor="dateOfBirth">Fecha de nacimiento</Label>
            <Input
              id="dateOfBirth"
              type="date"
              error={errors.dateOfBirth?.message}
              {...register('dateOfBirth')}
            />
          </div>

          <div>
            <Label>Genero</Label>
            <Select
              value={genderValue ?? ''}
              onValueChange={(val) => setValue('gender', val as Gender, { shouldValidate: true })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Seleccionar genero" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={Gender.MALE}>Masculino</SelectItem>
                <SelectItem value={Gender.FEMALE}>Femenino</SelectItem>
              </SelectContent>
            </Select>
            {errors.gender && (
              <p className="mt-1.5 text-sm text-destructive">
                {errors.gender.message}
              </p>
            )}
          </div>

          <div>
            <Label>Grupo</Label>
            <Select
              value={groupIdValue ?? ''}
              onValueChange={(val) => setValue('groupId', val, { shouldValidate: true })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Seleccionar grupo" />
              </SelectTrigger>
              <SelectContent>
                {groups.map((group) => (
                  <SelectItem key={group.id} value={group.id}>
                    {group.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.groupId && (
              <p className="mt-1.5 text-sm text-destructive">
                {errors.groupId.message}
              </p>
            )}
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => handleClose(false)}
            >
              Cancelar
            </Button>
            <Button type="submit" loading={createChild.isPending}>
              Guardar
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
