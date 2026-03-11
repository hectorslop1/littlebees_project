import { Injectable, NotFoundException } from '@nestjs/common';
import { ChildStatus, Gender } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChildrenService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(tenantId: string, userId: string, userRole: string, options?: { groupId?: string; status?: string; search?: string }) {
    // Role-based filtering
    let roleFilter = {};
    
    if (userRole === 'parent') {
      // Parents only see their own children
      roleFilter = {
        parents: {
          some: {
            userId: userId,
          },
        },
      };
    } else if (userRole === 'teacher') {
      // Teachers only see children in their groups
      const teacherGroups = await this.prisma.group.findMany({
        where: { tenantId, teacherId: userId },
        select: { id: true },
      });
      const groupIds = teacherGroups.map(g => g.id);
      
      if (groupIds.length > 0) {
        roleFilter = {
          groupId: { in: groupIds },
        };
      } else {
        // Teacher has no groups assigned, return empty
        return [];
      }
    }
    // Admin, director, super_admin see all children (no additional filter)
    
    return this.prisma.child.findMany({
      where: {
        tenantId,
        ...roleFilter,
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

  async update(
    id: string,
    tenantId: string,
    data: {
      firstName?: string;
      lastName?: string;
      dateOfBirth?: Date;
      gender?: Gender;
      groupId?: string;
      photoUrl?: string;
      status?: ChildStatus;
    },
  ) {
    await this.findById(id, tenantId);

    return this.prisma.child.update({
      where: { id },
      data,
      include: {
        group: { select: { id: true, name: true, color: true } },
      },
    });
  }

  async delete(id: string, tenantId: string) {
    await this.findById(id, tenantId);

    return this.prisma.child.update({
      where: { id },
      data: {
        status: ChildStatus.inactive,
        deletedAt: new Date(),
      },
    });
  }

  // Medical Info
  async upsertMedicalInfo(
    childId: string,
    tenantId: string,
    data: {
      allergies?: string[];
      conditions?: string[];
      medications?: string[];
      bloodType?: string;
      observations?: string;
      doctorName?: string;
      doctorPhone?: string;
      insuranceInfo?: any;
    },
  ) {
    await this.findById(childId, tenantId);

    return this.prisma.childMedicalInfo.upsert({
      where: { childId },
      create: {
        childId,
        tenantId,
        allergies: data.allergies || [],
        conditions: data.conditions || [],
        medications: data.medications || [],
        bloodType: data.bloodType,
        observations: data.observations,
        doctorName: data.doctorName,
        doctorPhone: data.doctorPhone,
        insuranceInfo: data.insuranceInfo,
      },
      update: data,
    });
  }

  // Emergency Contacts
  async addEmergencyContact(
    childId: string,
    tenantId: string,
    data: {
      name: string;
      relationship: string;
      phone: string;
      email?: string;
      priority?: number;
    },
  ) {
    await this.findById(childId, tenantId);

    return this.prisma.emergencyContact.create({
      data: {
        childId,
        tenantId,
        name: data.name,
        relationship: data.relationship,
        phone: data.phone,
        email: data.email,
        priority: data.priority || 1,
      },
    });
  }

  async updateEmergencyContact(
    contactId: string,
    childId: string,
    tenantId: string,
    data: {
      name?: string;
      relationship?: string;
      phone?: string;
      email?: string;
      priority?: number;
    },
  ) {
    const contact = await this.prisma.emergencyContact.findFirst({
      where: { id: contactId, childId, tenantId },
    });

    if (!contact) {
      throw new NotFoundException('Contacto de emergencia no encontrado');
    }

    return this.prisma.emergencyContact.update({
      where: { id: contactId },
      data,
    });
  }

  async deleteEmergencyContact(
    contactId: string,
    childId: string,
    tenantId: string,
  ) {
    const contact = await this.prisma.emergencyContact.findFirst({
      where: { id: contactId, childId, tenantId },
    });

    if (!contact) {
      throw new NotFoundException('Contacto de emergencia no encontrado');
    }

    return this.prisma.emergencyContact.delete({
      where: { id: contactId },
    });
  }
}
