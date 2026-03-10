import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AttendanceService } from './attendance.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';

@ApiTags('attendance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener asistencia por fecha' })
  async getByDate(@CurrentTenant() tenantId: string, @Query('date') date: string) {
    const records = await this.attendanceService.getByDate(tenantId, date);
    return createPaginatedResponse(records);
  }

  @Post('check-in')
  @ApiOperation({ summary: 'Registrar entrada' })
  checkIn(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: { childId: string; method: string },
  ) {
    return this.attendanceService.checkIn(tenantId, dto.childId, userId, dto.method);
  }

  @Post('check-out')
  @ApiOperation({ summary: 'Registrar salida' })
  checkOut(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: { childId: string },
  ) {
    return this.attendanceService.checkOut(tenantId, dto.childId, userId);
  }
}
