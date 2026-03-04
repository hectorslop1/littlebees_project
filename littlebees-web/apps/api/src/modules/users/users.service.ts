import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(tenantId: string) {
    return this.prisma.user.findMany({
      where: {
        userTenants: { some: { tenantId, active: true } },
      },
      include: {
        userTenants: {
          where: { tenantId },
          select: { role: true },
        },
      },
    });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }
}
