export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page?: number;
    limit?: number;
    totalPages?: number;
  };
}

export function createPaginatedResponse<T>(
  data: T[],
  total?: number,
  page?: number,
  limit?: number,
): PaginatedResponse<T> {
  const actualTotal = total ?? data.length;
  
  if (page !== undefined && limit !== undefined) {
    return {
      data,
      meta: {
        total: actualTotal,
        page,
        limit,
        totalPages: Math.ceil(actualTotal / limit),
      },
    };
  }

  return {
    data,
    meta: {
      total: actualTotal,
    },
  };
}
