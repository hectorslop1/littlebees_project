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

export function useCreateChild() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateChildRequest) =>
      api.post<ChildResponse>('/children', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['children'] }),
  });
}
