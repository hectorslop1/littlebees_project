'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  ExtraServiceResponse,
  PaginatedResponse,
  CreateExtraServiceRequest,
  UpdateExtraServiceRequest,
} from '@kinderspace/shared-types';

export function useServices(params?: {
  type?: string;
  status?: string;
  search?: string;
}) {
  return useQuery({
    queryKey: ['services', params],
    queryFn: () =>
      api.get<PaginatedResponse<ExtraServiceResponse>>(
        '/services',
        params as Record<string, string>,
      ),
  });
}

export function useCreateService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateExtraServiceRequest) =>
      api.post<ExtraServiceResponse>('/services', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['services'] }),
  });
}

export function useUpdateService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateExtraServiceRequest }) =>
      api.patch<ExtraServiceResponse>(`/services/${id}`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['services'] }),
  });
}

export function useDeleteService() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/services/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['services'] }),
  });
}
