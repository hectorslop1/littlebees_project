'use client';

import { useEffect, useRef, useMemo, useCallback, useState } from 'react';
import { ChevronUp, AlertTriangle, ArrowUpCircle } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { useMessages, useSendMessage, useEscalateConversation } from '@/hooks/use-chat';
import { useSocket } from '@/hooks/use-socket';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { EmptyState } from '@/components/ui/empty-state';
import { MessageSquare } from 'lucide-react';
import { MessageBubble } from './message-bubble';
import { MessageInput } from './message-input';
import { TypingIndicator } from './typing-indicator';
import { ConversationHeader } from './conversation-header';
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
  const [showEscalateDialog, setShowEscalateDialog] = useState(false);
  const [escalationReason, setEscalationReason] = useState('');

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
  } = useMessages(conversationId);

  const sendMessage = useSendMessage();
  const escalateConversation = useEscalateConversation();

  // Detectar si estamos fuera de horario laboral
  const isOutOfHours = useMemo(() => {
    const now = new Date();
    const hour = now.getHours();
    const day = now.getDay(); // 0 = Domingo, 6 = Sábado
    return hour < 7 || hour >= 18 || day === 0 || day === 6;
  }, []);

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

  const handleEscalate = useCallback(() => {
    if (!escalationReason.trim()) {
      toast.error('Por favor proporciona un motivo para escalar la conversación');
      return;
    }

    escalateConversation.mutate(
      {
        conversationId,
        reason: escalationReason,
      },
      {
        onSuccess: () => {
          toast.success('Conversación escalada a dirección exitosamente');
          setShowEscalateDialog(false);
          setEscalationReason('');
        },
        onError: (error: any) => {
          toast.error(error.message || 'Error al escalar conversación');
        },
      }
    );
  }, [conversationId, escalationReason, escalateConversation]);

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
      {conversation && <ConversationHeader conversation={conversation} />}

      {/* Banner de fuera de horario */}
      {isOutOfHours && (
        <div className="bg-amber-50 border-b border-amber-200 px-4 py-3">
          <div className="flex items-center gap-2 text-sm text-amber-800">
            <AlertTriangle className="h-4 w-4" />
            <p>
              <strong>Fuera de horario:</strong> Tu mensaje será respondido durante el horario laboral (Lunes a Viernes, 7:00 AM - 6:00 PM)
            </p>
          </div>
        </div>
      )}

      {/* Botón de escalar (solo para maestras) */}
      {user?.role === 'teacher' && !(conversation as any)?.isEscalated && (
        <div className="bg-blue-50 border-b border-blue-200 px-4 py-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowEscalateDialog(true)}
            className="text-blue-700 hover:text-blue-900 hover:bg-blue-100"
          >
            <ArrowUpCircle className="h-4 w-4 mr-2" />
            Escalar a Dirección
          </Button>
        </div>
      )}

      {/* Dialog de escalación */}
      {showEscalateDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-lg font-semibold mb-4">Escalar Conversación</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Esta conversación será escalada a la dirección. Por favor proporciona un motivo.
            </p>
            <textarea
              className="w-full border rounded-md p-2 mb-4 min-h-[100px]"
              placeholder="Motivo de escalación..."
              value={escalationReason}
              onChange={(e) => setEscalationReason(e.target.value)}
            />
            <div className="flex gap-2 justify-end">
              <Button
                variant="outline"
                onClick={() => {
                  setShowEscalateDialog(false);
                  setEscalationReason('');
                }}
              >
                Cancelar
              </Button>
              <Button
                onClick={handleEscalate}
                disabled={escalateConversation.isPending}
              >
                {escalateConversation.isPending ? 'Escalando...' : 'Escalar'}
              </Button>
            </div>
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
