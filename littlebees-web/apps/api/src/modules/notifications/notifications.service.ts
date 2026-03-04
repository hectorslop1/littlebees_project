import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    userId: string,
    options?: { read?: boolean; type?: string; page?: number; limit?: number },
  ) {
    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { tenantId, userId };

    if (options?.read !== undefined) where.read = options.read;
    if (options?.type) where.type = options.type;

    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    };
  }

  async getUnreadCount(tenantId: string, userId: string) {
    const [total, unread] = await Promise.all([
      this.prisma.notification.count({ where: { tenantId, userId } }),
      this.prisma.notification.count({ where: { tenantId, userId, read: false } }),
    ]);

    return { total, unread };
  }

  async markAsRead(tenantId: string, userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, tenantId, userId },
    });

    if (!notification) {
      throw new NotFoundException('Notificación no encontrada');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { read: true, readAt: new Date() },
    });
  }

  async markAllAsRead(tenantId: string, userId: string) {
    await this.prisma.notification.updateMany({
      where: { tenantId, userId, read: false },
      data: { read: true, readAt: new Date() },
    });

    return { success: true, message: 'Todas las notificaciones marcadas como leídas' };
  }

  async delete(tenantId: string, userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, tenantId, userId },
    });

    if (!notification) {
      throw new NotFoundException('Notificación no encontrada');
    }

    await this.prisma.notification.delete({ where: { id: notificationId } });

    return { success: true, message: 'Notificación eliminada' };
  }

  async create(
    tenantId: string,
    data: {
      userId: string;
      type: string;
      title: string;
      body: string;
      data?: Record<string, unknown>;
      channel?: string;
    },
  ) {
    return this.prisma.notification.create({
      data: {
        tenantId,
        userId: data.userId,
        type: data.type,
        title: data.title,
        body: data.body,
        data: data.data ? JSON.parse(JSON.stringify(data.data)) : undefined,
        channel: data.channel || 'in_app',
        sentAt: new Date(),
      },
    });
  }
}
