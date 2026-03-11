import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DailyLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async findByChildAndDate(tenantId: string, childId: string, date: string) {
    return this.prisma.dailyLogEntry.findMany({
      where: { tenantId, childId, date: new Date(date) },
      orderBy: { time: 'asc' },
    });
  }

  async create(tenantId: string, userId: string, data: {
    childId: string;
    date: string;
    type: string;
    title: string;
    description?: string;
    time: string;
    metadata?: Prisma.InputJsonValue;
  }) {
    return this.prisma.dailyLogEntry.create({
      data: {
        tenantId,
        childId: data.childId,
        date: new Date(data.date),
        type: data.type,
        title: data.title,
        description: data.description,
        time: data.time,
        metadata: data.metadata ?? Prisma.JsonNull,
        recordedBy: userId,
      },
    });
  }

  async update(
    id: string,
    tenantId: string,
    data: {
      type?: string;
      title?: string;
      description?: string;
      time?: string;
      metadata?: Prisma.InputJsonValue;
    },
  ) {
    const entry = await this.prisma.dailyLogEntry.findFirst({
      where: { id, tenantId },
    });

    if (!entry) {
      throw new NotFoundException('Entrada de bitácora no encontrada');
    }

    return this.prisma.dailyLogEntry.update({
      where: { id },
      data,
    });
  }

  async delete(id: string, tenantId: string) {
    const entry = await this.prisma.dailyLogEntry.findFirst({
      where: { id, tenantId },
    });

    if (!entry) {
      throw new NotFoundException('Entrada de bitácora no encontrada');
    }

    return this.prisma.dailyLogEntry.delete({
      where: { id },
    });
  }
}
