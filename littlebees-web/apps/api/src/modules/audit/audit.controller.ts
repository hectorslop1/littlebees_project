import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { AuditService } from './audit.service';

@ApiTags('audit')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('audit')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Listar registros de auditoría' })
  @ApiQuery({ name: 'resourceType', required: false })
  @ApiQuery({ name: 'resourceId', required: false })
  @ApiQuery({ name: 'userId', required: false })
  @ApiQuery({ name: 'action', required: false })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('resourceType') resourceType?: string,
    @Query('resourceId') resourceId?: string,
    @Query('userId') userId?: string,
    @Query('action') action?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.auditService.findAll(tenantId, {
      resourceType,
      resourceId,
      userId,
      action,
      startDate,
      endDate,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get('resource/:resourceType/:resourceId')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Obtener trail de auditoría de un recurso' })
  findByResource(
    @CurrentTenant() tenantId: string,
    @Param('resourceType') resourceType: string,
    @Param('resourceId') resourceId: string,
  ) {
    return this.auditService.findByResource(tenantId, resourceType, resourceId);
  }
}
