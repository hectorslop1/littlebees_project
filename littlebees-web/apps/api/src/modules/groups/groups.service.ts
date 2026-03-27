import { Injectable, NotFoundException } from '@nestjs/common';
import { FilesService } from '../files/files.service';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly filesService: FilesService,
  ) {}

  async findAll(tenantId: string, userId?: string, userRole?: string) {
    const where: any = { tenantId };

    if (userRole === 'teacher') {
      where.teacherId = userId;
    }

    return this.prisma.group.findMany({
      where,
      include: {
        _count: {
          select: { children: true },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  async findById(id: string, tenantId: string, userId?: string, userRole?: string) {
    const where: any = { id, tenantId };

    if (userRole === 'teacher') {
      where.teacherId = userId;
    }

    const group = await this.prisma.group.findFirst({
      where,
      include: {
        children: {
          where: { status: 'active' },
          select: {
            id: true,
            firstName: true,
            lastName: true,
            dateOfBirth: true,
            photoUrl: true,
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Grupo no encontrado');
    }

    return {
      ...group,
      children: group.children.map((child) => ({
        ...child,
        photoUrl: child.photoUrl
          ? this.filesService.resolveStoredFileUrl(child.photoUrl)
          : null,
      })),
    };
  }

  async create(
    tenantId: string,
    data: {
      name: string;
      level: string;
      friendlyName: string;
      subgroup?: string;
      ageRangeMin: number;
      ageRangeMax: number;
      capacity: number;
      color?: string;
      academicYear: string;
      teacherId?: string;
    },
  ) {
    return this.prisma.group.create({
      data: {
        tenantId,
        name: data.name,
        // level: data.level as any, // DISABLED: Field doesn't exist in DB
        // friendlyName: data.friendlyName, // DISABLED: Field doesn't exist in DB
        // subgroup: data.subgroup, // DISABLED: Field doesn't exist in DB
        ageRangeMin: data.ageRangeMin,
        ageRangeMax: data.ageRangeMax,
        capacity: data.capacity,
        color: data.color || '#4ECDC4',
        academicYear: data.academicYear,
        teacherId: data.teacherId,
      },
    });
  }

  async update(
    id: string,
    tenantId: string,
    data: {
      name?: string;
      level?: string;
      friendlyName?: string;
      subgroup?: string;
      ageRangeMin?: number;
      ageRangeMax?: number;
      capacity?: number;
      color?: string;
      academicYear?: string;
      teacherId?: string;
    },
  ) {
    await this.findById(id, tenantId);

    return this.prisma.group.update({
      where: { id },
      data: {
        ...data,
        // level: data.level as any, // DISABLED: Field doesn't exist in DB
      },
    });
  }

  async delete(id: string, tenantId: string) {
    await this.findById(id, tenantId);

    // Check if group has active children
    const childrenCount = await this.prisma.child.count({
      where: { groupId: id, status: 'active' },
    });

    if (childrenCount > 0) {
      throw new NotFoundException(
        `No se puede eliminar el grupo porque tiene ${childrenCount} niños activos`,
      );
    }

    return this.prisma.group.delete({
      where: { id },
    });
  }
}
