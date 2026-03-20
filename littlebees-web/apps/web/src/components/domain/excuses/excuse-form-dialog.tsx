'use client';

import { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import type { CreateExcuseDto } from '@/hooks/use-excuses';

interface ExcuseFormDialogProps {
  children: Array<{ id: string; firstName: string; lastName: string }>;
  onClose: () => void;
  onSubmit: (data: CreateExcuseDto) => Promise<void>;
}

const EXCUSE_TYPES = [
  { value: 'sick', label: 'Enfermedad' },
  { value: 'late_arrival', label: 'Llegada tarde' },
  { value: 'absence', label: 'Ausencia' },
  { value: 'other', label: 'Otro' },
];

export function ExcuseFormDialog({ children, onClose, onSubmit }: ExcuseFormDialogProps) {
  const [formData, setFormData] = useState<CreateExcuseDto>({
    childId: '',
    type: 'sick',
    reason: '',
    startDate: new Date().toISOString().split('T')[0],
    endDate: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await onSubmit({
        ...formData,
        endDate: formData.endDate || undefined,
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>Nuevo Justificante</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="childId">Niño/a *</Label>
            <Select
              value={formData.childId}
              onValueChange={(value) => setFormData({ ...formData, childId: value })}
              required
            >
              <SelectTrigger id="childId">
                <SelectValue placeholder="Selecciona un niño/a" />
              </SelectTrigger>
              <SelectContent>
                {children.map((child) => (
                  <SelectItem key={child.id} value={child.id}>
                    {child.firstName} {child.lastName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="type">Tipo de justificante *</Label>
            <Select
              value={formData.type}
              onValueChange={(value: any) => setFormData({ ...formData, type: value })}
              required
            >
              <SelectTrigger id="type">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {EXCUSE_TYPES.map((type) => (
                  <SelectItem key={type.value} value={type.value}>
                    {type.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="reason">Motivo *</Label>
            <Textarea
              id="reason"
              value={formData.reason}
              onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
              placeholder="Describe el motivo del justificante..."
              rows={4}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="startDate">Fecha inicio *</Label>
              <input
                type="date"
                id="startDate"
                value={formData.startDate}
                onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="endDate">Fecha fin (opcional)</Label>
              <input
                type="date"
                id="endDate"
                value={formData.endDate}
                onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                min={formData.startDate}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              />
            </div>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" onClick={onClose} disabled={isSubmitting}>
              Cancelar
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? 'Enviando...' : 'Enviar Justificante'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
