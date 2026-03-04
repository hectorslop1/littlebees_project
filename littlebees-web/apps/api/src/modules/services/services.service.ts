import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ServicesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    options?: { type?: string; status?: string; search?: string; page?: number; limit?: number },
  ) {
    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { tenantId };

    if (options?.type) where.type = options.type;
    if (options?.status) where.status = options.status;
    if (options?.search) {
      where.OR = [
        { name: { contains: options.search, mode: 'insensitive' as const } },
        { description: { contains: options.search, mode: 'insensitive' as const } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.extraService.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.extraService.count({ where }),
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

  async findById(tenantId: string, id: string) {
    const service = await this.prisma.extraService.findFirst({
      where: { id, tenantId },
    });

    if (!service) {
      throw new NotFoundException('Servicio no encontrado');
    }

    return service;
  }

  async create(
    tenantId: string,
    data: {
      name: string;
      description?: string;
      type: string;
      schedule?: string;
      price: number;
      capacity?: number;
      imageUrl?: string;
    },
  ) {
    return this.prisma.extraService.create({
      data: {
        ...data,
        tenantId,
        status: 'active',
      },
    });
  }

  async update(
    tenantId: string,
    id: string,
    data: {
      name?: string;
      description?: string;
      schedule?: string;
      price?: number;
      capacity?: number;
      imageUrl?: string;
      status?: string;
    },
  ) {
    await this.findById(tenantId, id);

    return this.prisma.extraService.update({
      where: { id },
      data,
    });
  }

  async delete(tenantId: string, id: string) {
    await this.findById(tenantId, id);

    return this.prisma.extraService.update({
      where: { id },
      data: { status: 'inactive' },
    });
  }
}
