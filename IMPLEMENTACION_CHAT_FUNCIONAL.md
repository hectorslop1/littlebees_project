# Implementación de Chat Funcional

## Objetivo
Crear un sistema de chat funcional donde:
1. **Padre** puede enviar mensajes a la **maestra** asignada a sus hijos
2. **Maestra** puede responder a los padres de los niños en su grupo
3. Las conversaciones están organizadas por niño
4. Los mensajes se entregan en tiempo real

---

## Estado Actual

### ✅ Base de Datos
- ✅ Tabla `conversations` con `child_id`
- ✅ Tabla `conversation_participants` (padre + maestra)
- ✅ Tabla `messages` con contenido
- ✅ 2 conversaciones creadas para Santiago y Sofía con Ana López (maestra)

### ❌ Problemas Identificados

1. **Backend API** - `chat.service.ts` no incluye información de usuarios en participantes
2. **Mobile App** - Error `RangeError` al intentar acceder a `participants.first`
3. **Filtrado** - Las conversaciones deben mostrar solo la maestra del grupo del niño

---

## Solución Implementada

### 1. Backend - Enriquecer Participantes con Info de Usuario

**Archivo:** `littlebees-web/apps/api/src/modules/chat/chat.service.ts`

**Cambio:**
```typescript
// Antes: participants solo tenía userId, joinedAt
// Ahora: incluye firstName, lastName, avatarUrl del usuario

const participantsWithUserInfo = await Promise.all(
  conv.participants.map(async (p) => {
    const user = await this.prisma.user.findUnique({
      where: { id: p.userId },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        photoUrl: true,
      },
    });
    return {
      userId: p.userId,
      firstName: user?.firstName || '',
      lastName: user?.lastName || '',
      avatarUrl: user?.photoUrl,
      joinedAt: p.joinedAt,
      lastReadAt: p.lastReadAt,
    };
  }),
);
```

**Resultado:**
```json
{
  "id": "conversation-id",
  "childName": "Santiago Ramírez",
  "participants": [
    {
      "userId": "padre-id",
      "firstName": "Carlos",
      "lastName": "Ramírez",
      "avatarUrl": null,
      "joinedAt": "2026-03-11T...",
      "lastReadAt": null
    },
    {
      "userId": "maestra-id",
      "firstName": "Ana",
      "lastName": "López",
      "avatarUrl": null,
      "joinedAt": "2026-03-11T...",
      "lastReadAt": null
    }
  ],
  "lastMessage": {...},
  "unreadCount": 3
}
```

---

## Cómo Funciona el Chat

### Flujo de Conversación

```
1. PADRE (Carlos) ve sus conversaciones
   ↓
   GET /api/v1/chat/conversations
   ↓
   Backend filtra: solo conversaciones donde Carlos es participante
   ↓
   Retorna: 2 conversaciones (Santiago + Sofía)
   ↓
   Cada conversación muestra:
   - Nombre del niño
   - Nombre de la maestra (Ana López)
   - Último mensaje
   - Mensajes no leídos

2. PADRE selecciona conversación de Santiago
   ↓
   GET /api/v1/chat/conversations/{id}/messages
   ↓
   Backend verifica: Carlos es participante
   ↓
   Retorna: todos los mensajes de la conversación

3. PADRE escribe mensaje
   ↓
   POST /api/v1/chat/conversations/{id}/messages
   Body: { "content": "Hola maestra, ¿cómo está Santiago?" }
   ↓
   Backend crea mensaje con senderId = Carlos
   ↓
   Actualiza conversation.updatedAt

4. MAESTRA (Ana) ve sus conversaciones
   ↓
   GET /api/v1/chat/conversations
   ↓
   Backend filtra: conversaciones de niños en grupos de Ana
   ↓
   Retorna: conversaciones con unreadCount > 0
   ↓
   Ve mensaje nuevo de Carlos

5. MAESTRA responde
   ↓
   POST /api/v1/chat/conversations/{id}/messages
   Body: { "content": "Hola Carlos, Santiago está muy bien" }
   ↓
   Backend crea mensaje con senderId = Ana
   ↓
   Carlos ve el mensaje en su app
```

---

## Estructura de Datos

### Conversation
```typescript
{
  id: string;
  tenantId: string;
  childId: string;
  childName: string;
  participants: [
    {
      userId: string;
      firstName: string;
      lastName: string;
      avatarUrl: string | null;
      joinedAt: DateTime;
      lastReadAt: DateTime | null;
    }
  ];
  lastMessage: Message | null;
  unreadCount: number;
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### Message
```typescript
{
  id: string;
  tenantId: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  senderAvatarUrl: string | null;
  content: string;
  messageType: 'text' | 'image';
  attachmentUrl: string | null;
  createdAt: DateTime;
  deletedAt: DateTime | null;
}
```

---

## Relación Padre-Maestra

### Cómo se Determina la Maestra

```sql
-- Para encontrar la maestra de un niño:
SELECT 
  u.id as teacher_id,
  u.first_name,
  u.last_name
FROM children c
JOIN groups g ON c.group_id = g.id
JOIN users u ON g.teacher_id = u.id
WHERE c.id = 'child-id';
```

**Ejemplo:**
- Santiago Ramírez → Grupo Mariposas → Maestra Ana López
- Sofía Ramírez → Grupo Mariposas → Maestra Ana López

Por lo tanto:
- Carlos (padre) tiene 2 conversaciones, ambas con Ana López
- Ana López (maestra) ve conversaciones de todos los niños en Grupo Mariposas

---

## Endpoints del Chat

### 1. Listar Conversaciones
```
GET /api/v1/chat/conversations
Headers: Authorization: Bearer {token}

Response:
[
  {
    "id": "conv-id",
    "childName": "Santiago Ramírez",
    "participants": [...],
    "lastMessage": {...},
    "unreadCount": 3
  }
]
```

### 2. Obtener Mensajes
```
GET /api/v1/chat/conversations/{id}/messages
Headers: Authorization: Bearer {token}

Response:
{
  "data": [
    {
      "id": "msg-id",
      "senderId": "user-id",
      "senderName": "Ana López",
      "content": "Hola Carlos...",
      "createdAt": "2026-03-11T..."
    }
  ],
  "hasMore": false,
  "nextCursor": null
}
```

### 3. Enviar Mensaje
```
POST /api/v1/chat/conversations/{id}/messages
Headers: Authorization: Bearer {token}
Body:
{
  "content": "Hola maestra, ¿cómo está mi hijo?",
  "messageType": "text"
}

Response:
{
  "id": "new-msg-id",
  "conversationId": "conv-id",
  "senderId": "padre-id",
  "content": "Hola maestra...",
  "createdAt": "2026-03-11T..."
}
```

### 4. Marcar como Leído
```
PATCH /api/v1/chat/conversations/{id}/read
Headers: Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Conversación marcada como leída"
}
```

---

## Testing

### Usuarios de Prueba

**Padre:**
- Email: `padre@gmail.com`
- Password: `Password123!`
- Hijos: Santiago Ramírez, Sofía Ramírez
- Grupo: Mariposas
- Maestra: Ana López

**Maestra:**
- Email: `maestra@petitsoleil.mx`
- Password: `Password123!`
- Grupo: Mariposas
- Niños: Santiago, Sofía, Isamar

### Pasos para Probar

1. **Teléfono 1 - Padre:**
   ```
   Login: padre@gmail.com
   Ir a: Chat
   Ver: 2 conversaciones (Santiago + Sofía)
   Seleccionar: Conversación de Santiago
   Enviar: "Hola maestra, ¿cómo está Santiago hoy?"
   ```

2. **Teléfono 2 - Maestra:**
   ```
   Login: maestra@petitsoleil.mx
   Ir a: Chat
   Ver: Conversaciones de niños en Grupo Mariposas
   Ver: Mensaje nuevo de Carlos (badge rojo)
   Abrir: Conversación de Santiago
   Responder: "Hola Carlos, Santiago está muy bien. Hoy jugó mucho en el jardín."
   ```

3. **Teléfono 1 - Padre:**
   ```
   Ver: Mensaje nuevo de Ana López
   Leer: Respuesta de la maestra
   ```

---

## Verificación en Base de Datos

### Ver Conversaciones
```sql
SELECT 
  conv.id,
  c.first_name || ' ' || c.last_name as child_name,
  COUNT(DISTINCT cp.user_id) as participants,
  COUNT(m.id) as messages
FROM conversations conv
JOIN children c ON conv.child_id = c.id
LEFT JOIN conversation_participants cp ON conv.id = cp.conversation_id
LEFT JOIN messages m ON conv.id = m.conversation_id
GROUP BY conv.id, c.first_name, c.last_name;
```

### Ver Mensajes de una Conversación
```sql
SELECT 
  u.first_name || ' ' || u.last_name as sender,
  m.content,
  m.created_at
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.conversation_id = 'conversation-id'
ORDER BY m.created_at ASC;
```

### Ver Participantes
```sql
SELECT 
  c.first_name || ' ' || c.last_name as child_name,
  u.first_name || ' ' || u.last_name as participant,
  u.email
FROM conversations conv
JOIN children c ON conv.child_id = c.id
JOIN conversation_participants cp ON conv.id = cp.conversation_id
JOIN users u ON cp.user_id = u.id
WHERE conv.id = 'conversation-id';
```

---

## Próximos Pasos

1. ✅ Backend enriquece participantes con info de usuario
2. ⏳ Reiniciar backend API
3. ⏳ Probar endpoint de conversaciones
4. ⏳ Verificar que mobile app muestra conversaciones
5. ⏳ Probar envío de mensajes
6. ⏳ Verificar recepción en tiempo real

---

## Notas Importantes

- **Cada conversación está asociada a UN niño específico**
- **Los participantes son: padre del niño + maestra del grupo**
- **Un padre puede tener múltiples conversaciones (una por hijo)**
- **Una maestra puede tener múltiples conversaciones (una por niño en su grupo)**
- **Los mensajes se ordenan por `createdAt` ascendente**
- **El `unreadCount` se calcula comparando `lastReadAt` con `message.createdAt`**
