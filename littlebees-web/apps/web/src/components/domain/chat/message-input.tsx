'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import { Send } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface MessageInputProps {
  onSend: (content: string) => void;
  onTypingStart?: () => void;
  onTypingStop?: () => void;
  disabled?: boolean;
}

export function MessageInput({
  onSend,
  onTypingStart,
  onTypingStop,
  disabled = false,
}: MessageInputProps) {
  const [value, setValue] = useState('');
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const typingTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isTypingRef = useRef(false);

  // Auto-resize el textarea
  const adjustHeight = useCallback(() => {
    const textarea = textareaRef.current;
    if (!textarea) return;
    textarea.style.height = 'auto';
    textarea.style.height = `${Math.min(textarea.scrollHeight, 120)}px`;
  }, []);

  useEffect(() => {
    adjustHeight();
  }, [value, adjustHeight]);

  const handleTyping = useCallback(() => {
    if (!isTypingRef.current) {
      isTypingRef.current = true;
      onTypingStart?.();
    }

    // Reiniciar el timeout para dejar de escribir
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    typingTimeoutRef.current = setTimeout(() => {
      isTypingRef.current = false;
      onTypingStop?.();
    }, 2000);
  }, [onTypingStart, onTypingStop]);

  const handleSend = useCallback(() => {
    const trimmed = value.trim();
    if (!trimmed) return;

    onSend(trimmed);
    setValue('');

    // Detener indicador de escritura al enviar
    if (isTypingRef.current) {
      isTypingRef.current = false;
      onTypingStop?.();
    }
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    // Enfocar de nuevo el textarea
    textareaRef.current?.focus();
  }, [value, onSend, onTypingStop]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        handleSend();
      }
    },
    [handleSend],
  );

  // Limpiar timeout al desmontar
  useEffect(() => {
    return () => {
      if (typingTimeoutRef.current) {
        clearTimeout(typingTimeoutRef.current);
      }
    };
  }, []);

  return (
    <div className="flex items-end gap-2 border-t border-gray-100 bg-white p-4">
      <textarea
        ref={textareaRef}
        value={value}
        onChange={(e) => {
          setValue(e.target.value);
          handleTyping();
        }}
        onKeyDown={handleKeyDown}
        placeholder="Escribe un mensaje..."
        disabled={disabled}
        rows={1}
        className={cn(
          'flex-1 resize-none rounded-xl border border-input bg-background px-4 py-2.5 text-sm',
          'ring-offset-background placeholder:text-muted-foreground',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2',
          'disabled:cursor-not-allowed disabled:opacity-50',
          'max-h-[120px] min-h-[40px]',
        )}
      />

      <Button
        variant="primary"
        size="md"
        onClick={handleSend}
        disabled={disabled || !value.trim()}
        className="shrink-0"
        aria-label="Enviar mensaje"
      >
        <Send className="h-4 w-4" />
      </Button>
    </div>
  );
}
