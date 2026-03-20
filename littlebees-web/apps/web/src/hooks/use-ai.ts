import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

export interface AiMessage {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  createdAt: string;
  metadata?: any;
}

export interface AiSession {
  id: string;
  title: string;
  createdAt: string;
  updatedAt: string;
  messages?: AiMessage[];
}

export interface ChatResponse {
  message: AiMessage;
  usage?: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}

export function useAiSessions() {
  return useQuery({
    queryKey: ['ai-sessions'],
    queryFn: () => api.get<AiSession[]>('/ai/sessions'),
  });
}

export function useAiSession(sessionId: string) {
  return useQuery({
    queryKey: ['ai-session', sessionId],
    queryFn: () => api.get<AiSession>(`/ai/sessions/${sessionId}`),
    enabled: !!sessionId,
  });
}

export function useCreateAiSession() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (title?: string) => api.post<AiSession>('/ai/sessions', { title }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-sessions'] });
    },
  });
}

export function useUpdateSessionTitle() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ sessionId, title }: { sessionId: string; title: string }) =>
      api.patch<AiSession>(`/ai/sessions/${sessionId}`, { title }),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['ai-session', variables.sessionId] });
      queryClient.invalidateQueries({ queryKey: ['ai-sessions'] });
    },
  });
}

export function useDeleteAiSession() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (sessionId: string) => api.delete(`/ai/sessions/${sessionId}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-sessions'] });
    },
  });
}

export function useSendAiMessage() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ sessionId, message }: { sessionId: string; message: string }) =>
      api.post<ChatResponse>(`/ai/sessions/${sessionId}/chat`, { message }),
    onMutate: async ({ sessionId, message }) => {
      // Cancelar queries en curso
      await queryClient.cancelQueries({ queryKey: ['ai-session', sessionId] });

      // Snapshot del estado anterior
      const previousSession = queryClient.getQueryData<AiSession>(['ai-session', sessionId]);

      // Optimistically update con el mensaje del usuario
      if (previousSession) {
        const optimisticMessage: AiMessage = {
          id: `temp-${Date.now()}`,
          role: 'user',
          content: message,
          createdAt: new Date().toISOString(),
        };

        queryClient.setQueryData<AiSession>(['ai-session', sessionId], {
          ...previousSession,
          messages: [...(previousSession.messages || []), optimisticMessage],
        });
      }

      return { previousSession };
    },
    onError: (err, variables, context) => {
      // Revertir en caso de error
      if (context?.previousSession) {
        queryClient.setQueryData(['ai-session', variables.sessionId], context.previousSession);
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['ai-session', variables.sessionId] });
      queryClient.invalidateQueries({ queryKey: ['ai-sessions'] });
    },
  });
}
