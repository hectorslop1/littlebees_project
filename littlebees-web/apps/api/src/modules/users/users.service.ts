import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangeRoleDto } from './dto/change-role.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(tenantId: string) {
    return this.prisma.user.findMany({
      where: {
        userTenants: { some: { tenantId, active: true } },
        deletedAt: null,
      },
      include: {
        userTenants: {
          where: { tenantId },
          select: { role: true, active: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findById(id: string, tenantId: string) {
    const user = await this.prisma.user.findFirst({
      where: {
        id,
        deletedAt: null,
        userTenants: { some: { tenantId, active: true } },
      },
      include: {
        userTenants: {
          where: { tenantId },
          select: { role: true, active: true, joinedAt: true },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    return user;
  }

  async create(tenantId: string, createUserDto: CreateUserDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
    });

    if (existingUser) {
      throw new ConflictException('El email ya está registrado');
    }

    const passwordHash = await bcrypt.hash(createUserDto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email: createUserDto.email,
        passwordHash,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        phone: createUserDto.phone,
        userTenants: {
          create: {
            tenantId,
            role: createUserDto.role,
            active: true,
          },
        },
      },
      include: {
        userTenants: {
          where: { tenantId },
          select: { role: true, active: true },
        },
      },
    });

    return user;
  }

  async update(id: string, tenantId: string, updateUserDto: UpdateUserDto) {
    await this.findById(id, tenantId);

    if (updateUserDto.email) {
      const existingUser = await this.prisma.user.findFirst({
        where: {
          email: updateUserDto.email,
          id: { not: id },
        },
      });

      if (existingUser) {
        throw new ConflictException('El email ya está en uso');
      }
    }

    const updateData: any = {
      email: updateUserDto.email,
      firstName: updateUserDto.firstName,
      lastName: updateUserDto.lastName,
      phone: updateUserDto.phone,
      avatarUrl: updateUserDto.avatarUrl,
    };

    if (updateUserDto.password) {
      updateData.passwordHash = await bcrypt.hash(updateUserDto.password, 10);
    }

    const user = await this.prisma.user.update({
      where: { id },
      data: updateData,
      include: {
        userTenants: {
          where: { tenantId },
          select: { role: true, active: true },
        },
      },
    });

    return user;
  }

  async remove(id: string, tenantId: string) {
    await this.findById(id, tenantId);

    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { message: 'Usuario desactivado exitosamente' };
  }

  async changeRole(id: string, tenantId: string, changeRoleDto: ChangeRoleDto) {
    await this.findById(id, tenantId);

    await this.prisma.userTenant.update({
      where: {
        userId_tenantId: {
          userId: id,
          tenantId,
        },
      },
      data: {
        role: changeRoleDto.role,
      },
    });

    return this.findById(id, tenantId);
  }
}
