'use client';

import { useState, useRef, useEffect } from 'react';
import { useAiSessions, useAiSession, useCreateAiSession, useUpdateSessionTitle, useDeleteAiSession, useSendAiMessage } from '@/hooks/use-ai';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Plus, Send, Trash2, Sparkles, Pencil } from 'lucide-react';
import { cn } from '@/lib/utils';

export default function AiAssistantPage() {
  const [selectedSessionId, setSelectedSessionId] = useState<string | null>(null);
  const [inputMessage, setInputMessage] = useState('');
  const [editingTitle, setEditingTitle] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const { data: sessions, isLoading: sessionsLoading } = useAiSessions();
  const { data: currentSession } = useAiSession(selectedSessionId || '');
  const createSession = useCreateAiSession();
  const updateTitle = useUpdateSessionTitle();
  const deleteSession = useDeleteAiSession();
  const sendMessage = useSendAiMessage();

  const messages = currentSession?.messages || [];

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleCreateSession = async () => {
    try {
      const session = await createSession.mutateAsync(undefined);
      setSelectedSessionId(session.id);
    } catch (error: any) {
      console.error('Error creating session:', error);
      const errorMessage = error?.response?.data?.message || error?.message || 'Error al crear la conversación';
      alert(`Error: ${errorMessage}`);
    }
  };

  const handleDeleteSession = async (sessionId: string) => {
    if (confirm('¿Eliminar esta conversación?')) {
      try {
        await deleteSession.mutateAsync(sessionId);
        if (selectedSessionId === sessionId) {
          setSelectedSessionId(null);
        }
      } catch (error) {
        console.error('Error deleting session:', error);
      }
    }
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputMessage.trim() || !selectedSessionId) return;

    const message = inputMessage;
    setInputMessage('');

    try {
      await sendMessage.mutateAsync({
        sessionId: selectedSessionId,
        message,
      });
    } catch (error: any) {
      console.error('Error sending message:', error);
      const errorMessage = error?.response?.data?.message || error?.message || 'Error al enviar mensaje';
      alert(`Error: ${errorMessage}\n\n${errorMessage.includes('GROQ') ? 'Verifica que GROQ_API_KEY esté configurado en el archivo .env del backend' : ''}`);
      setInputMessage(message);
    }
  };

  const handleDeleteCurrentSession = async () => {
    if (!selectedSessionId) return;
    if (confirm('¿Eliminar esta conversación?')) {
      try {
        await deleteSession.mutateAsync(selectedSessionId);
        setSelectedSessionId(null);
      } catch (error) {
        console.error('Error deleting session:', error);
      }
    }
  };

  return (
    <div className="flex h-[calc(100vh-8rem)] gap-4">
      {/* Sidebar - Sessions */}
      <Card className="w-80 p-4 flex flex-col">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-semibold text-lg">Conversaciones</h2>
          <Button size="sm" onClick={handleCreateSession} disabled={createSession.isPending}>
            <Plus className="h-4 w-4" />
          </Button>
        </div>

        <div className="flex-1 overflow-y-auto space-y-2">
          {sessionsLoading ? (
            <div className="text-center text-muted-foreground py-8">Cargando...</div>
          ) : sessions?.length === 0 ? (
            <div className="text-center text-muted-foreground py-8">
              <p className="text-sm">No hay conversaciones</p>
              <p className="text-xs mt-2">Crea una nueva para comenzar</p>
            </div>
          ) : (
            sessions?.map((session) => (
              <div
                key={session.id}
                className={cn(
                  'p-3 rounded-lg cursor-pointer hover:bg-accent transition-colors group',
                  selectedSessionId === session.id && 'bg-accent'
                )}
                onClick={() => setSelectedSessionId(session.id)}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-sm truncate">{session.title}</p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(session.updatedAt).toLocaleDateString('es-MX')}
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="opacity-0 group-hover:opacity-100 h-6 w-6 p-0"
                    onClick={(e) => {
                      e.stopPropagation();
                      handleDeleteSession(session.id);
                    }}
                  >
                    <Trash2 className="h-3 w-3" />
                  </Button>
                </div>
              </div>
            ))
          )}
        </div>
      </Card>

      {/* Chat Area */}
      <Card className="flex-1 flex flex-col">
        {!selectedSessionId ? (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center">
              <Sparkles className="w-16 h-16 mx-auto text-primary mb-4" />
              <h3 className="text-xl font-semibold mb-2">Asistente IA LittleBees</h3>
              <p className="text-muted-foreground mb-4">
                Selecciona una conversación o crea una nueva para comenzar
              </p>
              <Button onClick={handleCreateSession}>
                <Plus className="h-4 w-4 mr-2" />
                Nueva Conversación
              </Button>
            </div>
          </div>
        ) : (
          <>
            {/* Header */}
            <div className="border-b p-4 flex items-center justify-between">
              <div className="flex items-center gap-2 flex-1">
                {editingTitle ? (
                  <Input
                    value={newTitle}
                    onChange={(e) => setNewTitle(e.target.value)}
                    onBlur={async () => {
                      if (newTitle.trim() && selectedSessionId && newTitle !== currentSession?.title) {
                        await updateTitle.mutateAsync({ sessionId: selectedSessionId, title: newTitle.trim() });
                      }
                      setEditingTitle(false);
                    }}
                    onKeyDown={async (e) => {
                      if (e.key === 'Enter') {
                        if (newTitle.trim() && selectedSessionId && newTitle !== currentSession?.title) {
                          await updateTitle.mutateAsync({ sessionId: selectedSessionId, title: newTitle.trim() });
                        }
                        setEditingTitle(false);
                      }
                      if (e.key === 'Escape') {
                        setEditingTitle(false);
                      }
                    }}
                    autoFocus
                    className="max-w-md"
                  />
                ) : (
                  <>
                    <h3 className="font-semibold">{currentSession?.title || 'Conversación'}</h3>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => {
                        setNewTitle(currentSession?.title || '');
                        setEditingTitle(true);
                      }}
                      className="h-6 w-6 p-0"
                    >
                      <Pencil className="h-3 w-3" />
                    </Button>
                  </>
                )}
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={handleDeleteCurrentSession}
                disabled={deleteSession.isPending}
              >
                <Trash2 className="h-4 w-4 mr-2" />
                Eliminar
              </Button>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={cn(
                    'flex',
                    message.role === 'user' ? 'justify-end' : 'justify-start'
                  )}
                >
                  <div
                    className={cn(
                      'max-w-[70%] rounded-lg p-4',
                      message.role === 'user'
                        ? 'bg-primary text-primary-foreground'
                        : 'bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700'
                    )}
                  >
                    <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                    <p className="text-xs opacity-70 mt-2">
                      {new Date(message.createdAt).toLocaleTimeString('es-MX', {
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </p>
                  </div>
                </div>
              ))}
              {sendMessage.isPending && (
                <div className="flex justify-start">
                  <div className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-4">
                    <div className="flex gap-1">
                      <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></span>
                      <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></span>
                      <span className="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></span>
                    </div>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>

            {/* Input */}
            <div className="border-t p-4">
              <form onSubmit={handleSendMessage} className="flex gap-2">
                <Input
                  value={inputMessage}
                  onChange={(e) => setInputMessage(e.target.value)}
                  placeholder="Escribe tu mensaje..."
                  disabled={sendMessage.isPending}
                  className="flex-1"
                />
                <Button type="submit" disabled={!inputMessage.trim() || sendMessage.isPending}>
                  <Send className="h-4 w-4" />
                </Button>
              </form>
            </div>
          </>
        )}
      </Card>
    </div>
  );
}
