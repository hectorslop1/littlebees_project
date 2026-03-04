import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { Prisma } from '@prisma/client';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DailyLogsService } from './daily-logs.service';

@ApiTags('daily-logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('daily-logs')
export class DailyLogsController {
  constructor(private readonly dailyLogsService: DailyLogsService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener entradas de bitácora por niño y fecha' })
  findByChildAndDate(
    @CurrentTenant() tenantId: string,
    @Query('childId') childId: string,
    @Query('date') date: string,
  ) {
    return this.dailyLogsService.findByChildAndDate(tenantId, childId, date);
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
}
