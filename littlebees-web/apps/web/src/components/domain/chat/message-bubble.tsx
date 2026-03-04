'use client';

import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { cn } from '@/lib/utils';
import type { MessageResponse } from '@kinderspace/shared-types';
import { MessageType } from '@kinderspace/shared-types';

interface MessageBubbleProps {
  message: MessageResponse;
  isOwn: boolean;
}

function formatTime(dateString: string): string {
  try {
    return format(new Date(dateString), 'HH:mm', { locale: es });
  } catch {
    return '';
  }
}

export function MessageBubble({ message, isOwn }: MessageBubbleProps) {
  const time = formatTime(message.createdAt);

  // Mensajes del sistema: centrados y con estilo diferente
  if (message.messageType === MessageType.SYSTEM) {
    return (
      <div className="flex justify-center px-4 py-1">
        <div className="rounded-full bg-gray-100 px-4 py-1.5">
          <p className="text-xs text-muted-foreground">{message.content}</p>
        </div>
      </div>
    );
  }

  return (
    <div
      className={cn(
        'flex w-full px-4 py-0.5',
        isOwn ? 'justify-end' : 'justify-start',
      )}
    >
      <div
        className={cn(
          'max-w-[75%] rounded-2xl px-4 py-2',
          isOwn
            ? 'rounded-br-md bg-primary text-white'
            : 'rounded-bl-md bg-gray-100 text-foreground',
        )}
      >
        {/* Nombre del remitente (solo si no es propio) */}
        {!isOwn && (
          <p className="mb-0.5 text-xs font-semibold text-primary-700">
            {message.senderName}
          </p>
        )}

        {/* Contenido segun tipo */}
        {message.messageType === MessageType.IMAGE && message.attachmentUrl ? (
          <div className="space-y-1">
            <img
              src={message.attachmentUrl}
              alt="Imagen adjunta"
              className="max-h-60 rounded-lg object-cover"
            />
            {message.content && (
              <p className="text-sm">{message.content}</p>
            )}
          </div>
        ) : message.messageType === MessageType.FILE && message.attachmentUrl ? (
          <div className="space-y-1">
            <a
              href={message.attachmentUrl}
              target="_blank"
              rel="noopener noreferrer"
              className={cn(
                'inline-flex items-center gap-1 text-sm underline',
                isOwn ? 'text-white/90' : 'text-primary-600',
              )}
            >
              Descargar archivo
            </a>
            {message.content && (
              <p className="text-sm">{message.content}</p>
            )}
          </div>
        ) : (
          <p className="text-sm whitespace-pre-wrap break-words">
            {message.content}
          </p>
        )}

        {/* Hora */}
        <p
          className={cn(
            'mt-1 text-right text-[10px]',
            isOwn ? 'text-white/70' : 'text-muted-foreground',
          )}
        >
          {time}
        </p>
      </div>
    </div>
  );
}
