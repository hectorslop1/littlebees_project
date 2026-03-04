import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { Gender } from '@prisma/client';
import { ChildrenService } from './children.service';

@ApiTags('children')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('children')
export class ChildrenController {
  constructor(private readonly childrenService: ChildrenService) {}

  @Get()
  @ApiOperation({ summary: 'Listar niños del tenant' })
  @ApiQuery({ name: 'groupId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'search', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('groupId') groupId?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
  ) {
    return this.childrenService.findAll(tenantId, { groupId, status, search });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de niño/a' })
  findById(@Param('id') id: string, @CurrentTenant() tenantId: string) {
    return this.childrenService.findById(id, tenantId);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Registrar nuevo niño/a' })
  create(@Body() dto: { firstName: string; lastName: string; dateOfBirth: string; gender: Gender; groupId: string }, @CurrentTenant() tenantId: string) {
    return this.childrenService.create(tenantId, {
      ...dto,
      dateOfBirth: new Date(dto.dateOfBirth),
    });
  }
}
