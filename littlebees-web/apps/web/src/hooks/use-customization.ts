'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export interface Customization {
  id: string;
  tenantId: string;
  logoUrl?: string;
  primaryColor: string;
  secondaryColor: string;
  accentColor?: string;
  systemName: string;
  menuLabels: Record<string, string>;
  customCss?: string;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateCustomizationDto {
  logoUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  systemName?: string;
  menuLabels?: Record<string, string>;
  customCss?: string;
}

export function useCustomization() {
  return useQuery({
    queryKey: ['customization'],
    queryFn: () => api.get<Customization>('/customization'),
    staleTime: 5 * 60 * 1000, // 5 minutos
  });
}

export function useUpdateCustomization() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateCustomizationDto) =>
      api.patch<Customization>('/customization', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['customization'] });
    },
  });
}

export function useResetCustomization() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => api.post<Customization>('/customization/reset'),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['customization'] });
    },
  });
}
