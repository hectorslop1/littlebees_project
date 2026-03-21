# Sprint 2 - Chat en Tiempo Real - Progreso

**Fecha inicio:** 20 de marzo, 2026  
**Estado:** En progreso (Setup inicial completado)

---

## 🎯 Objetivo Sprint 2

Implementar sistema de chat en tiempo real usando Socket.IO para comunicación entre padres y maestras.

---

## ✅ Completado

### 1. Setup de Socket.IO (Completado)

#### **SocketClient Mejorado**
- ✅ Stream de estado de conexión (`connectionStream`)
- ✅ Getter `isConnected` para verificar estado
- ✅ Manejo de eventos: `onConnect`, `onDisconnect`, `onConnectError`, `onReconnect`
- ✅ Reconexión automática mejorada (10 intentos, delay exponencial)
- ✅ Prevención de múltiples intentos de conexión simultáneos
- ✅ Método `dispose()` para limpieza de recursos

**Archivo:** `lib/core/api/socket_client.dart`

#### **Modelos de Datos**
- ✅ `Message` model con freezed
  - Propiedades: id, conversationId, senderId, senderName, content, attachments
  - Estados: isRead, isDeleted
  - Timestamps: createdAt, updatedAt
- ✅ `Conversation` model con freezed
  - Propiedades: id, participantId, participantName, lastMessage
  - Estados: unreadCount, lastMessageAt

**Archivo:** `lib/shared/models/message_model.dart`

#### **Providers Reactivos**
- ✅ `socketConnectionProvider` - Stream del estado de conexión
- ✅ `realtimeMessagingProvider` - StateNotifier para mensajes en tiempo real
  - Eventos: `message:new`, `message:updated`, `message:deleted`
  - Métodos: `sendMessage()`, `startTyping()`, `stopTyping()`
  - Auto-join/leave de conversaciones
- ✅ `typingStatusProvider` - Stream de usuarios escribiendo

**Archivo:** `lib/features/messaging/application/realtime_messaging_provider.dart`

---

## ✅ Completado (Continuación)

### 2. Generación de Código Freezed
- ✅ Build runner ejecutado exitosamente
- ✅ 39 archivos generados (.freezed.dart y .g.dart)

### 3. ConversationsRepository
**Archivo:** `lib/features/messaging/data/conversations_repository.dart`

- ✅ Métodos CRUD completos
- ✅ `getConversations()` - Lista de conversaciones
- ✅ `getConversationById()` - Detalle de conversación
- ✅ `getMessages()` - Historial con paginación
- ✅ `createConversation()` - Crear nueva conversación
- ✅ `markAsRead()` - Marcar como leído
- ✅ Manejo de errores con códigos HTTP

### 4. ConversationsProvider
**Archivo:** `lib/features/messaging/application/conversations_provider.dart`

- ✅ `conversationsRepositoryProvider` - Repository provider
- ✅ `conversationsNotifierProvider` - StateNotifier con estado reactivo
- ✅ Métodos: `loadConversations()`, `refresh()`, `createConversation()`, `markAsRead()`
- ✅ `updateLastMessage()` - Actualización en tiempo real
- ✅ Auto-ordenamiento por fecha de último mensaje

### 5. ConversationsScreen Mejorado
**Archivo:** `lib/features/messaging/presentation/conversations_screen.dart`

- ✅ Integración con API real
- ✅ Pull-to-refresh funcional
- ✅ Lista de conversaciones con datos reales
- ✅ Badge de mensajes no leídos
- ✅ Último mensaje visible
- ✅ Timestamps inteligentes
- ✅ Estados vacíos y de error
- ✅ Navegación a ChatScreen con parámetros

### 6. ApiClient Provider
**Archivo:** `lib/core/api/api_client.dart`

- ✅ `apiClientProvider` agregado
- ✅ Integración con Riverpod

### 7. UI de Chat Completa
- [ ] Crear `ChatScreen` con burbujas de mensajes
- [ ] Implementar input de texto con indicador de "escribiendo..."
- [ ] Agregar soporte para adjuntos (imágenes)
- [ ] Mostrar timestamps y estado de lectura
- [ ] Scroll automático a nuevos mensajes

### 4. Mejoras a ConversationsScreen
- [ ] Integrar con providers de tiempo real
- [ ] Mostrar badge de mensajes no leídos
- [ ] Actualizar último mensaje en tiempo real
- [ ] Agregar indicador de "escribiendo..." en lista

### 5. Features Adicionales
- [ ] Notificaciones push para mensajes nuevos
- [ ] Persistencia local de mensajes (SQLite)
- [ ] Caché de conversaciones
- [ ] Búsqueda de mensajes
- [ ] Marcar como leído/no leído

---

## 🏗️ Arquitectura Implementada

### Flujo de Datos

```
Usuario → ChatScreen
    ↓
RealtimeMessagingNotifier.sendMessage()
    ↓
SocketClient.emit('message:send')
    ↓
Backend Socket.IO Server
    ↓
SocketClient.on('message:new')
    ↓
RealtimeMessagingNotifier actualiza state
    ↓
ChatScreen se reconstruye con nuevo mensaje
```

### Eventos Socket.IO

**Emitidos por el cliente:**
- `join_conversation` - Al entrar a un chat
- `leave_conversation` - Al salir de un chat
- `message:send` - Enviar mensaje
- `typing:start` - Usuario empieza a escribir
- `typing:stop` - Usuario deja de escribir

**Recibidos del servidor:**
- `message:new` - Nuevo mensaje recibido
- `message:updated` - Mensaje editado
- `message:deleted` - Mensaje eliminado
- `typing:start` - Otro usuario escribiendo
- `typing:stop` - Otro usuario dejó de escribir

---

## 🔌 Backend Requirements

### Endpoints Socket.IO Necesarios

#### 1. Conexión
```javascript
// Autenticación via JWT en handshake
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // Verificar token y adjuntar userId al socket
});
```

#### 2. Eventos a Implementar

**`join_conversation`**
```json
{
  "conversationId": "uuid"
}
```

**`message:send`**
```json
{
  "conversationId": "uuid",
  "content": "Mensaje de texto",
  "attachmentUrl": "https://..." // opcional
}
```

**`message:new` (broadcast)**
```json
{
  "id": "uuid",
  "conversationId": "uuid",
  "senderId": "uuid",
  "senderName": "María López",
  "senderAvatarUrl": "https://...",
  "content": "Mensaje de texto",
  "attachmentUrl": null,
  "createdAt": "2024-03-20T19:30:00.000Z",
  "isRead": false
}
```

**`typing:start` / `typing:stop`**
```json
{
  "conversationId": "uuid",
  "userId": "uuid",
  "userName": "María López"
}
```

---

## 📊 Estimación de Tiempo

| Tarea | Estimado | Real | Estado |
|-------|----------|------|--------|
| Setup Socket.IO | 2h | 1.5h | ✅ Completado |
| Modelos de datos | 1h | 0.5h | ✅ Completado |
| Providers reactivos | 2h | 1h | ✅ Completado |
| Build runner | 0.5h | En progreso | ⏳ |
| ChatScreen UI | 4h | - | Pendiente |
| ConversationsScreen mejoras | 2h | - | Pendiente |
| Testing | 2h | - | Pendiente |
| **Total** | **13.5h** | **3h** | **22% completado** |

---

## 🧪 Testing Checklist

- [ ] Conexión Socket.IO exitosa
- [ ] Envío de mensajes funcional
- [ ] Recepción de mensajes en tiempo real
- [ ] Indicador de "escribiendo..." funciona
- [ ] Reconexión automática tras pérdida de conexión
- [ ] Mensajes persisten tras reconexión
- [ ] Múltiples conversaciones funcionan simultáneamente
- [ ] Notificaciones de mensajes nuevos
- [ ] Performance con 100+ mensajes

---

## 🚀 Próximos Pasos Inmediatos

1. ✅ Esperar a que termine build_runner
2. Crear `ChatScreen` con UI de burbujas
3. Integrar providers en `ConversationsScreen`
4. Probar flujo completo de envío/recepción
5. Agregar persistencia local

---

## 📝 Notas Técnicas

### Consideraciones de Performance
- Los providers usan `family` para crear instancias por conversación
- Cada conversación tiene su propio `StateNotifier`
- Auto-cleanup al salir de conversación (`dispose`)
- Stream controllers con `broadcast` para múltiples listeners

### Manejo de Errores
- Try-catch en todos los métodos async
- AsyncValue para estados loading/error/data
- Reconexión automática en caso de fallo

### Seguridad
- JWT token en handshake de Socket.IO
- Validación de permisos en backend
- Sanitización de contenido de mensajes

---

**Última actualización:** 20 de marzo, 2026 - 19:30
