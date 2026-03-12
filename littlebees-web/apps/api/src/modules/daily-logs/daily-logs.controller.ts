import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { Prisma } from '@prisma/client';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DailyLogsService } from './daily-logs.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';

@ApiTags('daily-logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('daily-logs')
export class DailyLogsController {
  constructor(private readonly dailyLogsService: DailyLogsService) {}

  @Get()
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
  @ApiOperation({ summary: 'Eliminar entrada de bitácora' })
  delete(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
  ) {
    return this.dailyLogsService.delete(id, tenantId);
  }
}
