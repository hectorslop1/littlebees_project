'use client';

import { useQuery, useMutation, useQueryClient, useInfiniteQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import type {
  ConversationResponse,
  MessageResponse,
  SendMessageRequest,
  CreateConversationRequest,
} from '@kinderspace/shared-types';

// --- Conversaciones ---

export function useConversations() {
  return useQuery({
    queryKey: ['chat', 'conversations'],
    queryFn: () => api.get<ConversationResponse[]>('/chat/conversations'),
  });
}

// --- Mensajes con paginacion por cursor ---

interface MessagesPage {
  data: MessageResponse[];
  nextCursor: string | null;
}

export function useMessages(conversationId: string | null) {
  return useInfiniteQuery({
    queryKey: ['chat', 'messages', conversationId],
    queryFn: ({ pageParam }) => {
      const params: Record<string, string | number> = { limit: 30 };
      if (pageParam) {
        params.cursor = pageParam;
      }
      return api.get<MessagesPage>(
        `/chat/conversations/${conversationId}/messages`,
        params,
      );
    },
    initialPageParam: null as string | null,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    enabled: !!conversationId,
    select: (data) => ({
      pages: data.pages,
      pageParams: data.pageParams,
    }),
  });
}

// --- Enviar mensaje ---

export function useSendMessage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      conversationId,
      ...body
    }: SendMessageRequest & { conversationId: string }) =>
      api.post<MessageResponse>(
        `/chat/conversations/${conversationId}/messages`,
        body,
      ),
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({
        queryKey: ['chat', 'messages', variables.conversationId],
      });
      queryClient.invalidateQueries({
        queryKey: ['chat', 'conversations'],
      });
      queryClient.invalidateQueries({
        queryKey: ['chat', 'unread-count'],
      });
    },
  });
}

// --- Conteo de no leidos ---

export function useUnreadCount() {
  return useQuery({
    queryKey: ['chat', 'unread-count'],
    queryFn: () => api.get<{ count: number }>('/chat/unread-count'),
    refetchInterval: 30000,
  });
}

// --- Marcar conversacion como leida ---

export function useMarkConversationRead() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (conversationId: string) =>
      api.patch(`/chat/conversations/${conversationId}/read`),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: ['chat', 'conversations'],
      });
      queryClient.invalidateQueries({
        queryKey: ['chat', 'unread-count'],
      });
    },
  });
}

// --- Crear conversacion ---

export function useCreateConversation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateConversationRequest) =>
      api.post<ConversationResponse>('/chat/conversations', data),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: ['chat', 'conversations'],
      });
    },
  });
}
