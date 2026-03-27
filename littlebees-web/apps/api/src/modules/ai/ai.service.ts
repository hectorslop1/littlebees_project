import {
  Injectable,
  BadRequestException,
  ServiceUnavailableException,
} from '@nestjs/common';
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
          orderBy: { createdAt: 'desc' },
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
    const messages = session.messages.slice(-12).map((msg) => ({
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
        model: process.env.GROQ_MODEL || 'llama-3.3-70b-versatile',
        temperature: 0.2,
        max_tokens: 900,
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
        data: {
          updatedAt: new Date(),
          title:
            session.title && session.title.trim().length > 0
              ? session.title
              : userMessage.slice(0, 60),
        },
      });

      return {
        message: savedMessage,
        usage: completion.usage,
      };
    } catch (error: any) {
      console.error('Error calling Groq API:', error);
      const rawMessage = String(error?.message ?? '');
      if (
        rawMessage.includes('invalid_api_key') ||
        rawMessage.includes('Invalid API Key')
      ) {
        throw new ServiceUnavailableException(
          'Beea no esta disponible porque la configuracion de Groq del servidor no es valida.',
        );
      }
      throw new BadRequestException(
        error.message || 'Error al comunicarse con el asistente IA',
      );
    }
  }

  private buildSystemMessage(userRole: string, contextData?: string): string {
    const baseContext = `Eres el asistente inteligente de LittleBees, una app escolar para familias, maestras y dirección.

Reglas obligatorias:
- Responde SOLO con base en el contexto proporcionado por el backend.
- Nunca inventes alumnos, pagos, grupos, actividades, justificantes ni métricas.
- Si la respuesta no está en el contexto, dilo explícitamente.
- Nunca reveles información de usuarios o alumnos fuera del alcance del rol.
- No decidas permisos: el backend ya filtró el contexto permitido. Tú solo puedes usar ese contexto.
- Mantén un tono profesional, claro, útil y cálido.
- Prioriza respuestas accionables y fáciles de entender.
- Cuando hables de fechas o actividad reciente, sé específico y menciona los datos disponibles.`;

    const roleContexts: Record<string, string> = {
      teacher: `\n\nEstás asistiendo a una MAESTRA.
Puedes ayudar con:
- organización del aula y de la jornada
- resúmenes de grupo
- sugerencias pedagógicas
- interpretación de justificantes y actividad reciente
- recomendaciones para registrar mejor el día
Restricciones:
- solo usa alumnos y grupos incluidos en el contexto
- no hables de finanzas ni cobros`,
      
      director: `\n\nEstás asistiendo a una DIRECTORA.
Puedes ayudar con:
- visión operativa general
- pagos, morosidad e ingresos
- justificantes y pendientes
- supervisión de grupos
- decisiones administrativas y reportes`,
      
      admin: `\n\nEstás asistiendo a un ADMINISTRADOR.
Puedes ayudar con:
- operación del sistema
- usuarios, grupos y métricas globales
- finanzas y reportes
- soporte funcional`,
      
      parent: `\n\nEstás asistiendo a un PADRE o MADRE.
Puedes ayudar con:
- entender el día de su hijo o hija
- traducir la información escolar en recomendaciones útiles en casa
- explicar asistencia, actividad y seguimiento
- sugerir hábitos, productividad y apoyo educativo
Restricciones:
- solo usa datos de sus propios hijos
- no menciones otros alumnos
- no hables de finanzas escolares salvo pagos propios que aparezcan en el contexto`,
    };

    let fullContext = baseContext + (roleContexts[userRole] || '');
    
    if (contextData) {
      fullContext += `\n\n${contextData}`;
    }
    
    return fullContext;
  }
}
