'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { ServiceType } from '@kinderspace/shared-types';
import type { ExtraServiceResponse } from '@kinderspace/shared-types';
import { useCreateService, useUpdateService } from '@/hooks/use-services';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from '@/components/ui/select';

const serviceFormSchema = z.object({
  name: z.string().min(1, 'El nombre es obligatorio'),
  description: z.string().optional(),
  type: z.nativeEnum(ServiceType, {
    required_error: 'El tipo es obligatorio',
  }),
  schedule: z.string().optional(),
  price: z.coerce
    .number({ invalid_type_error: 'El precio debe ser un numero' })
    .min(0, 'El precio no puede ser negativo'),
  capacity: z.coerce
    .number({ invalid_type_error: 'La capacidad debe ser un numero' })
    .int('La capacidad debe ser un numero entero')
    .min(1, 'La capacidad minima es 1')
    .optional()
    .or(z.literal('')),
});

type ServiceFormValues = z.infer<typeof serviceFormSchema>;

interface ServiceFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  service?: ExtraServiceResponse | null;
  onSuccess?: () => void;
}

const typeLabels: Record<ServiceType, string> = {
  [ServiceType.CLASS]: 'Clase Extra',
  [ServiceType.WORKSHOP]: 'Taller',
  [ServiceType.MARKETPLACE_ITEM]: 'Tienda',
};

export function ServiceFormDialog({
  open,
  onOpenChange,
  service,
  onSuccess,
}: ServiceFormDialogProps) {
  const createService = useCreateService();
  const updateService = useUpdateService();
  const isEditing = !!service;

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    reset,
    formState: { errors },
  } = useForm<ServiceFormValues>({
    resolver: zodResolver(serviceFormSchema),
    defaultValues: {
      name: '',
      description: '',
      type: undefined,
      schedule: '',
      price: 0,
      capacity: '',
    },
  });

  const typeValue = watch('type');

  // Pre-fill form when editing
  useEffect(() => {
    if (service && open) {
      reset({
        name: service.name,
        description: service.description ?? '',
        type: service.type,
        schedule: service.schedule ?? '',
        price: service.price,
        capacity: service.capacity ?? '',
      });
    } else if (!service && open) {
      reset({
        name: '',
        description: '',
        type: undefined,
        schedule: '',
        price: 0,
        capacity: '',
      });
    }
  }, [service, open, reset]);

  async function onSubmit(data: ServiceFormValues) {
    const payload = {
      name: data.name,
      description: data.description || undefined,
      type: data.type,
      schedule: data.schedule || undefined,
      price: data.price,
      capacity: data.capacity ? Number(data.capacity) : undefined,
    };

    try {
      if (isEditing && service) {
        await updateService.mutateAsync({
          id: service.id,
          data: payload,
        });
        toast.success('Servicio actualizado exitosamente');
      } else {
        await createService.mutateAsync(payload);
        toast.success('Servicio creado exitosamente');
      }
      reset();
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error(
        isEditing
          ? 'Error al actualizar el servicio. Intenta de nuevo.'
          : 'Error al crear el servicio. Intenta de nuevo.',
      );
    }
  }

  function handleClose(value: boolean) {
    if (!value) {
      reset();
    }
    onOpenChange(value);
  }

  const isPending = createService.isPending || updateService.isPending;

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            {isEditing ? 'Editar Servicio' : 'Agregar Servicio'}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <Label htmlFor="name">Nombre</Label>
            <Input
              id="name"
              placeholder="Nombre del servicio"
              error={errors.name?.message}
              {...register('name')}
            />
          </div>

          <div>
            <Label htmlFor="description">Descripcion</Label>
            <Textarea
              id="description"
              placeholder="Descripcion del servicio (opcional)"
              error={errors.description?.message}
              {...register('description')}
            />
          </div>

          <div>
            <Label>Tipo</Label>
            <Select
              value={typeValue ?? ''}
              onValueChange={(val) =>
                setValue('type', val as ServiceType, { shouldValidate: true })
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Seleccionar tipo" />
              </SelectTrigger>
              <SelectContent>
                {Object.values(ServiceType).map((st) => (
                  <SelectItem key={st} value={st}>
                    {typeLabels[st]}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.type && (
              <p className="mt-1.5 text-sm text-destructive">
                {errors.type.message}
              </p>
            )}
          </div>

          <div>
            <Label htmlFor="schedule">Horario</Label>
            <Input
              id="schedule"
              placeholder="Ej: Lunes y Miercoles 3:00 - 4:00 PM"
              error={errors.schedule?.message}
              {...register('schedule')}
            />
          </div>

          <div>
            <Label htmlFor="price">Precio (MXN)</Label>
            <Input
              id="price"
              type="number"
              min={0}
              step="0.01"
              placeholder="0.00"
              error={errors.price?.message}
              {...register('price')}
            />
          </div>

          <div>
            <Label htmlFor="capacity">Capacidad</Label>
            <Input
              id="capacity"
              type="number"
              min={1}
              step={1}
              placeholder="Numero de lugares (opcional)"
              error={
                errors.capacity && typeof errors.capacity.message === 'string'
                  ? errors.capacity.message
                  : undefined
              }
              {...register('capacity')}
            />
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => handleClose(false)}
            >
              Cancelar
            </Button>
            <Button type="submit" loading={isPending}>
              {isEditing ? 'Guardar Cambios' : 'Crear Servicio'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
