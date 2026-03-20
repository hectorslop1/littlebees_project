import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { GroupsService } from './groups.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';

@ApiTags('groups')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('groups')
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar grupos del tenant' })
  async findAll(@CurrentTenant() tenantId: string) {
    const groups = await this.groupsService.findAll(tenantId);
    return createPaginatedResponse(groups);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de grupo' })
  findById(@Param('id') id: string, @CurrentTenant() tenantId: string) {
    return this.groupsService.findById(id, tenantId);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Crear grupo' })
  create(
    @CurrentTenant() tenantId: string,
    @Body()
    dto: {
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
    return this.groupsService.create(tenantId, dto);
  }

  @Patch(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar grupo' })
  update(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @Body()
    dto: {
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
    return this.groupsService.update(id, tenantId, dto);
  }

  @Delete(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Eliminar grupo' })
  delete(@Param('id') id: string, @CurrentTenant() tenantId: string) {
    return this.groupsService.delete(id, tenantId);
  }
}
