import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateCustomizationDto } from './dto/update-customization.dto';
import { FilesService } from '../files/files.service';

const DEFAULT_CUSTOMIZATION = {
  primaryColor: '#D4A853',
  secondaryColor: '#8FAE8B',
  accentColor: '#E8B84B',
  systemName: 'LittleBees',
  menuLabels: {},
  customCss: null,
} as const;

@Injectable()
export class CustomizationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly filesService: FilesService,
  ) {}

  async getCustomization(tenantId: string) {
    const customization = await this.findOrCreate(tenantId);
    return this.serialize(customization);
  }

  async updateCustomization(tenantId: string, dto: UpdateCustomizationDto) {
    const customization = await this.findOrCreate(tenantId);

    const updated = await this.prisma.customization.update({
      where: { id: customization.id },
      data: {
        logoUrl: dto.logoUrl?.trim() ? dto.logoUrl.trim() : dto.logoUrl === '' ? null : undefined,
        primaryColor: dto.primaryColor,
        secondaryColor: dto.secondaryColor,
        accentColor: dto.accentColor,
        systemName: dto.systemName?.trim() || undefined,
        menuLabels: dto.menuLabels,
        customCss: dto.customCss?.trim() ? dto.customCss : dto.customCss === '' ? null : undefined,
      },
    });

    return this.serialize(updated);
  }

  async resetCustomization(tenantId: string) {
    const customization = await this.findOrCreate(tenantId);
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: {
        name: true,
        logoUrl: true,
      },
    });

    const reset = await this.prisma.customization.update({
      where: { id: customization.id },
      data: {
        logoUrl: tenant?.logoUrl ?? null,
        primaryColor: DEFAULT_CUSTOMIZATION.primaryColor,
        secondaryColor: DEFAULT_CUSTOMIZATION.secondaryColor,
        accentColor: DEFAULT_CUSTOMIZATION.accentColor,
        systemName: tenant?.name || DEFAULT_CUSTOMIZATION.systemName,
        menuLabels: {},
        customCss: null,
      },
    });

    return this.serialize(reset);
  }

  async getMenuLabelOverrides(tenantId: string) {
    const customization = await this.prisma.customization.findUnique({
      where: { tenantId },
      select: { menuLabels: true },
    });

    if (!customization || typeof customization.menuLabels !== 'object' || customization.menuLabels === null) {
      return {};
    }

    return customization.menuLabels as Record<string, string>;
  }

  private async findOrCreate(tenantId: string) {
    const existing = await this.prisma.customization.findUnique({
      where: { tenantId },
    });

    if (existing) {
      return existing;
    }

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
      select: {
        name: true,
        logoUrl: true,
      },
    });

    return this.prisma.customization.create({
      data: {
        tenantId,
        logoUrl: tenant?.logoUrl ?? null,
        primaryColor: DEFAULT_CUSTOMIZATION.primaryColor,
        secondaryColor: DEFAULT_CUSTOMIZATION.secondaryColor,
        accentColor: DEFAULT_CUSTOMIZATION.accentColor,
        systemName: tenant?.name || DEFAULT_CUSTOMIZATION.systemName,
        menuLabels: {},
        customCss: null,
      },
    });
  }

  private serialize<T extends { logoUrl?: string | null }>(customization: T) {
    return {
      ...customization,
      logoUrl: this.filesService.resolveStoredFileUrl(customization.logoUrl),
    };
  }
}
