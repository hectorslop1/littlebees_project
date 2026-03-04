'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'sonner';
import { useCreateInvoice } from '@/hooks/use-invoices';
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

const invoiceFormSchema = z.object({
  rfcReceptor: z
    .string()
    .min(12, 'El RFC debe tener al menos 12 caracteres')
    .max(13, 'El RFC debe tener como m\u00e1ximo 13 caracteres'),
  razonSocial: z.string().min(1, 'La raz\u00f3n social es obligatoria'),
  regimenFiscal: z
    .string()
    .length(3, 'El r\u00e9gimen fiscal debe tener 3 caracteres'),
  usoCfdi: z
    .string()
    .length(3, 'El uso de CFDI debe tener 3 caracteres'),
  codigoPostal: z
    .string()
    .length(5, 'El c\u00f3digo postal debe tener 5 d\u00edgitos'),
});

type InvoiceFormValues = z.infer<typeof invoiceFormSchema>;

interface InvoiceDialogProps {
  paymentId: string | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function InvoiceDialog({
  paymentId,
  open,
  onOpenChange,
}: InvoiceDialogProps) {
  const createInvoice = useCreateInvoice();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<InvoiceFormValues>({
    resolver: zodResolver(invoiceFormSchema),
    defaultValues: {
      rfcReceptor: '',
      razonSocial: '',
      regimenFiscal: '',
      usoCfdi: '',
      codigoPostal: '',
    },
  });

  async function onSubmit(data: InvoiceFormValues) {
    if (!paymentId) return;

    try {
      await createInvoice.mutateAsync({
        paymentId,
        ...data,
      });
      toast.success('Factura generada exitosamente');
      reset();
      onOpenChange(false);
    } catch {
      toast.error('Error al generar la factura. Intenta de nuevo.');
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
          <DialogTitle>Generar Factura (CFDI)</DialogTitle>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <Label htmlFor="rfcReceptor">RFC del Receptor</Label>
            <Input
              id="rfcReceptor"
              placeholder="XAXX010101000"
              error={errors.rfcReceptor?.message}
              {...register('rfcReceptor')}
            />
          </div>

          <div>
            <Label htmlFor="razonSocial">Raz\u00f3n Social</Label>
            <Input
              id="razonSocial"
              placeholder="Nombre o raz\u00f3n social"
              error={errors.razonSocial?.message}
              {...register('razonSocial')}
            />
          </div>

          <div>
            <Label htmlFor="regimenFiscal">R\u00e9gimen Fiscal</Label>
            <Input
              id="regimenFiscal"
              placeholder="601"
              maxLength={3}
              error={errors.regimenFiscal?.message}
              {...register('regimenFiscal')}
            />
          </div>

          <div>
            <Label htmlFor="usoCfdi">Uso de CFDI</Label>
            <Input
              id="usoCfdi"
              placeholder="G03"
              maxLength={3}
              error={errors.usoCfdi?.message}
              {...register('usoCfdi')}
            />
          </div>

          <div>
            <Label htmlFor="codigoPostal">C\u00f3digo Postal</Label>
            <Input
              id="codigoPostal"
              placeholder="06600"
              maxLength={5}
              error={errors.codigoPostal?.message}
              {...register('codigoPostal')}
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
            <Button type="submit" loading={createInvoice.isPending}>
              Generar Factura
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
