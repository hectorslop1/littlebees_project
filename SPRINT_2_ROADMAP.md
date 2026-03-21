# Sprint 2 - Roadmap y Recomendaciones
## LittleBees Mobile App - Funcionalidad Core

**Fecha:** 20 de marzo, 2026  
**Sprint anterior:** Sprint 1 ✅ Completado  
**Estado:** Planificación

---

## 🎯 Objetivos de Sprint 2

Construir sobre la base sólida de Sprint 1 para agregar funcionalidad core que convierta la app en una herramienta completa y útil para padres, maestras y directores.

---

## 📋 Tareas Propuestas

### 🔴 Alta Prioridad - Features Core

#### 1. Chat en Tiempo Real con Socket.IO
**Estimación:** 5 días  
**Complejidad:** Alta

**Descripción:**
Implementar sistema de mensajería en tiempo real usando Socket.IO para comunicación entre padres y maestras.

**Tareas técnicas:**
- [ ] Integrar `SocketClient` existente con providers de Riverpod
- [ ] Crear `ChatProvider` con estado reactivo
- [ ] Implementar UI de chat con burbujas de mensajes
- [ ] Agregar indicadores de "escribiendo..."
- [ ] Implementar notificaciones push para mensajes nuevos
- [ ] Manejar reconexión automática
- [ ] Agregar persistencia local de mensajes (SQLite)

**Archivos a modificar:**
- `lib/core/api/socket_client.dart`
- `lib/features/messaging/application/messaging_providers.dart`
- `lib/features/messaging/presentation/chat_screen.dart`

**Backend requerido:**
- Socket.IO server configurado
- Eventos: `message:send`, `message:receive`, `typing:start`, `typing:stop`
- Autenticación via JWT en handshake

---

#### 2. AI Chatbot Assistant
**Estimación:** 4 días  
**Complejidad:** Media-Alta

**Descripción:**
Restaurar y mejorar el asistente de IA para responder preguntas de padres y maestras.

**Tareas técnicas:**
- [ ] Integrar API de Groq/Llama 3 (según plan técnico)
- [ ] Crear `AIChatProvider` con historial de conversación
- [ ] Implementar UI de chat con el bot
- [ ] Agregar contexto específico por rol (padre/maestra/director)
- [ ] Implementar sugerencias rápidas
- [ ] Agregar límite de rate para prevenir abuso
- [ ] Persistir historial de conversaciones

**Archivos a crear:**
- `lib/features/ai_assistant/application/ai_chat_provider.dart`
- `lib/features/ai_assistant/data/ai_repository.dart`
- `lib/features/ai_assistant/presentation/ai_chat_screen.dart`

**Archivos a modificar:**
- `lib/features/ai_assistant/presentation/ai_assistant_fab.dart`

**Backend requerido:**
- Endpoint: `POST /api/ai/chat`
- Integración con Groq API
- Context injection basado en rol del usuario

---

#### 3. Upload de Fotos de Actividades
**Estimación:** 3 días  
**Complejidad:** Media

**Descripción:**
Permitir a maestras subir fotos de actividades diarias con descripción.

**Tareas técnicas:**
- [ ] Implementar selector de imágenes (camera + galería)
- [ ] Agregar compresión de imágenes antes de upload
- [ ] Crear formulario de nueva actividad con fotos
- [ ] Implementar upload a cloud storage (S3/Cloudinary)
- [ ] Agregar progress indicator durante upload
- [ ] Permitir múltiples fotos por actividad
- [ ] Agregar tags y descripción

**Archivos a crear:**
- `lib/features/activity/presentation/new_activity_screen.dart`
- `lib/features/activity/application/activity_upload_provider.dart`

**Paquetes a agregar:**
```yaml
dependencies:
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  http_parser: ^4.0.2
```

**Backend requerido:**
- Endpoint: `POST /api/activities`
- Upload de archivos multipart/form-data
- Integración con cloud storage

---

#### 4. Sistema de Reportes
**Estimación:** 4 días  
**Complejidad:** Media

**Descripción:**
Implementar generación y visualización de reportes para directores y maestras.

**Tareas técnicas:**
- [ ] Crear pantallas de reportes individuales
- [ ] Implementar gráficas con `fl_chart`
- [ ] Agregar filtros por fecha, grupo, niño
- [ ] Permitir exportar a PDF
- [ ] Implementar caché de reportes
- [ ] Agregar indicadores de tendencias

**Tipos de reportes:**
1. **Asistencia:** Gráfica de asistencia por día/semana/mes
2. **Actividades:** Resumen de actividades por grupo
3. **Pagos:** Estado de pagos y morosidad
4. **Inscripciones:** Estadísticas de inscripciones

**Archivos a crear:**
- `lib/features/reports/presentation/attendance_report_screen.dart`
- `lib/features/reports/presentation/activities_report_screen.dart`
- `lib/features/reports/presentation/payments_report_screen.dart`
- `lib/features/reports/presentation/enrollment_report_screen.dart`

**Paquetes a agregar:**
```yaml
dependencies:
  fl_chart: ^0.66.0
  pdf: ^3.10.7
  printing: ^5.12.0
```

---

### 🟡 Prioridad Media - UX Improvements

#### 5. Notificaciones Push
**Estimación:** 3 días  
**Complejidad:** Media

**Tareas técnicas:**
- [ ] Integrar Firebase Cloud Messaging
- [ ] Implementar manejo de notificaciones en foreground/background
- [ ] Agregar deep linking desde notificaciones
- [ ] Crear preferencias de notificaciones por tipo
- [ ] Implementar badge count en ícono de app
- [ ] Agregar sonidos personalizados

**Paquetes a agregar:**
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
```

---

#### 6. Gestión de Recogidas Autorizadas
**Estimación:** 2 días  
**Complejidad:** Baja

**Tareas técnicas:**
- [ ] Crear pantalla de lista de personas autorizadas
- [ ] Implementar formulario para agregar/editar persona
- [ ] Agregar validación de datos (teléfono, ID)
- [ ] Permitir subir foto de identificación
- [ ] Implementar eliminación con confirmación
- [ ] Agregar búsqueda y filtros

**Archivos a crear:**
- `lib/features/authorized_pickups/presentation/pickups_list_screen.dart`
- `lib/features/authorized_pickups/presentation/pickup_form_screen.dart`
- `lib/features/authorized_pickups/application/pickups_provider.dart`

---

#### 7. Calendario de Eventos
**Estimación:** 3 días  
**Complejidad:** Media

**Tareas técnicas:**
- [ ] Implementar vista de calendario mensual
- [ ] Mostrar eventos, cumpleaños, días festivos
- [ ] Permitir agregar eventos (solo maestras/director)
- [ ] Agregar recordatorios
- [ ] Sincronizar con calendario del dispositivo
- [ ] Implementar vista de agenda

**Paquetes a agregar:**
```yaml
dependencies:
  table_calendar: ^3.0.9
  add_2_calendar: ^3.0.1
```

---

### 🟢 Prioridad Baja - Nice to Have

#### 8. Modo Offline
**Estimación:** 4 días  
**Complejidad:** Alta

**Tareas técnicas:**
- [ ] Implementar SQLite para caché local
- [ ] Agregar sincronización automática
- [ ] Manejar conflictos de datos
- [ ] Mostrar indicador de estado de conexión
- [ ] Implementar queue de acciones pendientes

**Paquetes a agregar:**
```yaml
dependencies:
  sqflite: ^2.3.0
  connectivity_plus: ^5.0.2
```

---

#### 9. Onboarding y Tutorial
**Estimación:** 2 días  
**Complejidad:** Baja

**Tareas técnicas:**
- [ ] Crear pantallas de onboarding
- [ ] Implementar tutorial interactivo
- [ ] Agregar tooltips contextuales
- [ ] Guardar estado de tutorial completado

**Paquetes a agregar:**
```yaml
dependencies:
  introduction_screen: ^3.1.12
  showcaseview: ^2.0.3
```

---

#### 10. Búsqueda Global
**Estimación:** 2 días  
**Complejidad:** Baja

**Tareas técnicas:**
- [ ] Implementar barra de búsqueda global
- [ ] Buscar en: niños, grupos, actividades, mensajes
- [ ] Agregar historial de búsquedas
- [ ] Implementar sugerencias mientras escribe

---

## 📊 Estimación Total

| Prioridad | Tareas | Días estimados |
|-----------|--------|----------------|
| Alta      | 4      | 16 días        |
| Media     | 3      | 8 días         |
| Baja      | 3      | 8 días         |
| **Total** | **10** | **32 días**    |

**Sprint 2 recomendado:** 3 semanas (15 días hábiles)  
**Scope:** Tareas de alta prioridad + 2 tareas de prioridad media

---

## 🏗️ Arquitectura Recomendada

### State Management
Continuar con **Riverpod** para consistencia:
```dart
// Ejemplo de provider para chat
final chatMessagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, conversationId) {
    final socket = ref.watch(socketClientProvider);
    return socket.messagesStream(conversationId);
  },
);
```

### Navegación
Continuar con **GoRouter** para deep linking:
```dart
// Ejemplo de ruta para chat
GoRoute(
  path: '/chat/:conversationId',
  name: RouteNames.chat,
  builder: (context, state) => ChatScreen(
    conversationId: state.pathParameters['conversationId']!,
  ),
),
```

### Persistencia Local
Usar **Hive** o **SQLite** según necesidad:
- **Hive:** Para settings, preferencias, caché simple
- **SQLite:** Para datos relacionales complejos, modo offline

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// Ejemplo de test para AI chat
test('AI chat provider sends message correctly', () async {
  final container = ProviderContainer();
  final provider = container.read(aiChatProvider.notifier);
  
  await provider.sendMessage('Hola');
  
  final messages = container.read(aiChatProvider);
  expect(messages.length, 1);
  expect(messages.first.content, 'Hola');
});
```

### Widget Tests
```dart
// Ejemplo de test para chat screen
testWidgets('Chat screen displays messages', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: ChatScreen(conversationId: '123')),
    ),
  );
  
  expect(find.byType(MessageBubble), findsWidgets);
});
```

### Integration Tests
- Flujo completo de envío de mensaje
- Upload de foto de actividad
- Generación de reporte

---

## 📦 Nuevas Dependencias Recomendadas

```yaml
dependencies:
  # Chat y tiempo real
  socket_io_client: ^2.0.3
  
  # AI
  http: ^1.1.2
  
  # Imágenes
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.1
  
  # Gráficas y reportes
  fl_chart: ^0.66.0
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # Notificaciones
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # Calendario
  table_calendar: ^3.0.9
  add_2_calendar: ^3.0.1
  
  # Persistencia
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  
  # Utilidades
  connectivity_plus: ^5.0.2
  share_plus: ^7.2.1
  url_launcher: ^6.2.3

dev_dependencies:
  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

---

## 🚨 Riesgos y Mitigaciones

### Riesgo 1: Socket.IO desconexiones frecuentes
**Mitigación:**
- Implementar reconexión automática con backoff exponencial
- Caché local de mensajes
- Indicador visual de estado de conexión

### Riesgo 2: Upload de imágenes lento
**Mitigación:**
- Compresión agresiva de imágenes
- Upload en background
- Progress indicator detallado
- Permitir cancelar upload

### Riesgo 3: AI API rate limits
**Mitigación:**
- Implementar rate limiting en cliente
- Caché de respuestas comunes
- Mensajes de error amigables
- Fallback a respuestas predefinidas

### Riesgo 4: Complejidad de modo offline
**Mitigación:**
- Empezar con caché simple de lectura
- Implementar sincronización incremental
- Priorizar datos críticos
- Considerar mover a Sprint 3 si es muy complejo

---

## 📈 Métricas de Éxito

### Técnicas
- [ ] 0 crashes en producción
- [ ] < 2s tiempo de carga de pantallas
- [ ] > 95% success rate en API calls
- [ ] < 100ms latencia en mensajes de chat

### UX
- [ ] > 80% de usuarios completan onboarding
- [ ] > 70% de maestras usan upload de fotos semanalmente
- [ ] > 60% de padres usan chat regularmente
- [ ] < 5% tasa de abandono en formularios

### Negocio
- [ ] 100% de funcionalidad core implementada
- [ ] 0 bugs críticos reportados
- [ ] Feedback positivo de usuarios beta

---

## 🎓 Aprendizajes de Sprint 1

### Lo que funcionó bien ✅
- Separación clara por roles
- Uso de Riverpod para state management
- GoRouter para navegación type-safe
- Documentación detallada

### Áreas de mejora 🔄
- Agregar más tests unitarios
- Implementar CI/CD pipeline
- Mejorar manejo de errores
- Agregar logging estructurado

### Para Sprint 2 📝
- Escribir tests antes de implementar features
- Hacer code reviews más frecuentes
- Documentar decisiones arquitectónicas
- Mantener changelog actualizado

---

## 📅 Timeline Propuesto

### Semana 1 (Días 1-5)
- **Días 1-3:** Chat en tiempo real
- **Días 4-5:** AI Chatbot (inicio)

### Semana 2 (Días 6-10)
- **Días 6-7:** AI Chatbot (finalización)
- **Días 8-10:** Upload de fotos

### Semana 3 (Días 11-15)
- **Días 11-14:** Sistema de reportes
- **Día 15:** Testing, fixes, documentación

---

## 🎯 Definición de "Done"

Una tarea se considera completa cuando:
- [ ] Código implementado y funcional
- [ ] Tests unitarios escritos y pasando
- [ ] UI/UX revisado y aprobado
- [ ] Integración con backend verificada
- [ ] Documentación actualizada
- [ ] Code review completado
- [ ] Sin bugs críticos conocidos
- [ ] Probado en iOS y Android

---

## 🚀 Próximos Pasos Inmediatos

1. **Reunión de planning** con equipo de desarrollo
2. **Grooming de tareas** con product owner
3. **Coordinación con backend** para endpoints necesarios
4. **Setup de ambiente** para testing de Socket.IO
5. **Inicio de Sprint 2** 🎉

---

## 📞 Stakeholders

- **Product Owner:** [Nombre]
- **Mobile Lead:** [Nombre]
- **Backend Lead:** [Nombre]
- **UX Designer:** [Nombre]
- **QA Lead:** [Nombre]

---

**Preparado por:** Mobile Development Team  
**Fecha:** 20 de marzo, 2026  
**Versión:** 1.0
