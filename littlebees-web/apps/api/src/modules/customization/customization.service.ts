import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateCustomizationDto } from './dto/update-customization.dto';
import { FilesService } from '../files/files.service';

const DEFAULT_CUSTOMIZATION = {
  primaryColor: '#D4A853',
  secondaryColor: '#8FAE8B',
  accentColor: '#E8B84B',
  sidebarBg: '#1A1410',
  sidebarText: '#D1D5DB',
  sidebarActiveText: '#FFFFFF',
  bgSurface: '#FFFFFF',
  bgPage: '#FBF6E9',
  textPrimary: '#2C2C2C',
  textSecondary: '#6B6B6B',
  borderColor: '#E5E7EB',
  tableHeaderBg: '#F3F4F6',
  tableStripeBg: '#F9FAFB',
  tableHoverBg: '#FBF6E9',
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
        sidebarBg: dto.sidebarBg,
        sidebarText: dto.sidebarText,
        sidebarActiveText: dto.sidebarActiveText,
        bgSurface: dto.bgSurface,
        bgPage: dto.bgPage,
        textPrimary: dto.textPrimary,
        textSecondary: dto.textSecondary,
        borderColor: dto.borderColor,
        tableHeaderBg: dto.tableHeaderBg,
        tableStripeBg: dto.tableStripeBg,
        tableHoverBg: dto.tableHoverBg,
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
        sidebarBg: DEFAULT_CUSTOMIZATION.sidebarBg,
        sidebarText: DEFAULT_CUSTOMIZATION.sidebarText,
        sidebarActiveText: DEFAULT_CUSTOMIZATION.sidebarActiveText,
        bgSurface: DEFAULT_CUSTOMIZATION.bgSurface,
        bgPage: DEFAULT_CUSTOMIZATION.bgPage,
        textPrimary: DEFAULT_CUSTOMIZATION.textPrimary,
        textSecondary: DEFAULT_CUSTOMIZATION.textSecondary,
        borderColor: DEFAULT_CUSTOMIZATION.borderColor,
        tableHeaderBg: DEFAULT_CUSTOMIZATION.tableHeaderBg,
        tableStripeBg: DEFAULT_CUSTOMIZATION.tableStripeBg,
        tableHoverBg: DEFAULT_CUSTOMIZATION.tableHoverBg,
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
        sidebarBg: DEFAULT_CUSTOMIZATION.sidebarBg,
        sidebarText: DEFAULT_CUSTOMIZATION.sidebarText,
        sidebarActiveText: DEFAULT_CUSTOMIZATION.sidebarActiveText,
        bgSurface: DEFAULT_CUSTOMIZATION.bgSurface,
        bgPage: DEFAULT_CUSTOMIZATION.bgPage,
        textPrimary: DEFAULT_CUSTOMIZATION.textPrimary,
        textSecondary: DEFAULT_CUSTOMIZATION.textSecondary,
        borderColor: DEFAULT_CUSTOMIZATION.borderColor,
        tableHeaderBg: DEFAULT_CUSTOMIZATION.tableHeaderBg,
        tableStripeBg: DEFAULT_CUSTOMIZATION.tableStripeBg,
        tableHoverBg: DEFAULT_CUSTOMIZATION.tableHoverBg,
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
