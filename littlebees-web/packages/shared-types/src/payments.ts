import { InvoiceStatus, PaymentMethodType, PaymentStatus } from './enums';

export interface PaymentResponse {
  id: string;
  childId: string;
  childName: string;
  concept: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  dueDate: string;
  paidAt: string | null;
  paymentMethod: PaymentMethodType | null;
  createdAt: string;
}

export interface CreatePaymentRequest {
  childId: string;
  concept: string;
  amount: number;
  dueDate: string;
}

export interface ProcessPaymentRequest {
  paymentMethodId: string;
}

export interface PaymentMethodResponse {
  id: string;
  type: PaymentMethodType;
  lastFour: string | null;
  brand: string | null;
  isDefault: boolean;
}

export interface CreatePaymentMethodRequest {
  type: PaymentMethodType;
  gatewayToken: string;
}

// CFDI 4.0 Invoice
export interface InvoiceResponse {
  id: string;
  paymentId: string;
  folio: string;
  uuidFiscal: string;
  rfcEmisor: string;
  rfcReceptor: string;
  total: number;
  status: InvoiceStatus;
  pdfUrl: string;
  xmlUrl: string;
  issuedAt: string;
}

export interface CreateInvoiceRequest {
  paymentId: string;
  rfcReceptor: string;
  razonSocial: string;
  regimenFiscal: string;
  usoCfdi: string;
  codigoPostal: string;
}
