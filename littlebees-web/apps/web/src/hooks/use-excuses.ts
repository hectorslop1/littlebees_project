import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export interface Excuse {
  id: string;
  childId: string;
  childName: string;
  type: 'sick' | 'late_arrival' | 'absence' | 'other';
  reason: string;
  startDate: string;
  endDate?: string;
  status: 'pending' | 'approved' | 'rejected';
  reviewedBy?: string;
  reviewedByName?: string;
  reviewedAt?: string;
  rejectionReason?: string;
  createdAt: string;
}

export interface CreateExcuseDto {
  childId: string;
  type: 'sick' | 'late_arrival' | 'absence' | 'other';
  reason: string;
  startDate: string;
  endDate?: string;
}

export interface UpdateExcuseStatusDto {
  status: 'approved' | 'rejected';
  rejectionReason?: string;
}

interface ExcusesParams {
  childId?: string;
  status?: 'pending' | 'approved' | 'rejected';
  startDate?: string;
  endDate?: string;
}

export function useExcuses(params?: ExcusesParams) {
  return useQuery({
    queryKey: ['excuses', params],
    queryFn: async () => {
      const searchParams = new URLSearchParams();
      if (params?.childId) searchParams.append('childId', params.childId);
      if (params?.status) searchParams.append('status', params.status);
      if (params?.startDate) searchParams.append('startDate', params.startDate);
      if (params?.endDate) searchParams.append('endDate', params.endDate);
      
      const url = `/excuses${searchParams.toString() ? `?${searchParams.toString()}` : ''}`;
      return api.get<Excuse[]>(url);
    },
  });
}

export function useExcuse(id: string) {
  return useQuery({
    queryKey: ['excuse', id],
    queryFn: () => api.get<Excuse>(`/excuses/${id}`),
    enabled: !!id,
  });
}

export function useChildExcuses(childId: string) {
  return useQuery({
    queryKey: ['excuses', 'child', childId],
    queryFn: () => api.get<Excuse[]>(`/excuses/child/${childId}`),
    enabled: !!childId,
  });
}

export function useCreateExcuse() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateExcuseDto) => api.post<Excuse>('/excuses', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['excuses'] });
    },
  });
}

export function useUpdateExcuseStatus() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateExcuseStatusDto }) =>
      api.patch<Excuse>(`/excuses/${id}/status`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['excuses'] });
    },
  });
}

export function useDeleteExcuse() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: string) => api.delete(`/excuses/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['excuses'] });
    },
  });
}
