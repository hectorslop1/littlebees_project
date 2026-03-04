export interface AuditLogResponse {
  id: string;
  userId: string;
  action: string;
  resourceType: string;
  resourceId: string | null;
  changes: Record<string, unknown> | null;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: string;
}

export interface AuditLogQuery {
  resourceType?: string;
  resourceId?: string;
  userId?: string;
  action?: string;
  startDate?: string;
  endDate?: string;
  page?: number;
  limit?: number;
}
