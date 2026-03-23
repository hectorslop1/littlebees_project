import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { JwtService } from '@nestjs/jwt';
import { ChatService } from './chat.service';

// Use any for socket types to avoid socket.io version mismatch issues
type SocketServer = any;
type SocketClient = any;

type ActiveCallSession = {
  callId: string;
  tenantId: string;
  conversationId: string;
  callerId: string;
  participantIds: string[];
  acceptedUserIds: Set<string>;
  callType: 'voice' | 'video';
  createdAt: Date;
  acceptedAt?: Date;
};

@WebSocketGateway({
  namespace: '/chat',
  cors: { origin: '*', credentials: true },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: SocketServer;

  private userSockets = new Map<string, Set<string>>();
  private activeCalls = new Map<string, ActiveCallSession>();

  constructor(
    private readonly jwtService: JwtService,
    private readonly chatService: ChatService,
  ) {}

  async handleConnection(client: SocketClient) {
    try {
      const token =
        client.handshake.auth?.token ||
        client.handshake.headers?.authorization?.replace('Bearer ', '');

      if (!token) {
        client.emit('error', { message: 'Token requerido', code: 'AUTH_REQUIRED' });
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);

      client.data = {
        userId: payload.sub,
        tenantId: payload.tid,
        role: payload.role,
      };

      // Track user socket
      const sockets = this.userSockets.get(payload.sub) || new Set();
      sockets.add(client.id);
      this.userSockets.set(payload.sub, sockets);
    } catch {
      client.emit('error', { message: 'Token inválido', code: 'AUTH_INVALID' });
      client.disconnect();
    }
  }

  handleDisconnect(client: SocketClient) {
    if (client.data?.userId) {
      this.cleanupCallsForUser(client.data.userId);
      const sockets = this.userSockets.get(client.data.userId);
      if (sockets) {
        sockets.delete(client.id);
        if (sockets.size === 0) {
          this.userSockets.delete(client.data.userId);
        }
      }
    }
  }

  @SubscribeMessage('join_conversation')
  async handleJoinConversation(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string },
  ) {
    try {
      // Verify user is a participant
      await this.chatService.findConversationById(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
      );

      client.join(data.conversationId);
      client.emit('joined_conversation', { conversationId: data.conversationId });
    } catch {
      client.emit('error', {
        message: 'No se puede unir a la conversación',
        code: 'JOIN_FAILED',
      });
    }
  }

  @SubscribeMessage('leave_conversation')
  handleLeaveConversation(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string },
  ) {
    client.leave(data.conversationId);
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: SocketClient,
    @MessageBody()
    data: {
      conversationId: string;
      content: string;
      messageType?: string;
      attachmentUrl?: string;
    },
  ) {
    try {
      const message = await this.chatService.sendMessage(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
        {
          content: data.content,
          messageType: data.messageType,
          attachmentUrl: data.attachmentUrl,
        },
      );

      const participants = await this.chatService.getConversationParticipantsForUser(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
      );

      this.emitToUsers(
        participants.map((participant) => participant.userId),
        'new_message',
        message,
      );

      // Acknowledge to sender
      client.emit('message_sent', {
        messageId: message.id,
        conversationId: data.conversationId,
      });
    } catch {
      client.emit('error', {
        message: 'Error al enviar mensaje',
        code: 'SEND_FAILED',
      });
    }
  }

  @SubscribeMessage('typing_start')
  handleTypingStart(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string },
  ) {
    client.to(data.conversationId).emit('user_typing', {
      conversationId: data.conversationId,
      userId: client.data.userId,
    });
  }

  @SubscribeMessage('typing_stop')
  handleTypingStop(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string },
  ) {
    client.to(data.conversationId).emit('user_stop_typing', {
      conversationId: data.conversationId,
      userId: client.data.userId,
    });
  }

  @SubscribeMessage('mark_read')
  async handleMarkRead(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string },
  ) {
    try {
      await this.chatService.markAsRead(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
      );

      const participants = await this.chatService.getConversationParticipantsForUser(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
      );

      this.emitToUsers(
        participants.map((participant) => participant.userId),
        'conversation_read',
        {
          conversationId: data.conversationId,
          userId: client.data.userId,
          readAt: new Date().toISOString(),
        },
      );
    } catch {
      client.emit('error', {
        message: 'Error al marcar como leída',
        code: 'MARK_READ_FAILED',
      });
    }
  }

  @SubscribeMessage('start_call')
  async handleStartCall(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { conversationId: string; callType: 'voice' | 'video' },
  ) {
    try {
      const participants = await this.chatService.getConversationParticipantsForUser(
        client.data.tenantId,
        data.conversationId,
        client.data.userId,
      );

      const recipientIds = participants
        .map((participant) => participant.userId)
        .filter((userId) => userId !== client.data.userId);

      if (recipientIds.length === 0) {
        client.emit('error', {
          message: 'No hay destinatarios disponibles para la llamada',
          code: 'CALL_NO_RECIPIENTS',
        });
        return;
      }

      const caller = await this.chatService.getUserSummary(
        client.data.tenantId,
        client.data.userId,
      );

      const callId = `call_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
      this.activeCalls.set(callId, {
        callId,
        tenantId: client.data.tenantId,
        conversationId: data.conversationId,
        callerId: client.data.userId,
        participantIds: [
          client.data.userId,
          ...recipientIds,
        ],
        acceptedUserIds: new Set(),
        callType: data.callType,
        createdAt: new Date(),
      });

      client.emit('call_started', {
        callId,
        conversationId: data.conversationId,
        callType: data.callType,
      });

      this.emitToUsers(recipientIds, 'incoming_call', {
        callId,
        conversationId: data.conversationId,
        callType: data.callType,
        from: caller,
        initiatedAt: new Date().toISOString(),
      });
    } catch {
      client.emit('error', {
        message: 'No fue posible iniciar la llamada',
        code: 'CALL_START_FAILED',
      });
    }
  }

  @SubscribeMessage('accept_call')
  handleAcceptCall(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      client.emit('error', {
        message: 'Llamada no encontrada',
        code: 'CALL_NOT_FOUND',
      });
      return;
    }

    if (client.data.userId !== session.callerId) {
      session.acceptedUserIds.add(client.data.userId);
      session.acceptedAt ??= new Date();
    }

    this.emitToUsers(session.participantIds, 'call_accepted', {
      callId: session.callId,
      conversationId: session.conversationId,
      acceptedBy: client.data.userId,
      callType: session.callType,
    });
  }

  @SubscribeMessage('decline_call')
  async handleDeclineCall(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      return;
    }

    this.emitToUsers(session.participantIds, 'call_declined', {
      callId: session.callId,
      conversationId: session.conversationId,
      declinedBy: client.data.userId,
      callType: session.callType,
    });

    const callLogMessage = await this.chatService.createCallLogMessage(
      session.tenantId,
      session.conversationId,
      session.callerId,
      {
        callType: session.callType,
        callerId: session.callerId,
        durationSeconds: 0,
        status: 'declined',
      },
    );

    this.emitToUsers(session.participantIds, 'new_message', callLogMessage);
    this.activeCalls.delete(session.callId);
  }

  @SubscribeMessage('end_call')
  async handleEndCall(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      return;
    }

    const status =
      session.acceptedAt != null
        ? 'completed'
        : client.data.userId === session.callerId
          ? 'cancelled'
          : 'missed';
    const durationSeconds = session.acceptedAt
      ? (Date.now() - session.acceptedAt.getTime()) / 1000
      : 0;

    this.emitToUsers(session.participantIds, 'call_ended', {
      callId: session.callId,
      conversationId: session.conversationId,
      endedBy: client.data.userId,
      callType: session.callType,
      durationSeconds: Math.max(0, Math.round(durationSeconds)),
      status,
    });

    const callLogMessage = await this.chatService.createCallLogMessage(
      session.tenantId,
      session.conversationId,
      session.callerId,
      {
        callType: session.callType,
        callerId: session.callerId,
        durationSeconds,
        status,
      },
    );

    this.emitToUsers(session.participantIds, 'new_message', callLogMessage);
    this.activeCalls.delete(session.callId);
  }

  @SubscribeMessage('webrtc_offer')
  handleWebrtcOffer(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string; sdp: Record<string, unknown> },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      return;
    }

    this.emitToUsers(
      session.participantIds.filter((userId) => userId !== client.data.userId),
      'webrtc_offer',
      {
        callId: session.callId,
        conversationId: session.conversationId,
        fromUserId: client.data.userId,
        sdp: data.sdp,
      },
    );
  }

  @SubscribeMessage('webrtc_answer')
  handleWebrtcAnswer(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string; sdp: Record<string, unknown> },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      return;
    }

    this.emitToUsers(
      session.participantIds.filter((userId) => userId !== client.data.userId),
      'webrtc_answer',
      {
        callId: session.callId,
        conversationId: session.conversationId,
        fromUserId: client.data.userId,
        sdp: data.sdp,
      },
    );
  }

  @SubscribeMessage('webrtc_ice_candidate')
  handleWebrtcIceCandidate(
    @ConnectedSocket() client: SocketClient,
    @MessageBody() data: { callId: string; candidate: Record<string, unknown> },
  ) {
    const session = this.activeCalls.get(data.callId);
    if (!session || !session.participantIds.includes(client.data.userId)) {
      return;
    }

    this.emitToUsers(
      session.participantIds.filter((userId) => userId !== client.data.userId),
      'webrtc_ice_candidate',
      {
        callId: session.callId,
        conversationId: session.conversationId,
        fromUserId: client.data.userId,
        candidate: data.candidate,
      },
    );
  }

  private emitToUsers(userIds: string[], event: string, payload: unknown) {
    for (const userId of [...new Set(userIds)]) {
      const sockets = this.userSockets.get(userId);
      if (!sockets) continue;

      for (const socketId of sockets) {
        this.server.to(socketId).emit(event, payload);
      }
    }
  }

  private cleanupCallsForUser(userId: string) {
    for (const session of this.activeCalls.values()) {
      if (!session.participantIds.includes(userId)) {
        continue;
      }

      this.emitToUsers(session.participantIds, 'call_ended', {
        callId: session.callId,
        conversationId: session.conversationId,
        endedBy: userId,
        callType: session.callType,
        durationSeconds: session.acceptedAt
          ? Math.max(0, Math.round((Date.now() - session.acceptedAt.getTime()) / 1000))
          : 0,
        status: session.acceptedAt ? 'completed' : 'missed',
      });

      this.activeCalls.delete(session.callId);
    }
  }
}
