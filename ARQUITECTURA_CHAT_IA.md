# 🤖 ARQUITECTURA CHAT CON IA - LITTLEBEES

**Fecha**: 19 de Marzo, 2026  
**Versión**: 1.0  
**Objetivo**: Sistema de chat con IA seguro, escalable y con permisos por rol

---

## 📋 ÍNDICE

1. [Arquitectura General](#arquitectura-general)
2. [Stack Tecnológico](#stack-tecnológico)
3. [Sistema de Permisos](#sistema-de-permisos)
4. [Flujo de Datos](#flujo-de-datos)
5. [Implementación Backend](#implementación-backend)
6. [Implementación Mobile](#implementación-mobile)
7. [Seguridad](#seguridad)
8. [Escalabilidad](#escalabilidad)

---

## 🏗️ ARQUITECTURA GENERAL

```
┌─────────────────────────────────────────────────────────────┐
│                      APP MÓVIL / WEB                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Chat UI      │  │ Voice Input  │  │ Suggestions  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                  │              │
│         └─────────────────┴──────────────────┘              │
│                           │                                 │
└───────────────────────────┼─────────────────────────────────┘
                            │ WebSocket / HTTP
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND (NestJS)                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              AI CHAT CONTROLLER                      │   │
│  │  - Autenticación JWT                                 │   │
│  │  - Validación de permisos por rol                    │   │
│  │  - Rate limiting                                     │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                     │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │              AI SERVICE LAYER                        │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │   │
│  │  │ Context      │  │ Query        │  │ Response  │  │   │
│  │  │ Builder      │  │ Sanitizer    │  │ Formatter │  │   │
│  │  └──────────────┘  └──────────────┘  └───────────┘  │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                     │
│  ┌────────────────────▼─────────────────────────────────┐   │
│  │         PERMISSION-AWARE DATA ACCESS LAYER           │   │
│  │  - Role-based query filters                          │   │
│  │  - Data masking                                      │   │
│  │  - Audit logging                                     │   │
│  └────────────────────┬─────────────────────────────────┘   │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────┐              ┌────────────────┐
│  PostgreSQL   │              │   Groq API     │
│  (IONOS)      │              │  (Llama 3.3)   │
│               │              │                │
│ - users       │              │ - Streaming    │
│ - children    │              │ - Function     │
│ - activities  │              │   calling      │
│ - reports     │              │ - Context      │
└───────────────┘              └────────────────┘
```

---

## 🛠️ STACK TECNOLÓGICO

### Backend
- **Framework**: NestJS (TypeScript)
- **ORM**: Prisma
- **IA Provider**: Groq (Llama 3.3 70B)
- **WebSockets**: Socket.io
- **Cache**: Redis (para contexto de conversaciones)
- **Queue**: Bull (para procesamiento asíncrono)

### Mobile
- **Framework**: Flutter
- **State Management**: Riverpod
- **WebSocket**: socket_io_client
- **Markdown**: flutter_markdown (para respuestas formateadas)

### Seguridad
- **Autenticación**: JWT
- **Rate Limiting**: @nestjs/throttler
- **Sanitización**: class-validator, class-transformer
- **Audit**: Custom logging middleware

---

## 🔐 SISTEMA DE PERMISOS

### Matriz de Permisos por Rol

| Funcionalidad | Padre | Maestra | Admin | Director | Super Admin |
|--------------|-------|---------|-------|----------|-------------|
| **Consultar hijos propios** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Consultar niños del grupo** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Consultar todos los niños** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Ver actividades de sus hijos** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Ver actividades del grupo** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Generar reportes individuales** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Generar reportes grupales** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Generar reportes institucionales** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Ver datos financieros** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Gestionar usuarios** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Recomendaciones personalizadas** | ✅ | ✅ | ✅ | ✅ | ✅ |

### Reglas de Acceso a Datos

```typescript
// Ejemplo de filtros por rol
const DATA_ACCESS_RULES = {
  parent: {
    children: (userId) => ({
      parents: { some: { userId } }
    }),
    activities: (userId) => ({
      child: { parents: { some: { userId } } }
    }),
    reports: (userId) => ({
      child: { parents: { some: { userId } } }
    }),
    // PROHIBIDO: financial, users, other_children
  },
  
  teacher: {
    children: (userId) => ({
      group: { teacherId: userId }
    }),
    activities: (userId) => ({
      child: { group: { teacherId: userId } }
    }),
    reports: (userId) => ({
      child: { group: { teacherId: userId } }
    }),
    // PROHIBIDO: financial, users, other_groups
  },
  
  admin: {
    children: (tenantId) => ({ tenantId }),
    activities: (tenantId) => ({ child: { tenantId } }),
    reports: (tenantId) => ({ tenantId }),
    users: (tenantId) => ({ tenantId }),
    // PROHIBIDO: financial (solo director/super_admin)
  },
  
  director: {
    // Acceso completo a su tenant
    all: (tenantId) => ({ tenantId }),
  },
  
  super_admin: {
    // Acceso completo a todos los tenants
    all: () => ({}),
  }
};
```

---

## 🔄 FLUJO DE DATOS

### 1. Usuario Envía Mensaje

```
Usuario: "¿Cómo estuvo mi hijo Santiago hoy?"
   │
   ├─ JWT Token (contiene: userId, role, tenantId)
   ├─ Mensaje
   └─ Historial de conversación (últimos 10 mensajes)
```

### 2. Backend Procesa

```typescript
// 1. Autenticación y extracción de contexto
const { userId, role, tenantId } = extractFromJWT(token);

// 2. Construcción de contexto seguro
const context = await buildSecureContext({
  userId,
  role,
  tenantId,
  message: "¿Cómo estuvo mi hijo Santiago hoy?"
});

// Context para PADRE:
{
  role: "parent",
  availableChildren: [
    { id: "...", name: "Santiago Ramírez", age: 3 }
  ],
  todayActivities: [
    { type: "check_in", time: "08:30", mood: "happy" },
    { type: "meal", time: "12:00", consumed: "all" }
  ],
  permissions: ["view_own_children", "view_children_activities"]
}

// 3. Envío a IA con instrucciones de seguridad
const aiPrompt = `
Eres un asistente de guardería. 
Rol del usuario: ${role}
Permisos: ${context.permissions.join(", ")}

IMPORTANTE: Solo puedes responder sobre:
- Hijos del usuario: ${context.availableChildren.map(c => c.name).join(", ")}
- NO reveles información de otros niños
- NO reveles información financiera
- NO reveles información de otros padres

Contexto disponible:
${JSON.stringify(context, null, 2)}

Pregunta del usuario: ${message}
`;

// 4. Llamada a Groq
const response = await groq.chat.completions.create({
  model: "llama-3.3-70b-versatile",
  messages: [
    { role: "system", content: aiPrompt },
    ...conversationHistory,
    { role: "user", content: message }
  ],
  functions: [
    {
      name: "query_child_activities",
      description: "Consulta actividades de un niño específico",
      parameters: {
        type: "object",
        properties: {
          childId: { type: "string" },
          date: { type: "string" }
        }
      }
    }
  ]
});

// 5. Sanitización de respuesta
const sanitizedResponse = sanitizeAIResponse(response, context.permissions);

// 6. Audit log
await logAIInteraction({
  userId,
  role,
  query: message,
  response: sanitizedResponse,
  dataAccessed: context.dataAccessed
});
```

---

## 💻 IMPLEMENTACIÓN BACKEND

### Estructura de Archivos

```
littlebees-web/apps/api/src/modules/ai-chat/
├── ai-chat.module.ts
├── ai-chat.controller.ts
├── ai-chat.gateway.ts (WebSocket)
├── services/
│   ├── ai-chat.service.ts
│   ├── context-builder.service.ts
│   ├── groq.service.ts
│   └── permission-validator.service.ts
├── dto/
│   ├── chat-message.dto.ts
│   └── ai-response.dto.ts
├── guards/
│   └── ai-permissions.guard.ts
└── functions/
    ├── query-children.function.ts
    ├── query-activities.function.ts
    ├── generate-report.function.ts
    └── get-recommendations.function.ts
```

### Código Clave

#### 1. AI Chat Service

```typescript
// ai-chat.service.ts
import { Injectable } from '@nestjs/common';
import { GroqService } from './groq.service';
import { ContextBuilderService } from './context-builder.service';
import { PermissionValidatorService } from './permission-validator.service';

@Injectable()
export class AIChatService {
  constructor(
    private groq: GroqService,
    private contextBuilder: ContextBuilderService,
    private permissionValidator: PermissionValidatorService,
  ) {}

  async chat(
    message: string,
    userId: string,
    role: string,
    tenantId: string,
    conversationHistory: any[]
  ) {
    // 1. Construir contexto seguro basado en rol
    const context = await this.contextBuilder.build({
      userId,
      role,
      tenantId,
      message
    });

    // 2. Validar que el mensaje no intente acceder a datos prohibidos
    await this.permissionValidator.validateQuery(message, context);

    // 3. Preparar prompt con instrucciones de seguridad
    const systemPrompt = this.buildSystemPrompt(role, context);

    // 4. Llamar a Groq con function calling
    const response = await this.groq.chat({
      messages: [
        { role: 'system', content: systemPrompt },
        ...conversationHistory,
        { role: 'user', content: message }
      ],
      functions: this.getAvailableFunctions(role),
      userId,
      tenantId
    });

    // 5. Si la IA quiere ejecutar una función, validar permisos
    if (response.function_call) {
      const functionResult = await this.executeFunctionWithPermissions(
        response.function_call,
        context
      );
      
      // Llamar de nuevo a la IA con el resultado
      return this.groq.chat({
        messages: [
          ...conversationHistory,
          { role: 'user', content: message },
          { role: 'assistant', content: null, function_call: response.function_call },
          { role: 'function', name: response.function_call.name, content: JSON.stringify(functionResult) }
        ]
      });
    }

    // 6. Sanitizar respuesta
    return this.sanitizeResponse(response, context);
  }

  private buildSystemPrompt(role: string, context: any): string {
    const basePrompt = `Eres un asistente inteligente para LittleBees, un sistema de gestión de guarderías.`;
    
    const rolePrompts = {
      parent: `
        Estás ayudando a un PADRE/MADRE.
        
        PUEDES:
        - Responder sobre sus hijos: ${context.children.map(c => c.name).join(', ')}
        - Mostrar actividades, comidas, siestas de sus hijos
        - Dar recomendaciones personalizadas
        - Recordar eventos importantes
        
        NO PUEDES:
        - Revelar información de otros niños
        - Mostrar datos financieros
        - Revelar información de otros padres o maestras
        - Acceder a configuración del sistema
      `,
      teacher: `
        Estás ayudando a una MAESTRA.
        
        PUEDES:
        - Responder sobre niños de su grupo: ${context.group?.name}
        - Generar reportes de su grupo
        - Sugerir actividades educativas
        - Ayudar con planificación de clases
        
        NO PUEDES:
        - Revelar información de otros grupos
        - Mostrar datos financieros
        - Acceder a información de padres
        - Modificar configuración del sistema
      `,
      admin: `
        Estás ayudando a un ADMINISTRADOR.
        
        PUEDES:
        - Generar reportes institucionales
        - Consultar estadísticas generales
        - Ayudar con gestión de usuarios
        - Sugerir mejoras operativas
        
        NO PUEDES:
        - Mostrar datos financieros sensibles (solo director)
        - Modificar datos directamente
      `,
      director: `
        Estás ayudando a un DIRECTOR.
        
        PUEDES:
        - Acceder a toda la información de la institución
        - Generar cualquier tipo de reporte
        - Analizar datos financieros
        - Obtener insights estratégicos
      `
    };

    return `${basePrompt}\n\n${rolePrompts[role]}\n\nContexto actual:\n${JSON.stringify(context, null, 2)}`;
  }

  private getAvailableFunctions(role: string) {
    const allFunctions = {
      query_child_activities: {
        name: 'query_child_activities',
        description: 'Consulta las actividades de un niño en una fecha específica',
        parameters: {
          type: 'object',
          properties: {
            childId: { type: 'string', description: 'ID del niño' },
            date: { type: 'string', description: 'Fecha en formato YYYY-MM-DD' }
          },
          required: ['childId']
        }
      },
      generate_report: {
        name: 'generate_report',
        description: 'Genera un reporte basado en criterios específicos',
        parameters: {
          type: 'object',
          properties: {
            type: { type: 'string', enum: ['individual', 'group', 'institutional'] },
            childId: { type: 'string' },
            groupId: { type: 'string' },
            startDate: { type: 'string' },
            endDate: { type: 'string' }
          }
        }
      },
      get_recommendations: {
        name: 'get_recommendations',
        description: 'Obtiene recomendaciones personalizadas',
        parameters: {
          type: 'object',
          properties: {
            childId: { type: 'string' },
            category: { type: 'string', enum: ['nutrition', 'development', 'activities'] }
          }
        }
      }
    };

    // Filtrar funciones según rol
    const allowedFunctions = {
      parent: ['query_child_activities', 'get_recommendations'],
      teacher: ['query_child_activities', 'generate_report', 'get_recommendations'],
      admin: ['generate_report', 'get_recommendations'],
      director: Object.keys(allFunctions),
      super_admin: Object.keys(allFunctions)
    };

    return allowedFunctions[role].map(name => allFunctions[name]);
  }
}
```

#### 2. Context Builder Service

```typescript
// context-builder.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ContextBuilderService {
  constructor(private prisma: PrismaService) {}

  async build({ userId, role, tenantId, message }) {
    const context = {
      userId,
      role,
      tenantId,
      permissions: this.getPermissions(role),
      children: [],
      groups: [],
      recentActivities: [],
      dataAccessed: []
    };

    // Cargar datos según rol
    if (role === 'parent') {
      context.children = await this.prisma.child.findMany({
        where: {
          parents: { some: { userId } }
        },
        select: {
          id: true,
          firstName: true,
          lastName: true,
          dateOfBirth: true,
          groupName: true
        }
      });

      // Actividades de hoy de sus hijos
      const childIds = context.children.map(c => c.id);
      context.recentActivities = await this.prisma.dailyLogEntry.findMany({
        where: {
          childId: { in: childIds },
          date: new Date()
        },
        include: {
          child: { select: { firstName: true, lastName: true } }
        },
        orderBy: { createdAt: 'desc' },
        take: 10
      });

      context.dataAccessed.push('children', 'activities');
    }

    if (role === 'teacher') {
      context.groups = await this.prisma.group.findMany({
        where: { teacherId: userId },
        include: {
          children: {
            select: {
              id: true,
              firstName: true,
              lastName: true
            }
          }
        }
      });

      context.dataAccessed.push('groups', 'children');
    }

    // Admin, director, super_admin tienen acceso más amplio
    // pero se filtra por tenantId

    return context;
  }

  private getPermissions(role: string): string[] {
    const permissions = {
      parent: ['view_own_children', 'view_children_activities', 'get_recommendations'],
      teacher: ['view_group_children', 'view_group_activities', 'generate_group_reports'],
      admin: ['view_all_children', 'generate_institutional_reports', 'manage_users'],
      director: ['full_access_tenant'],
      super_admin: ['full_access_all']
    };

    return permissions[role] || [];
  }
}
```

#### 3. WebSocket Gateway

```typescript
// ai-chat.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { UseGuards } from '@nestjs/common';
import { WsJwtGuard } from '../../common/guards/ws-jwt.guard';
import { AIChatService } from './services/ai-chat.service';

@WebSocketGateway({
  namespace: 'ai-chat',
  cors: { origin: '*' }
})
export class AIChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private conversations = new Map<string, any[]>();

  constructor(private aiChatService: AIChatService) {}

  async handleConnection(client: Socket) {
    // Validar JWT del cliente
    const token = client.handshake.auth.token;
    // ... validación
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.conversations.delete(client.id);
    console.log(`Client disconnected: ${client.id}`);
  }

  @UseGuards(WsJwtGuard)
  @SubscribeMessage('chat_message')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { message: string; userId: string; role: string; tenantId: string }
  ) {
    try {
      // Obtener historial de conversación
      const history = this.conversations.get(client.id) || [];

      // Emitir estado "typing"
      client.emit('ai_typing', { isTyping: true });

      // Procesar mensaje con IA
      const response = await this.aiChatService.chat(
        data.message,
        data.userId,
        data.role,
        data.tenantId,
        history
      );

      // Actualizar historial
      history.push(
        { role: 'user', content: data.message },
        { role: 'assistant', content: response.content }
      );
      this.conversations.set(client.id, history.slice(-20)); // Mantener últimos 20 mensajes

      // Emitir respuesta
      client.emit('ai_response', {
        message: response.content,
        timestamp: new Date()
      });

      client.emit('ai_typing', { isTyping: false });
    } catch (error) {
      client.emit('ai_error', {
        message: 'Error al procesar tu mensaje',
        error: error.message
      });
      client.emit('ai_typing', { isTyping: false });
    }
  }

  @SubscribeMessage('clear_conversation')
  handleClearConversation(@ConnectedSocket() client: Socket) {
    this.conversations.delete(client.id);
    client.emit('conversation_cleared');
  }
}
```

---

## 📱 IMPLEMENTACIÓN MOBILE

### Estructura de Archivos

```
littlebees-mobile/lib/features/ai_chat/
├── data/
│   └── ai_chat_repository.dart
├── application/
│   └── ai_chat_provider.dart
├── presentation/
│   ├── ai_chat_screen.dart
│   └── widgets/
│       ├── chat_message_bubble.dart
│       ├── chat_input.dart
│       └── typing_indicator.dart
└── models/
    └── chat_message.dart
```

### Código Clave

#### 1. AI Chat Provider

```dart
// ai_chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/config/app_config.dart';
import '../../auth/application/auth_provider.dart';

final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  final authState = ref.watch(authProvider);
  return AIChatNotifier(authState.accessToken, authState.user);
});

class AIChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isConnected;
  final String? error;

  AIChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isConnected = false,
    this.error,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isConnected,
    String? error,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  late IO.Socket socket;
  final String? token;
  final UserInfo? user;

  AIChatNotifier(this.token, this.user) : super(AIChatState()) {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(
      '${AppConfig.wsBaseUrl.replaceAll('/api/v1', '')}/ai-chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    socket.on('connect', (_) {
      state = state.copyWith(isConnected: true, error: null);
    });

    socket.on('disconnect', (_) {
      state = state.copyWith(isConnected: false);
    });

    socket.on('ai_response', (data) {
      final message = ChatMessage(
        content: data['message'],
        isUser: false,
        timestamp: DateTime.parse(data['timestamp']),
      );
      state = state.copyWith(
        messages: [...state.messages, message],
        isTyping: false,
      );
    });

    socket.on('ai_typing', (data) {
      state = state.copyWith(isTyping: data['isTyping']);
    });

    socket.on('ai_error', (data) {
      state = state.copyWith(
        error: data['message'],
        isTyping: false,
      );
    });

    socket.connect();
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, userMessage]);

    // Enviar al backend
    socket.emit('chat_message', {
      'message': message,
      'userId': user?.id,
      'role': user?.role,
      'tenantId': user?.tenantId,
    });
  }

  void clearConversation() {
    socket.emit('clear_conversation');
    state = state.copyWith(messages: []);
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
}
```

#### 2. Chat Screen UI

```dart
// ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../design_system/theme/app_colors.dart';
import '../application/ai_chat_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_input.dart';
import 'widgets/typing_indicator.dart';

class AIChatScreen extends ConsumerWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);
    final chatNotifier = ref.read(aiChatProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: chatState.isConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Asistente IA'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () => chatNotifier.clearConversation(),
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isTyping) {
                  return const TypingIndicator();
                }
                return ChatMessageBubble(
                  message: chatState.messages[index],
                );
              },
            ),
          ),

          // Error banner
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Text(
                chatState.error!,
                style: TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),

          // Input
          ChatInput(
            onSend: chatNotifier.sendMessage,
            enabled: chatState.isConnected,
          ),
        ],
      ),
    );
  }
}
```

---

## 🔒 SEGURIDAD

### 1. Validación de Queries

```typescript
// Detectar intentos de acceso no autorizado
const FORBIDDEN_PATTERNS = {
  parent: [
    /financial/i,
    /salary/i,
    /payment/i,
    /other.*children/i,
    /all.*users/i
  ],
  teacher: [
    /financial/i,
    /salary/i,
    /other.*groups/i,
    /parent.*contact/i
  ]
};

async validateQuery(query: string, context: any) {
  const patterns = FORBIDDEN_PATTERNS[context.role] || [];
  
  for (const pattern of patterns) {
    if (pattern.test(query)) {
      throw new ForbiddenException(
        'No tienes permiso para acceder a esa información'
      );
    }
  }
}
```

### 2. Sanitización de Respuestas

```typescript
function sanitizeResponse(aiResponse: string, permissions: string[]) {
  // Remover cualquier mención a datos sensibles
  let sanitized = aiResponse;
  
  if (!permissions.includes('view_financial')) {
    sanitized = sanitized.replace(/\$[\d,]+/g, '[REDACTED]');
  }
  
  if (!permissions.includes('view_all_users')) {
    // Remover emails, teléfonos de otros usuarios
    sanitized = sanitized.replace(/[\w.-]+@[\w.-]+/g, '[EMAIL REDACTED]');
  }
  
  return sanitized;
}
```

### 3. Rate Limiting

```typescript
@UseGuards(ThrottlerGuard)
@Throttle(20, 60) // 20 mensajes por minuto
@SubscribeMessage('chat_message')
async handleMessage(...) {
  // ...
}
```

### 4. Audit Logging

```typescript
await this.prisma.aiChatLog.create({
  data: {
    userId,
    role,
    query: message,
    response: sanitizedResponse,
    dataAccessed: context.dataAccessed,
    timestamp: new Date(),
    ipAddress: client.handshake.address
  }
});
```

---

## 📈 ESCALABILIDAD

### 1. Caching con Redis

```typescript
// Cachear contexto de usuario por 5 minutos
const cacheKey = `ai_context:${userId}`;
let context = await redis.get(cacheKey);

if (!context) {
  context = await this.contextBuilder.build({...});
  await redis.setex(cacheKey, 300, JSON.stringify(context));
}
```

### 2. Queue para Reportes Largos

```typescript
// Para reportes que toman tiempo
@Process('generate-report')
async handleReportGeneration(job: Job) {
  const { userId, reportType, params } = job.data;
  
  const report = await this.generateReport(reportType, params);
  
  // Notificar al usuario vía WebSocket
  this.server.to(userId).emit('report_ready', { report });
}
```

### 3. Streaming de Respuestas

```typescript
// Enviar respuesta de la IA en chunks para mejor UX
const stream = await this.groq.chat.stream({...});

for await (const chunk of stream) {
  client.emit('ai_chunk', { content: chunk.content });
}

client.emit('ai_complete');
```

---

## 🎯 PRÓXIMOS PASOS

1. **Implementar módulo base** (Backend)
   - AI Chat Module
   - Context Builder
   - Permission Validator

2. **Integrar Groq API**
   - Configurar API key
   - Implementar function calling
   - Manejar streaming

3. **Crear UI Mobile**
   - Chat screen
   - WebSocket connection
   - Message bubbles

4. **Testing**
   - Unit tests para permisos
   - Integration tests para functions
   - E2E tests por rol

5. **Optimización**
   - Caching
   - Rate limiting
   - Monitoring

---

**¿Quieres que empiece a implementar alguna parte específica?**
