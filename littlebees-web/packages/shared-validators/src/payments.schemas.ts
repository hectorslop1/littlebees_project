import { z } from 'zod';

export const createPaymentSchema = z.object({
  childId: z.string().uuid(),
  concept: z.string().min(1).max(255),
  amount: z.number().positive('El monto debe ser positivo'),
  dueDate: z.string().datetime(),
});

export const processPaymentSchema = z.object({
  paymentMethodId: z.string().uuid(),
});

export const createInvoiceSchema = z.object({
  paymentId: z.string().uuid(),
  rfcReceptor: z
    .string()
    .min(12)
    .max(13)
    .regex(/^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/, 'RFC inválido'),
  razonSocial: z.string().min(1).max(300),
  regimenFiscal: z.string().length(3, 'Régimen fiscal inválido'),
  usoCfdi: z.string().length(3, 'Uso de CFDI inválido'),
  codigoPostal: z.string().length(5, 'Código postal inválido'),
});

export type CreatePaymentInput = z.infer<typeof createPaymentSchema>;
export type ProcessPaymentInput = z.infer<typeof processPaymentSchema>;
export type CreateInvoiceInput = z.infer<typeof createInvoiceSchema>;
