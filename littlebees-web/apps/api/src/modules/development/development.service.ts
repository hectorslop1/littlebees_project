import { Injectable, NotFoundException } from '@nestjs/common';
import { DevelopmentCategory, MilestoneStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DevelopmentService {
  constructor(private readonly prisma: PrismaService) {}

  // --- Milestones (global catalog, no tenantId) ---

  async findAllMilestones(options?: { category?: string; ageRangeMin?: number; ageRangeMax?: number }) {
    const where: Record<string, unknown> = {};

    if (options?.category) where.category = options.category as DevelopmentCategory;
    if (options?.ageRangeMin !== undefined) where.ageRangeMin = { gte: options.ageRangeMin };
    if (options?.ageRangeMax !== undefined) where.ageRangeMax = { lte: options.ageRangeMax };

    return this.prisma.developmentMilestone.findMany({
      where,
      orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }],
    });
  }

  async findMilestoneById(id: string) {
    const milestone = await this.prisma.developmentMilestone.findUnique({ where: { id } });

    if (!milestone) {
      throw new NotFoundException('Hito de desarrollo no encontrado');
    }

    return milestone;
  }

  async createMilestone(data: {
    category: DevelopmentCategory;
    title: string;
    description?: string;
    ageRangeMin: number;
    ageRangeMax: number;
    sortOrder: number;
  }) {
    return this.prisma.developmentMilestone.create({ data });
  }

  async updateMilestone(id: string, data: Partial<{
    category: DevelopmentCategory;
    title: string;
    description: string;
    ageRangeMin: number;
    ageRangeMax: number;
    sortOrder: number;
  }>) {
    await this.findMilestoneById(id);
    return this.prisma.developmentMilestone.update({ where: { id }, data });
  }

  async deleteMilestone(id: string) {
    await this.findMilestoneById(id);
    return this.prisma.developmentMilestone.delete({ where: { id } });
  }

  // --- Development Records (tenant-scoped) ---

  async findRecords(
    tenantId: string,
    options?: { childId?: string; milestoneId?: string; category?: string; status?: string },
  ) {
    const where: Record<string, unknown> = { tenantId };

    if (options?.childId) where.childId = options.childId;
    if (options?.milestoneId) where.milestoneId = options.milestoneId;
    if (options?.status) where.status = options.status as MilestoneStatus;
    if (options?.category) {
      where.milestone = { category: options.category as DevelopmentCategory };
    }

    return this.prisma.developmentRecord.findMany({
      where,
      include: {
        milestone: true,
        child: { select: { id: true, firstName: true, lastName: true } },
      },
      orderBy: { evaluatedAt: 'desc' },
    });
  }

  async findRecordById(id: string, tenantId: string) {
    const record = await this.prisma.developmentRecord.findFirst({
      where: { id, tenantId },
      include: {
        milestone: true,
        child: { select: { id: true, firstName: true, lastName: true } },
      },
    });

    if (!record) {
      throw new NotFoundException('Registro de desarrollo no encontrado');
    }

    return record;
  }

  async createRecord(
    tenantId: string,
    userId: string,
    data: {
      childId: string;
      milestoneId: string;
      status: MilestoneStatus;
      observations?: string;
      evidenceUrls?: string[];
    },
  ) {
    return this.prisma.developmentRecord.create({
      data: {
        tenantId,
        childId: data.childId,
        milestoneId: data.milestoneId,
        status: data.status,
        observations: data.observations,
        evidenceUrls: data.evidenceUrls || [],
        evaluatedBy: userId,
        evaluatedAt: new Date(),
      },
      include: { milestone: true },
    });
  }

  async updateRecord(
    id: string,
    tenantId: string,
    data: {
      status?: MilestoneStatus;
      observations?: string;
      evidenceUrls?: string[];
    },
  ) {
    await this.findRecordById(id, tenantId);

    return this.prisma.developmentRecord.update({
      where: { id },
      data,
      include: { milestone: true },
    });
  }

  async getChildSummary(tenantId: string, childId: string) {
    const records = await this.prisma.developmentRecord.findMany({
      where: { tenantId, childId },
      include: { milestone: true },
    });

    const categories = Object.values(DevelopmentCategory);
    const summary = categories.map((category) => {
      const categoryRecords = records.filter((r) => r.milestone.category === category);
      const achieved = categoryRecords.filter((r) => r.status === MilestoneStatus.achieved).length;
      const total = categoryRecords.length;

      return {
        category,
        achieved,
        inProgress: categoryRecords.filter((r) => r.status === MilestoneStatus.in_progress).length,
        notAchieved: categoryRecords.filter((r) => r.status === MilestoneStatus.not_achieved).length,
        total,
        percent: total > 0 ? Math.round((achieved / total) * 100) : 0,
      };
    });

    const totalRecords = records.length;
    const totalAchieved = records.filter((r) => r.status === MilestoneStatus.achieved).length;

    return {
      childId,
      overallProgress: totalRecords > 0 ? Math.round((totalAchieved / totalRecords) * 100) : 0,
      categories: summary,
    };
  }
}
