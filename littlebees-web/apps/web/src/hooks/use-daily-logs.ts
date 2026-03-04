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
