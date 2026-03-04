'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  AttendanceRecordResponse,
  CheckInRequest,
  CheckOutRequest,
  PaginatedResponse,
} from '@kinderspace/shared-types';

export function useAttendance(date: string) {
  return useQuery({
    queryKey: ['attendance', date],
    queryFn: () =>
      api.get<PaginatedResponse<AttendanceRecordResponse>>('/attendance', {
        date,
      }),
    enabled: !!date,
  });
}

export function useCheckIn() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CheckInRequest) =>
      api.post<AttendanceRecordResponse>('/attendance/check-in', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['attendance'] }),
  });
}

export function useCheckOut() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: CheckOutRequest) =>
      api.post<AttendanceRecordResponse>('/attendance/check-out', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['attendance'] }),
  });
}
