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
        participants: {
          include: {
            // No direct user relation on ConversationParticipant in schema
            // We'll enrich this separately
          },
        },
        messages: {
          take: 1,
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });

    // Enrich with unread count for the current user
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

        return {
          ...conv,
          lastMessage: conv.messages[0] || null,
          unreadCount,
          messages: undefined,
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

    // Update conversation's updatedAt
    await this.prisma.conversation.update({
      where: { id: conversationId },
      data: { updatedAt: new Date() },
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
}
