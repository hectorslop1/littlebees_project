import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { ChildStatus, Gender } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ChildProfileDto } from './dto/child-profile.dto';
import { FilesService } from '../files/files.service';

@Injectable()
export class ChildrenService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly filesService: FilesService,
  ) {}

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
    
    const children = await this.prisma.child.findMany({
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

    return Promise.all(
      children.map(async (child) => ({
        ...child,
        photoUrl: await this.resolvePhotoUrl(tenantId, child.photoUrl),
      })),
    );
  }

  async findById(id: string, tenantId: string, userId?: string, userRole?: string) {
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

    if (userId && userRole) {
      await this.assertChildAccess(child, tenantId, userId, userRole);
    }

    return {
      ...child,
      photoUrl: await this.resolvePhotoUrl(tenantId, child.photoUrl),
    };
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

  async updateProfile(
    childId: string,
    tenantId: string,
    userId: string,
    userRole: string,
    data: {
      firstName?: string;
      lastName?: string;
      dateOfBirth?: Date;
      gender?: Gender;
      photoUrl?: string | null;
    },
  ) {
    await this.findById(childId, tenantId, userId, userRole);

    const updatedChild = await this.prisma.child.update({
      where: { id: childId },
      data,
      include: {
        group: { select: { id: true, name: true, color: true } },
      },
    });

    return {
      ...updatedChild,
      photoUrl: await this.resolvePhotoUrl(tenantId, updatedChild.photoUrl),
    };
  }

  // Medical Info
  async upsertMedicalInfo(
    childId: string,
    tenantId: string,
    userId: string,
    userRole: string,
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
    await this.findById(childId, tenantId, userId, userRole);

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
    userId: string,
    userRole: string,
    data: {
      name: string;
      relationship: string;
      phone: string;
      email?: string;
      photoUrl?: string;
      idPhotoUrl?: string;
      priority?: number;
    },
  ) {
    await this.findById(childId, tenantId, userId, userRole);

    return this.prisma.emergencyContact.create({
      data: {
        childId,
        tenantId,
        name: data.name,
        relationship: data.relationship,
        phone: data.phone,
        email: data.email,
        photoUrl: data.photoUrl,
        idPhotoUrl: data.idPhotoUrl,
        priority: data.priority || 1,
      },
    });
  }

  async updateEmergencyContact(
    contactId: string,
    childId: string,
    tenantId: string,
    userId: string,
    userRole: string,
    data: {
      name?: string;
      relationship?: string;
      phone?: string;
      email?: string;
      photoUrl?: string;
      idPhotoUrl?: string;
      priority?: number;
    },
  ) {
    await this.findById(childId, tenantId, userId, userRole);

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
    userId: string,
    userRole: string,
  ) {
    await this.findById(childId, tenantId, userId, userRole);

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

  // Get complete child profile
  async getProfile(
    childId: string,
    tenantId: string,
    userId: string,
    userRole: string,
  ): Promise<ChildProfileDto> {
    // Verificar que el niño existe
    const child = await this.prisma.child.findFirst({
      where: { id: childId, tenantId },
      include: {
        group: { select: { id: true, name: true } },
        medicalInfo: true,
        emergencyContacts: { orderBy: { priority: 'asc' } },
        parents: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                phone: true,
              },
            },
          },
        },
      },
    });

    if (!child) {
      throw new NotFoundException('Niño/a no encontrado');
    }

    await this.assertChildAccess(child, tenantId, userId, userRole);

    const resolvedEmergencyContacts = await Promise.all(
      child.emergencyContacts.map(async (contact) => ({
        id: contact.id,
        name: contact.name,
        relationship: contact.relationship,
        phone: contact.phone,
        email: contact.email,
        photoUrl: await this.resolvePhotoUrl(tenantId, contact.photoUrl),
        idPhotoUrl: await this.resolvePhotoUrl(tenantId, contact.idPhotoUrl),
        priority: contact.priority,
      })),
    );

    // Calcular edad
    const today = new Date();
    const birthDate = new Date(child.dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    // Construir DTO de respuesta
    const profile: ChildProfileDto = {
      id: child.id,
      firstName: child.firstName,
      lastName: child.lastName,
      dateOfBirth: child.dateOfBirth,
      gender: child.gender,
      photoUrl: await this.resolvePhotoUrl(tenantId, child.photoUrl),
      groupId: child.groupId,
      groupName: child.group.name,
      enrollmentDate: child.enrollmentDate,
      status: child.status,
      // diagnosis: child.diagnosis, // DISABLED: Field doesn't exist
      age,
      medicalInfo: child.medicalInfo
        ? {
            allergies: child.medicalInfo.allergies,
            conditions: child.medicalInfo.conditions,
            medications: child.medicalInfo.medications,
            bloodType: child.medicalInfo.bloodType,
            observations: child.medicalInfo.observations,
            doctorName: child.medicalInfo.doctorName,
            doctorPhone: child.medicalInfo.doctorPhone,
            // medicalNotes: child.medicalInfo.medicalNotes, // DISABLED: Field doesn't exist
          }
        : undefined,
      emergencyContacts: resolvedEmergencyContacts,
      parents: child.parents.map((parent) => ({
        userId: parent.user.id,
        firstName: parent.user.firstName,
        lastName: parent.user.lastName,
        email: parent.user.email,
        phone: parent.user.phone,
        relationship: parent.relationship,
        isPrimary: parent.isPrimary,
        canPickup: parent.canPickup,
      })),
    };

    return profile;
  }

  async getProfileSuggestions(
    childId: string,
    tenantId: string,
    userId: string,
    userRole: string,
  ) {
    await this.findById(childId, tenantId, userId, userRole);

    const accessibleChildren = await this.findAll(tenantId, userId, userRole);
    const relatedChildIds = accessibleChildren
      .map((child) => child.id)
      .filter((id) => id !== childId);

    if (relatedChildIds.length === 0) {
      return {
        doctors: [],
        pickupContacts: [],
      };
    }

    const relatedChildren = await this.prisma.child.findMany({
      where: {
        tenantId,
        id: { in: relatedChildIds },
      },
      include: {
        medicalInfo: true,
        emergencyContacts: { orderBy: { priority: 'asc' } },
      },
      orderBy: { firstName: 'asc' },
    });

    const doctors = new Map<
      string,
      {
        name: string;
        phone?: string;
        sourceChildId: string;
        sourceChildName: string;
      }
    >();
    const pickupContacts = new Map<
      string,
      {
        name: string;
        relationship: string;
        phone: string;
        email?: string | null;
        photoUrl?: string;
        idPhotoUrl?: string;
        sourceChildId: string;
        sourceChildName: string;
      }
    >();

    for (const child of relatedChildren) {
      const sourceChildName = `${child.firstName} ${child.lastName}`.trim();

      if (child.medicalInfo) {
        const doctorName = child.medicalInfo.doctorName?.trim();
        const doctorPhone = child.medicalInfo.doctorPhone?.trim();

        if (doctorName || doctorPhone) {
          const key = `${doctorName?.toLowerCase() ?? ''}|${doctorPhone ?? ''}`;
          if (!doctors.has(key)) {
            doctors.set(key, {
              name: doctorName ?? 'Doctor registrado',
              phone: doctorPhone || undefined,
              sourceChildId: child.id,
              sourceChildName,
            });
          }
        }
      }

      for (const contact of child.emergencyContacts) {
        const key = [
          contact.name.trim().toLowerCase(),
          contact.phone.trim(),
          contact.relationship.trim().toLowerCase(),
        ].join('|');

        if (pickupContacts.has(key)) {
          continue;
        }

        pickupContacts.set(key, {
          name: contact.name,
          relationship: contact.relationship,
          phone: contact.phone,
          email: contact.email,
          photoUrl: await this.resolvePhotoUrl(tenantId, contact.photoUrl),
          idPhotoUrl: await this.resolvePhotoUrl(tenantId, contact.idPhotoUrl),
          sourceChildId: child.id,
          sourceChildName,
        });
      }
    }

    return {
      doctors: Array.from(doctors.values()).sort((a, b) => a.name.localeCompare(b.name)),
      pickupContacts: Array.from(pickupContacts.values()).sort((a, b) =>
        a.name.localeCompare(b.name),
      ),
    };
  }

  private async resolvePhotoUrl(_tenantId: string, photoUrl?: string | null) {
    if (!photoUrl) {
      return photoUrl ?? undefined;
    }

    if (
      photoUrl.startsWith('http://') ||
      photoUrl.startsWith('https://') ||
      photoUrl.startsWith('data:') ||
      photoUrl.startsWith('/files/public/')
    ) {
      return photoUrl;
    }

    try {
      return this.filesService.getPublicFileUrl(photoUrl);
    } catch {
      return photoUrl;
    }
  }

  private async assertChildAccess(
    child: {
      groupId: string;
      parents: Array<{ userId: string }>;
    },
    tenantId: string,
    userId: string,
    userRole: string,
  ) {
    if (userRole === 'parent') {
      const isParent = child.parents.some((parent) => parent.userId === userId);
      if (!isParent) {
        throw new ForbiddenException('No tienes permiso para ver este perfil');
      }
      return;
    }

    if (userRole === 'teacher') {
      const teacherGroups = await this.prisma.group.findMany({
        where: { tenantId, teacherId: userId },
        select: { id: true },
      });
      const groupIds = teacherGroups.map((group) => group.id);

      if (!groupIds.includes(child.groupId)) {
        throw new ForbiddenException('No tienes permiso para ver este perfil');
      }
    }
  }
}
