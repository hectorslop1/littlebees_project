'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type { NotificationResponse, NotificationCountResponse } from '@kinderspace/shared-types';

interface PaginatedNotifications {
  data: NotificationResponse[];
  meta: { total: number; page: number; limit: number; totalPages: number };
}

export function useNotifications(params?: { read?: boolean; type?: string; page?: number; limit?: number }) {
  return useQuery({
    queryKey: ['notifications', params],
    queryFn: () => api.get<PaginatedNotifications>('/notifications', params as Record<string, string>),
  });
}

export function useNotificationCount() {
  return useQuery({
    queryKey: ['notifications', 'count'],
    queryFn: () => api.get<NotificationCountResponse>('/notifications/count'),
    refetchInterval: 30000,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.patch(`/notifications/${id}/read`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => api.patch('/notifications/read-all'),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}
