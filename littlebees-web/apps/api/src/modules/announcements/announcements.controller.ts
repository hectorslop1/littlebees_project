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
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AnnouncementsService } from './announcements.service';
import { CreateAnnouncementDto, UpdateAnnouncementDto } from './dto';

@ApiTags('announcements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('announcements')
export class AnnouncementsController {
  constructor(private readonly announcementsService: AnnouncementsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar anuncios' })
  @ApiQuery({ name: 'type', required: false })
  @ApiQuery({ name: 'priority', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('type') type?: string,
    @Query('priority') priority?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.announcementsService.findAll(tenantId, {
      type,
      priority,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 10,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener anuncio por ID' })
  findOne(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.announcementsService.findOne(tenantId, id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear anuncio' })
  create(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() createAnnouncementDto: CreateAnnouncementDto,
  ) {
    return this.announcementsService.create(tenantId, userId, createAnnouncementDto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar anuncio' })
  update(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() updateAnnouncementDto: UpdateAnnouncementDto,
  ) {
    return this.announcementsService.update(tenantId, id, updateAnnouncementDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar anuncio' })
  delete(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.announcementsService.delete(tenantId, id);
  }
}
