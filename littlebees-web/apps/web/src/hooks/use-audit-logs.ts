'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type { PaginatedResponse } from '@kinderspace/shared-types';

interface AuditLog {
  id: string;
  tenantId: string;
  userId: string;
  action: string;
  resourceType: string;
  resourceId: string;
  changes: any;
  ipAddress?: string;
  userAgent?: string;
  createdAt: Date;
}

export function useAuditLogs(params?: {
  userId?: string;
  resourceType?: string;
  resourceId?: string;
  action?: string;
  page?: number;
  limit?: number;
}) {
  return useQuery({
    queryKey: ['audit-logs', params],
    queryFn: () =>
      api.get<PaginatedResponse<AuditLog>>(
        '/audit',
        params as Record<string, string>,
      ),
    enabled: !!params,
  });
}

export function useResourceAuditTrail(resourceType: string, resourceId: string) {
  return useQuery({
    queryKey: ['audit-logs', 'resource', resourceType, resourceId],
    queryFn: () =>
      api.get<AuditLog[]>(`/audit/resource/${resourceType}/${resourceId}`),
    enabled: !!(resourceType && resourceId),
  });
}
