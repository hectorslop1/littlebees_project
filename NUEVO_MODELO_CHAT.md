# Nuevo Modelo de Chat - Simplificado

## Problema Actual

❌ **3 conversaciones separadas** con Ana López (una por niño)
❌ Confuso para el usuario
❌ Mensajes mock en la pantalla de detalle

## Solución Propuesta

✅ **Una conversación por maestra** (agrupada en el frontend)
✅ Dentro del chat se pueden mencionar diferentes niños
✅ Mensajes reales del backend

---

## Implementación

### Opción 1: Agrupar en Frontend (Más Rápido)

**Backend:** Mantener conversaciones por niño
**Frontend:** Agrupar visualmente por maestra

```dart
// En conversations_screen.dart
Map<String, List<Conversation>> groupByTeacher(List<Conversation> conversations) {
  final grouped = <String, List<Conversation>>{};
  
  for (final conv in conversations) {
    final teacher = conv.participants.firstWhere(
      (p) => p.userId != currentUserId,
    );
    final teacherId = teacher.userId;
    
    if (!grouped.containsKey(teacherId)) {
      grouped[teacherId] = [];
    }
    grouped[teacherId]!.add(conv);
  }
  
  return grouped;
}
```

**Resultado:**
```
Messages
┌─────────────────────────────┐
│ Ana López                   │
│ Maestra de Mariposas        │
│ Último mensaje...           │
└─────────────────────────────┘
```

Al abrir:
- Muestra TODOS los mensajes de las 3 conversaciones combinadas
- Ordenados por fecha

---

### Opción 2: Cambiar Modelo de BD (Más Complejo)

**Cambio en schema:**
```sql
-- Eliminar child_id de conversations
ALTER TABLE conversations DROP COLUMN child_id;

-- Ahora una conversación es solo: padre <-> maestra
-- Los mensajes pueden mencionar niños en el contenido
```

**Pros:**
- Modelo más limpio
- Una sola conversación por par de usuarios

**Contras:**
- Requiere migración de datos
- Más cambios en backend

---

## Decisión: Opción 1 (Agrupar en Frontend)

**Razones:**
1. ✅ Más rápido de implementar
2. ✅ No requiere cambios en BD
3. ✅ Mantiene historial por niño (útil para reportes)
4. ✅ Solo cambios en mobile app

---

## Pasos de Implementación

### 1. Agrupar Conversaciones por Maestra

```dart
// conversations_screen.dart
final groupedConversations = _groupByTeacher(conversations, currentUserId);

Map<String, ConversationGroup> _groupByTeacher(
  List<Conversation> conversations,
  String currentUserId,
) {
  final groups = <String, ConversationGroup>{};
  
  for (final conv in conversations) {
    final teacher = conv.participants.firstWhere(
      (p) => p.userId != currentUserId,
    );
    
    if (!groups.containsKey(teacher.userId)) {
      groups[teacher.userId] = ConversationGroup(
        teacherId: teacher.userId,
        teacherName: '${teacher.firstName} ${teacher.lastName}',
        teacherAvatar: teacher.avatarUrl,
        conversations: [],
      );
    }
    
    groups[teacher.userId]!.conversations.add(conv);
  }
  
  return groups;
}
```

### 2. Mostrar Una Tarjeta por Maestra

```dart
ListView.builder(
  itemCount: groupedConversations.length,
  itemBuilder: (context, index) {
    final group = groupedConversations.values.elementAt(index);
    final lastMessage = _getLatestMessage(group.conversations);
    
    return ConversationCard(
      teacherName: group.teacherName,
      teacherAvatar: group.teacherAvatar,
      lastMessage: lastMessage,
      unreadCount: _getTotalUnread(group.conversations),
      onTap: () => _openGroupChat(group),
    );
  },
)
```

### 3. Pantalla de Chat Combinada

```dart
// chat_screen.dart
class GroupChatScreen extends ConsumerWidget {
  final ConversationGroup group;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Combinar mensajes de todas las conversaciones del grupo
    final allMessages = await _getCombinedMessages(group.conversations);
    
    return ChatView(
      title: group.teacherName,
      subtitle: 'Maestra de ${_getGroupNames(group)}',
      messages: allMessages,
      onSendMessage: (content) => _sendToLatestConversation(content),
    );
  }
}
```

---

## Resultado Final

### Lista de Conversaciones
```
Messages

┌─────────────────────────────────────┐
│ 👤 Ana López              9:42 PM  │
│ Maestra de Mariposas               │
│ Le encantó jugar en el jardín...   │
│                                 🔴 6│
└─────────────────────────────────────┘
```

### Dentro del Chat
```
Ana López
Maestra de Mariposas

┌─────────────────────────────────────┐
│ Hola Carlos, Santiago tuvo un       │
│ excelente día hoy.                  │
│                          2:30 PM    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│                  Qué bien! Gracias  │
│                          2:32 PM    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Sofía también estuvo muy activa     │
│ en la clase de música.              │
│                          3:15 PM    │
└─────────────────────────────────────┘
```

---

## Ventajas de Este Enfoque

1. ✅ **Intuitivo:** Una conversación por maestra
2. ✅ **Rápido:** Solo cambios en frontend
3. ✅ **Flexible:** Mantiene datos por niño en BD
4. ✅ **Escalable:** Funciona con múltiples maestras
5. ✅ **Simple:** No requiere migración de datos

---

## Implementación Inmediata

Voy a:
1. Crear función para agrupar conversaciones
2. Modificar `conversations_screen.dart`
3. Crear/modificar `chat_detail_screen.dart` para mostrar mensajes reales
4. Implementar envío de mensajes real
