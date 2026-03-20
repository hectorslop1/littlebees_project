'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';

interface UnreadCountResponse {
  unreadCount: number;
}

export function useUnreadMessagesCount() {
  return useQuery({
    queryKey: ['chat', 'unread-count'],
    queryFn: async () => {
      try {
        const conversations = await api.get<any[]>('/chat/conversations');
        const unreadCount = conversations.reduce((total, conv) => {
          return total + (conv.unreadCount || 0);
        }, 0);
        return unreadCount;
      } catch (error) {
        console.error('Error fetching unread count:', error);
        return 0;
      }
    },
    refetchInterval: 30000, // Refetch every 30 seconds
    staleTime: 20000,
  });
}
