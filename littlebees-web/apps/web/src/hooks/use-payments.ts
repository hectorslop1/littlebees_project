'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  PaymentResponse,
  CreatePaymentRequest,
  PaginatedResponse,
} from '@kinderspace/shared-types';

export function usePayments(params?: {
  status?: string;
  childId?: string;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
}) {
  return useQuery({
    queryKey: ['payments', params],
    queryFn: () =>
      api.get<PaginatedResponse<PaymentResponse>>(
        '/payments',
        params as Record<string, string | number>,
      ),
  });
}

export interface OverduePaymentsResponse {
  totalOverdue: number;
  count: number;
  payments: PaymentResponse[];
}

export function useOverduePayments() {
  return useQuery({
    queryKey: ['payments', 'overdue'],
    queryFn: () =>
      api.get<OverduePaymentsResponse>('/payments/overdue'),
  });
}

export function useMarkPaid(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { paymentMethod: string }) =>
      api.post<PaymentResponse>(`/payments/${id}/mark-paid`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['payments'] });
    },
  });
}

export function useCreatePayment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreatePaymentRequest) =>
      api.post<PaymentResponse>('/payments', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['payments'] }),
  });
}

export function useCancelPayment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) =>
      api.post<PaymentResponse>(`/payments/${id}/cancel`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['payments'] }),
  });
}
