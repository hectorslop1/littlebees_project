import { Injectable, NotFoundException } from '@nestjs/common';
import { ChildStatus, Gender } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChildrenService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(tenantId: string, options?: { groupId?: string; status?: string; search?: string }) {
    return this.prisma.child.findMany({
      where: {
        tenantId,
        ...(options?.groupId && { groupId: options.groupId }),
        ...(options?.status && { status: options.status as ChildStatus }),
        ...(options?.search && {
          OR: [
            { firstName: { contains: options.search, mode: 'insensitive' as const } },
            { lastName: { contains: options.search, mode: 'insensitive' as const } },
          ],
        }),
      },
      include: {
        group: { select: { id: true, name: true, color: true } },
      },
      orderBy: { firstName: 'asc' },
    });
  }

  async findById(id: string, tenantId: string) {
    const child = await this.prisma.child.findFirst({
      where: { id, tenantId },
      include: {
        group: true,
        medicalInfo: true,
        emergencyContacts: { orderBy: { priority: 'asc' } },
        parents: {
          include: { user: { select: { id: true, firstName: true, lastName: true, phone: true, email: true } } },
        },
      },
    });

    if (!child) {
      throw new NotFoundException('Niño/a no encontrado');
    }

    return child;
  }

  async create(tenantId: string, data: { firstName: string; lastName: string; dateOfBirth: Date; gender: Gender; groupId: string }) {
    return this.prisma.child.create({
      data: {
        firstName: data.firstName,
        lastName: data.lastName,
        dateOfBirth: data.dateOfBirth,
        gender: data.gender,
        groupId: data.groupId,
        tenantId,
        enrollmentDate: new Date(),
        status: ChildStatus.active,
      },
    });
  }
}
