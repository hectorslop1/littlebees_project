'use client';

import { useForm } from 'react-hook-form';
import { toast } from 'sonner';
import { LogType } from '@kinderspace/shared-types';
import type { CreateDailyLogRequest } from '@kinderspace/shared-types';
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
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useChildren } from '@/hooks/use-children';
import { useCreateDailyLog } from '@/hooks/use-daily-logs';

const LOG_TYPE_LABELS: Record<LogType, string> = {
  [LogType.MEAL]: 'Comida',
  [LogType.NAP]: 'Siesta',
  [LogType.ACTIVITY]: 'Actividad',
  [LogType.DIAPER]: 'Pañal',
  [LogType.MEDICATION]: 'Medicamento',
  [LogType.OBSERVATION]: 'Observación',
  [LogType.INCIDENT]: 'Incidente',
};

interface LogFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  date: string;
  onSuccess?: () => void;
}

interface LogFormValues {
  childId: string;
  type: LogType;
  title: string;
  time: string;
  description: string;
}

export function LogFormDialog({
  open,
  onOpenChange,
  date,
  onSuccess,
}: LogFormDialogProps) {
  const { data: childrenData } = useChildren();
  const createLog = useCreateDailyLog();

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    reset,
    formState: { errors },
  } = useForm<LogFormValues>({
    defaultValues: {
      childId: '',
      type: LogType.OBSERVATION,
      title: '',
      time: new Date().toLocaleTimeString('en-GB', {
        hour: '2-digit',
        minute: '2-digit',
      }),
      description: '',
    },
  });

  const selectedChildId = watch('childId');
  const selectedType = watch('type');

  const onSubmit = async (values: LogFormValues) => {
    const payload: CreateDailyLogRequest = {
      childId: values.childId,
      date,
      type: values.type,
      title: values.title,
      time: values.time,
      ...(values.description ? { description: values.description } : {}),
    };

    try {
      await createLog.mutateAsync(payload);
      toast.success('Registro creado exitosamente');
      reset();
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error('Error al crear el registro');
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Nuevo Registro</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Child select */}
          <div className="space-y-1.5">
            <Label>Niño/a *</Label>
            <Select
              value={selectedChildId}
              onValueChange={(val) => setValue('childId', val)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Selecciona un niño" />
              </SelectTrigger>
              <SelectContent>
                {childrenData?.data?.map((child) => (
                  <SelectItem key={child.id} value={child.id}>
                    {child.firstName} {child.lastName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.childId && (
              <p className="text-sm text-destructive">
                Selecciona un niño
              </p>
            )}
          </div>

          {/* Type select */}
          <div className="space-y-1.5">
            <Label>Tipo *</Label>
            <Select
              value={selectedType}
              onValueChange={(val) => setValue('type', val as LogType)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Tipo de registro" />
              </SelectTrigger>
              <SelectContent>
                {Object.entries(LOG_TYPE_LABELS).map(([value, label]) => (
                  <SelectItem key={value} value={value}>
                    {label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Title */}
          <Input
            label="Título *"
            placeholder="Ej: Almuerzo, Siesta de la tarde..."
            {...register('title', { required: 'El título es requerido' })}
            error={errors.title?.message}
          />

          {/* Time */}
          <Input
            label="Hora *"
            type="time"
            {...register('time', { required: 'La hora es requerida' })}
            error={errors.time?.message}
          />

          {/* Description */}
          <Textarea
            label="Descripción (opcional)"
            placeholder="Detalles adicionales del registro..."
            rows={3}
            {...register('description')}
          />

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
            >
              Cancelar
            </Button>
            <Button type="submit" loading={createLog.isPending}>
              Guardar
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
