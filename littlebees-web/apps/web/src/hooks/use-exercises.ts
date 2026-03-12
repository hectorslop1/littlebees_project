import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  Exercise,
  CreateExerciseDto,
  UpdateExerciseDto,
  ExerciseListResponse,
} from '@kinderspace/shared-types';

export function useExercises(filters?: {
  category?: string;
  childId?: string;
  page?: number;
  limit?: number;
}) {
  return useQuery({
    queryKey: ['exercises', filters],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (filters?.category) params.append('category', filters.category);
      if (filters?.childId) params.append('childId', filters.childId);
      if (filters?.page) params.append('page', filters.page.toString());
      if (filters?.limit) params.append('limit', filters.limit.toString());

      const response = await api.get<ExerciseListResponse>(
        `/exercises?${params.toString()}`,
      );
      return response.data;
    },
  });
}

export function useExercise(id: string) {
  return useQuery({
    queryKey: ['exercises', id],
    queryFn: async () => {
      const response = await api.get<Exercise>(`/exercises/${id}`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useCreateExercise() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: CreateExerciseDto) => {
      const response = await api.post<Exercise>('/exercises', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['exercises'] });
    },
  });
}

export function useUpdateExercise() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      id,
      data,
    }: {
      id: string;
      data: UpdateExerciseDto;
    }) => {
      const response = await api.patch<Exercise>(`/exercises/${id}`, data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['exercises'] });
    },
  });
}

export function useDeleteExercise() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      await api.delete(`/exercises/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['exercises'] });
    },
  });
}

export function useToggleExerciseCompleted() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      exerciseId,
      childId,
    }: {
      exerciseId: string;
      childId: string;
    }) => {
      const response = await api.post(
        `/exercises/${exerciseId}/children/${childId}/toggle`,
      );
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['exercises'] });
    },
  });
}
