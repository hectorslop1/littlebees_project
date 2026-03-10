import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { DevelopmentCategory, MilestoneStatus } from '@prisma/client';
import { DevelopmentService } from './development.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';

@ApiTags('development')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('development')
export class DevelopmentController {
  constructor(private readonly developmentService: DevelopmentService) {}

  // --- Milestones ---

  @Get('milestones')
  @ApiOperation({ summary: 'Listar hitos de desarrollo' })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'ageRangeMin', required: false })
  @ApiQuery({ name: 'ageRangeMax', required: false })
  findAllMilestones(
    @Query('category') category?: string,
    @Query('ageRangeMin') ageRangeMin?: string,
    @Query('ageRangeMax') ageRangeMax?: string,
  ) {
    return this.developmentService.findAllMilestones({
      category,
      ageRangeMin: ageRangeMin ? parseInt(ageRangeMin, 10) : undefined,
      ageRangeMax: ageRangeMax ? parseInt(ageRangeMax, 10) : undefined,
    });
  }

  @Get('milestones/:id')
  @ApiOperation({ summary: 'Obtener detalle de hito' })
  findMilestoneById(@Param('id') id: string) {
    return this.developmentService.findMilestoneById(id);
  }

  @Post('milestones')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Crear hito de desarrollo' })
  createMilestone(
    @Body()
    dto: {
      category: DevelopmentCategory;
      title: string;
      description?: string;
      ageRangeMin: number;
      ageRangeMax: number;
      sortOrder: number;
    },
  ) {
    return this.developmentService.createMilestone(dto);
  }

  @Patch('milestones/:id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar hito de desarrollo' })
  updateMilestone(
    @Param('id') id: string,
    @Body()
    dto: Partial<{
      category: DevelopmentCategory;
      title: string;
      description: string;
      ageRangeMin: number;
      ageRangeMax: number;
      sortOrder: number;
    }>,
  ) {
    return this.developmentService.updateMilestone(id, dto);
  }

  @Delete('milestones/:id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Eliminar hito de desarrollo' })
  deleteMilestone(@Param('id') id: string) {
    return this.developmentService.deleteMilestone(id);
  }

  // --- Records ---

  @Get('records')
  @ApiOperation({ summary: 'Listar evaluaciones de desarrollo' })
  @ApiQuery({ name: 'childId', required: false })
  @ApiQuery({ name: 'milestoneId', required: false })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'status', required: false })
  async findRecords(
    @CurrentTenant() tenantId: string,
    @Query('childId') childId?: string,
    @Query('milestoneId') milestoneId?: string,
    @Query('category') category?: string,
    @Query('status') status?: string,
  ) {
    const records = await this.developmentService.findRecords(tenantId, {
      childId,
      milestoneId,
      category,
      status,
    });
    return createPaginatedResponse(records);
  }

  @Get('records/:id')
  @ApiOperation({ summary: 'Obtener detalle de evaluación' })
  findRecordById(@Param('id') id: string, @CurrentTenant() tenantId: string) {
    return this.developmentService.findRecordById(id, tenantId);
  }

  @Post('records')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.TEACHER)
  @ApiOperation({ summary: 'Crear evaluación de desarrollo' })
  createRecord(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body()
    dto: {
      childId: string;
      milestoneId: string;
      status: MilestoneStatus;
      observations?: string;
      evidenceUrls?: string[];
    },
  ) {
    return this.developmentService.createRecord(tenantId, userId, dto);
  }

  @Patch('records/:id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.TEACHER)
  @ApiOperation({ summary: 'Actualizar evaluación de desarrollo' })
  updateRecord(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @Body()
    dto: {
      status?: MilestoneStatus;
      observations?: string;
      evidenceUrls?: string[];
    },
  ) {
    return this.developmentService.updateRecord(id, tenantId, dto);
  }

  // --- Summary ---

  @Get('children/:childId/summary')
  @ApiOperation({ summary: 'Resumen de desarrollo de un niño/a' })
  getChildSummary(
    @CurrentTenant() tenantId: string,
    @Param('childId') childId: string,
  ) {
    return this.developmentService.getChildSummary(tenantId, childId);
  }
}
