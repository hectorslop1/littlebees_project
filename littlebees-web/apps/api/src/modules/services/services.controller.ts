import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
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
import { ServicesService } from './services.service';

@ApiTags('services')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('services')
export class ServicesController {
  constructor(private readonly servicesService: ServicesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar servicios extra' })
  @ApiQuery({ name: 'type', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('type') type?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.servicesService.findAll(tenantId, {
      type,
      status,
      search,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de servicio' })
  findById(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.servicesService.findById(tenantId, id);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Crear servicio extra' })
  create(
    @CurrentTenant() tenantId: string,
    @Body()
    dto: {
      name: string;
      description?: string;
      type: string;
      schedule?: string;
      price: number;
      capacity?: number;
      imageUrl?: string;
    },
  ) {
    return this.servicesService.create(tenantId, dto);
  }

  @Patch(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar servicio extra' })
  update(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body()
    dto: {
      name?: string;
      description?: string;
      schedule?: string;
      price?: number;
      capacity?: number;
      imageUrl?: string;
      status?: string;
    },
  ) {
    return this.servicesService.update(tenantId, id, dto);
  }

  @Delete(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Desactivar servicio extra' })
  delete(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.servicesService.delete(tenantId, id);
  }
}
