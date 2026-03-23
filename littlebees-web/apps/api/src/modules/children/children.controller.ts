import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { Gender } from '@prisma/client';
import { ChildrenService } from './children.service';
import { createPaginatedResponse } from '../../common/helpers/pagination.helper';
import { ChildProfileDto } from './dto/child-profile.dto';

@ApiTags('children')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('children')
export class ChildrenController {
  constructor(private readonly childrenService: ChildrenService) {}

  @Get()
  @ApiOperation({ summary: 'Listar niños del tenant (filtrado por rol)' })
  @ApiQuery({ name: 'groupId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'search', required: false })
  async findAll(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Query('groupId') groupId?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
  ) {
    const children = await this.childrenService.findAll(tenantId, userId, userRole, { groupId, status, search });
    return createPaginatedResponse(children);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener detalle de niño/a' })
  findById(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ) {
    return this.childrenService.findById(id, tenantId, userId, userRole);
  }

  @Get(':id/profile')
  @ApiOperation({ summary: 'Obtener perfil completo del niño/a' })
  @ApiResponse({ status: 200, description: 'Perfil completo del niño', type: ChildProfileDto })
  @ApiResponse({ status: 403, description: 'No tienes permiso para ver este perfil' })
  @ApiResponse({ status: 404, description: 'Niño/a no encontrado' })
  getProfile(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ): Promise<ChildProfileDto> {
    return this.childrenService.getProfile(id, tenantId, userId, userRole);
  }

  @Get(':id/profile-suggestions')
  @Roles(
    UserRole.SUPER_ADMIN,
    UserRole.DIRECTOR,
    UserRole.ADMIN,
    UserRole.TEACHER,
    UserRole.PARENT,
  )
  @ApiOperation({
    summary:
        'Obtener personas autorizadas y doctores ya registrados en otros perfiles accesibles',
  })
  getProfileSuggestions(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ) {
    return this.childrenService.getProfileSuggestions(id, tenantId, userId, userRole);
  }

  @Post()
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Registrar nuevo niño/a' })
  create(@Body() dto: { firstName: string; lastName: string; dateOfBirth: string; gender: Gender; groupId: string }, @CurrentTenant() tenantId: string) {
    return this.childrenService.create(tenantId, {
      ...dto,
      dateOfBirth: new Date(dto.dateOfBirth),
    });
  }

  @Patch(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar niño/a' })
  update(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @Body() dto: {
      firstName?: string;
      lastName?: string;
      dateOfBirth?: string;
      gender?: Gender;
      groupId?: string;
      photoUrl?: string;
      status?: string;
    },
  ) {
    const updateData: any = { ...dto };
    if (dto.dateOfBirth) {
      updateData.dateOfBirth = new Date(dto.dateOfBirth);
    }
    delete updateData.status;
    if (dto.status) {
      updateData.status = dto.status;
    }
    return this.childrenService.update(id, tenantId, updateData);
  }

  @Delete(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Eliminar niño/a (soft delete)' })
  delete(@Param('id') id: string, @CurrentTenant() tenantId: string) {
    return this.childrenService.delete(id, tenantId);
  }

  @Patch(':id/profile')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Actualizar perfil editable del niño/a' })
  updateProfile(
    @Param('id') id: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: {
      firstName?: string;
      lastName?: string;
      dateOfBirth?: string;
      gender?: Gender;
      photoUrl?: string | null;
    },
  ) {
    const updateData: {
      firstName?: string;
      lastName?: string;
      dateOfBirth?: Date;
      gender?: Gender;
      photoUrl?: string | null;
    } = {
      firstName: dto.firstName,
      lastName: dto.lastName,
      gender: dto.gender,
      photoUrl: dto.photoUrl,
    };

    if (dto.dateOfBirth) {
      updateData.dateOfBirth = new Date(dto.dateOfBirth);
    }

    return this.childrenService.updateProfile(id, tenantId, userId, userRole, updateData);
  }

  @Post(':id/medical-info')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.TEACHER, UserRole.PARENT)
  @ApiOperation({ summary: 'Crear/actualizar información médica' })
  upsertMedicalInfo(
    @Param('id') childId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: {
      allergies?: string[];
      conditions?: string[];
      medications?: string[];
      bloodType?: string;
      observations?: string;
      doctorName?: string;
      doctorPhone?: string;
      insuranceInfo?: any;
    },
  ) {
    return this.childrenService.upsertMedicalInfo(childId, tenantId, userId, userRole, dto);
  }

  @Post(':id/emergency-contacts')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Agregar contacto de emergencia' })
  addEmergencyContact(
    @Param('id') childId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: {
      name: string;
      relationship: string;
      phone: string;
      email?: string;
      photoUrl?: string;
      idPhotoUrl?: string;
      priority?: number;
    },
  ) {
    return this.childrenService.addEmergencyContact(childId, tenantId, userId, userRole, dto);
  }

  @Patch(':id/emergency-contacts/:contactId')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Actualizar contacto de emergencia' })
  updateEmergencyContact(
    @Param('id') childId: string,
    @Param('contactId') contactId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: {
      name?: string;
      relationship?: string;
      phone?: string;
      email?: string;
      photoUrl?: string;
      idPhotoUrl?: string;
      priority?: number;
    },
  ) {
    return this.childrenService.updateEmergencyContact(contactId, childId, tenantId, userId, userRole, dto);
  }

  @Delete(':id/emergency-contacts/:contactId')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN, UserRole.PARENT)
  @ApiOperation({ summary: 'Eliminar contacto de emergencia' })
  deleteEmergencyContact(
    @Param('id') childId: string,
    @Param('contactId') contactId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ) {
    return this.childrenService.deleteEmergencyContact(contactId, childId, tenantId, userId, userRole);
  }
}
