import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAnnouncementDto, UpdateAnnouncementDto } from './dto';

@Injectable()
export class AnnouncementsService {
  constructor(private prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    filters: {
      type?: string;
      priority?: string;
      page?: number;
      limit?: number;
    },
  ) {
    const { type, priority, page = 1, limit = 10 } = filters;
    const skip = (page - 1) * limit;

    const where: any = { tenantId };
    if (type) where.type = type;
    if (priority) where.priority = priority;

    const [announcements, total] = await Promise.all([
      this.prisma.announcement.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: {
          author: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
            },
          },
        },
      }),
      this.prisma.announcement.count({ where }),
    ]);

    return {
      announcements,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(tenantId: string, id: string) {
    const announcement = await this.prisma.announcement.findFirst({
      where: { id, tenantId },
    });

    if (!announcement) {
      throw new NotFoundException('Anuncio no encontrado');
    }

    return announcement;
  }

  async create(
    tenantId: string,
    authorId: string,
    createAnnouncementDto: CreateAnnouncementDto,
  ) {
    return this.prisma.announcement.create({
      data: {
        ...createAnnouncementDto,
        tenantId,
        authorId,
      },
    });
  }

  async update(
    tenantId: string,
    id: string,
    updateAnnouncementDto: UpdateAnnouncementDto,
  ) {
    await this.findOne(tenantId, id);

    return this.prisma.announcement.update({
      where: { id },
      data: updateAnnouncementDto,
    });
  }

  async delete(tenantId: string, id: string) {
    await this.findOne(tenantId, id);

    await this.prisma.announcement.delete({
      where: { id },
    });

    return { message: 'Anuncio eliminado exitosamente' };
  }
}
