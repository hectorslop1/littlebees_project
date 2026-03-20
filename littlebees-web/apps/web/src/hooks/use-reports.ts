'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  AttendanceReportResponse,
  DevelopmentReportResponse,
  PaymentReportResponse,
} from '@kinderspace/shared-types';

export function useAttendanceReport(params: {
  from: string;
  to: string;
  groupId?: string;
}) {
  return useQuery({
    queryKey: ['reports', 'attendance', params],
    queryFn: () =>
      api.get<AttendanceReportResponse>(
        '/reports/attendance',
        params as Record<string, string>,
      ),
    enabled: !!params.from && !!params.to,
  });
}

export function useDevelopmentReport(params: {
  from: string;
  to: string;
  groupId?: string;
}) {
  return useQuery({
    queryKey: ['reports', 'development', params],
    queryFn: () =>
      api.get<DevelopmentReportResponse>(
        '/reports/development',
        params as Record<string, string>,
      ),
    enabled: !!params.from && !!params.to,
  });
}

export function usePaymentReport(params: {
  from: string;
  to: string;
}) {
  return useQuery({
    queryKey: ['reports', 'payments', params],
    queryFn: () =>
      api.get<PaymentReportResponse>(
        '/reports/payments',
        params as Record<string, string>,
      ),
    enabled: !!params.from && !!params.to,
  });
}

export function useActivitiesReport(params: {
  from: string;
  to: string;
  groupId?: string;
}) {
  return useQuery({
    queryKey: ['reports', 'activities', params],
    queryFn: () =>
      api.get<any>(
        '/reports/activities',
        params as Record<string, string>,
      ),
    enabled: !!params.from && !!params.to,
  });
}
