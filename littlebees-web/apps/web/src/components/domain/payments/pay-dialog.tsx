'use client';

import { useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import type { PaymentResponse } from '@kinderspace/shared-types';
import { PaymentMethodType } from '@kinderspace/shared-types';

interface PayDialogProps {
  payment: PaymentResponse | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: (paymentMethod: PaymentMethodType) => void;
}

const currencyFormatter = new Intl.NumberFormat('es-MX', {
  style: 'currency',
  currency: 'MXN',
  minimumFractionDigits: 2,
});

const paymentMethods: { value: PaymentMethodType; label: string }[] = [
  { value: PaymentMethodType.CARD, label: 'Tarjeta' },
  { value: PaymentMethodType.OXXO, label: 'OXXO' },
  { value: PaymentMethodType.SPEI, label: 'SPEI' },
];

export function PayDialog({
  payment,
  open,
  onOpenChange,
  onConfirm,
}: PayDialogProps) {
  const [selectedMethod, setSelectedMethod] = useState<PaymentMethodType>(
    PaymentMethodType.CARD,
  );

  function handleConfirm() {
    onConfirm(selectedMethod);
    setSelectedMethod(PaymentMethodType.CARD);
  }

  function handleClose(value: boolean) {
    if (!value) {
      setSelectedMethod(PaymentMethodType.CARD);
    }
    onOpenChange(value);
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Confirmar Pago</DialogTitle>
        </DialogHeader>

        {payment && (
          <div className="space-y-4">
            <div className="rounded-xl bg-gray-50 p-4 space-y-2">
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">Concepto</span>
                <span className="text-sm font-medium">{payment.concept}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">Alumno</span>
                <span className="text-sm font-medium">{payment.childName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-muted-foreground">Monto</span>
                <span className="text-sm font-bold text-foreground">
                  {currencyFormatter.format(payment.amount)}
                </span>
              </div>
            </div>

            <div className="space-y-2">
              <Label>M\u00e9todo de pago</Label>
              <div className="grid grid-cols-3 gap-2">
                {paymentMethods.map((method) => (
                  <button
                    key={method.value}
                    type="button"
                    className={`rounded-xl border px-3 py-2 text-sm font-medium transition-colors ${
                      selectedMethod === method.value
                        ? 'border-primary bg-primary-50 text-primary'
                        : 'border-input bg-background text-foreground hover:bg-gray-50'
                    }`}
                    onClick={() => setSelectedMethod(method.value)}
                  >
                    {method.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            onClick={() => handleClose(false)}
          >
            Cancelar
          </Button>
          <Button type="button" onClick={handleConfirm}>
            Confirmar Pago
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
