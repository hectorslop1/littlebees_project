import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AttendanceService } from './attendance.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';
import { BulkCheckInDto, BulkCheckInResponseDto } from './dto/bulk-check-in.dto';

@ApiTags('attendance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Get()
  @Roles('teacher', 'director', 'admin', 'super_admin', 'parent')
  @ApiOperation({ summary: 'Obtener asistencia por fecha' })
  async getByDate(
    @CurrentTenant() tenantId: string,
    @CurrentUser() user: { id: string; role: string },
    @Query('date') date: string,
    @Query('childId') childId?: string,
  ) {
    const records = await this.attendanceService.getByDate(
      tenantId,
      user.id,
      user.role,
      date,
      childId,
    );
    return createPaginatedResponse(records);
  }

  @Post('check-in')
  @Roles('teacher', 'director', 'admin', 'super_admin')
  @ApiOperation({ summary: 'Registrar entrada' })
  checkIn(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: { childId: string; method: string },
  ) {
    return this.attendanceService.checkIn(tenantId, dto.childId, userId, dto.method);
  }

  @Post('check-out')
  @Roles('teacher', 'director', 'admin', 'super_admin')
  @ApiOperation({ summary: 'Registrar salida' })
  checkOut(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: { childId: string },
  ) {
    return this.attendanceService.checkOut(tenantId, dto.childId, userId);
  }

  @Post('bulk-check-in')
  @Roles('teacher', 'director', 'admin', 'super_admin')
  @ApiOperation({ summary: 'Check-in masivo para múltiples niños' })
  @ApiResponse({ status: 201, description: 'Check-in masivo completado', type: BulkCheckInResponseDto })
  bulkCheckIn(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: BulkCheckInDto,
  ): Promise<BulkCheckInResponseDto> {
    return this.attendanceService.bulkCheckIn(tenantId, userId, dto);
  }
}
