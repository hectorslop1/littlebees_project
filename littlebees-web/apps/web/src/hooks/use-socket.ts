'use client';

import { useEffect, useState, useCallback, useRef } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { connectSocket, disconnectSocket, getSocket } from '@/lib/socket';
import type { MessageResponse } from '@kinderspace/shared-types';

interface UseSocketOptions {
  activeConversationId: string | null;
}

interface UseSocketReturn {
  isConnected: boolean;
  typingUsers: string[];
  emitTypingStart: () => void;
  emitTypingStop: () => void;
}

export function useSocket({ activeConversationId }: UseSocketOptions): UseSocketReturn {
  const queryClient = useQueryClient();
  const [isConnected, setIsConnected] = useState(false);
  const [typingUsers, setTypingUsers] = useState<string[]>([]);
  const previousConversationRef = useRef<string | null>(null);

  // Conectar socket al montar, desconectar al desmontar
  useEffect(() => {
    const socket = connectSocket();

    function handleConnect() {
      setIsConnected(true);
    }

    function handleDisconnect() {
      setIsConnected(false);
    }

    socket.on('connect', handleConnect);
    socket.on('disconnect', handleDisconnect);

    // Si ya esta conectado al momento de suscribirse
    if (socket.connected) {
      setIsConnected(true);
    }

    return () => {
      socket.off('connect', handleConnect);
      socket.off('disconnect', handleDisconnect);
      disconnectSocket();
    };
  }, []);

  // Unirse/salir de sala cuando cambia la conversacion activa
  useEffect(() => {
    const socket = getSocket();

    if (previousConversationRef.current) {
      socket.emit('leave_conversation', {
        conversationId: previousConversationRef.current,
      });
    }

    if (activeConversationId) {
      socket.emit('join_conversation', {
        conversationId: activeConversationId,
      });
    }

    // Limpiar los usuarios escribiendo al cambiar de conversacion
    setTypingUsers([]);
    previousConversationRef.current = activeConversationId;

    return () => {
      if (activeConversationId) {
        socket.emit('leave_conversation', {
          conversationId: activeConversationId,
        });
      }
    };
  }, [activeConversationId]);

  // Escuchar eventos en tiempo real
  useEffect(() => {
    const socket = getSocket();

    function handleNewMessage(message: MessageResponse) {
      // Actualizar la cache de mensajes de la conversacion
      queryClient.setQueryData(
        ['chat', 'messages', message.conversationId],
        (oldData: any) => {
          if (!oldData) return oldData;

          // Verificar que el mensaje no exista ya (evitar duplicados)
          const allMessages = oldData.pages.flatMap((p: any) => p.data);
          if (allMessages.some((m: MessageResponse) => m.id === message.id)) {
            return oldData;
          }

          // Agregar el mensaje nuevo al final de la ultima pagina
          const newPages = [...oldData.pages];
          const lastPageIndex = newPages.length - 1;
          newPages[lastPageIndex] = {
            ...newPages[lastPageIndex],
            data: [...newPages[lastPageIndex].data, message],
          };

          return {
            ...oldData,
            pages: newPages,
          };
        },
      );

      // Refrescar la lista de conversaciones para actualizar el ultimo mensaje
      queryClient.invalidateQueries({
        queryKey: ['chat', 'conversations'],
      });

      // Refrescar conteo de no leidos
      queryClient.invalidateQueries({
        queryKey: ['chat', 'unread-count'],
      });
    }

    function handleUserTyping(data: { conversationId: string; userId: string }) {
      if (data.conversationId === activeConversationId) {
        setTypingUsers((prev) => {
          if (prev.includes(data.userId)) return prev;
          return [...prev, data.userId];
        });
      }
    }

    function handleUserStopTyping(data: { conversationId: string; userId: string }) {
      if (data.conversationId === activeConversationId) {
        setTypingUsers((prev) => prev.filter((id) => id !== data.userId));
      }
    }

    socket.on('new_message', handleNewMessage);
    socket.on('user_typing', handleUserTyping);
    socket.on('user_stop_typing', handleUserStopTyping);

    return () => {
      socket.off('new_message', handleNewMessage);
      socket.off('user_typing', handleUserTyping);
      socket.off('user_stop_typing', handleUserStopTyping);
    };
  }, [activeConversationId, queryClient]);

  const emitTypingStart = useCallback(() => {
    if (!activeConversationId) return;
    const socket = getSocket();
    socket.emit('typing_start', { conversationId: activeConversationId });
  }, [activeConversationId]);

  const emitTypingStop = useCallback(() => {
    if (!activeConversationId) return;
    const socket = getSocket();
    socket.emit('typing_stop', { conversationId: activeConversationId });
  }, [activeConversationId]);

  return {
    isConnected,
    typingUsers,
    emitTypingStart,
    emitTypingStop,
  };
}
