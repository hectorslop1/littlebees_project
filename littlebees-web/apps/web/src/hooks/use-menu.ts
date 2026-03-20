'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export interface MenuItem {
  id: string;
  label: string;
  icon: string;
  path: string;
  order: number;
}

export interface MenuConfig {
  items: MenuItem[];
}

export function useMenu() {
  return useQuery<MenuConfig>({
    queryKey: ['menu'],
    queryFn: () => api.get('/menu'),
    staleTime: 1000 * 60 * 5, // 5 minutos
    retry: 3,
  });
}
