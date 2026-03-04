import {
  Controller,
  Get,
  Post,
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
import { UserRole } from '@kinderspace/shared-types';
import { InvoicingService } from './invoicing.service';

@ApiTags('invoicing')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('invoices')
export class InvoicingController {
  constructor(private readonly invoicingService: InvoicingService) {}

  @Get()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Listar facturas' })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'paymentId', required: false })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('status') status?: string,
    @Query('paymentId') paymentId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.invoicingService.findAll(tenantId, {
      status,
      paymentId,
      startDate,
      endDate,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get('payment/:paymentId')
  @ApiOperation({ summary: 'Obtener facturas de un pago' })
  findByPayment(
    @CurrentTenant() tenantId: string,
    @Param('paymentId') paymentId: string,
  ) {
    return this.invoicingService.findByPayment(tenantId, paymentId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de factura' })
  findById(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.invoicingService.findById(tenantId, id);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Crear factura' })
  create(
    @CurrentTenant() tenantId: string,
    @Body()
    dto: {
      paymentId: string;
      rfcReceptor: string;
      razonSocial: string;
      regimenFiscal: string;
      usoCfdi: string;
      codigoPostal: string;
    },
  ) {
    return this.invoicingService.create(tenantId, dto);
  }

  @Post(':id/cancel')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Cancelar factura' })
  cancel(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() dto: { reason: string },
  ) {
    return this.invoicingService.cancel(tenantId, id, dto.reason);
  }
}
