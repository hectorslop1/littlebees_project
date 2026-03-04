'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get('/users'),
  });
}

export function useUpdateProfile() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { firstName?: string; lastName?: string; phone?: string }) =>
      api.patch('/users/profile', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['users'] }),
  });
}
