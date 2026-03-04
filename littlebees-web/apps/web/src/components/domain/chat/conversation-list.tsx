'use client';

import { useState, useMemo } from 'react';
import { Search } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { EmptyState } from '@/components/ui/empty-state';
import { MessageSquare } from 'lucide-react';
import { ConversationItem } from './conversation-item';
import type { ConversationResponse } from '@kinderspace/shared-types';

interface ConversationListProps {
  conversations: ConversationResponse[];
  activeId: string | null;
  onSelect: (id: string) => void;
  isLoading: boolean;
}

export function ConversationList({
  conversations,
  activeId,
  onSelect,
  isLoading,
}: ConversationListProps) {
  const [search, setSearch] = useState('');

  const filtered = useMemo(() => {
    if (!search.trim()) return conversations;
    const term = search.toLowerCase();
    return conversations.filter((c) =>
      c.childName.toLowerCase().includes(term),
    );
  }, [conversations, search]);

  return (
    <div className="flex h-full flex-col">
      {/* Encabezado y buscador */}
      <div className="border-b border-gray-100 p-4">
        <h2 className="mb-3 text-lg font-bold font-heading text-foreground">
          Mensajes
        </h2>
        <Input
          placeholder="Buscar conversacion..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          icon={<Search className="h-4 w-4" />}
        />
      </div>

      {/* Lista scrolleable */}
      <div className="flex-1 overflow-y-auto px-2 py-2">
        {isLoading ? (
          <div className="space-y-2 px-2">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 rounded-xl p-3">
                <Skeleton className="h-10 w-10 shrink-0 rounded-full" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-3.5 w-3/4" />
                  <Skeleton className="h-3 w-1/2" />
                </div>
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <EmptyState
            icon={<MessageSquare />}
            title={search ? 'Sin resultados' : 'Sin conversaciones'}
            description={
              search
                ? 'No se encontraron conversaciones con ese termino.'
                : 'Aun no tienes conversaciones. Inicia una nueva para comenzar.'
            }
            className="py-8"
          />
        ) : (
          <div className="space-y-1">
            {filtered.map((conversation) => (
              <ConversationItem
                key={conversation.id}
                conversation={conversation}
                isActive={activeId === conversation.id}
                onClick={onSelect}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
