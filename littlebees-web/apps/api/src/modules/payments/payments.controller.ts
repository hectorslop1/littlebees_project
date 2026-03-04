import {
  Controller,
  Get,
  Post,
  Patch,
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
import { PaymentsService } from './payments.service';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar pagos' })
  @ApiQuery({ name: 'childId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @CurrentUser() user: { id: string; role: string },
    @Query('childId') childId?: string,
    @Query('status') status?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    if (user.role === UserRole.PARENT) {
      return this.paymentsService.findAllForParent(tenantId, user.id, {
        status,
        page: page ? parseInt(page, 10) : undefined,
        limit: limit ? parseInt(limit, 10) : undefined,
      });
    }

    return this.paymentsService.findAll(tenantId, {
      childId,
      status,
      startDate,
      endDate,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get('overdue')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Resumen de pagos vencidos' })
  getOverdueSummary(@CurrentTenant() tenantId: string) {
    return this.paymentsService.getOverdueSummary(tenantId);
  }

  @Get('child/:childId')
  @ApiOperation({ summary: 'Historial de pagos por niño/a' })
  findByChild(
    @CurrentTenant() tenantId: string,
    @Param('childId') childId: string,
  ) {
    return this.paymentsService.findByChild(tenantId, childId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de pago' })
  findById(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.paymentsService.findById(tenantId, id);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Crear cargo de pago' })
  create(
    @CurrentTenant() tenantId: string,
    @Body() dto: { childId: string; concept: string; amount: number; dueDate: string },
  ) {
    return this.paymentsService.create(tenantId, dto);
  }

  @Patch(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar datos del pago' })
  update(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() dto: { concept?: string; amount?: number; dueDate?: string },
  ) {
    return this.paymentsService.update(tenantId, id, dto);
  }

  @Post(':id/mark-paid')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Marcar pago como realizado' })
  markAsPaid(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() dto: { paymentMethod: string },
  ) {
    return this.paymentsService.markAsPaid(tenantId, id, dto.paymentMethod);
  }

  @Post(':id/cancel')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Cancelar pago' })
  cancel(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.paymentsService.cancel(tenantId, id);
  }
}
