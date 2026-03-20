import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async findConversations(tenantId: string, userId: string) {
    const participations = await this.prisma.conversationParticipant.findMany({
      where: { userId },
      select: { conversationId: true },
    });

    const conversationIds = participations.map((p) => p.conversationId);

    const conversations = await this.prisma.conversation.findMany({
      where: { id: { in: conversationIds }, tenantId },
      include: {
        child: { select: { id: true, firstName: true, lastName: true, photoUrl: true } },
        participants: true,
        messages: {
          take: 1,
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });

    // Enrich with unread count and participant user info
    const enriched = await Promise.all(
      conversations.map(async (conv) => {
        const participation = await this.prisma.conversationParticipant.findUnique({
          where: {
            conversationId_userId: { conversationId: conv.id, userId },
          },
        });

        const unreadCount = await this.prisma.message.count({
          where: {
            conversationId: conv.id,
            createdAt: { gt: participation?.lastReadAt || new Date(0) },
            senderId: { not: userId },
          },
        });

        // Get user info for each participant
        const participantsWithUserInfo = await Promise.all(
          conv.participants.map(async (p) => {
            const user = await this.prisma.user.findUnique({
              where: { id: p.userId },
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                avatarUrl: true,
              },
            });
            return {
              userId: p.userId,
              firstName: user?.firstName || '',
              lastName: user?.lastName || '',
              avatarUrl: user?.avatarUrl,
              joinedAt: p.joinedAt,
              lastReadAt: p.lastReadAt,
            };
          }),
        );

        return {
          id: conv.id,
          tenantId: conv.tenantId,
          childId: conv.childId,
          childName: conv.child ? `${conv.child.firstName} ${conv.child.lastName}` : null,
          participants: participantsWithUserInfo,
          lastMessage: conv.messages[0] || null,
          unreadCount,
          createdAt: conv.createdAt,
          updatedAt: conv.updatedAt,
        };
      }),
    );

    return enriched;
  }

  async findConversationById(tenantId: string, conversationId: string, userId: string) {
    const conversation = await this.prisma.conversation.findFirst({
      where: { id: conversationId, tenantId },
      include: {
        child: { select: { id: true, firstName: true, lastName: true, photoUrl: true } },
        participants: true,
      },
    });

    if (!conversation) {
      throw new NotFoundException('Conversación no encontrada');
    }

    // Verify user is a participant
    const isParticipant = conversation.participants.some(
      (p) => p.userId === userId,
    );

    if (!isParticipant) {
      throw new ForbiddenException('No eres participante de esta conversación');
    }

    return conversation;
  }

  async createConversation(
    tenantId: string,
    data: { childId: string; participantIds: string[] },
  ) {
    return this.prisma.conversation.create({
      data: {
        tenantId,
        childId: data.childId,
        participants: {
          create: data.participantIds.map((userId) => ({
            userId,
            joinedAt: new Date(),
          })),
        },
      },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
        participants: true,
      },
    });
  }

  async findMessages(
    tenantId: string,
    conversationId: string,
    userId: string,
    cursor?: string,
    limit = 50,
  ) {
    // Verify participation
    await this.findConversationById(tenantId, conversationId, userId);

    const messages = await this.prisma.message.findMany({
      where: {
        conversationId,
        tenantId,
        deletedAt: null,
        ...(cursor && { createdAt: { lt: new Date(cursor) } }),
      },
      take: limit,
      orderBy: { createdAt: 'desc' },
    });

    return {
      data: messages.reverse(),
      hasMore: messages.length === limit,
      nextCursor: messages.length > 0 ? messages[0].createdAt.toISOString() : null,
    };
  }

  async sendMessage(
    tenantId: string,
    conversationId: string,
    senderId: string,
    data: { content: string; messageType?: string; attachmentUrl?: string },
  ) {
    // Verify participation
    await this.findConversationById(tenantId, conversationId, senderId);

    const message = await this.prisma.message.create({
      data: {
        tenantId,
        conversationId,
        senderId,
        content: data.content,
        messageType: data.messageType || 'text',
        attachmentUrl: data.attachmentUrl,
      },
    });

    // Detectar si el mensaje se envía fuera de horario
    const outOfHours = this.isOutOfHours();

    // Update conversation's updatedAt y marcar si es fuera de horario
    await this.prisma.conversation.update({
      where: { id: conversationId },
      data: { 
        updatedAt: new Date(),
        // isOutOfHours: outOfHours ? true : undefined, // DISABLED: Field doesn't exist
      },
    });

    return message;
  }

  async markAsRead(tenantId: string, conversationId: string, userId: string) {
    // Verify conversation exists
    await this.findConversationById(tenantId, conversationId, userId);

    await this.prisma.conversationParticipant.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: { lastReadAt: new Date() },
    });

    return { success: true, message: 'Conversación marcada como leída' };
  }

  async getUnreadCount(tenantId: string, userId: string) {
    const participations = await this.prisma.conversationParticipant.findMany({
      where: { userId },
    });

    let totalUnread = 0;

    for (const p of participations) {
      const count = await this.prisma.message.count({
        where: {
          conversationId: p.conversationId,
          tenantId,
          createdAt: { gt: p.lastReadAt || new Date(0) },
          senderId: { not: userId },
        },
      });
      totalUnread += count;
    }

    return { unread: totalUnread };
  }

  async escalateConversation(tenantId: string, conversationId: string, userId: string, reason: string) {
    // Verificar que la conversación existe
    const conversation = await this.prisma.conversation.findFirst({
      where: { id: conversationId, tenantId },
      include: { participants: true },
    });

    if (!conversation) {
      throw new NotFoundException('Conversación no encontrada');
    }

    // Buscar directores del tenant
    const directors = await this.prisma.userTenant.findMany({
      where: {
        tenantId,
        role: 'director',
        active: true,
      },
      select: { userId: true },
    });

    // Actualizar conversación
    const updated = await this.prisma.conversation.update({
      where: { id: conversationId },
      data: {
        // isEscalated: true, // DISABLED: Field doesn't exist
        // escalatedAt: new Date(), // DISABLED: Field doesn't exist
        // escalatedBy: userId, // DISABLED: Field doesn't exist
        // escalationReason: reason, // DISABLED: Field doesn't exist
        // conversationType: 'escalated', // DISABLED: Field doesn't exist
      },
    });

    // Agregar directores como participantes si no están ya
    for (const director of directors) {
      const exists = conversation.participants.find(p => p.userId === director.userId);
      if (!exists) {
        await this.prisma.conversationParticipant.create({
          data: {
            conversationId,
            userId: director.userId,
          },
        });
      }
    }

    return updated;
  }

  async updateConversationType(tenantId: string, conversationId: string, type: 'normal' | 'urgent' | 'escalated') {
    const conversation = await this.prisma.conversation.findFirst({
      where: { id: conversationId, tenantId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversación no encontrada');
    }

    return this.prisma.conversation.update({
      where: { id: conversationId },
      data: { /* conversationType: type */ }, // DISABLED: Field doesn't exist
    });
  }

  private isOutOfHours(): boolean {
    const now = new Date();
    const hour = now.getHours();
    const day = now.getDay(); // 0 = Domingo, 6 = Sábado

    // Fuera de horario: antes de 7am, después de 6pm, o fin de semana
    return hour < 7 || hour >= 18 || day === 0 || day === 6;
  }
}
