'use client';

import { formatDistanceToNow } from 'date-fns';
import { es } from 'date-fns/locale';
import { Avatar } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import type { ConversationResponse } from '@kinderspace/shared-types';
import { MessageType } from '@kinderspace/shared-types';

interface ConversationItemProps {
  conversation: ConversationResponse;
  isActive: boolean;
  onClick: (id: string) => void;
}

function getMessagePreview(conversation: ConversationResponse): string {
  if (!conversation.lastMessage) return 'Sin mensajes';

  const { lastMessage } = conversation;

  switch (lastMessage.messageType) {
    case MessageType.IMAGE:
      return 'Envio una imagen';
    case MessageType.FILE:
      return 'Envio un archivo';
    case MessageType.SYSTEM:
      return lastMessage.content;
    default:
      return lastMessage.content;
  }
}

function getTimeAgo(dateString: string): string {
  try {
    return formatDistanceToNow(new Date(dateString), {
      addSuffix: true,
      locale: es,
    });
  } catch {
    return '';
  }
}

export function ConversationItem({ conversation, isActive, onClick }: ConversationItemProps) {
  const preview = getMessagePreview(conversation);
  const truncatedPreview = preview.length > 50 ? `${preview.slice(0, 50)}...` : preview;
  const timeAgo = conversation.lastMessage
    ? getTimeAgo(conversation.lastMessage.createdAt)
    : getTimeAgo(conversation.createdAt);

  return (
    <button
      type="button"
      onClick={() => onClick(conversation.id)}
      className={cn(
        'flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left transition-colors hover:bg-gray-50',
        isActive && 'bg-primary-50 hover:bg-primary-50',
      )}
    >
      <Avatar
        size="md"
        name={conversation.childName}
      />

      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between gap-2">
          <p className={cn(
            'truncate text-sm font-semibold text-foreground',
            conversation.unreadCount > 0 && 'text-foreground',
          )}>
            {conversation.childName}
          </p>
          <span className="shrink-0 text-xs text-muted-foreground">
            {timeAgo}
          </span>
        </div>

        <div className="flex items-center justify-between gap-2">
          <p className={cn(
            'truncate text-xs text-muted-foreground',
            conversation.unreadCount > 0 && 'font-medium text-foreground',
          )}>
            {truncatedPreview}
          </p>

          {conversation.unreadCount > 0 && (
            <Badge variant="default" size="sm" className="shrink-0 min-w-[20px] justify-center">
              {conversation.unreadCount > 99 ? '99+' : conversation.unreadCount}
            </Badge>
          )}
        </div>
      </div>
    </button>
  );
}
