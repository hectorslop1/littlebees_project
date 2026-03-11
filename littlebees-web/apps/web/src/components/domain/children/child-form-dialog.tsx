'use client';

import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { useQuery } from '@tanstack/react-query';
import { useEffect } from 'react';
import { api } from '@/lib/api-client';
import { useCreateChild, useUpdateChild } from '@/hooks/use-children';
import { Gender } from '@kinderspace/shared-types';
import type { GroupResponse, PaginatedResponse, ChildResponse } from '@kinderspace/shared-types';
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
import { DatePicker } from '@/components/ui/date-picker';
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
  dateOfBirth: z.date({
    required_error: 'La fecha de nacimiento es obligatoria',
  }),
  gender: z.nativeEnum(Gender, {
    required_error: 'El género es obligatorio',
  }),
  groupId: z.string().min(1, 'El grupo es obligatorio'),
});

type ChildFormValues = z.infer<typeof childFormSchema>;

interface ChildFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSuccess?: () => void;
  child?: ChildResponse | null;
}

export function ChildFormDialog({
  open,
  onOpenChange,
  onSuccess,
  child,
}: ChildFormDialogProps) {
  const createChild = useCreateChild();
  const updateChild = useUpdateChild();
  const isEditing = !!child;

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
    control,
    formState: { errors },
  } = useForm<ChildFormValues>({
    resolver: zodResolver(childFormSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      dateOfBirth: undefined,
      gender: undefined,
      groupId: '',
    },
  });

  const genderValue = watch('gender');
  const groupIdValue = watch('groupId');

  useEffect(() => {
    if (child && open) {
      reset({
        firstName: child.firstName,
        lastName: child.lastName,
        dateOfBirth: new Date(child.dateOfBirth),
        gender: child.gender,
        groupId: child.groupId,
      });
    } else if (!open) {
      reset({
        firstName: '',
        lastName: '',
        dateOfBirth: undefined,
        gender: undefined,
        groupId: '',
      });
    }
  }, [child, open, reset]);

  async function onSubmit(data: ChildFormValues) {
    try {
      const year = data.dateOfBirth.getFullYear();
      const month = String(data.dateOfBirth.getMonth() + 1).padStart(2, '0');
      const day = String(data.dateOfBirth.getDate()).padStart(2, '0');
      const dateString = `${year}-${month}-${day}`;

      const basePayload = {
        firstName: data.firstName,
        lastName: data.lastName,
        dateOfBirth: dateString,
        gender: data.gender,
        groupId: data.groupId,
      };

      if (isEditing && child) {
        await updateChild.mutateAsync({ id: child.id, data: basePayload });
        toast.success('Niño actualizado exitosamente');
      } else {
        await createChild.mutateAsync({
          ...basePayload,
          parentIds: [],
        });
        toast.success('Niño registrado exitosamente');
      }
      
      reset();
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error(
        isEditing
          ? 'Error al actualizar el niño. Intenta de nuevo.'
          : 'Error al registrar el niño. Intenta de nuevo.'
      );
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
          <DialogTitle>{isEditing ? 'Editar Niño' : 'Agregar Niño'}</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <Label htmlFor="firstName">Nombre</Label>
            <Input
              id="firstName"
              placeholder="Nombre del niño"
              error={errors.firstName?.message}
              {...register('firstName')}
            />
          </div>

          <div>
            <Label htmlFor="lastName">Apellido</Label>
            <Input
              id="lastName"
              placeholder="Apellido del niño"
              error={errors.lastName?.message}
              {...register('lastName')}
            />
          </div>

          <div>
            <Label htmlFor="dateOfBirth">Fecha de nacimiento</Label>
            <Controller
              name="dateOfBirth"
              control={control}
              render={({ field }) => (
                <DatePicker
                  value={field.value}
                  onChange={field.onChange}
                  placeholder="Selecciona la fecha de nacimiento"
                  error={errors.dateOfBirth?.message}
                  toDate={new Date()}
                />
              )}
            />
          </div>

          <div>
            <Label>Género</Label>
            <Select
              value={genderValue ?? ''}
              onValueChange={(val) => setValue('gender', val as Gender, { shouldValidate: true })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Seleccionar género" />
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
            <Button 
              type="submit" 
              loading={createChild.isPending || updateChild.isPending}
            >
              {isEditing ? 'Actualizar' : 'Guardar'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
