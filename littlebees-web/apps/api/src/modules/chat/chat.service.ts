import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

type UserDisplay = {
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
  role: string | null;
};

type ContactCategory = 'teachers' | 'administration' | 'parents';

type ChatContactOption = {
  userId: string;
  firstName: string;
  lastName: string;
  avatarUrl: string | null;
  role: string;
  category: ContactCategory;
  childIds: string[];
  childNames: string[];
  groupIds: string[];
  groupNames: string[];
};

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

    const usersById = await this.getUsersMap(
      conversations.flatMap((conversation) => [
        ...conversation.participants.map((participant) => participant.userId),
        ...conversation.messages.map((message) => message.senderId),
      ]),
      tenantId,
    );

    const enriched = await Promise.all(
      conversations.map(async (conversation) => {
        const participation = await this.prisma.conversationParticipant.findUnique({
          where: {
            conversationId_userId: { conversationId: conversation.id, userId },
          },
        });

        const unreadCount = await this.prisma.message.count({
          where: {
            conversationId: conversation.id,
            createdAt: { gt: participation?.lastReadAt || new Date(0) },
            senderId: { not: userId },
          },
        });

        return {
          id: conversation.id,
          tenantId: conversation.tenantId,
          childId: conversation.childId,
          childName: conversation.child
            ? `${conversation.child.firstName} ${conversation.child.lastName}`
            : null,
          participants: conversation.participants.map((participant) =>
            this.enrichParticipant(participant, usersById),
          ),
          lastMessage: conversation.messages[0]
            ? this.enrichMessageWithSender(conversation.messages[0], usersById)
            : null,
          unreadCount,
          createdAt: conversation.createdAt,
          updatedAt: conversation.updatedAt,
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

    const isParticipant = conversation.participants.some(
      (participant) => participant.userId === userId,
    );

    if (!isParticipant) {
      throw new ForbiddenException('No eres participante de esta conversación');
    }

    const usersById = await this.getUsersMap(
      conversation.participants.map((participant) => participant.userId),
      tenantId,
    );

    return {
      ...conversation,
      participants: conversation.participants.map((participant) =>
        this.enrichParticipant(participant, usersById),
      ),
    };
  }

  async getAvailableContacts(tenantId: string, userId: string, userRole: string) {
    switch (userRole) {
      case 'parent':
        return this.getParentContacts(tenantId, userId);
      case 'teacher':
        return this.getTeacherContacts(tenantId, userId);
      case 'director':
      case 'admin':
      case 'super_admin':
        return this.getStaffContacts(tenantId, userId);
      default:
        return [];
    }
  }

  async createConversation(
    tenantId: string,
    currentUserId: string,
    currentUserRole: string,
    data: { childId: string; participantIds: string[] },
  ) {
    const participantIds = [...new Set(data.participantIds.filter(Boolean))]
      .filter((participantId) => participantId !== currentUserId);

    if (!data.childId) {
      throw new BadRequestException('Debes seleccionar un niño/a para iniciar la conversación');
    }

    if (participantIds.length === 0) {
      throw new BadRequestException('Debes seleccionar al menos un contacto');
    }

    const availableContacts = await this.getAvailableContacts(
      tenantId,
      currentUserId,
      currentUserRole,
    );
    const contactsById = new Map(
      availableContacts.map((contact) => [contact.userId, contact]),
    );

    for (const participantId of participantIds) {
      const contact = contactsById.get(participantId);

      if (!contact) {
        throw new ForbiddenException('No puedes iniciar conversación con este usuario');
      }

      if (!contact.childIds.includes(data.childId)) {
        throw new ForbiddenException(
          'El contacto seleccionado no está relacionado con el niño/a elegido',
        );
      }
    }

    const normalizedParticipants = [...new Set([currentUserId, ...participantIds])];
    const existingConversation = await this.findExistingConversation(
      tenantId,
      data.childId,
      normalizedParticipants,
    );

    if (existingConversation) {
      return this.findConversationById(tenantId, existingConversation.id, currentUserId);
    }

    const conversation = await this.prisma.conversation.create({
      data: {
        tenantId,
        childId: data.childId,
        participants: {
          create: normalizedParticipants.map((userId) => ({
            userId,
            joinedAt: new Date(),
          })),
        },
      },
    });

    return this.findConversationById(tenantId, conversation.id, currentUserId);
  }

  async findMessages(
    tenantId: string,
    conversationId: string,
    userId: string,
    cursor?: string,
    limit = 50,
  ) {
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

    const orderedMessages = messages.reverse();
    const usersById = await this.getUsersMap(
      orderedMessages.map((message) => message.senderId),
      tenantId,
    );

    return {
      data: orderedMessages.map((message) =>
        this.enrichMessageWithSender(message, usersById),
      ),
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

    await this.prisma.conversation.update({
      where: { id: conversationId },
      data: {
        updatedAt: new Date(),
        // isOutOfHours: this.isOutOfHours() ? true : undefined, // DISABLED: Field doesn't exist
      },
    });

    const usersById = await this.getUsersMap([senderId], tenantId);
    return this.enrichMessageWithSender(message, usersById);
  }

  async markAsRead(tenantId: string, conversationId: string, userId: string) {
    await this.findConversationById(tenantId, conversationId, userId);

    await this.prisma.conversationParticipant.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: { lastReadAt: new Date() },
    });

    return { success: true, message: 'Conversación marcada como leída' };
  }

  async deleteConversation(tenantId: string, conversationId: string, userId: string) {
    const conversation = await this.prisma.conversation.findFirst({
      where: { id: conversationId, tenantId },
      include: {
        participants: true,
      },
    });

    if (!conversation) {
      throw new NotFoundException('Conversación no encontrada');
    }

    const isParticipant = conversation.participants.some(
      (participant) => participant.userId === userId,
    );

    if (!isParticipant) {
      throw new ForbiddenException('No eres participante de esta conversación');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.conversationParticipant.delete({
        where: {
          conversationId_userId: { conversationId, userId },
        },
      });

      const remainingParticipants = await tx.conversationParticipant.count({
        where: { conversationId },
      });

      if (remainingParticipants === 0) {
        await tx.message.deleteMany({
          where: { conversationId },
        });

        await tx.conversation.delete({
          where: { id: conversationId },
        });
      }
    });

    return { success: true, message: 'Conversación eliminada' };
  }

  async getUnreadCount(tenantId: string, userId: string) {
    const participations = await this.prisma.conversationParticipant.findMany({
      where: { userId },
    });

    let totalUnread = 0;

    for (const participation of participations) {
      const count = await this.prisma.message.count({
        where: {
          conversationId: participation.conversationId,
          tenantId,
          createdAt: { gt: participation.lastReadAt || new Date(0) },
          senderId: { not: userId },
        },
      });
      totalUnread += count;
    }

    return { unread: totalUnread };
  }

  async escalateConversation(tenantId: string, conversationId: string, userId: string, reason: string) {
    const conversation = await this.prisma.conversation.findFirst({
      where: { id: conversationId, tenantId },
      include: { participants: true },
    });

    if (!conversation) {
      throw new NotFoundException('Conversación no encontrada');
    }

    const directors = await this.prisma.userTenant.findMany({
      where: {
        tenantId,
        role: 'director',
        active: true,
      },
      select: { userId: true },
    });

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

    for (const director of directors) {
      const exists = conversation.participants.find(
        (participant) => participant.userId === director.userId,
      );
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

  async updateConversationType(
    tenantId: string,
    conversationId: string,
    type: 'normal' | 'urgent' | 'escalated',
  ) {
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

  private async getUsersMap(userIds: string[], tenantId: string) {
    const uniqueIds = [...new Set(userIds.filter(Boolean))];
    if (uniqueIds.length === 0) {
      return new Map<string, UserDisplay>();
    }

    const users = await this.prisma.user.findMany({
      where: { id: { in: uniqueIds } },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        avatarUrl: true,
        userTenants: {
          where: { tenantId, active: true },
          select: { role: true },
          take: 1,
        },
      },
    });

    return new Map<string, UserDisplay>(
      users.map((user) => [
        user.id,
        {
          firstName: user.firstName,
          lastName: user.lastName,
          avatarUrl: user.avatarUrl,
          role: user.userTenants[0]?.role ?? null,
        },
      ]),
    );
  }

  private enrichParticipant(
    participant: {
      userId: string;
      joinedAt: Date;
      lastReadAt: Date | null;
    },
    usersById: Map<string, UserDisplay>,
  ) {
    const user = usersById.get(participant.userId);

    return {
      userId: participant.userId,
      firstName: user?.firstName || '',
      lastName: user?.lastName || '',
      avatarUrl: user?.avatarUrl ?? null,
      role: user?.role ?? null,
      joinedAt: participant.joinedAt,
      lastReadAt: participant.lastReadAt,
    };
  }

  private enrichMessageWithSender(
    message: {
      id: string;
      tenantId: string;
      conversationId: string;
      senderId: string;
      content: string;
      messageType: string;
      attachmentUrl: string | null;
      createdAt: Date;
      deletedAt: Date | null;
    },
    usersById: Map<string, UserDisplay>,
  ) {
    const sender = usersById.get(message.senderId);
    const senderName = [sender?.firstName, sender?.lastName]
      .filter((value): value is string => Boolean(value))
      .join(' ')
      .trim();

    return {
      ...message,
      senderName: senderName || 'Usuario',
      senderAvatarUrl: sender?.avatarUrl ?? null,
    };
  }

  private isOutOfHours(): boolean {
    const now = new Date();
    const hour = now.getHours();
    const day = now.getDay();

    return hour < 7 || hour >= 18 || day === 0 || day === 6;
  }

  private async getParentContacts(tenantId: string, userId: string) {
    const children = await this.prisma.child.findMany({
      where: {
        tenantId,
        deletedAt: null,
        parents: { some: { userId } },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        group: {
          select: {
            id: true,
            name: true,
            teacherId: true,
          },
        },
      },
    });

    const teacherIds = [
      ...new Set(
        children
          .map((child) => child.group.teacherId)
          .filter((teacherId): teacherId is string => Boolean(teacherId)),
      ),
    ];

    const teachers = await this.prisma.user.findMany({
      where: {
        id: { in: teacherIds },
        deletedAt: null,
        userTenants: {
          some: { tenantId, role: 'teacher', active: true },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        avatarUrl: true,
      },
    });

    const teachersById = new Map(teachers.map((teacher) => [teacher.id, teacher]));
    const directors = await this.getTenantUsersByRole(tenantId, 'director', userId);
    const contacts = new Map<string, ChatContactOption>();

    for (const child of children) {
      const teacherId = child.group.teacherId;
      if (teacherId) {
        const teacher = teachersById.get(teacherId);
        if (teacher) {
          this.upsertContact(
            contacts,
            teacher,
            'teacher',
            'teachers',
            child,
            child.group,
          );
        }
      }

      for (const director of directors) {
        this.upsertContact(
          contacts,
          director,
          'director',
          'administration',
          child,
          child.group,
        );
      }
    }

    return this.sortContacts(contacts);
  }

  private async getTeacherContacts(tenantId: string, userId: string) {
    const children = await this.prisma.child.findMany({
      where: {
        tenantId,
        deletedAt: null,
        group: {
          is: { teacherId: userId },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        group: {
          select: {
            id: true,
            name: true,
          },
        },
        parents: {
          select: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                avatarUrl: true,
                deletedAt: true,
              },
            },
          },
        },
      },
    });

    const contacts = new Map<string, ChatContactOption>();
    const directors = await this.getTenantUsersByRole(tenantId, 'director', userId);

    for (const child of children) {
      for (const parentRelation of child.parents) {
        if (!parentRelation.user || parentRelation.user.deletedAt) {
          continue;
        }

        this.upsertContact(
          contacts,
          parentRelation.user,
          'parent',
          'parents',
          child,
          child.group,
        );
      }

      for (const director of directors) {
        this.upsertContact(
          contacts,
          director,
          'director',
          'administration',
          child,
          child.group,
        );
      }
    }

    return this.sortContacts(contacts);
  }

  private async getStaffContacts(tenantId: string, currentUserId: string) {
    const contacts = new Map<string, ChatContactOption>();

    const childrenWithTeachers = await this.prisma.child.findMany({
      where: {
        tenantId,
        deletedAt: null,
        group: {
          is: {
            teacherId: { not: null },
          },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        group: {
          select: {
            id: true,
            name: true,
            teacherId: true,
          },
        },
      },
    });

    const teacherIds = [
      ...new Set(
        childrenWithTeachers
          .map((child) => child.group.teacherId)
          .filter(
            (teacherId): teacherId is string =>
              Boolean(teacherId) && teacherId !== currentUserId,
          ),
      ),
    ];

    const teachers = await this.prisma.user.findMany({
      where: {
        id: { in: teacherIds },
        deletedAt: null,
        userTenants: {
          some: { tenantId, role: 'teacher', active: true },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        avatarUrl: true,
      },
    });
    const teachersById = new Map(teachers.map((teacher) => [teacher.id, teacher]));

    for (const child of childrenWithTeachers) {
      const teacherId = child.group.teacherId;
      if (!teacherId) {
        continue;
      }

      const teacher = teachersById.get(teacherId);
      if (!teacher) {
        continue;
      }

      this.upsertContact(
        contacts,
        teacher,
        'teacher',
        'teachers',
        child,
        child.group,
      );
    }

    const parentRelations = await this.prisma.childParent.findMany({
      where: {
        child: {
          is: {
            tenantId,
            deletedAt: null,
          },
        },
        user: {
          is: {
            deletedAt: null,
          },
        },
      },
      select: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            group: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
          },
        },
      },
    });

    for (const relation of parentRelations) {
      if (!relation.user || relation.user.id === currentUserId) {
        continue;
      }

      this.upsertContact(
        contacts,
        relation.user,
        'parent',
        'parents',
        relation.child,
        relation.child.group,
      );
    }

    return this.sortContacts(contacts);
  }

  private async getTenantUsersByRole(
    tenantId: string,
    role: 'director' | 'teacher',
    excludedUserId?: string,
  ) {
    const memberships = await this.prisma.userTenant.findMany({
      where: {
        tenantId,
        role,
        active: true,
        ...(excludedUserId ? { userId: { not: excludedUserId } } : {}),
      },
      select: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
            deletedAt: true,
          },
        },
      },
    });

    return memberships
      .map((membership) => membership.user)
      .filter((user): user is { id: string; firstName: string; lastName: string; avatarUrl: string | null; deletedAt: Date | null } => (
        Boolean(user && !user.deletedAt)
      ))
      .map(({ deletedAt, ...user }) => user);
  }

  private upsertContact(
    contacts: Map<string, ChatContactOption>,
    user: {
      id: string;
      firstName: string;
      lastName: string;
      avatarUrl: string | null;
    },
    role: string,
    category: ContactCategory,
    child: {
      id: string;
      firstName: string;
      lastName: string;
    },
    group?: {
      id: string;
      name: string;
    } | null,
  ) {
    const existing = contacts.get(user.id);
    const contact: ChatContactOption = existing ?? {
      userId: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      role,
      category,
      childIds: [],
      childNames: [],
      groupIds: [],
      groupNames: [],
    };

    this.pushUnique(contact.childIds, child.id);
    this.pushUnique(contact.childNames, `${child.firstName} ${child.lastName}`.trim());

    if (group) {
      this.pushUnique(contact.groupIds, group.id);
      this.pushUnique(contact.groupNames, group.name);
    }

    contacts.set(user.id, contact);
  }

  private pushUnique(target: string[], value: string) {
    if (value && !target.includes(value)) {
      target.push(value);
    }
  }

  private sortContacts(contacts: Map<string, ChatContactOption>) {
    return [...contacts.values()].sort((left, right) => {
      if (left.category !== right.category) {
        return left.category.localeCompare(right.category);
      }

      return `${left.firstName} ${left.lastName}`
        .trim()
        .localeCompare(`${right.firstName} ${right.lastName}`.trim());
    });
  }

  private async findExistingConversation(
    tenantId: string,
    childId: string,
    participantIds: string[],
  ) {
    const normalizedIds = [...participantIds].sort();
    const conversations = await this.prisma.conversation.findMany({
      where: {
        tenantId,
        childId,
        participants: {
          some: {
            userId: { in: normalizedIds },
          },
        },
      },
      include: {
        participants: true,
      },
    });

    return conversations.find((conversation) => {
      const conversationParticipantIds = conversation.participants
        .map((participant) => participant.userId)
        .sort();

      return (
        conversationParticipantIds.length === normalizedIds.length &&
        conversationParticipantIds.every((participantId, index) => (
          participantId === normalizedIds[index]
        ))
      );
    });
  }
}
