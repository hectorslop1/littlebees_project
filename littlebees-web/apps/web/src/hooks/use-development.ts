'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  MilestoneResponse,
  DevelopmentRecordResponse,
  DevelopmentSummaryResponse,
  CreateDevelopmentRecordRequest,
  PaginatedResponse,
} from '@kinderspace/shared-types';

export function useMilestones(params?: {
  category?: string;
  ageRangeMin?: number;
  ageRangeMax?: number;
}) {
  return useQuery({
    queryKey: ['milestones', params],
    queryFn: () =>
      api.get<PaginatedResponse<MilestoneResponse>>(
        '/development/milestones',
        params as Record<string, string>,
      ),
  });
}

export function useDevelopmentRecords(params?: {
  childId?: string;
  category?: string;
  status?: string;
}) {
  return useQuery({
    queryKey: ['development-records', params],
    queryFn: () =>
      api.get<PaginatedResponse<DevelopmentRecordResponse>>(
        '/development/records',
        params as Record<string, string>,
      ),
    enabled: !!params?.childId,
  });
}

export function useDevelopmentSummary(childId: string) {
  return useQuery({
    queryKey: ['development-summary', childId],
    queryFn: () =>
      api.get<DevelopmentSummaryResponse>(
        `/development/children/${childId}/summary`,
      ),
    enabled: !!childId,
  });
}

export function useCreateDevelopmentRecord() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CreateDevelopmentRecordRequest) =>
      api.post<DevelopmentRecordResponse>('/development/records', data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['development-records'] });
      qc.invalidateQueries({ queryKey: ['development-summary'] });
    },
  });
}
