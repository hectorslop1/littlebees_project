'use client';

import { useForm } from 'react-hook-form';
import { toast } from 'sonner';
import { MilestoneStatus } from '@kinderspace/shared-types';
import type { CreateDevelopmentRecordRequest } from '@kinderspace/shared-types';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useMilestones, useCreateDevelopmentRecord } from '@/hooks/use-development';

const STATUS_LABELS: Record<MilestoneStatus, string> = {
  [MilestoneStatus.ACHIEVED]: 'Logrado',
  [MilestoneStatus.IN_PROGRESS]: 'En Progreso',
  [MilestoneStatus.NOT_ACHIEVED]: 'No Logrado',
};

interface EvaluationFormDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  childId: string;
  onSuccess?: () => void;
}

interface EvaluationFormValues {
  milestoneId: string;
  status: MilestoneStatus;
  observations: string;
}

export function EvaluationFormDialog({
  open,
  onOpenChange,
  childId,
  onSuccess,
}: EvaluationFormDialogProps) {
  const { data: milestonesData } = useMilestones();
  const createRecord = useCreateDevelopmentRecord();

  const milestones = milestonesData?.data ?? [];

  const {
    handleSubmit,
    setValue,
    watch,
    register,
    reset,
    formState: { errors },
  } = useForm<EvaluationFormValues>({
    defaultValues: {
      milestoneId: '',
      status: MilestoneStatus.IN_PROGRESS,
      observations: '',
    },
  });

  const selectedMilestoneId = watch('milestoneId');
  const selectedStatus = watch('status');

  const onSubmit = async (values: EvaluationFormValues) => {
    if (!values.milestoneId) {
      toast.error('Selecciona un hito para evaluar');
      return;
    }

    const payload: CreateDevelopmentRecordRequest = {
      childId,
      milestoneId: values.milestoneId,
      status: values.status,
      ...(values.observations ? { observations: values.observations } : {}),
    };

    try {
      await createRecord.mutateAsync(payload);
      toast.success('Evaluación registrada exitosamente');
      reset();
      onOpenChange(false);
      onSuccess?.();
    } catch {
      toast.error('Error al registrar la evaluación');
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Nueva Evaluación</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Milestone select */}
          <div className="space-y-1.5">
            <Label>Hito *</Label>
            <Select
              value={selectedMilestoneId}
              onValueChange={(val) => setValue('milestoneId', val)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Selecciona un hito" />
              </SelectTrigger>
              <SelectContent>
                {milestones.map((milestone) => (
                  <SelectItem key={milestone.id} value={milestone.id}>
                    {milestone.title}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.milestoneId && (
              <p className="text-sm text-destructive">
                Selecciona un hito
              </p>
            )}
          </div>

          {/* Status select */}
          <div className="space-y-1.5">
            <Label>Estado *</Label>
            <Select
              value={selectedStatus}
              onValueChange={(val) =>
                setValue('status', val as MilestoneStatus)
              }
            >
              <SelectTrigger>
                <SelectValue placeholder="Estado de la evaluación" />
              </SelectTrigger>
              <SelectContent>
                {Object.entries(STATUS_LABELS).map(([value, label]) => (
                  <SelectItem key={value} value={value}>
                    {label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Observations */}
          <Textarea
            label="Observaciones (opcional)"
            placeholder="Notas adicionales sobre la evaluación..."
            rows={3}
            {...register('observations')}
          />

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
            >
              Cancelar
            </Button>
            <Button type="submit" loading={createRecord.isPending}>
              Guardar
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
