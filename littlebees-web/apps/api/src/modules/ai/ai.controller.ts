import { Controller, Get, Post, Delete, Patch, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AiService } from './ai.service';
import {
  CreateSessionDto,
  ChatMessageDto,
  SessionResponseDto,
  ChatResponseDto,
} from './dto/ai-chat.dto';

@ApiTags('ai')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('sessions')
  @ApiOperation({ summary: 'Crear nueva sesión de chat con IA' })
  @ApiResponse({ status: 201, description: 'Sesión creada', type: SessionResponseDto })
  createSession(
    @Body() createSessionDto: CreateSessionDto,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.aiService.createSession(tenantId, userId, createSessionDto.title);
  }

  @Get('sessions')
  @ApiOperation({ summary: 'Listar sesiones de chat del usuario' })
  @ApiResponse({ status: 200, description: 'Lista de sesiones', type: [SessionResponseDto] })
  getSessions(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.aiService.getSessions(tenantId, userId);
  }

  @Get('sessions/:id')
  @ApiOperation({ summary: 'Obtener detalle de una sesión con historial completo' })
  @ApiResponse({ status: 200, description: 'Detalle de sesión', type: SessionResponseDto })
  @ApiResponse({ status: 400, description: 'Sesión no encontrada' })
  getSession(
    @Param('id') sessionId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.aiService.getSession(sessionId, tenantId, userId);
  }

  @Patch('sessions/:id')
  @ApiOperation({ summary: 'Actualizar título de sesión' })
  @ApiResponse({ status: 200, description: 'Título actualizado', type: SessionResponseDto })
  updateSessionTitle(
    @Param('id') sessionId: string,
    @Body() updateDto: { title: string },
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.aiService.updateSessionTitle(sessionId, updateDto.title, tenantId, userId);
  }

  @Delete('sessions/:id')
  @ApiOperation({ summary: 'Eliminar una sesión de chat' })
  @ApiResponse({ status: 200, description: 'Sesión eliminada' })
  @ApiResponse({ status: 400, description: 'Sesión no encontrada' })
  deleteSession(
    @Param('id') sessionId: string,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.aiService.deleteSession(sessionId, tenantId, userId);
  }

  @Post('sessions/:id/chat')
  @ApiOperation({ summary: 'Enviar mensaje al asistente IA' })
  @ApiResponse({ status: 200, description: 'Respuesta del asistente', type: ChatResponseDto })
  @ApiResponse({ status: 400, description: 'Error en la solicitud' })
  chat(
    @Param('id') sessionId: string,
    @Body() chatMessageDto: ChatMessageDto,
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @CurrentUser('role') userRole: string,
  ) {
    return this.aiService.chat(
      sessionId,
      chatMessageDto.message,
      tenantId,
      userId,
      userRole,
    );
  }
}
