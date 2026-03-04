'use client';

import { useEffect, useRef, useMemo, useCallback } from 'react';
import { ChevronUp } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { useMessages, useSendMessage } from '@/hooks/use-chat';
import { useSocket } from '@/hooks/use-socket';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { EmptyState } from '@/components/ui/empty-state';
import { MessageSquare } from 'lucide-react';
import { MessageBubble } from './message-bubble';
import { MessageInput } from './message-input';
import { TypingIndicator } from './typing-indicator';
import type { ConversationResponse } from '@kinderspace/shared-types';

interface MessageAreaProps {
  conversationId: string;
  conversation?: ConversationResponse;
}

export function MessageArea({ conversationId, conversation }: MessageAreaProps) {
  const { user } = useAuth();
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const bottomRef = useRef<HTMLDivElement>(null);
  const isInitialLoadRef = useRef(true);

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useMessages(conversationId);

  const sendMessage = useSendMessage();

  const { typingUsers, emitTypingStart, emitTypingStop } = useSocket({
    activeConversationId: conversationId,
  });

  // Obtener nombres de los usuarios escribiendo a partir de los participantes
  const typingUserNames = useMemo(() => {
    if (!conversation) return typingUsers;
    return typingUsers
      .filter((userId) => userId !== user?.id)
      .map((userId) => {
        const participant = conversation.participants.find(
          (p) => p.userId === userId,
        );
        return participant?.name ?? 'Alguien';
      });
  }, [typingUsers, conversation, user?.id]);

  // Todos los mensajes aplanados y ordenados cronologicamente
  const messages = useMemo(() => {
    if (!data?.pages) return [];
    // Las paginas vienen de mas reciente a mas antigua (cursor-based),
    // invertir para mostrar del mas antiguo al mas reciente
    const allMessages = data.pages
      .slice()
      .reverse()
      .flatMap((page) => page.data);
    return allMessages;
  }, [data]);

  // Auto-scroll al fondo cuando llegan mensajes nuevos (solo si ya estaba abajo)
  useEffect(() => {
    if (isInitialLoadRef.current && messages.length > 0) {
      // En la carga inicial, ir directamente al fondo
      bottomRef.current?.scrollIntoView();
      isInitialLoadRef.current = false;
      return;
    }

    const container = scrollContainerRef.current;
    if (!container) return;

    // Solo auto-scroll si el usuario ya esta cerca del fondo
    const isNearBottom =
      container.scrollHeight - container.scrollTop - container.clientHeight < 100;

    if (isNearBottom) {
      bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages]);

  // Reset al cambiar de conversacion
  useEffect(() => {
    isInitialLoadRef.current = true;
  }, [conversationId]);

  const handleSend = useCallback(
    (content: string) => {
      sendMessage.mutate({
        conversationId,
        content,
      });
    },
    [conversationId, sendMessage],
  );

  const handleLoadMore = useCallback(() => {
    if (hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  if (isLoading) {
    return (
      <div className="flex h-full items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="flex h-full flex-col">
      {/* Encabezado de la conversacion */}
      {conversation && (
        <div className="flex items-center gap-3 border-b border-gray-100 px-4 py-3">
          <div>
            <p className="text-sm font-semibold text-foreground">
              {conversation.childName}
            </p>
            <p className="text-xs text-muted-foreground">
              {conversation.participants.length} participante{conversation.participants.length !== 1 ? 's' : ''}
            </p>
          </div>
        </div>
      )}

      {/* Area de mensajes */}
      <div
        ref={scrollContainerRef}
        className="flex-1 overflow-y-auto py-4"
      >
        {/* Boton para cargar mensajes anteriores */}
        {hasNextPage && (
          <div className="mb-4 flex justify-center">
            <Button
              variant="ghost"
              size="sm"
              onClick={handleLoadMore}
              loading={isFetchingNextPage}
            >
              <ChevronUp className="h-4 w-4" />
              Cargar mensajes anteriores
            </Button>
          </div>
        )}

        {messages.length === 0 ? (
          <EmptyState
            icon={<MessageSquare />}
            title="Inicia la conversacion"
            description="Envia un mensaje para comenzar a platicar."
            className="py-8"
          />
        ) : (
          <div className="space-y-1">
            {messages.map((message) => (
              <MessageBubble
                key={message.id}
                message={message}
                isOwn={message.senderId === user?.id}
              />
            ))}
          </div>
        )}

        {/* Indicador de escritura */}
        <TypingIndicator users={typingUserNames} />

        {/* Ancla para scroll al fondo */}
        <div ref={bottomRef} />
      </div>

      {/* Input de mensaje */}
      <MessageInput
        onSend={handleSend}
        onTypingStart={emitTypingStart}
        onTypingStop={emitTypingStop}
        disabled={sendMessage.isPending}
      />
    </div>
  );
}
