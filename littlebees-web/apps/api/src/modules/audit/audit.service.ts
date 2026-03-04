import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    options?: {
      resourceType?: string;
      resourceId?: string;
      userId?: string;
      action?: string;
      startDate?: string;
      endDate?: string;
      page?: number;
      limit?: number;
    },
  ) {
    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { tenantId };

    if (options?.resourceType) where.resourceType = options.resourceType;
    if (options?.resourceId) where.resourceId = options.resourceId;
    if (options?.userId) where.userId = options.userId;
    if (options?.action) where.action = options.action;

    if (options?.startDate || options?.endDate) {
      where.createdAt = {
        ...(options?.startDate && { gte: new Date(options.startDate) }),
        ...(options?.endDate && { lte: new Date(options.endDate) }),
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.auditLog.count({ where }),
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

  async findByResource(
    tenantId: string,
    resourceType: string,
    resourceId: string,
  ) {
    return this.prisma.auditLog.findMany({
      where: { tenantId, resourceType, resourceId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
