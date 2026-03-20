'use client';

import { useState } from 'react';
import { ArrowUpCircle, MoreVertical, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Textarea } from '@/components/ui/textarea';
import { useEscalateConversation, useUpdateConversationType } from '@/hooks/use-chat';
import { useAuth } from '@/hooks/use-auth';
import type { ConversationResponse } from '@kinderspace/shared-types';

interface ConversationHeaderProps {
  conversation: ConversationResponse;
}

export function ConversationHeader({ conversation }: ConversationHeaderProps) {
  const { user } = useAuth();
  const [showEscalateDialog, setShowEscalateDialog] = useState(false);
  const [escalationReason, setEscalationReason] = useState('');
  
  const escalate = useEscalateConversation();
  const updateType = useUpdateConversationType();

  const isTeacherOrDirector = user?.role === 'teacher' || user?.role === 'director' || user?.role === 'admin';
  const isEscalated = (conversation as any).isEscalated;
  const conversationType = (conversation as any).conversationType || 'normal';

  const handleEscalate = async () => {
    if (!escalationReason.trim()) return;
    
    try {
      await escalate.mutateAsync({
        conversationId: conversation.id,
        reason: escalationReason,
      });
      setShowEscalateDialog(false);
      setEscalationReason('');
    } catch (error) {
      console.error('Error escalating conversation:', error);
    }
  };

  const handleMarkAsUrgent = async () => {
    try {
      await updateType.mutateAsync({
        conversationId: conversation.id,
        type: conversationType === 'urgent' ? 'normal' : 'urgent',
      });
    } catch (error) {
      console.error('Error updating conversation type:', error);
    }
  };

  return (
    <>
      <div className="flex items-center justify-between border-b p-4">
        <div className="flex items-center gap-3">
          <div>
            <h2 className="font-semibold text-foreground">
              {conversation.childName}
            </h2>
            <div className="flex items-center gap-2 mt-1">
              {conversationType === 'urgent' && (
                <Badge variant="danger" size="sm">
                  <AlertCircle className="h-3 w-3 mr-1" />
                  Urgente
                </Badge>
              )}
              {isEscalated && (
                <Badge variant="secondary" size="sm" className="bg-purple-100 text-purple-700">
                  <ArrowUpCircle className="h-3 w-3 mr-1" />
                  Escalada a Dirección
                </Badge>
              )}
            </div>
          </div>
        </div>

        {isTeacherOrDirector && (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="sm">
                <MoreVertical className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={handleMarkAsUrgent}>
                <AlertCircle className="h-4 w-4 mr-2" />
                {conversationType === 'urgent' ? 'Marcar como Normal' : 'Marcar como Urgente'}
              </DropdownMenuItem>
              {!isEscalated && (
                <>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={() => setShowEscalateDialog(true)}>
                    <ArrowUpCircle className="h-4 w-4 mr-2" />
                    Escalar a Dirección
                  </DropdownMenuItem>
                </>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        )}
      </div>

      {/* Dialog para escalar conversación */}
      <Dialog open={showEscalateDialog} onOpenChange={setShowEscalateDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Escalar Conversación a Dirección</DialogTitle>
            <DialogDescription>
              Esta conversación será visible para la dirección y se marcará como escalada.
              Por favor, proporciona un motivo para el escalamiento.
            </DialogDescription>
          </DialogHeader>
          
          <Textarea
            placeholder="Motivo del escalamiento..."
            value={escalationReason}
            onChange={(e) => setEscalationReason(e.target.value)}
            rows={4}
          />

          <DialogFooter>
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
              disabled={!escalationReason.trim() || escalate.isPending}
            >
              {escalate.isPending ? 'Escalando...' : 'Escalar'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
