import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { ReportsService } from './reports.service';

@ApiTags('reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('attendance')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Reporte de asistencia' })
  @ApiQuery({ name: 'from', required: true })
  @ApiQuery({ name: 'to', required: true })
  @ApiQuery({ name: 'groupId', required: false })
  getAttendanceReport(
    @CurrentTenant() tenantId: string,
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.reportsService.getAttendanceReport(tenantId, from, to, groupId);
  }

  @Get('development')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Reporte de desarrollo' })
  @ApiQuery({ name: 'from', required: true })
  @ApiQuery({ name: 'to', required: true })
  @ApiQuery({ name: 'groupId', required: false })
  getDevelopmentReport(
    @CurrentTenant() tenantId: string,
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.reportsService.getDevelopmentReport(tenantId, from, to, groupId);
  }

  @Get('payments')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Reporte de pagos' })
  @ApiQuery({ name: 'from', required: true })
  @ApiQuery({ name: 'to', required: true })
  getPaymentReport(
    @CurrentTenant() tenantId: string,
    @Query('from') from: string,
    @Query('to') to: string,
  ) {
    return this.reportsService.getPaymentReport(tenantId, from, to);
  }

  @Get('activities')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.TEACHER)
  @ApiOperation({ summary: 'Reporte de actividades del día' })
  @ApiQuery({ name: 'from', required: true })
  @ApiQuery({ name: 'to', required: true })
  @ApiQuery({ name: 'groupId', required: false })
  getActivitiesReport(
    @CurrentTenant() tenantId: string,
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('groupId') groupId?: string,
  ) {
    return this.reportsService.getActivitiesReport(tenantId, from, to, groupId);
  }
}
