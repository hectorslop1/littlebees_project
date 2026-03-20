import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Prisma } from '@prisma/client';
import { UserRole } from '@kinderspace/shared-types';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DailyLogsService } from './daily-logs.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';
import { QuickRegisterDto, QuickRegisterResponseDto } from './dto/quick-register.dto';
import { DayScheduleResponseDto } from './dto/day-schedule.dto';

@ApiTags('daily-logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('daily-logs')
export class DailyLogsController {
  constructor(private readonly dailyLogsService: DailyLogsService) {}

  @Get()
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Obtener entradas de bitácora por niño y/o fecha' })
  async findByChildAndDate(
    @CurrentTenant() tenantId: string,
    @Query('childId') childId?: string,
    @Query('date') date?: string,
  ) {
    if (!childId && !date) {
      return createPaginatedResponse([]);
    }

    let entries: any[];
    if (childId && date) {
      entries = await this.dailyLogsService.findByChildAndDate(tenantId, childId, date);
    } else if (date) {
      entries = await this.dailyLogsService.findByDate(tenantId, date);
    } else {
      entries = [];
    }
    
    return createPaginatedResponse(entries);
  }

  @Post()
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Crear entrada de bitácora' })
  create(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: {
      childId: string;
      date: string;
      type: string;
      title: string;
      description?: string;
      time: string;
      metadata?: Prisma.InputJsonValue;
    },
  ) {
    return this.dailyLogsService.create(tenantId, userId, dto);
  }

  @Patch(':id')
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Actualizar entrada de bitácora' })
  update(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @Body() dto: {
      type?: string;
      title?: string;
      description?: string;
      time?: string;
      metadata?: Prisma.InputJsonValue;
    },
  ) {
    return this.dailyLogsService.update(id, tenantId, dto);
  }

  @Delete(':id')
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Eliminar entrada de bitácora' })
  delete(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
  ) {
    return this.dailyLogsService.delete(id, tenantId);
  }

  @Post('quick-register')
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Registro rápido de actividad (entrada, comida, siesta, actividad, salida)' })
  @ApiResponse({ status: 201, description: 'Actividad registrada exitosamente', type: QuickRegisterResponseDto })
  quickRegister(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: QuickRegisterDto,
  ): Promise<QuickRegisterResponseDto> {
    return this.dailyLogsService.quickRegister(tenantId, userId, dto);
  }

  @Get('day-schedule/:groupId')
  @Roles(UserRole.TEACHER, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Obtener programación y estado del día para un grupo' })
  @ApiResponse({ status: 200, description: 'Programación del día', type: DayScheduleResponseDto })
  getDaySchedule(
    @CurrentTenant() tenantId: string,
    @Param('groupId') groupId: string,
    @Query('date') date?: string,
  ): Promise<DayScheduleResponseDto> {
    return this.dailyLogsService.getDaySchedule(tenantId, groupId, date);
  }
}
