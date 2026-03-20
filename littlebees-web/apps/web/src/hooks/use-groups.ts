'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type { GroupResponse } from '@kinderspace/shared-types';

export function useGroups() {
  return useQuery({
    queryKey: ['groups'],
    queryFn: async () => {
      const response = await api.get<{ data: GroupResponse[] }>('/groups');
      return response.data;
    },
  });
}

export function useGroup(id: string) {
  return useQuery({
    queryKey: ['groups', id],
    queryFn: async () => {
      const response = await api.get<GroupResponse>(`/groups/${id}`);
      return response;
    },
    enabled: !!id,
  });
}

export function useCreateGroup() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (data: any) => {
      const response = await api.post<GroupResponse>('/groups', data);
      return response;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['groups'] });
    },
  });
}

export function useUpdateGroup() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: any }) => {
      const response = await api.patch<GroupResponse>(`/groups/${id}`, data);
      return response;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['groups'] });
    },
  });
}

export function useDeleteGroup() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      await api.delete(`/groups/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['groups'] });
    },
  });
}
