import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import Groq from 'groq-sdk';
import { ContextBuilderService } from './services/context-builder.service';
import { AiFunctionsService } from './services/ai-functions.service';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

@Injectable()
export class AiService {
  private groq: Groq;

  constructor(
    private readonly prisma: PrismaService,
    private readonly contextBuilder: ContextBuilderService,
    private readonly aiFunctions: AiFunctionsService,
  ) {
    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) {
      console.warn('GROQ_API_KEY not found in environment variables');
    }
    this.groq = new Groq({ apiKey: apiKey || '' });
  }

  async createSession(tenantId: string, userId: string, title?: string) {
    console.log('Creating AI session:', { tenantId, userId, title });
    
    if (!tenantId || !userId) {
      throw new BadRequestException('TenantId y UserId son requeridos');
    }

    try {
      const session = await this.prisma.aiChatSession.create({
        data: {
          tenantId,
          userId,
          title: title || 'Nueva conversación',
        },
      });
      console.log('Session created successfully:', session.id);
      return session;
    } catch (error) {
      console.error('Error creating AI session:', error);
      throw new BadRequestException('Error al crear la sesión de chat');
    }
  }

  async getSessions(tenantId: string, userId: string) {
    return this.prisma.aiChatSession.findMany({
      where: {
        tenantId,
        userId,
      },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
          take: 1,
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getSessionById(sessionId: string, tenantId: string, userId: string) {
    const session = await this.prisma.aiChatSession.findFirst({
      where: {
        id: sessionId,
        tenantId,
        userId,
      },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!session) {
      throw new BadRequestException('Sesión no encontrada');
    }

    return session;
  }

  async getSession(sessionId: string, tenantId: string, userId: string) {
    const session = await this.prisma.aiChatSession.findFirst({
      where: {
        id: sessionId,
        tenantId,
        userId,
      },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!session) {
      throw new BadRequestException('Sesión no encontrada');
    }

    return session;
  }

  async updateSessionTitle(sessionId: string, title: string, tenantId: string, userId: string) {
    const session = await this.prisma.aiChatSession.findFirst({
      where: {
        id: sessionId,
        tenantId,
        userId,
      },
    });

    if (!session) {
      throw new BadRequestException('Sesión no encontrada');
    }

    return this.prisma.aiChatSession.update({
      where: { id: sessionId },
      data: { title },
    });
  }

  async deleteSession(sessionId: string, tenantId: string, userId: string) {
    const session = await this.prisma.aiChatSession.findFirst({
      where: {
        id: sessionId,
        tenantId,
        userId,
      },
    });

    if (!session) {
      throw new BadRequestException('Sesión no encontrada');
    }

    // Delete session (messages will be cascade deleted)
    return this.prisma.aiChatSession.delete({
      where: { id: sessionId },
    });
  }

  async chat(
    sessionId: string,
    userMessage: string,
    tenantId: string,
    userId: string,
    userRole: string,
  ) {
    // Verificar que la sesión existe y pertenece al usuario
    const session = await this.getSession(sessionId, tenantId, userId);

    // Guardar mensaje del usuario
    await this.prisma.aiChatMessage.create({
      data: {
        sessionId,
        role: 'user',
        content: userMessage,
      },
    });

    // Construir contexto con datos reales de la BD
    const context = await this.contextBuilder.buildContext(userId, userRole, tenantId);
    const contextFormatted = this.contextBuilder.formatContextForAI(context);

    // Construir historial de mensajes para el contexto
    const messages = session.messages.map((msg) => ({
      role: msg.role as 'user' | 'assistant' | 'system',
      content: msg.content,
    }));

    // Agregar mensaje del usuario
    messages.push({ role: 'user', content: userMessage });

    // Agregar mensaje de sistema con contexto enriquecido
    const systemMessage = this.buildSystemMessage(userRole, contextFormatted);
    const chatMessages: ChatMessage[] = [
      { role: 'system', content: systemMessage },
      ...messages,
    ];

    // NOTE: Function calling disabled - llama-3.3-70b-versatile doesn't support it properly
    // The AI will respond based on the rich context provided instead
    
    try {
      // Llamar a Groq API sin function calling
      const completion = await this.groq.chat.completions.create({
        messages: chatMessages,
        model: 'llama-3.3-70b-versatile',
        temperature: 0.7,
        max_tokens: 1024,
        top_p: 1,
        stream: false,
      });

      const choice = completion.choices[0];
      const assistantMessage = choice?.message?.content || 'Lo siento, no pude generar una respuesta.';

      // Guardar respuesta del asistente
      const savedMessage = await this.prisma.aiChatMessage.create({
        data: {
          sessionId,
          role: 'assistant',
          content: assistantMessage,
          metadata: {
            model: completion.model,
            usage: completion.usage ? JSON.parse(JSON.stringify(completion.usage)) : null,
            dataAccessed: context.dataAccessed,
          } as any,
        },
      });

      // Actualizar timestamp de la sesión
      await this.prisma.aiChatSession.update({
        where: { id: sessionId },
        data: { updatedAt: new Date() },
      });

      return {
        message: savedMessage,
        usage: completion.usage,
      };
    } catch (error: any) {
      console.error('Error calling Groq API:', error);
      throw new BadRequestException(
        error.message || 'Error al comunicarse con el asistente IA',
      );
    }
  }

  private buildSystemMessage(userRole: string, contextData?: string): string {
    const baseContext = `Eres un asistente inteligente para LittleBees, un sistema de gestión de guarderías y jardines de niños. 
Tu objetivo es ayudar a los usuarios con información, consejos y respuestas relacionadas con la administración educativa, el cuidado infantil y el uso del sistema.

Características importantes:
- Sé amable, profesional y empático
- Proporciona respuestas claras y concisas
- Si no sabes algo, admítelo honestamente
- Enfócate en temas relacionados con educación infantil, administración escolar y el sistema LittleBees`;

    const roleContexts: Record<string, string> = {
      teacher: `\n\nEres un asistente para una MAESTRA. Puedes ayudar con:
- Planificación de actividades educativas
- Registro de desarrollo infantil
- Comunicación con padres
- Gestión de grupos y alumnos
- Consejos pedagógicos`,
      
      director: `\n\nEres un asistente para una DIRECTORA. Puedes ayudar con:
- Gestión administrativa
- Supervisión de maestras
- Reportes y estadísticas
- Planificación institucional
- Toma de decisiones estratégicas`,
      
      admin: `\n\nEres un asistente para un ADMINISTRADOR. Puedes ayudar con:
- Configuración del sistema
- Gestión de usuarios
- Reportes financieros
- Análisis de datos
- Soporte técnico`,
      
      parent: `\n\nEres un asistente para un PADRE/MADRE. Puedes ayudar con:
- Información sobre el desarrollo de su hijo/a
- Actividades educativas en casa
- Comprensión de reportes
- Comunicación con maestras
- Consejos de crianza`,
    };

    let fullContext = baseContext + (roleContexts[userRole] || '');
    
    if (contextData) {
      fullContext += `\n\n${contextData}`;
    }
    
    return fullContext;
  }
}
