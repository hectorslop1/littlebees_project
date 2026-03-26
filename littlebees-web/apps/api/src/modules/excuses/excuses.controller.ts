import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@kinderspace/shared-types';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ExcusesService } from './excuses.service';
import { CreateExcuseDto } from './dto/create-excuse.dto';
import { UpdateExcuseStatusDto } from './dto/update-excuse-status.dto';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';

@ApiTags('excuses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('excuses')
export class ExcusesController {
  constructor(private readonly excusesService: ExcusesService) {}

  @Post()
  @Roles(UserRole.PARENT)
  @ApiOperation({ summary: 'Crear justificante' })
  create(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: CreateExcuseDto,
  ) {
    return this.excusesService.create(tenantId, userId, userRole, dto);
  }

  @Get()
  @Roles(
    UserRole.PARENT,
    UserRole.TEACHER,
    UserRole.DIRECTOR,
    UserRole.ADMIN,
    UserRole.SUPER_ADMIN,
  )
  @ApiOperation({ summary: 'Listar justificantes visibles por rol' })
  @ApiQuery({ name: 'childId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  async findAll(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Query('childId') childId?: string,
    @Query('status') status?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const items = await this.excusesService.findAll(tenantId, userId, userRole, {
      childId,
      status,
      startDate,
      endDate,
    });

    return createPaginatedResponse(items);
  }

  @Get('child/:childId')
  @Roles(
    UserRole.PARENT,
    UserRole.TEACHER,
    UserRole.DIRECTOR,
    UserRole.ADMIN,
    UserRole.SUPER_ADMIN,
  )
  @ApiOperation({ summary: 'Listar justificantes por niño' })
  async findByChild(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Param('childId') childId: string,
  ) {
    const items = await this.excusesService.findByChild(
      tenantId,
      userId,
      userRole,
      childId,
    );

    return createPaginatedResponse(items);
  }

  @Get(':id')
  @Roles(
    UserRole.PARENT,
    UserRole.TEACHER,
    UserRole.DIRECTOR,
    UserRole.ADMIN,
    UserRole.SUPER_ADMIN,
  )
  @ApiOperation({ summary: 'Detalle de un justificante' })
  findOne(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Param('id') id: string,
  ) {
    return this.excusesService.findOne(tenantId, userId, userRole, id);
  }

  @Patch(':id/status')
  @Roles(UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Aprobar o rechazar justificante' })
  updateStatus(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') reviewerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateExcuseStatusDto,
  ) {
    return this.excusesService.updateStatus(tenantId, reviewerId, id, dto);
  }

  @Delete(':id')
  @Roles(UserRole.PARENT, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Eliminar justificante pendiente' })
  delete(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Param('id') id: string,
  ) {
    return this.excusesService.delete(tenantId, userId, userRole, id);
  }
}
