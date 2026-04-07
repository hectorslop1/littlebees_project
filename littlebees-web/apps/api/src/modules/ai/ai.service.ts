import {
  Injectable,
  BadRequestException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import Groq from 'groq-sdk';
import { ContextBuilderService } from './services/context-builder.service';
import { AiFunctionsService } from './services/ai-functions.service';
import {
  CreateVoiceCallDto,
  FinalizeVoiceSessionDto,
} from './dto/ai-chat.dto';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

interface ChildReference {
  id: string;
  firstName: string;
  lastName: string;
}

interface VoicePresetConfig {
  id: string;
  label: string;
  voice: string;
  guidance: string;
}

interface VoiceTranscriptTurn {
  itemId?: string;
  role: 'user' | 'assistant';
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

    const deterministicReply = this.tryBuildDeterministicReply(
      userMessage,
      userRole,
      context,
    );

    if (deterministicReply) {
      const savedMessage = await this.prisma.aiChatMessage.create({
        data: {
          sessionId,
          role: 'assistant',
          content: deterministicReply,
          metadata: {
            mode: 'deterministic_context',
            dataAccessed: context.dataAccessed,
          } as any,
        },
      });

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
        usage: null,
      };
    }

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

  async createVoiceCall(
    sessionId: string,
    voiceCallDto: CreateVoiceCallDto,
    tenantId: string,
    userId: string,
    userRole: string,
  ) {
    const openAiApiKey = process.env.OPENAI_API_KEY;
    if (!openAiApiKey) {
      throw new ServiceUnavailableException(
        'Beea voz no esta disponible porque falta configurar OPENAI_API_KEY en el servidor.',
      );
    }

    const session = await this.getSession(sessionId, tenantId, userId);
    const context = await this.contextBuilder.buildContext(userId, userRole, tenantId);
    const contextFormatted = this.contextBuilder.formatContextForAI(context);
    const preset = this.resolveVoicePreset(voiceCallDto.voicePresetId);
    const instructions = this.buildVoiceSessionInstructions(
      userRole,
      contextFormatted,
      preset,
      session.messages,
    );

    const formData = new FormData();
    formData.set('sdp', voiceCallDto.sdp);
    formData.set(
      'session',
      JSON.stringify({
        type: 'realtime',
        model: process.env.OPENAI_REALTIME_MODEL || 'gpt-realtime-mini',
        instructions,
        output_modalities: ['audio'],
        max_output_tokens: 320,
        audio: {
          input: {
            transcription: {
              model:
                process.env.OPENAI_REALTIME_TRANSCRIPTION_MODEL ||
                'gpt-4o-mini-transcribe',
            },
            turn_detection: {
              type: 'server_vad',
              create_response: true,
              interrupt_response: true,
              silence_duration_ms: 1200,
              prefix_padding_ms: 500,
              idle_timeout_ms: 12000,
            },
          },
          output: {
            voice: preset.voice,
          },
        },
      }),
    );

    const response = await fetch('https://api.openai.com/v1/realtime/calls', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openAiApiKey}`,
      },
      body: formData,
    });

    const sdpAnswer = await response.text();
    if (!response.ok) {
      throw new BadRequestException(
        sdpAnswer || 'No fue posible iniciar la sesion de voz con OpenAI Realtime.',
      );
    }

    return {
      sdp: sdpAnswer,
      voicePresetId: preset.id,
      voice: preset.voice,
    };
  }

  async finalizeVoiceSession(
    sessionId: string,
    finalizeVoiceSessionDto: FinalizeVoiceSessionDto,
    tenantId: string,
    userId: string,
  ) {
    const session = await this.getSession(sessionId, tenantId, userId);
    const preset = this.resolveVoicePreset(finalizeVoiceSessionDto.voicePresetId);
    const mergedTurns = this.mergeVoiceTranscriptTurns(finalizeVoiceSessionDto.turns);

    if (mergedTurns.length === 0) {
      return session;
    }

    for (const turn of mergedTurns) {
      await this.prisma.aiChatMessage.create({
        data: {
          sessionId,
          role: turn.role,
          content: turn.content,
          metadata: {
            source: 'voice_realtime',
            voicePresetId: preset.id,
            voice: preset.voice,
            durationMs: finalizeVoiceSessionDto.durationMs ?? null,
          } as any,
        },
      });
    }

    await this.prisma.aiChatSession.update({
      where: { id: sessionId },
      data: {
        updatedAt: new Date(),
        title:
          session.title && session.title.trim().length > 0
            ? session.title
            : mergedTurns.find((turn) => turn.role === 'user')?.content.slice(0, 60) ||
              'Nueva conversación',
      },
    });

    return this.getSession(sessionId, tenantId, userId);
  }

  private buildSystemMessage(userRole: string, contextData?: string): string {
    const baseContext = `Eres el asistente inteligente de LittleBees, una app escolar para familias, maestras y dirección.

Reglas obligatorias:
- Responde SOLO con base en el contexto proporcionado por el backend.
- Nunca inventes alumnos, pagos, grupos, actividades, justificantes ni métricas.
- Si la respuesta no está en el contexto, dilo explícitamente.
- Si el contexto sí incluye actividades, asistencia o eventos, menciona los detalles concretos disponibles en vez de responder de forma vaga.
- Interpreta "hoy", "ayer" y periodos relativos usando la zona horaria operativa incluida en el contexto.
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

  private buildVoiceSessionInstructions(
    userRole: string,
    contextData: string,
    preset: VoicePresetConfig,
    messages: Array<{ role: string; content: string }>,
  ): string {
    const baseInstructions = this.buildSystemMessage(userRole, contextData);
    const recentConversation = messages
      .filter((message) => message.role === 'user' || message.role === 'assistant')
      .slice(-8)
      .map((message) => {
        const speaker = message.role === 'user' ? 'Usuario' : 'Beea';
        return `${speaker}: ${message.content}`;
      })
      .join('\n');

    return `${baseInstructions}

Modo de voz Beea:
- Habla siempre en espanol mexicano natural.
- Responde en un tono cercano, sereno y facil de seguir.
- Mantén las respuestas cortas: maximo 1 o 2 frases por turno.
- Tolera pausas, muletillas e interrupciones del usuario sin sonar rigida.
- Si algo no esta claro, haz una sola pregunta breve.
- No uses listas largas ni respuestas extensas en voz.
- No digas que eres un modelo ni menciones configuraciones tecnicas.
- Tu voz seleccionada para esta sesion es "${preset.label}".
- Comportamiento de voz deseado: ${preset.guidance}

${recentConversation
      ? `Contexto reciente de esta misma conversacion:\n${recentConversation}`
      : 'No hay historial previo en esta conversacion.'}`;
  }

  private resolveVoicePreset(presetId?: string): VoicePresetConfig {
    const presets: VoicePresetConfig[] = [
      {
        id: 'calida',
        label: 'Calida',
        voice: 'shimmer',
        guidance: 'Habla con calidez, amabilidad y un ritmo suave.',
      },
      {
        id: 'clara',
        label: 'Clara',
        voice: 'verse',
        guidance: 'Habla con claridad, diccion limpia y energia equilibrada.',
      },
      {
        id: 'serena',
        label: 'Serena',
        voice: 'sage',
        guidance: 'Habla con tranquilidad, paciencia y seguridad.',
      },
      {
        id: 'firme',
        label: 'Firme',
        voice: 'echo',
        guidance: 'Habla con mas presencia, seguridad y tono sobrio.',
      },
    ];

    return (
      presets.find((preset) => preset.id === presetId) ??
      presets[0]
    );
  }

  private mergeVoiceTranscriptTurns(
    turns: Array<{ itemId?: string; role: string; content: string }>,
  ): VoiceTranscriptTurn[] {
    return turns
      .map((turn) => ({
        itemId: turn.itemId?.trim() || undefined,
        role: turn.role === 'assistant' ? 'assistant' : 'user',
        content: turn.content.trim(),
      }))
      .filter((turn) => turn.content.length > 0) as VoiceTranscriptTurn[];
  }

  private tryBuildDeterministicReply(
    userMessage: string,
    userRole: string,
    context: any,
  ): string | null {
    if (userRole !== 'parent') {
      return null;
    }

    const normalizedMessage = this.normalizeText(userMessage);
    const child = this.findReferencedChild(normalizedMessage, context.children ?? []);

    if (!child) {
      return null;
    }

    const timeZone = context.tenantTimezone ?? 'America/Mexico_City';
    const targetDate = this.resolveRelativeDate(normalizedMessage, timeZone);

    if (this.isAttendanceQuestion(normalizedMessage)) {
      return this.buildAttendanceReply(child, targetDate, context.recentAttendance ?? [], timeZone);
    }

    if (this.isActivitiesQuestion(normalizedMessage)) {
      return this.buildActivitiesReply(child, targetDate, context.recentActivities ?? [], timeZone);
    }

    return null;
  }

  private buildAttendanceReply(
    child: ChildReference,
    targetDate: Date,
    attendanceEntries: any[],
    timeZone: string,
  ) {
    const targetIso = this.toIsoDate(targetDate);
    const childEntries = attendanceEntries.filter(
      (entry) =>
        entry.child?.firstName === child.firstName &&
        entry.child?.lastName === child.lastName &&
        this.toIsoDate(entry.date) === targetIso,
    );
    const entry = childEntries[0];
    const absoluteDate = this.formatLongDate(targetDate, timeZone);

    if (!entry) {
      return `Revisé la asistencia de ${child.firstName} ${child.lastName} para ${absoluteDate} y no encuentro una confirmación de llegada en el sistema.`;
    }

    if (entry.status === 'absent' && !entry.checkInAt) {
      return `Revisé la asistencia de ${child.firstName} ${child.lastName} para ${absoluteDate} y aparece como ausente.`;
    }

    if (entry.checkInAt) {
      const checkInTime = this.formatTime(entry.checkInAt, timeZone);
      return `Sí. La llegada de ${child.firstName} ${child.lastName} sí está registrada para ${absoluteDate}. Hora de llegada: ${checkInTime}.`;
    }

    return `Revisé la asistencia de ${child.firstName} ${child.lastName} para ${absoluteDate} y no veo una llegada confirmada todavía.`;
  }

  private buildActivitiesReply(
    child: ChildReference,
    targetDate: Date,
    activityEntries: any[],
    timeZone: string,
  ) {
    const targetIso = this.toIsoDate(targetDate);
    const childActivities = activityEntries.filter(
      (entry) =>
        entry.child?.firstName === child.firstName &&
        entry.child?.lastName === child.lastName &&
        this.toIsoDate(entry.date) === targetIso,
    );
    const absoluteDate = this.formatLongDate(targetDate, timeZone);

    if (childActivities.length === 0) {
      const latestActivities = activityEntries
        .filter(
          (entry) =>
            entry.child?.firstName === child.firstName &&
            entry.child?.lastName === child.lastName,
        )
        .slice(0, 3);

      if (latestActivities.length === 0) {
        return `Revisé las actividades de ${child.firstName} ${child.lastName} para ${absoluteDate} y no hay actividades registradas todavía.`;
      }

      const latestDate = new Date(latestActivities[0].date);
      const latestDateLabel = this.formatLongDate(latestDate, timeZone);
      const details = latestActivities
        .map((entry) => this.formatActivityLine(entry))
        .join('\n');

      return `Para ${absoluteDate} no veo actividades registradas todavía.\n\nLa fecha más reciente con actividades para ${child.firstName} ${child.lastName} es ${latestDateLabel}:\n${details}`;
    }

    const details = childActivities
      .map((entry) => this.formatActivityLine(entry))
      .join('\n');

    return `Estas son las actividades registradas para ${child.firstName} ${child.lastName} en ${absoluteDate}:\n${details}`;
  }

  private formatActivityLine(entry: any) {
    const time = entry.time?.toString();
    const title = entry.title?.toString() ?? 'Actividad';
    const description = entry.description?.toString();
    const prefix = time && time.trim().length > 0 ? `- ${time}: ` : '- ';

    if (description && description.trim().length > 0) {
      return `${prefix}${title}. ${description.trim()}`;
    }

    return `${prefix}${title}`;
  }

  private isAttendanceQuestion(message: string) {
    return message.includes('llegada') ||
        message.includes('llego') ||
        message.includes('asistencia') ||
        message.includes('registro la llegada') ||
        message.includes('confirmo la llegada') ||
        message.includes('ya registro');
  }

  private isActivitiesQuestion(message: string) {
    return message.includes('actividad') ||
        message.includes('actividades') ||
        message.includes('que hizo') ||
        message.includes('que ha hecho') ||
        message.includes('que hizo ') ||
        message.includes('hizo hoy');
  }

  private findReferencedChild(
    normalizedMessage: string,
    children: any[],
  ): ChildReference | null {
    const typedChildren: ChildReference[] = children.map((child) => ({
      id: child.id as string,
      firstName: child.firstName as string,
      lastName: child.lastName as string,
    }));

    for (const child of typedChildren) {
      const firstName = this.normalizeText(child.firstName);
      const lastName = this.normalizeText(child.lastName);
      const fullName = this.normalizeText(`${child.firstName} ${child.lastName}`);

      if (normalizedMessage.includes(fullName)) {
        return child;
      }

      if (normalizedMessage.includes(firstName)) {
        const sameFirstNameCount = typedChildren.filter(
          (candidate) => this.normalizeText(candidate.firstName) === firstName,
        ).length;
        if (sameFirstNameCount === 1 || normalizedMessage.includes(lastName)) {
          return child;
        }
      }
    }

    if (typedChildren.length === 1) {
      return typedChildren[0];
    }

    return null;
  }

  private resolveRelativeDate(message: string, timeZone: string) {
    const oneDayMs = 24 * 60 * 60 * 1000;
    const today = this.getLogicalDateInTimezone(timeZone);

    if (message.includes('ayer')) {
      return new Date(today.getTime() - oneDayMs);
    }

    return today;
  }

  private normalizeText(input: string) {
    const replacements: Record<string, string> = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    return input
        .toLowerCase()
        .split('')
        .map((char) => replacements[char] ?? char)
        .join('')
        .replace(/\s+/g, ' ')
        .trim();
  }

  private getLogicalDateInTimezone(timeZone: string) {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());

    const year = Number(parts.find((part) => part.type === 'year')?.value);
    const month = Number(parts.find((part) => part.type === 'month')?.value);
    const day = Number(parts.find((part) => part.type === 'day')?.value);

    return new Date(Date.UTC(year, month - 1, day));
  }

  private formatTime(date: Date, timeZone: string) {
    return new Intl.DateTimeFormat('es-MX', {
      timeZone,
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
    }).format(new Date(date));
  }

  private formatLongDate(date: Date, _timeZone: string) {
    return new Intl.DateTimeFormat('es-MX', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      timeZone: 'UTC',
    }).format(new Date(date));
  }

  private toIsoDate(date: Date) {
    return new Date(date).toISOString().split('T')[0];
  }
}
