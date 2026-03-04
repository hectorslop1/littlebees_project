'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export function useInvoicesByPayment(paymentId: string) {
  return useQuery({
    queryKey: ['invoices', 'payment', paymentId],
    queryFn: () => api.get(`/invoices/payment/${paymentId}`),
    enabled: !!paymentId,
  });
}

export function useCreateInvoice() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: any) => api.post('/invoices', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['invoices'] }),
  });
}
