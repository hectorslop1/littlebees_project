# Diagnóstico Completo — Little Bees App Móvil

> Generado por: Senior Mobile Engineer + Product Designer + QA Engineer
> Fecha: 2026-03-20

---

## RESUMEN EJECUTIVO

La app tiene una base arquitectónica sólida (Riverpod, GoRouter, Freezed, feature-based structure) pero está en estado **prototipo avanzado**, no producto. La mayoría de pantallas muestran snackbars, placeholders o "Coming Soon". Se identificaron **38 problemas concretos** agrupados en 4 categorías: Bugs Críticos, Funcionalidad Incompleta, UX/UI, y Backend Required.

---

## 1. PROBLEMAS GENERALES (TODOS LOS ROLES)

### 1.1 Chatbot IA — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/ai_assistant/presentation/ai_assistant_fab.dart`

**Diagnóstico:** El FAB abre un `DraggableScrollableSheet` pero su contenido es solo un placeholder estático con texto "Próximamente podrás chatear...". No hay:
- Provider para chat con IA
- Repository para endpoint de IA
- Modelo de mensajes IA
- Integración con Groq/Llama 3

**Causa raíz:** Nunca se implementó la integración real. El FAB siempre fue placeholder.

**Solución concreta:**

1. **Backend (requerido):** Crear endpoint `POST /ai/chat` que reciba `{ message, context?, role }` y devuelva streaming response vía SSE o response completa. Integrar Groq API con Llama 3.
2. **Crear modelo:**
```dart
// lib/features/ai_assistant/domain/ai_message.dart
@freezed
class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
  }) = _AiMessage;
}
```
3. **Crear repository:**
```dart
// lib/features/ai_assistant/data/ai_repository.dart
class AiRepository {
  final ApiClient _client;
  
  Future<String> sendMessage(String message, {String? context}) async {
    final response = await _client.post('/ai/chat', data: {
      'message': message,
      'context': context,
    });
    return response.data['reply'];
  }
}
```
4. **Crear provider:**
```dart
// lib/features/ai_assistant/application/ai_provider.dart
final aiMessagesProvider = StateNotifierProvider<AiChatNotifier, List<AiMessage>>((ref) {
  return AiChatNotifier(ref.watch(aiRepositoryProvider));
});
```
5. **Reescribir el bottom sheet** con chat real: lista de mensajes + campo de texto + botón enviar.

**Endpoint backend necesario:**
```
POST /ai/chat
Body: { message: string, conversationHistory?: array, role: string }
Response: { reply: string, suggestions?: string[] }
```

---

### 1.2 Notificaciones — PRIORIDAD ALTA 🔴

**Diagnóstico:** No existe pantalla de notificaciones. El endpoint `GET /notifications` existe en `endpoints.dart` pero no hay:
- Pantalla de notificaciones
- Ícono en header/navbar
- Modelo de notificación implementado (existe `notification_model.dart` pero no se usa)
- Integración con push notifications (Firebase/APNs)

**Solución concreta:**

1. **Agregar ícono de notificaciones en el AppBar del HomeScreen** (tanto teacher como parent):
```dart
// En SliverAppBar actions, agregar antes del botón de mensajes:
Stack(
  children: [
    IconButton(
      icon: const Icon(LucideIcons.bell),
      onPressed: () => context.push('/notifications'),
    ),
    if (unreadCount > 0)
      Positioned(
        right: 8, top: 8,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          child: Text('$unreadCount', style: TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ),
  ],
)
```

2. **Crear pantalla de notificaciones:**
```
lib/features/notifications/
├── application/
│   └── notifications_provider.dart
├── data/
│   └── notifications_repository.dart
└── presentation/
    └── notifications_screen.dart
```

3. **Agregar ruta:**
```dart
GoRoute(
  path: '/notifications',
  name: RouteNames.notifications,
  builder: (context, state) => const NotificationsScreen(),
),
```

4. **Tipos de notificación a manejar:**
   - `message` — Nuevo mensaje de chat
   - `announcement` — Aviso importante de dirección
   - `reminder` — Recordatorio (pago, evento, etc.)
   - `ai_recommendation` — Sugerencia del asistente IA
   - `activity` — Nueva actividad publicada
   - `excuse_status` — Cambio de estado en justificante

5. **Push Notifications (Backend requerido):**
   - Integrar `firebase_messaging` en Flutter
   - Backend: guardar FCM tokens y enviar push vía Firebase Admin SDK
   - Endpoint: `POST /notifications/register-device` con `{ fcmToken, platform }`

---

### 1.3 Chat en Tiempo Real — PRIORIDAD ALTA 🔴

**Archivo:** `lib/core/api/socket_client.dart`, `lib/features/messaging/`

**Diagnóstico:** 
- `SocketClient` existe y se conecta a `ws://.../chat` con Socket.IO.
- Pero `messaging_providers.dart` usa solo `FutureProvider` (fetch único), **no escucha eventos de socket**.
- No hay listener de `newMessage`, `typing`, ni `messageRead`.
- No se implementa polling ni WebSocket real-time en el chat.

**Causa raíz:** El socket client fue creado pero nunca se integró con los providers del chat.

**Solución concreta:**

1. **Crear un StreamProvider para mensajes en tiempo real:**
```dart
// lib/features/messaging/application/realtime_messaging_provider.dart

final chatSocketProvider = Provider<ChatSocketService>((ref) {
  return ChatSocketService();
});

class ChatSocketService {
  io.Socket? _socket;
  final _messageController = StreamController<Message>.broadcast();
  
  Stream<Message> get onNewMessage => _messageController.stream;
  
  Future<void> connect() async {
    _socket = await SocketClient.connect();
    _socket!.on('newMessage', (data) {
      _messageController.add(Message.fromJson(data));
    });
  }
  
  void joinConversation(String conversationId) {
    _socket?.emit('joinRoom', {'conversationId': conversationId});
  }
  
  void sendMessage(String conversationId, String content) {
    _socket?.emit('sendMessage', {
      'conversationId': conversationId,
      'content': content,
    });
  }
}
```

2. **En `ChatScreen`, usar el socket para mensajes en vivo:**
```dart
final realtimeMessagesProvider = StreamProvider.family<Message, String>((ref, convId) {
  final socket = ref.watch(chatSocketProvider);
  socket.joinConversation(convId);
  return socket.onNewMessage.where((m) => m.conversationId == convId);
});
```

3. **Push notifications para mensajes cuando la app no está abierta** — ver punto 1.2.

---

## 2. ROL MAESTRA / MAESTRO

### 2.1 HOME → "Mis Grupos" solo muestra snackbar — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/home/presentation/teacher_home_screen.dart:119-127`

**Diagnóstico:** El `onTap` del grupo ejecuta un `ScaffoldMessenger.showSnackBar` en lugar de navegar. Literalmente tiene `// TODO: Navigate to group detail with children list`.

**Solución concreta:**
```dart
// Reemplazar líneas 119-127 con:
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupDetailScreen(groupId: group.id),
    ),
  );
},
```
**Cambio adicional:** La `GroupDetailScreen` actual es un placeholder vacío (ver punto 2.3). Necesita implementación real.

---

### 2.2 ACTIVIDAD — Botón mal ubicado + actividades no se muestran — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/activity/presentation/activity_screen.dart`

**Diagnóstico:**
1. **Botón "Nueva Actividad"** está como `FloatingActionButton` (línea 44-58) que colisiona con el FAB del AI Assistant en `MainShell` (línea 31). **Dos FABs compitiendo por el mismo espacio.**
2. **Ícono de calendario** (línea 35-41) en el AppBar no hace nada (`onPressed: () {}`).
3. **Tab "Registro de Actividades"** muestra placeholder estático, no datos reales.

**Solución concreta:**

1. **Mover "Nueva Actividad" al AppBar**, reemplazando el ícono de calendario inútil:
```dart
actions: [
  if (isTeacher)
    TextButton.icon(
      icon: const Icon(LucideIcons.plus, size: 18),
      label: const Text('Nueva'),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
      ),
    ),
],
```

2. **Eliminar el `floatingActionButton`** del `ActivityScreen` (ya que `MainShell` tiene el FAB de IA).

3. **Para mostrar actividades creadas**, crear provider que llame al endpoint:
```dart
// GET /daily-logs?groupId=xxx  (para maestra)
// GET /daily-logs?childId=xxx  (para padre)
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.watch(activitiesRepositoryProvider);
  return repo.getActivities();
});
```

4. **En el tab "Registro de Actividades"**, reemplazar el placeholder por un `ListView` real con los datos del provider.

---

### 2.3 GRUPOS → Pantalla vacía "groupDetails" — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/groups/presentation/group_detail_screen.dart`

**Diagnóstico:** La pantalla es un stub con solo un ícono de construcción y texto placeholder. No carga datos reales.

**Solución concreta — Reescribir completamente:**

```dart
class GroupDetailScreen extends ConsumerWidget {
  final String groupId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupByIdProvider(groupId));
    // Necesario: provider para niños del grupo
    final childrenAsync = ref.watch(childrenByGroupProvider(groupId));
    
    return Scaffold(
      appBar: AppBar(title: Text(group.displayName)),
      body: CustomScrollView(
        slivers: [
          // Header con info del grupo
          SliverToBoxAdapter(child: _GroupInfoHeader(group)),
          // Estadísticas: capacidad, edad, maestras
          SliverToBoxAdapter(child: _GroupStats(group)),
          // Lista de alumnos
          SliverToBoxAdapter(child: Text('Alumnos')),
          SliverList(delegate: SliverChildBuilderDelegate(...)),
          // Actividades recientes del grupo
          SliverToBoxAdapter(child: Text('Actividades recientes')),
          // ...
        ],
      ),
    );
  }
}
```

**Backend requerido:**
- `GET /groups/:id` — Ya existe endpoint
- `GET /children?groupId=:id` — Para obtener niños del grupo
- Crear `childrenByGroupProvider`:
```dart
final childrenByGroupProvider = FutureProvider.family<List<Child>, String>((ref, groupId) async {
  final repo = ref.watch(childrenRepositoryProvider);
  return repo.getChildrenByGroup(groupId);
});
```

---

### 2.4 EXCUSES (Justificantes) — Spinner infinito — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/excuses/presentation/excuses_list_screen.dart`

**Diagnóstico:** La pantalla está **bien implementada** con estados vacíos, error handling, y filtros. El spinner infinito sugiere que el **endpoint `GET /excuses` devuelve error o timeout**.

**Causas probables:**
1. El backend devuelve 404 o 500
2. El modelo `excuse_model.dart` no coincide con el JSON del backend
3. No hay datos en la BD y el error handling del provider no llega al estado `data: []`

**Solución concreta:**
1. **Verificar en el backend** que `GET /excuses` responde correctamente (incluso con array vacío)
2. **Revisar `excuses_repository.dart`** — agregar logging y verificar que el parsing no falla:
```dart
try {
  final response = await _client.get(Endpoints.excuses);
  // Verificar que response.data es una lista
  if (response.data is List && (response.data as List).isEmpty) {
    return []; // Retornar lista vacía, no error
  }
  return (response.data as List).map((e) => Excuse.fromJson(e)).toList();
} catch (e) {
  print('❌ EXCUSES ERROR: $e');
  rethrow;
}
```
3. **La pantalla ya maneja estado vacío** (líneas 85-111) correctamente en español. ✅

---

### 2.5 PERFIL → Lista de alumnos sin Avatar Group — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/profile/presentation/profile_screen.dart:65-91`

**Diagnóstico:** Todos los alumnos se muestran en una columna vertical. Con muchos alumnos, ocupa mucho espacio sin ser navegable.

**Solución concreta:**
1. **Si hay >4 alumnos**, mostrar Avatar Group (stack horizontal):
```dart
if (children.length > 4) {
  // Mostrar Avatar Group stack
  return GestureDetector(
    onTap: () => context.push('/students-list'),
    child: Row(
      children: [
        SizedBox(
          width: 40.0 * 4 + 20, // 4 avatars stacked
          height: 48,
          child: Stack(
            children: children.take(4).toList().asMap().entries.map((entry) {
              return Positioned(
                left: entry.key * 30.0,
                child: LBAvatar(
                  placeholder: '${entry.value.firstName[0]}',
                  imageUrl: entry.value.photoUrl,
                  size: LBAvatarSize.small,
                ),
              );
            }).toList(),
          ),
        ),
        Text('+${children.length - 4} más'),
        const Spacer(),
        Icon(LucideIcons.chevronRight),
      ],
    ),
  );
}
```
2. **Crear pantalla de lista completa de alumnos** con buscador y filtros (por grupo, edad).

---

### 2.6 Dark Mode — Mal implementado — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/design_system/theme/app_theme_dark.dart`

**Diagnóstico:**
1. `AppColors` usa colores **estáticos/constantes** que no cambian con el tema. Toda la app referencia `AppColors.textPrimary` (hardcoded `Color(0xFF2C2C2C)` — oscuro sobre oscuro en dark mode).
2. `AppColors.surface` es `#FFFFFF` (blanco) — no funciona en dark mode.
3. `AppThemeDark` define un `colorScheme` y `textTheme` correcto, pero como todos los widgets usan `AppColors.xxxx` directamente, **el tema oscuro no se aplica a los colores de los componentes**.

**Causa raíz:** **Arquitectura de colores incorrecta.** Los colores deben ser contextuales (vía `Theme.of(context)`) no estáticos.

**Solución concreta (requiere refactor):**

1. **Crear colores que respondan al tema:**
```dart
// Opción A: Usar extensiones de tema
extension AppColorsExtension on BuildContext {
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get textPrimary => Theme.of(this).brightness == Brightness.dark 
    ? const Color(0xFFE0E0E0) 
    : const Color(0xFF2C2C2C);
  // etc.
}

// Opción B (más práctica): Crear AppColors como clase que tome Brightness
class AppColors {
  static Color surface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
  // etc.
}
```

2. **Refactorizar progresivamente** reemplazando `AppColors.surface` → `Theme.of(context).colorScheme.surface` en todos los widgets.

3. **Mientras tanto, mejorar `AppThemeDark`** para cubrir más componentes:
```dart
// Agregar a AppThemeDark:
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  backgroundColor: const Color(0xFF1C1C1E),
  selectedItemColor: AppColors.primary,
  unselectedItemColor: const Color(0xFF8E8E93),
),
floatingActionButtonTheme: FloatingActionButtonThemeData(
  backgroundColor: AppColors.primary,
),
```

---

### 2.7 Ajustes (Perfil) — Opciones no funcionales — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/profile/presentation/profile_screen.dart:100-160`

**Diagnóstico:** Los settings rows muestran snackbar "Navigating to..." excepto Billing que sí navega. **Información familiar** y **Recogidas autorizadas** no aplican a maestras.

**Solución concreta:**

1. **Hacer opciones condicionales por rol:**
```dart
// Para MAESTRA, mostrar:
- Tema (ya existe)
- Notificaciones → navegar a config de notificaciones
- Idioma (ya existe)
- Actualizar foto de perfil → ImagePicker + upload

// Para PADRE, mostrar:
- Tema
- Recogidas autorizadas → pantalla real
- Notificaciones
- Facturación → pantalla de pagos
- Idioma

// Para DIRECTOR, mostrar:
- Tema
- Notificaciones
- Gestión de escuela
- Facturación
- Idioma
```

2. **Implementar subida de foto de perfil:**
```dart
// En el avatar del perfil, agregar onTap:
GestureDetector(
  onTap: () async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final url = await ref.read(fileUploadServiceProvider).upload(image.path);
      await ref.read(userRepositoryProvider).updateAvatar(url);
    }
  },
  child: Stack(
    children: [
      LBAvatar(...),
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.camera, size: 16, color: Colors.white),
        ),
      ),
    ],
  ),
)
```

**Backend requerido:**
- `PATCH /auth/me` con `{ avatarUrl }` — para actualizar foto de perfil
- `POST /files/upload` — ya existe

---

## 3. ROL PADRE / MADRE

### 3.1 HOME vacío — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/home/presentation/home_screen.dart:31-144`

**Diagnóstico:** El home de padres depende de `dailyStoryProvider(childId)` que llama a `RemoteHomeRepository.getDailyStory()`. Si el backend no tiene datos para el día, puede mostrar error o vacío.

**Causa probable:** El endpoint de daily story no devuelve datos para el hijo seleccionado, o el backend no tiene logs para hoy.

**Solución concreta:**
1. **Manejar el caso de "sin actividades hoy"** como estado normal, no error:
```dart
// En dailyStoryProvider, si el API devuelve 404 o vacío:
// Retornar un DailyStory con lista de eventos vacía y un mensaje amigable

// En la UI:
if (dailyStory.events.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(LucideIcons.sun, size: 64),
        Text('Aún no hay actividades hoy'),
        Text('Las actividades aparecerán cuando la maestra las publique'),
      ],
    ),
  );
}
```

2. **Agregar sección de resumen rápido:**
   - Asistencia del día (check-in/check-out)
   - Próximos eventos
   - Últimas fotos del hijo

---

### 3.2 MIS HIJOS → GoException: no routes for location — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/children/presentation/children_list_screen.dart:62`

**Diagnóstico:** Al hacer tap navega a `context.push('/children/${child.id}/profile')` pero **NO existe esa ruta en `app_router.dart`**. Solo existe `/children` sin subrutas.

**Causa raíz:** Falta la ruta en el router.

**Solución concreta:**

1. **Agregar ruta en `app_router.dart`:**
```dart
GoRoute(
  path: '/children',
  name: RouteNames.children,
  builder: (context, state) => const ChildrenListScreen(),
  routes: [
    GoRoute(
      path: ':childId/profile',
      name: RouteNames.childProfile,
      builder: (context, state) {
        final childId = state.pathParameters['childId']!;
        return ChildProfileScreen(childId: childId);
      },
    ),
  ],
),
```

2. **Agregar `childProfile` a `RouteNames`:**
```dart
static const String childProfile = 'childProfile';
```

3. **Conectar `ChildProfileScreen` con datos reales** — actualmente usa datos hardcodeados. Crear provider:
```dart
final childProfileProvider = FutureProvider.family<Child, String>((ref, childId) async {
  final repo = ref.watch(childrenRepositoryProvider);
  return repo.getChildById(childId);
});
```

---

### 3.3 CHAT — Solo permite hablar con profesora — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/messaging/presentation/conversations_screen.dart`

**Diagnóstico:** El chat agrupa conversaciones por "teacher" (el otro participante). No hay opción de iniciar chat con dirección.

**Solución concreta:**
1. **Backend:** Crear endpoint `POST /chat/conversations` que permita iniciar conversación con director:
```json
{ "participantId": "director-user-id", "type": "parent_director" }
```

2. **UI:** Agregar botón "Nuevo Chat" en `ConversationsScreen`:
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () => _showNewChatDialog(context),
  child: Icon(LucideIcons.messagePlus),
),
```

3. **En el diálogo**, mostrar opciones: "Chat con maestra de [nombre del hijo]" + "Chat con dirección".

---

### 3.4 PERFIL → Hijos no navegan — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/profile/presentation/profile_screen.dart:72-86`

**Diagnóstico:** Los hijos en perfil se muestran como `_buildChildRow` que es un `Row` sin `GestureDetector` ni `InkWell`. No son clickeables.

**Solución:**
```dart
// Envolver cada child row con GestureDetector:
GestureDetector(
  onTap: () => context.push('/children/${child.id}/profile'),
  child: _buildChildRow(...),
)
```

---

### 3.5 Recogidas autorizadas — Nueva funcionalidad — PRIORIDAD MEDIA 🟡

**Diagnóstico:** El modelo `AuthorizedPickup` ya existe en `child_model.dart` con `id, name, relation, photoUrl, phone`. Falta `identification` y `securityNotes`.

**Solución:**
1. **Extender modelo:**
```dart
const factory AuthorizedPickup({
  required String id,
  required String name,
  required String relation,
  required String? photoUrl,
  required String phone,
  String? identification,    // NUEVO
  String? securityNotes,     // NUEVO
}) = _AuthorizedPickup;
```

2. **Crear pantalla de gestión:**
```
lib/features/authorized_pickups/
├── presentation/
│   ├── pickups_list_screen.dart
│   └── add_pickup_screen.dart  (formulario con foto, nombre, tel, ID, relación, notas)
```

3. **Backend requerido:**
- `GET /children/:id/authorized-pickups`
- `POST /children/:id/authorized-pickups`
- `PUT /children/:id/authorized-pickups/:pickupId`
- `DELETE /children/:id/authorized-pickups/:pickupId`

---

### 3.6 FACTURACIÓN — Datos hardcodeados — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/features/payments/presentation/payments_screen.dart`

**Diagnóstico:** Toda la pantalla usa datos estáticos hardcodeados (balance: $450, tarjeta Mastercard ****4242, transacciones mock). No se conecta al backend.

**Solución:**
1. **Conectar con el provider real** (existe `payments_providers.dart`):
```dart
final paymentsAsync = ref.watch(paymentsProvider);
```

2. **Backend requerido para padres:**
- `GET /payments?childId=xxx` — historial de pagos
- `GET /payments/balance` — balance actual

3. **Para director** (punto 4.4), endpoint diferente:
- `GET /payments/school-summary` — ingresos/egresos totales

---

### 3.7 TIENDA — Funcionalidad nueva — PRIORIDAD BAJA 🟢

**Diagnóstico:** No existe nada. Es feature completamente nuevo.

**Solución (alto nivel):**
1. **Backend:** Crear módulo completo de tienda:
   - Tabla `products`: id, name, description, price, category, imageUrl, stock
   - Tabla `orders`: id, parentId, status, total, createdAt
   - Tabla `order_items`: orderId, productId, quantity, price
   - Endpoints: `GET /store/products`, `POST /store/orders`, `GET /store/orders`

2. **Mobile:** Crear feature:
```
lib/features/store/
├── domain/
│   ├── product_model.dart
│   └── order_model.dart
├── data/
│   └── store_repository.dart
├── application/
│   └── store_providers.dart
└── presentation/
    ├── store_screen.dart
    ├── product_detail_screen.dart
    └── cart_screen.dart
```

3. **Agregar a la navegación del padre** un ícono de tienda o acceso desde perfil.

**Recomendación:** Implementar en fase posterior. No es bloqueante para MVP.

---

## 4. ROL DIRECTOR / DIRECTORA

### 4.1 HOME muestra lo mismo que maestra — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/home/presentation/home_screen.dart:27`

**Diagnóstico:** Línea 27: `if (authState.isTeacher || authState.isDirector || authState.isAdmin)` → todos van a `TeacherHomeScreen`. **Director ve exactamente lo mismo que una maestra.**

**Solución concreta:**

1. **Crear `DirectorHomeScreen`:**
```dart
// lib/features/home/presentation/director_home_screen.dart
class DirectorHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header con bienvenida
          // Dashboard cards:
          //   - Total alumnos activos
          //   - Total maestras
          //   - Asistencia del día (%)
          //   - Pagos pendientes
          // Gráfica de asistencia semanal
          // Grupos con su ocupación
          // Actividad reciente (últimas actividades registradas)
          // Alertas (pagos vencidos, justificantes pendientes)
        ],
      ),
    );
  }
}
```

2. **Modificar `HomeScreen`:**
```dart
if (authState.isDirector || authState.isAdmin) {
  return const DirectorHomeScreen();
}
if (authState.isTeacher) {
  return const TeacherHomeScreen();
}
```

3. **Backend requerido:**
- `GET /dashboard/director` — resumen general:
```json
{
  "totalStudents": 45,
  "totalTeachers": 8,
  "todayAttendance": { "present": 38, "absent": 7, "percentage": 84.4 },
  "pendingPayments": 12,
  "pendingExcuses": 3,
  "recentActivities": [...]
}
```

---

### 4.2 REPORTES no funcionan — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/reports/presentation/reports_screen.dart`

**Diagnóstico:** Todos los 4 tipos de reporte muestran snackbar "Feature Coming Soon". No hay implementación real.

**Solución concreta:**

1. **Reporte de Asistencia:**
```dart
// Endpoint: GET /reports/attendance?from=&to=&groupId=
// Mostrar: tabla con nombre del alumno, días asistidos, faltas, justificadas
// Formato: vista en app + opción de exportar PDF
```

2. **Reporte de Actividades:**
```dart
// Endpoint: GET /reports/activities?from=&to=&groupId=
// Mostrar: lista de actividades con fotos, grupo, fecha, maestra
```

3. **Reporte de Pagos:**
```dart
// Endpoint: GET /reports/payments?from=&to=
// Mostrar: ingresos totales, desglose por concepto, morosos
```

4. **Reporte de Inscripción:**
```dart
// Endpoint: GET /reports/enrollment
// Mostrar: total inscritos, por grupo, capacidad vs ocupación
```

5. **Crear pantalla de detalle de reporte** con filtros de fecha, grupo, y opción de exportar.

---

### 4.3 PERFIL muestra "Hijos" — PRIORIDAD ALTA 🔴

**Archivo:** `lib/features/profile/presentation/profile_screen.dart:58-61`

**Diagnóstico:** Línea 59-61:
```dart
user?.role.value == 'teacher'
    ? tr.tr('my_students')
    : tr.tr('children'),
```
Solo diferencia entre teacher y "otros". Director cae en `children` (hijos).

**Solución:**
```dart
user?.role.value == 'teacher'
    ? tr.tr('my_students')
    : user?.role.value == 'director' || user?.role.value == 'admin'
        ? 'Alumnos y Maestros'
        : tr.tr('children'),
```

Y para el director, en lugar de mostrar niños de `myChildrenProvider`, mostrar:
- **Sección "Maestros"** con lista de maestros
- **Sección "Alumnos"** con total de alumnos por grupo

**Eliminar** del perfil de director:
- Información familiar
- Recogidas autorizadas

---

### 4.4 FACTURACIÓN (Director) — Vista diferente — PRIORIDAD MEDIA 🟡

**Diagnóstico:** El director necesita ver finanzas de la escuela, no pagos personales.

**Solución:**
1. **Crear `SchoolFinancesScreen`** para el director:
   - Ingresos del mes (colegiaturas cobradas)
   - Egresos (nómina, servicios, materiales)
   - Balance
   - Gráfica de ingresos/egresos últimos 6 meses
   - Lista de padres morosos

2. **Backend requerido:**
- `GET /payments/school-finances?from=&to=`
- Tablas necesarias: `expenses` (egresos), `income_categories`

---

### 4.5 Gestión desde app — PRIORIDAD MEDIA 🟡

**Diagnóstico:** El director no puede crear/editar/eliminar alumnos ni maestros desde la app.

**Solución:**
1. **Crear módulo de gestión:**
```
lib/features/management/
├── presentation/
│   ├── manage_students_screen.dart  (CRUD alumnos)
│   ├── manage_teachers_screen.dart  (CRUD maestros)
│   ├── add_student_screen.dart
│   ├── add_teacher_screen.dart
│   └── edit_user_screen.dart
```

2. **Backend requerido:**
- `POST /children` — crear alumno
- `PUT /children/:id` — editar alumno
- `DELETE /children/:id` — eliminar alumno
- `POST /users` — crear maestro (con rol teacher)
- `PUT /users/:id` — editar maestro
- `DELETE /users/:id` — eliminar/desactivar maestro
- `GET /users?role=teacher` — listar maestros

---

## 5. NOTAS GENERALES

### 5.1 Grupos con nombres genéricos — PRIORIDAD MEDIA 🟡

**Archivo:** `lib/shared/models/group_model.dart`

**Diagnóstico:** El modelo `Group` del shared no tiene `friendlyName`, pero el modelo en `features/groups/domain/group_model.dart` tiene `GroupModel` con `friendlyName`, `displayName`, etc.

**Hay dos modelos Group diferentes:**
- `lib/shared/models/group_model.dart` → Freezed, basico (sin friendlyName)
- `lib/features/groups/domain/group_model.dart` → Manual, más completo

**Solución:** Unificar en un solo modelo con todos los campos:
```dart
@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String tenantId,
    required String name,           // "Lactantes" (nivel)
    String? friendlyName,           // "Abejitas" (nombre personalizado)
    required int ageRangeMin,
    required int ageRangeMax,
    required int capacity,
    int? currentCapacity,
    required String color,
    required String academicYear,
    String? teacherId,
    String? teacherName,
    List<String>? teacherNames,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Group;
  
  const Group._();
  
  String get displayName => friendlyName ?? name;
  String get ageRange => '$ageRangeMin-$ageRangeMax meses';
}
```

---

### 5.2 Fotos de perfil — Todos los roles — PRIORIDAD MEDIA 🟡

**Diagnóstico:** `UserInfo` ya tiene `avatarUrl` pero no hay forma de actualizarla desde la app.

**Solución:** Ver punto 2.7 (implementar upload de foto en perfil).

---

## 6. PROBLEMAS NO MENCIONADOS DETECTADOS 🔍

### 6.1 Duplicación de modelos

- **`Group`** existe en 2 lugares con campos diferentes
- **`AppColors`** existe en `core/theme/` y `design_system/theme/` — potencial confusión

### 6.2 Sin manejo de conexión offline

No hay manejo de estado offline. Si el usuario pierde conexión, no hay feedback.
**Recomendación:** Agregar `connectivity_plus` y un banner de "Sin conexión".

### 6.3 Sin caché de datos

Todos los providers son `FutureProvider` que re-fetch en cada cambio de pantalla. No hay caché local.
**Recomendación:** Usar `Hive` o `drift` para caché offline de datos críticos.

### 6.4 Inconsistencia de idioma

Algunos textos están en español hardcodeado, otros usan `tr.tr()`. Ejemplo:
- `excuses_list_screen.dart` — mezcla español hardcodeado y i18n
- `activity_screen.dart` — mezcla inglés y español
- `conversations_screen.dart` — inglés hardcodeado ("No Messages Yet")
**Recomendación:** Estandarizar TODO a español vía i18n.

### 6.5 `ChildProfileScreen` usa datos hardcodeados

**Archivo:** `lib/features/child_profile/presentation/child_profile_screen.dart`
Toda la pantalla muestra datos estáticos ("Nombre del Niño", "3 años", "Dr. García", etc.).
**Solución:** Conectar con `childProfileProvider` y mostrar datos reales.

### 6.6 Sin splash screen animada

El splash es simple. Para nivel profesional, usar animación Lottie con el logo.

### 6.7 Falta manejo de sesión expirada

Si el token expira mientras el usuario usa la app, no hay redirect a login ni refresh automático visible.

---

## 7. PRIORIZACIÓN DE IMPLEMENTACIÓN

### Sprint 1 — Bugs Críticos (1-2 semanas)
| # | Tarea | Impacto | Esfuerzo |
|---|-------|---------|----------|
| 1 | Fix ruta `/children/:id/profile` (GoException) | 🔴 Alto | ⚡ Bajo |
| 2 | Fix HOME maestra → navegar a grupo (no snackbar) | 🔴 Alto | ⚡ Bajo |
| 3 | Fix HOME director → crear DirectorHomeScreen | 🔴 Alto | 🔧 Medio |
| 4 | Fix PERFIL director muestra "Hijos" | 🔴 Alto | ⚡ Bajo |
| 5 | Fix EXCUSES spinner → manejar estado vacío | 🔴 Alto | ⚡ Bajo |
| 6 | Fix ACTIVIDAD → mover botón, eliminar calendar inútil | 🔴 Alto | ⚡ Bajo |

### Sprint 2 — Funcionalidad Core (2-3 semanas)
| # | Tarea | Impacto | Esfuerzo |
|---|-------|---------|----------|
| 7 | Implementar GroupDetailScreen real | 🔴 Alto | 🔧 Medio |
| 8 | Conectar ChildProfileScreen con datos reales | 🔴 Alto | 🔧 Medio |
| 9 | Implementar chat en tiempo real (WebSocket) | 🔴 Alto | 🔧 Alto |
| 10 | Implementar pantalla de notificaciones | 🔴 Alto | 🔧 Medio |
| 11 | Restaurar chatbot IA | 🟡 Medio | 🔧 Alto |

### Sprint 3 — Mejoras UX/UI (1-2 semanas)
| # | Tarea | Impacto | Esfuerzo |
|---|-------|---------|----------|
| 12 | Refactor Dark Mode (colores contextuales) | 🟡 Medio | 🔧 Alto |
| 13 | Estandarizar idioma español | 🟡 Medio | 🔧 Bajo |
| 14 | Avatar Group para alumnos en perfil | 🟡 Medio | ⚡ Bajo |
| 15 | Upload foto de perfil | 🟡 Medio | 🔧 Medio |
| 16 | Perfil condicional por rol | 🟡 Medio | 🔧 Medio |

### Sprint 4 — Features Nuevos (3-4 semanas)
| # | Tarea | Impacto | Esfuerzo |
|---|-------|---------|----------|
| 17 | Reportes funcionales (director) | 🟡 Medio | 🔧 Alto |
| 18 | Facturación real (padre + director) | 🟡 Medio | 🔧 Alto |
| 19 | Recogidas autorizadas CRUD | 🟡 Medio | 🔧 Medio |
| 20 | Gestión director (CRUD alumnos/maestros) | 🟡 Medio | 🔧 Alto |
| 21 | Chat padre → dirección | 🟡 Medio | 🔧 Medio |
| 22 | Configuración de notificaciones | 🟢 Bajo | 🔧 Medio |
| 23 | Tienda | 🟢 Bajo | 🔧 Muy Alto |

---

## 8. ENDPOINTS BACKEND NECESARIOS (RESUMEN)

```
# Ya existen (verificar funcionamiento):
GET    /groups
GET    /groups/:id
GET    /children
GET    /children/:id
GET    /excuses
GET    /chat/conversations
GET    /notifications
POST   /files/upload

# Nuevos necesarios:
POST   /ai/chat                         → Chat IA con Groq/Llama3
GET    /dashboard/director              → Dashboard resumen escuela
GET    /reports/attendance              → Reporte asistencia
GET    /reports/activities              → Reporte actividades
GET    /reports/payments                → Reporte pagos
GET    /reports/enrollment              → Reporte inscripción
GET    /children?groupId=:id            → Niños por grupo
PATCH  /auth/me                         → Actualizar perfil (avatar)
POST   /notifications/register-device   → Registrar FCM token
PUT    /notifications/settings          → Config notificaciones
GET    /payments/school-finances        → Finanzas para director
GET    /users?role=teacher              → Listar maestros
POST   /users                           → Crear maestro
PUT    /users/:id                       → Editar usuario
DELETE /users/:id                       → Eliminar usuario
POST   /chat/conversations              → Iniciar conversación
GET    /children/:id/authorized-pickups
POST   /children/:id/authorized-pickups
PUT    /children/:id/authorized-pickups/:pid
DELETE /children/:id/authorized-pickups/:pid
```

---

## 9. ESTRUCTURA DE ARCHIVOS A CREAR

```
lib/features/
├── ai_assistant/
│   ├── application/ai_provider.dart          ← NUEVO
│   ├── data/ai_repository.dart               ← NUEVO
│   └── domain/ai_message.dart                ← NUEVO
├── notifications/
│   ├── application/notifications_provider.dart ← NUEVO
│   ├── data/notifications_repository.dart      ← NUEVO
│   └── presentation/notifications_screen.dart  ← NUEVO
├── home/
│   └── presentation/director_home_screen.dart  ← NUEVO
├── management/
│   └── presentation/
│       ├── manage_students_screen.dart         ← NUEVO
│       ├── manage_teachers_screen.dart         ← NUEVO
│       ├── add_student_screen.dart             ← NUEVO
│       └── add_teacher_screen.dart             ← NUEVO
├── authorized_pickups/
│   └── presentation/
│       ├── pickups_list_screen.dart            ← NUEVO
│       └── add_pickup_screen.dart              ← NUEVO
└── store/  (Fase posterior)
    ├── domain/
    ├── data/
    ├── application/
    └── presentation/

# Archivos a MODIFICAR:
lib/routing/app_router.dart              → agregar rutas faltantes
lib/routing/route_names.dart             → agregar nombres de ruta
lib/features/home/presentation/home_screen.dart → separar director
lib/features/profile/presentation/profile_screen.dart → condicionar por rol
lib/features/groups/presentation/group_detail_screen.dart → implementar real
lib/features/child_profile/presentation/child_profile_screen.dart → datos reales
lib/features/activity/presentation/activity_screen.dart → fix botón
lib/design_system/theme/app_theme_dark.dart → mejorar dark mode
lib/shared/models/child_model.dart → extender AuthorizedPickup
```
