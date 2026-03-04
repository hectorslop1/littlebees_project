// Common response wrappers

export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export interface PaginationQuery {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

export interface ApiErrorResponse {
  statusCode: number;
  message: string;
  error: string;
  details?: Record<string, string[]>;
}

export interface SuccessResponse {
  success: boolean;
  message: string;
}
