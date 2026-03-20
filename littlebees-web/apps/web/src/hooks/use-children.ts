'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  ChildResponse,
  CreateChildRequest,
  PaginatedResponse,
} from '@kinderspace/shared-types';

export function useChildren(params?: {
  groupId?: string;
  status?: string;
  search?: string;
}) {
  return useQuery({
    queryKey: ['children', params],
    queryFn: () =>
      api.get<PaginatedResponse<ChildResponse>>(
        '/children',
        params as Record<string, string>,
      ),
  });
}

export function useChild(id: string) {
  return useQuery({
    queryKey: ['children', id],
    queryFn: () => api.get<ChildResponse>(`/children/${id}`),
    enabled: !!id,
  });
}

export function useChildProfile(id: string) {
  return useQuery({
    queryKey: ['children', id, 'profile'],
    queryFn: () => api.get<any>(`/children/${id}/profile`),
    enabled: !!id,
  });
}

export function useCreateChild() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateChildRequest) =>
      api.post<ChildResponse>('/children', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['children'] }),
  });
}

export function useUpdateChild() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<CreateChildRequest> }) =>
      api.patch<ChildResponse>(`/children/${id}`, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['children'] });
    },
  });
}

export function useDeleteChild() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.delete(`/children/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['children'] }),
  });
}

export function useUpdateChildStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      api.patch<ChildResponse>(`/children/${id}`, { status }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['children'] });
    },
  });
}
