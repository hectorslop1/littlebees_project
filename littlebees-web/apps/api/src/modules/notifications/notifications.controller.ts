import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar notificaciones del usuario' })
  @ApiQuery({ name: 'read', required: false })
  @ApiQuery({ name: 'type', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Query('read') read?: string,
    @Query('type') type?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.notificationsService.findAll(tenantId, userId, {
      read: read !== undefined ? read === 'true' : undefined,
      type,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get('count')
  @ApiOperation({ summary: 'Conteo de notificaciones no leídas' })
  getUnreadCount(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.notificationsService.getUnreadCount(tenantId, userId);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Marcar notificación como leída' })
  markAsRead(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.notificationsService.markAsRead(tenantId, userId, id);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Marcar todas como leídas' })
  markAllAsRead(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.notificationsService.markAllAsRead(tenantId, userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar notificación' })
  delete(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.notificationsService.delete(tenantId, userId, id);
  }
}
