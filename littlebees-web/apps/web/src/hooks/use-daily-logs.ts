'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  DailyLogEntryResponse,
  CreateDailyLogRequest,
  PaginatedResponse,
} from '@kinderspace/shared-types';

export function useDailyLogs(params: { childId?: string; date?: string }) {
  return useQuery({
    queryKey: ['daily-logs', params],
    queryFn: () =>
      api.get<PaginatedResponse<DailyLogEntryResponse>>(
        '/daily-logs',
        params as Record<string, string>,
      ),
    enabled: !!(params.childId || params.date),
  });
}

export function useCreateDailyLog() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateDailyLogRequest) =>
      api.post<DailyLogEntryResponse>('/daily-logs', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['daily-logs'] }),
  });
}

export function useQuickRegister() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: {
      childId: string;
      type: 'check_in' | 'meal' | 'nap' | 'activity' | 'check_out';
      metadata?: {
        photoUrl?: string;
        notes?: string;
        mood?: string;
        foodEaten?: string;
        napDuration?: number;
        activityDescription?: string;
      };
    }) => api.post<any>('/daily-logs/quick-register', data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['daily-logs'] });
      qc.invalidateQueries({ queryKey: ['attendance'] });
      qc.invalidateQueries({ queryKey: ['day-schedule'] });
    },
  });
}

export function useDaySchedule(groupId: string, date?: string) {
  return useQuery({
    queryKey: ['day-schedule', groupId, date],
    queryFn: () =>
      api.get<any>(`/daily-logs/day-schedule/${groupId}`, date ? { date } : {}),
    enabled: !!groupId,
  });
}
