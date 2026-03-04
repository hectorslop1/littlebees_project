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

@WebSocketGateway({
  namespace: '/chat',
  cors: { origin: '*', credentials: true },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: SocketServer;

  private userSockets = new Map<string, Set<string>>();

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

      // Broadcast to all participants in the conversation room
      this.server.to(data.conversationId).emit('new_message', message);

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

      this.server.to(data.conversationId).emit('conversation_read', {
        conversationId: data.conversationId,
        userId: client.data.userId,
        readAt: new Date().toISOString(),
      });
    } catch {
      client.emit('error', {
        message: 'Error al marcar como leída',
        code: 'MARK_READ_FAILED',
      });
    }
  }
}
