import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  Announcement,
  CreateAnnouncementDto,
  UpdateAnnouncementDto,
  AnnouncementListResponse,
} from '@kinderspace/shared-types';

export function useAnnouncements(filters?: {
  type?: string;
  priority?: string;
  page?: number;
  limit?: number;
}) {
  return useQuery({
    queryKey: ['announcements', filters],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (filters?.type) params.append('type', filters.type);
      if (filters?.priority) params.append('priority', filters.priority);
      if (filters?.page) params.append('page', filters.page.toString());
      if (filters?.limit) params.append('limit', filters.limit.toString());

      const response = await api.get<AnnouncementListResponse>(
        `/announcements?${params.toString()}`,
      );
      return response.data;
    },
  });
}

export function useAnnouncement(id: string) {
  return useQuery({
    queryKey: ['announcements', id],
    queryFn: async () => {
      const response = await api.get<Announcement>(`/announcements/${id}`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useCreateAnnouncement() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: CreateAnnouncementDto) => {
      const response = await api.post<Announcement>('/announcements', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] });
    },
  });
}

export function useUpdateAnnouncement() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      id,
      data,
    }: {
      id: string;
      data: UpdateAnnouncementDto;
    }) => {
      const response = await api.patch<Announcement>(
        `/announcements/${id}`,
        data,
      );
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] });
    },
  });
}

export function useDeleteAnnouncement() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      await api.delete(`/announcements/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['announcements'] });
    },
  });
}
