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
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ChatService } from './chat.service';

@ApiTags('chat')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('teacher', 'director', 'admin', 'super_admin', 'parent')
@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'Listar conversaciones del usuario' })
  findConversations(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.chatService.findConversations(tenantId, userId);
  }

  @Get('contacts')
  @ApiOperation({ summary: 'Listar contactos válidos para iniciar conversación' })
  getAvailableContacts(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ) {
    return this.chatService.getAvailableContacts(tenantId, userId, userRole);
  }

  @Get('conversations/:id')
  @ApiOperation({ summary: 'Detalle de conversación' })
  findConversationById(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.chatService.findConversationById(tenantId, id, userId);
  }

  @Post('conversations')
  @ApiOperation({ summary: 'Crear conversación' })
  createConversation(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
    @Body() dto: { childId: string; participantIds: string[] },
  ) {
    return this.chatService.createConversation(tenantId, userId, userRole, dto);
  }

  @Get('conversations/:id/messages')
  @ApiOperation({ summary: 'Obtener mensajes de conversación' })
  @ApiQuery({ name: 'cursor', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findMessages(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    return this.chatService.findMessages(
      tenantId,
      id,
      userId,
      cursor,
      limit ? parseInt(limit, 10) : undefined,
    );
  }

  @Post('conversations/:id/messages')
  @ApiOperation({ summary: 'Enviar mensaje' })
  sendMessage(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: { content: string; messageType?: string; attachmentUrl?: string },
  ) {
    return this.chatService.sendMessage(tenantId, id, userId, dto);
  }

  @Patch('conversations/:id/read')
  @ApiOperation({ summary: 'Marcar conversación como leída' })
  markAsRead(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.chatService.markAsRead(tenantId, id, userId);
  }

  @Delete('conversations/:id')
  @ApiOperation({ summary: 'Eliminar conversación para el usuario actual' })
  deleteConversation(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    return this.chatService.deleteConversation(tenantId, id, userId);
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Total de mensajes no leídos' })
  getUnreadCount(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.chatService.getUnreadCount(tenantId, userId);
  }

  @Patch('conversations/:id/escalate')
  @ApiOperation({ summary: 'Escalar conversación a dirección' })
  @Roles('teacher', 'director', 'admin', 'super_admin')
  escalateConversation(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: { reason: string },
  ) {
    return this.chatService.escalateConversation(tenantId, id, userId, dto.reason);
  }

  @Patch('conversations/:id/type')
  @ApiOperation({ summary: 'Cambiar tipo de conversación' })
  @Roles('teacher', 'director', 'admin', 'super_admin')
  updateConversationType(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() dto: { type: 'normal' | 'urgent' | 'escalated' },
  ) {
    return this.chatService.updateConversationType(tenantId, id, dto.type);
  }
}
