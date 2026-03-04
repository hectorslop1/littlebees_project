'use client';

import { useState, useCallback, useMemo, useEffect } from 'react';
import { ArrowLeft, MessageSquare } from 'lucide-react';
import { useConversations, useMarkConversationRead } from '@/hooks/use-chat';
import { useSocket } from '@/hooks/use-socket';
import { ConversationList } from '@/components/domain/chat/conversation-list';
import { MessageArea } from '@/components/domain/chat/message-area';
import { EmptyState } from '@/components/ui/empty-state';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

export default function ChatPage() {
  const [activeConversationId, setActiveConversationId] = useState<string | null>(null);

  const { data: conversations, isLoading } = useConversations();
  const markRead = useMarkConversationRead();

  // Conectar socket para eventos globales (notificaciones de nuevos mensajes, etc.)
  useSocket({ activeConversationId });

  const conversationList = useMemo(
    () => conversations ?? [],
    [conversations],
  );

  const activeConversation = useMemo(
    () => conversationList.find((c) => c.id === activeConversationId) ?? undefined,
    [conversationList, activeConversationId],
  );

  const handleSelectConversation = useCallback(
    (id: string) => {
      setActiveConversationId(id);
      // Marcar como leida al seleccionar
      markRead.mutate(id);
    },
    [markRead],
  );

  const handleBackToList = useCallback(() => {
    setActiveConversationId(null);
  }, []);

  // En escritorio, marcar como leida cuando se carga la conversacion activa
  useEffect(() => {
    if (activeConversationId && activeConversation && activeConversation.unreadCount > 0) {
      markRead.mutate(activeConversationId);
    }
    // Solo ejecutar cuando cambie la conversacion activa
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeConversationId]);

  return (
    <div className="flex h-[calc(100vh-64px)] flex-col">
      <div className="flex items-center justify-between border-b border-gray-100 px-6 py-4 md:hidden">
        {activeConversationId ? (
          <Button variant="ghost" size="sm" onClick={handleBackToList}>
            <ArrowLeft className="h-4 w-4" />
            Volver
          </Button>
        ) : (
          <h1 className="text-xl font-bold font-heading">Chat</h1>
        )}
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Panel izquierdo: lista de conversaciones */}
        <div
          className={cn(
            'w-full shrink-0 border-r border-gray-100 md:w-96',
            // En movil, ocultar cuando hay una conversacion activa
            activeConversationId ? 'hidden md:block' : 'block',
          )}
        >
          <ConversationList
            conversations={conversationList}
            activeId={activeConversationId}
            onSelect={handleSelectConversation}
            isLoading={isLoading}
          />
        </div>

        {/* Panel derecho: area de mensajes */}
        <div
          className={cn(
            'flex-1',
            // En movil, ocultar cuando NO hay conversacion activa
            !activeConversationId ? 'hidden md:flex' : 'flex',
          )}
        >
          {activeConversationId ? (
            <div className="flex h-full w-full flex-col">
              <MessageArea
                conversationId={activeConversationId}
                conversation={activeConversation}
              />
            </div>
          ) : (
            <div className="flex h-full w-full items-center justify-center">
              <EmptyState
                icon={<MessageSquare />}
                title="Selecciona una conversacion"
                description="Elige una conversacion de la lista para ver los mensajes."
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
