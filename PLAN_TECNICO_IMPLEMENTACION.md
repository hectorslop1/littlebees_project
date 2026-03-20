# Plan Técnico de Implementación — LittleBees

> Documento generado a partir del análisis profundo de `littlebees-system-guide.md` vs. el código actual del proyecto.
> Fecha: 2026-03-13
> Objetivo: Alinear el sistema completo con la guía oficial de arquitectura funcional.

---

## Resumen del Análisis

### Estado actual del sistema

| Componente | Estado |
|---|---|
| **Backend API** (NestJS) | 20 módulos implementados: auth, users, tenants, groups, children, attendance, daily-logs, development, exercises, chat, payments, invoicing, notifications, reports, announcements, services, files, audit, health, prisma |
| **Base de datos** (Prisma/PostgreSQL) | Esquema completo con 22 modelos, 1 migración aplicada, seed funcional |
| **App Web** (Next.js) | 11 páginas: dashboard, children, attendance, logs, development, chat, payments, services, reports, settings, profile |
| **App Móvil** (Flutter) | 7 features: auth, home, activity, messaging, calendar, payments, profile, splash |

### Roles definidos actualmente

- `super_admin`, `director`, `admin`, `teacher`, `parent` — correctamente alineados con la guía (excepto `super_admin` que es adicional al sistema y está bien como rol técnico).

---

## Inconsistencias Detectadas

### 1. Menús y navegación

#### App Web — Sidebar actual vs. Guía

| Item actual | Maestra | Directora | Admin | Requerido por guía |
|---|---|---|---|---|
| Dashboard | ✅ | ✅ | ✅ | ✅ |
| Niños (children) | ✅ todos | ✅ | ✅ | ✅ — Pero Maestra debería ver "Mis Grupos" y "Alumnos" separados |
| Asistencia | ✅ todos | — | — | ❌ No está en menú de guía para ningún rol web (es funcionalidad dentro de Actividades/Grupos) |
| Bitácora (logs) | ✅ todos | — | — | ❌ En la guía se llama "Actividades" para Maestra |
| Desarrollo | ✅ todos | — | — | ❌ No aparece como menú independiente en la guía |
| Mensajes | ✅ todos | ✅ | — | ✅ — Pero Admin no debería tener Mensajes según guía |
| Pagos | ✅ (filtrado) | ✅ | ✅ | ✅ Directora y Admin |
| Servicios | ✅ (filtrado) | — | — | ❌ No aparece en la guía |
| Reportes | ✅ (filtrado) | ✅ | ✅ | ✅ |
| **Usuarios** | ❌ FALTA | — | — | ✅ Admin necesita "Usuarios" |
| **Grupos** | ❌ FALTA en menú | ✅ | ✅ | ✅ Directora y Admin necesitan "Grupos" en menú |
| **Maestras** | ❌ FALTA | ✅ | — | ✅ Directora necesita "Maestras" |
| **Personalización** | ❌ FALTA | — | ✅ | ✅ Solo Admin |
| **Configuración** | ✅ (todos) | ✅ | ✅ | ✅ Directora; Admin usa "Configuración" + "Personalización" separados |
| **Asistente IA** | ❌ FALTA | ✅ | ✅ | ✅ Todos los roles web |
| **Perfil** | ✅ | ✅ | ✅ | ✅ Solo Maestra según guía, pero es razonable para todos |

#### App Móvil — Bottom Navigation actual vs. Guía

**Menú actual (único para todos):** Home, Activity, Messages, Calendar, Profile

**Guía — Menú Padre:**
| Item guía | Implementado | Notas |
|---|---|---|
| Inicio | ✅ | Home screen |
| Día | ❌ FALTA | Pantalla dedicada a la planeación del día |
| Calendario | ✅ | Calendar screen |
| Mensajes | ✅ | Conversations screen |
| Pagos | ✅ | Payments screen (pero no está en bottom nav) |
| Perfil del Niño | ❌ FALTA | Pantalla dedicada con info médica, alergias, etc. |
| Justificantes | ❌ FALTA | Sistema completo inexistente |
| Asistente IA | ❌ FALTA | No implementado |

**Guía — Menú Maestra:**
| Item guía | Implementado | Notas |
|---|---|---|
| Inicio | ✅ | Pero muestra vista de Padre, no de Maestra |
| Grupos | ❌ FALTA | Lista de grupos asignados |
| Día | ❌ FALTA | Programación del día por grupo |
| Registrar Actividad | ❌ PARCIAL | Activity screen existe pero no tiene acciones rápidas de registro |
| Mensajes | ✅ | |
| Perfil de Alumno | ❌ FALTA | Vista rápida de info del niño |
| Asistente IA | ❌ FALTA | No implementado |

### 2. Diferenciación por rol en la app móvil

**CRÍTICO:** La app móvil actual no diferencia entre Padre y Maestra. Usa un único flujo centrado en el Padre (selección de hijo, daily story). No existe:
- Vista de Maestra con sus grupos
- Registro de actividades por la Maestra (entrada, comida, siesta, salida)
- Fotos de entrada/salida

### 3. Funcionalidades faltantes completas

| Funcionalidad | Backend | Web | Móvil |
|---|---|---|---|
| **Justificantes** | ❌ | ❌ | ❌ |
| **Asistente IA (Groq/Llama 3)** | ❌ | ❌ | ❌ |
| **Personalización del sistema** | ❌ | ❌ | N/A |
| **Gestión de usuarios (CRUD)** | ❌ (solo GET) | ❌ | N/A |
| **Vista Maestra en móvil** | ❌ | N/A | ❌ |
| **Registro rápido de actividades** | ❌ | ❌ | ❌ |
| **Fotos entrada/salida** | ❌ | ❌ | ❌ |
| **Aviso fuera de horario (chat)** | ❌ | ❌ | ❌ |
| **Escalar conversación a dirección** | ❌ | ❌ | ❌ |
| **Menú dinámico por rol (web)** | ❌ PARCIAL | ❌ PARCIAL | ❌ |

### 4. Campos faltantes en base de datos

| Modelo | Campo/Tabla faltante | Descripción |
|---|---|---|
| `Tenant` | `primary_color`, `secondary_color`, `custom_menu_labels` | Personalización visual |
| N/A | Tabla `Excuse` (justificantes) | Sistema de justificantes completo |
| N/A | Tabla `AiChatSession` + `AiChatMessage` | Historial del asistente IA |
| N/A | Tabla `TenantCustomization` | Personalización avanzada del tenant |
| `Conversation` | campo `escalated_to_direction` | Para escalar a dirección |
| `Conversation` | campo `type` (parent-teacher, escalated) | Tipo de conversación |
| `AttendanceRecord` | `check_in_photo_url`, `check_out_photo_url` | Fotos de entrada/salida |
| `Child` | `diagnosis` | Campo de diagnóstico mencionado en la guía |
| `ChildMedicalInfo` | `medical_notes` | Notas médicas adicionales |
| `Tenant` | `business_hours_start`, `business_hours_end` | Para aviso fuera de horario en chat |
| N/A | Tabla `DayScheduleTemplate` | Plantilla de programación del día |
| N/A | Tabla `DayScheduleEntry` | Programación del día real |

---

## Fases de Implementación

---

## Fase 1 — Sistema de Roles, Permisos y Menús Dinámicos

### Objetivo
Alinear la estructura de roles y permisos con la guía. Implementar menús dinámicos por rol tanto en web como en móvil.

### Cambios en Backend

1. **Crear endpoint `GET /api/menu`** que retorne la configuración de menú según el rol del usuario autenticado.
   - Archivo: `apps/api/src/modules/menu/menu.controller.ts` (nuevo módulo)
   - Archivo: `apps/api/src/modules/menu/menu.service.ts`
   - El servicio debe retornar un array de items de menú filtrados por rol.

2. **Ampliar `UsersController`** con CRUD completo:
   - `POST /users` — Crear usuario (solo Admin/Director)
   - `PATCH /users/:id` — Actualizar usuario
   - `DELETE /users/:id` — Desactivar usuario (soft delete)
   - `PATCH /users/:id/role` — Cambiar rol
   - Archivo: `apps/api/src/modules/users/users.controller.ts`
   - Archivo: `apps/api/src/modules/users/users.service.ts`

3. **Agregar guards de rol** en todos los controllers existentes que no los tienen:
   - `daily-logs.controller.ts` — agregar `RolesGuard`
   - `chat.controller.ts` — agregar filtrado por rol
   - `attendance.controller.ts` — agregar `RolesGuard`

### Cambios en Base de Datos

No se requieren cambios de schema en esta fase. Los roles ya están correctamente definidos en el enum `UserRole`.

### Seed data adicional

Ninguno en esta fase.

### Cambios en Frontend Web

1. **Refactorizar `sidebar.tsx`** para usar configuración de menú por rol según la guía:

   ```
   Maestra: Dashboard, Mis Grupos, Alumnos, Actividades, Reportes, Mensajes, Asistente IA, Perfil
   Directora: Dashboard, Grupos, Alumnos, Maestras, Reportes, Pagos, Mensajes, Configuración, Asistente IA
   Admin: Dashboard, Usuarios, Grupos, Alumnos, Pagos, Reportes, Configuración, Personalización, Asistente IA
   ```

2. **Crear nuevas páginas web**:
   - `/users` — Gestión de usuarios (Admin)
   - `/teachers` — Vista de maestras (Directora)
   - `/customization` — Personalización (Admin)

3. **Renombrar/reorganizar páginas existentes**:
   - `/logs` → `/activities` (para Maestra)
   - Agregar `/groups` como página independiente en el menú

### Cambios en App Móvil

1. **Implementar detección de rol** en `main_shell.dart` para mostrar bottom navigation diferente según rol:
   - Si `role == parent`: tabs de Padre
   - Si `role == teacher`: tabs de Maestra

2. **Crear configuración de tabs por rol** en un archivo dedicado `lib/routing/role_navigation.dart`.

### Dependencias
- Ninguna. Esta es la fase base.

---

## Fase 2 — Gestión de Alumnos y Perfiles Completos

### Objetivo
Completar el perfil del niño según la guía: nombre, edad, foto, alergias, tipo de sangre, contactos de emergencia, diagnóstico, notas médicas.

### Cambios en Backend

1. **Actualizar `ChildrenController`** para exponer endpoint de perfil completo:
   - `GET /children/:id/profile` — Retorna child + medical info + emergency contacts + parent info unificado.

2. **Agregar endpoint para que Padres vean el perfil de su hijo**:
   - Validar que el parent solo acceda a sus propios hijos (`ChildParent` relation).

### Cambios en Base de Datos

1. **Migración: agregar campo `diagnosis` a `Child`**:
   ```sql
   ALTER TABLE children ADD COLUMN diagnosis TEXT;
   ```

2. **Migración: agregar campo `medical_notes` a `child_medical_info`**:
   ```sql
   ALTER TABLE child_medical_info ADD COLUMN medical_notes TEXT;
   ```

3. **Actualizar Prisma schema**:
   ```prisma
   model Child {
     // ... campos existentes
     diagnosis String?  // Diagnóstico (si aplica)
   }
   
   model ChildMedicalInfo {
     // ... campos existentes
     medicalNotes String? @map("medical_notes")  // Notas médicas
   }
   ```

### Cambios en Frontend Web

1. **Mejorar `child-detail-dialog.tsx`** para mostrar todos los campos de la guía.
2. **Agregar sección de diagnóstico y notas médicas** al formulario de edición de niño.
3. **Implementar regla de privacidad**: info médica solo visible para maestras y dirección (no para padres en web).

### Cambios en App Móvil

1. **Crear pantalla `ChildProfileScreen`** en `lib/features/child_profile/`:
   - Foto del niño
   - Nombre y edad
   - Alergias (resaltadas)
   - Tipo de sangre
   - Contactos de emergencia
   - Diagnóstico (si aplica)
   - Notas médicas
   
2. **Agregar ruta** `/child-profile/:childId` en `app_router.dart`.

3. **Para Maestra**: Mostrar "Perfil de Alumno" como item de navegación o accesible desde la lista de alumnos.

### Seed Data

- Actualizar `seed.ts` para incluir `diagnosis` y `medical_notes` en algunos niños de ejemplo.

### Dependencias
- Fase 1 (sistema de roles para controlar quién ve qué info)

---

## Fase 3 — Registro de Actividades del Día (Maestra)

### Objetivo
Implementar el sistema de registro rápido de actividades para Maestras: entrada, comida, siesta, actividad, salida. Incluir fotos de entrada y salida.

### Cambios en Backend

1. **Crear endpoint `POST /daily-logs/quick-register`**:
   - Tipos: `check_in`, `meal`, `nap`, `activity`, `check_out`
   - Acepta `childId`, `type`, `metadata` (incluye foto URL para check_in/check_out)
   - Crea simultáneamente el `DailyLogEntry` y actualiza `AttendanceRecord` si aplica.

2. **Crear endpoint `GET /daily-logs/day-schedule/:groupId`**:
   - Retorna la programación/estado del día para un grupo completo.
   - Muestra qué niños tienen check-in, comida, siesta, etc.

3. **Crear endpoint `POST /attendance/bulk-check-in`**:
   - Check-in masivo para un grupo completo.

4. **Actualizar endpoint de attendance** para aceptar foto URLs.

### Cambios en Base de Datos

1. **Migración: agregar campos de foto a `attendance_records`**:
   ```sql
   ALTER TABLE attendance_records ADD COLUMN check_in_photo_url TEXT;
   ALTER TABLE attendance_records ADD COLUMN check_out_photo_url TEXT;
   ```

2. **Crear tabla `day_schedule_templates`** (plantillas de programación del día):
   ```prisma
   model DayScheduleTemplate {
     id          String   @id @default(uuid()) @db.Uuid
     tenantId    String   @map("tenant_id") @db.Uuid
     name        String   @db.VarChar(100)
     items       Json     // Array de { time, type, label }
     isDefault   Boolean  @default(false) @map("is_default")
     createdAt   DateTime @default(now()) @map("created_at")
     
     tenant Tenant @relation(fields: [tenantId], references: [id])
     @@map("day_schedule_templates")
   }
   ```

3. **Actualizar Prisma schema** con los nuevos campos.

### Seed Data

- Crear plantilla de programación del día por defecto:
  ```
  07:30 - Entrada
  09:00 - Actividad educativa
  10:00 - Recreo
  11:00 - Comida
  12:00 - Siesta
  14:00 - Actividad
  16:00 - Salida
  ```

### Cambios en Frontend Web

1. **Crear/refactorizar página `/activities`** (renombrar desde `/logs`):
   - Vista de timeline del día por grupo
   - Botones rápidos de registro
   - Indicadores visuales de estado por niño

2. **Agregar componente de foto** para entrada/salida.

### Cambios en App Móvil

1. **Crear feature `register_activity/`** con pantallas:
   - `QuickRegisterScreen` — Acciones rápidas (Entrada, Comida, Siesta, Actividad, Salida)
   - `RegisterEntryScreen` — Formulario con cámara para foto
   - `RegisterMealScreen` — Formulario de comida
   - `RegisterNapScreen` — Formulario de siesta
   - `RegisterActivityScreen` — Formulario de actividad genérica

2. **Crear feature `groups/`** para Maestra:
   - `GroupsScreen` — Lista de grupos asignados
   - `GroupDetailScreen` — Detalle de grupo con lista de alumnos

3. **Crear pantalla `DayScreen`** (`lib/features/day/`):
   - Para **Padre**: ver planeación del día de su hijo (timeline de eventos)
   - Para **Maestra**: ver programación del día del grupo

### Dependencias
- Fase 1 (diferenciación de rol en móvil)
- Fase 2 (perfiles de alumnos)

---

## Fase 4 — Sistema de Justificantes

### Objetivo
Implementar el sistema de justificantes para que padres puedan enviar avisos de ausencia, llegada tarde, enfermedad, etc.

### Cambios en Backend

1. **Crear módulo `excuses/`**:
   - `ExcusesController`
   - `ExcusesService`
   - `ExcusesModule`

2. **Endpoints**:
   - `POST /excuses` — Padre crea justificante
   - `GET /excuses` — Listar justificantes (filtrado por rol: padre ve los suyos, maestra ve los de su grupo, director/admin ve todos)
   - `GET /excuses/:id` — Detalle
   - `PATCH /excuses/:id/status` — Maestra/Director acepta o rechaza
   - `GET /excuses/child/:childId` — Justificantes de un niño

### Cambios en Base de Datos

1. **Crear tabla `excuses`**:
   ```prisma
   model Excuse {
     id          String       @id @default(uuid()) @db.Uuid
     tenantId    String       @map("tenant_id") @db.Uuid
     childId     String       @map("child_id") @db.Uuid
     parentId    String       @map("parent_id") @db.Uuid
     type        ExcuseType
     title       String       @db.VarChar(255)
     description String?
     date        DateTime     @db.Date
     attachments String[]     @default([])
     status      ExcuseStatus @default(pending)
     reviewedBy  String?      @map("reviewed_by") @db.Uuid
     reviewedAt  DateTime?    @map("reviewed_at")
     createdAt   DateTime     @default(now()) @map("created_at")
     updatedAt   DateTime     @updatedAt @map("updated_at")
     
     tenant Tenant @relation(fields: [tenantId], references: [id])
     child  Child  @relation(fields: [childId], references: [id])
     
     @@index([tenantId, childId])
     @@index([tenantId, date])
     @@map("excuses")
   }
   
   enum ExcuseType {
     sick          // El niño está enfermo
     late_arrival  // Llegará tarde
     absence       // No asistirá hoy
     other         // Otro motivo
   }
   
   enum ExcuseStatus {
     pending
     approved
     rejected
   }
   ```

2. **Agregar relación** en `Child` y `Tenant`:
   ```prisma
   model Child {
     // ... existente
     excuses Excuse[]
   }
   ```

### Seed Data

- Crear 2-3 justificantes de ejemplo en el seed.

### Cambios en Frontend Web

1. No es necesaria una página dedicada. Los justificantes se muestran en el detalle del niño y en la vista de asistencia.
2. Agregar **banner/badge** en la vista de asistencia cuando un niño tiene justificante para el día.

### Cambios en App Móvil

1. **Crear feature `excuses/`**:
   - `ExcusesScreen` — Lista de justificantes enviados
   - `CreateExcuseScreen` — Formulario con:
     - Tipo (enfermedad, llegada tarde, ausencia, otro)
     - Descripción
     - Opción de adjuntar foto/nota
     - Fecha

2. **Agregar ruta** `/excuses` en `app_router.dart`.
3. **Agregar al bottom navigation del Padre**.

### Dependencias
- Fase 1 (roles)
- Fase 2 (perfiles de alumnos — relación con Child)

---

## Fase 5 — Sistema de Mensajería Mejorado

### Objetivo
Mejorar el chat existente con: aviso fuera de horario, opción de escalar a dirección, chat separado por clase.

### Cambios en Backend

1. **Agregar middleware de horario** en `ChatService`:
   - Al enviar un mensaje, verificar si es dentro del horario laboral del tenant (`settings.businessHours`).
   - Si está fuera de horario, agregar flag `outsideBusinessHours: true` a la respuesta.

2. **Crear endpoint `POST /chat/conversations/:id/escalate`**:
   - Agrega al Director como participante de la conversación.
   - Envía notificación al Director.
   - Marca la conversación como escalada.

3. **Agregar filtrado de conversaciones por clase/grupo**:
   - `GET /chat/conversations?groupId=xxx` — Filtrar conversaciones por grupo.

### Cambios en Base de Datos

1. **Migración: agregar campos a `conversations`**:
   ```sql
   ALTER TABLE conversations ADD COLUMN type VARCHAR(20) DEFAULT 'parent_teacher';
   ALTER TABLE conversations ADD COLUMN escalated BOOLEAN DEFAULT false;
   ALTER TABLE conversations ADD COLUMN escalated_at TIMESTAMP;
   ALTER TABLE conversations ADD COLUMN group_id UUID REFERENCES groups(id);
   ```

2. **Actualizar Prisma schema**:
   ```prisma
   model Conversation {
     // ... existente
     type        String    @default("parent_teacher") @db.VarChar(20)
     escalated   Boolean   @default(false)
     escalatedAt DateTime? @map("escalated_at")
     groupId     String?   @map("group_id") @db.Uuid
     
     group Group? @relation(fields: [groupId], references: [id])
   }
   ```

### Cambios en Frontend Web

1. **Mejorar página `/chat`**:
   - Agregar filtro por grupo para Maestra.
   - Mostrar badge de "Escalada" en conversaciones escaladas.
   - Para Directora: mostrar sección de "Conversaciones escaladas".

### Cambios en App Móvil

1. **Actualizar `ConversationsScreen`**:
   - Para Maestra: agrupar conversaciones por grupo/clase.
   - Agregar botón "Escalar a dirección" en la pantalla de chat.

2. **Agregar aviso visual** cuando se envía mensaje fuera de horario:
   - Banner: "Estás enviando un mensaje fuera del horario escolar. Es posible que no recibas respuesta inmediata."

### Dependencias
- Fase 1 (roles)

---

## Fase 6 — Integración de Asistente IA (Groq / Llama 3 8B)

### Objetivo
Implementar el chatbot de IA como asistente educativo y administrativo, disponible en ambas apps con botón flotante y acciones rápidas.

### Cambios en Backend

1. **Crear módulo `ai-assistant/`**:
   - `AiAssistantController`
   - `AiAssistantService`
   - `AiAssistantModule`

2. **Endpoints**:
   - `POST /ai/chat` — Enviar mensaje al asistente y recibir respuesta
     - Body: `{ message: string, sessionId?: string, quickAction?: string }`
     - El servicio construye el prompt basado en el rol del usuario.
   - `GET /ai/sessions` — Historial de sesiones del usuario
   - `GET /ai/sessions/:id/messages` — Mensajes de una sesión
   - `GET /ai/quick-actions` — Obtener acciones rápidas según rol
   - `DELETE /ai/sessions/:id` — Eliminar sesión

3. **Servicio de IA** (`ai-assistant.service.ts`):
   ```typescript
   // Integración con Groq API
   // - URL: https://api.groq.com/openai/v1/chat/completions
   // - Model: llama3-8b-8192
   // - System prompt personalizado por rol:
   //   PADRE: experto en desarrollo infantil, consejos para padres
   //   MAESTRA: experto en pedagogía, planeación de clases
   //   DIRECTORA: experto en gestión educativa, comunicados
   //   ADMIN: asistente administrativo general
   ```

4. **Variables de entorno necesarias**:
   - `GROQ_API_KEY`
   - `GROQ_MODEL=llama3-8b-8192`

### Cambios en Base de Datos

1. **Crear tablas para historial de IA**:
   ```prisma
   model AiChatSession {
     id        String   @id @default(uuid()) @db.Uuid
     tenantId  String   @map("tenant_id") @db.Uuid
     userId    String   @map("user_id") @db.Uuid
     title     String?  @db.VarChar(255)
     createdAt DateTime @default(now()) @map("created_at")
     updatedAt DateTime @updatedAt @map("updated_at")
     
     messages AiChatMessage[]
     
     @@index([userId])
     @@map("ai_chat_sessions")
   }
   
   model AiChatMessage {
     id        String   @id @default(uuid()) @db.Uuid
     sessionId String   @map("session_id") @db.Uuid
     role      String   @db.VarChar(20) // 'user' | 'assistant'
     content   String
     metadata  Json     @default("{}")
     createdAt DateTime @default(now()) @map("created_at")
     
     session AiChatSession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
     
     @@index([sessionId, createdAt])
     @@map("ai_chat_messages")
   }
   ```

### Seed Data

- No se requiere seed data para IA.

### Configuración de Acciones Rápidas por Rol

```json
{
  "parent": [
    { "id": "educational_activities", "label": "Actividades educativas", "prompt": "Sugiere actividades educativas para hacer en casa con mi hijo" },
    { "id": "parenting_tips", "label": "Consejos para padres", "prompt": "Dame consejos sobre desarrollo infantil" },
    { "id": "home_activities", "label": "Actividades para el hogar", "prompt": "Sugiere juegos y actividades divertidas para hacer en casa" },
    { "id": "ask_question", "label": "Preguntar algo", "prompt": "" }
  ],
  "teacher": [
    { "id": "activity_ideas", "label": "Ideas de actividades", "prompt": "Sugiere actividades educativas para mi clase" },
    { "id": "plan_class", "label": "Planear clase", "prompt": "Ayúdame a planear una clase" },
    { "id": "behavior_management", "label": "Manejo de comportamiento", "prompt": "Dame estrategias para manejar comportamiento en el aula" },
    { "id": "create_report", "label": "Crear reporte", "prompt": "Ayúdame a crear un reporte del día para los padres" },
    { "id": "ask_question", "label": "Preguntar algo", "prompt": "" }
  ],
  "director": [
    { "id": "write_announcement", "label": "Redactar comunicado", "prompt": "Ayúdame a redactar un comunicado para padres" },
    { "id": "educational_recommendations", "label": "Recomendaciones educativas", "prompt": "Dame recomendaciones para mejorar procesos educativos" },
    { "id": "ask_question", "label": "Preguntar algo", "prompt": "" }
  ],
  "admin": [
    { "id": "write_notice", "label": "Redactar aviso", "prompt": "Ayúdame a redactar un aviso general" },
    { "id": "admin_support", "label": "Apoyo administrativo", "prompt": "Necesito apoyo con una tarea administrativa" },
    { "id": "ask_question", "label": "Preguntar algo", "prompt": "" }
  ]
}
```

### Reglas del Modelo de IA

El system prompt debe incluir:
1. Responder de forma clara y corta.
2. Adaptarse al rol del usuario.
3. Evitar respuestas médicas o diagnósticos profesionales.
4. Enfocarse en educación infantil y apoyo pedagógico.
5. Contexto: el sistema es para guarderías y kinders en México.

### Cambios en Frontend Web

1. **Crear componente `AiAssistantButton`** (botón flotante):
   - Posición: esquina inferior derecha
   - Icono: sparkle/bot
   - Al hacer clic: abre panel lateral o modal de chat

2. **Crear componente `AiChatPanel`**:
   - Sección superior: acciones rápidas (botones)
   - Sección inferior: campo de texto libre + historial de mensajes
   - Streaming de respuesta (si Groq lo soporta)

3. **Agregar `AiAssistantButton` al layout del dashboard** (`(dashboard)/layout.tsx`).

4. **Crear página `/ai-assistant`** como opción de menú.

### Cambios en App Móvil

1. **Crear feature `ai_assistant/`**:
   - `AiAssistantScreen` — Pantalla de chat con IA
   - `AiQuickActionsWidget` — Grid de acciones rápidas
   - `AiChatBubble` — Widget de mensaje individual
   - `AiFloatingButton` — Botón flotante para acceso rápido

2. **Agregar botón flotante** en `MainShell` (sobre el bottom navigation).

3. **Agregar ruta** `/ai-assistant` en `app_router.dart`.

### Dependencias
- Fase 1 (roles — para determinar system prompt y acciones rápidas)

---

## Fase 7 — Personalización del Sistema

### Objetivo
Permitir al Administrador personalizar el aspecto visual del sistema: logo, colores, nombres de menú, branding.

### Cambios en Backend

1. **Crear módulo `customization/`**:
   - `CustomizationController`
   - `CustomizationService`
   - `CustomizationModule`

2. **Endpoints**:
   - `GET /customization` — Obtener configuración actual
   - `PATCH /customization` — Actualizar (solo Admin)
   - `POST /customization/logo` — Subir nuevo logo
   - `POST /customization/reset` — Resetear a valores por defecto

### Cambios en Base de Datos

1. **Crear tabla `tenant_customizations`**:
   ```prisma
   model TenantCustomization {
     id               String   @id @default(uuid()) @db.Uuid
     tenantId         String   @unique @map("tenant_id") @db.Uuid
     logoUrl          String?  @map("logo_url")
     primaryColor     String   @default("#F5A623") @map("primary_color") @db.VarChar(7)
     secondaryColor   String   @default("#4ECDC4") @map("secondary_color") @db.VarChar(7)
     accentColor      String?  @map("accent_color") @db.VarChar(7)
     systemName       String   @default("LittleBees") @map("system_name") @db.VarChar(100)
     menuLabels       Json     @default("{}") @map("menu_labels") // { "dashboard": "Inicio", ... }
     customCss        String?  @map("custom_css")
     createdAt        DateTime @default(now()) @map("created_at")
     updatedAt        DateTime @updatedAt @map("updated_at")
     
     tenant Tenant @relation(fields: [tenantId], references: [id])
     
     @@map("tenant_customizations")
   }
   ```

2. **Agregar relación en `Tenant`**:
   ```prisma
   model Tenant {
     // ... existente
     customization TenantCustomization?
   }
   ```

### Seed Data

- Crear customización por defecto para el tenant de demo:
  ```json
  {
    "primaryColor": "#F5A623",
    "secondaryColor": "#4ECDC4",
    "systemName": "Petit Soleil"
  }
  ```

### Cambios en Frontend Web

1. **Crear página `/customization`**:
   - Formulario con:
     - Subir logo
     - Selector de color primario
     - Selector de color secundario
     - Nombre del sistema
     - Renombrar items de menú
   - Preview en tiempo real

2. **Implementar ThemeProvider dinámico**:
   - Al cargar la app, obtener customización del tenant.
   - Aplicar colores dinámicamente a CSS variables.
   - Cambiar logo dinámicamente.

3. **Actualizar `Sidebar`** para usar nombres de menú personalizados.

### Cambios en App Móvil

- La app móvil debe cargar los colores del tema del tenant al iniciar sesión.
- Actualizar `AppColors` para soportar colores dinámicos desde el tenant.

### Dependencias
- Fase 1 (roles — solo Admin puede personalizar)

---

## Fase 8 — Programación del Día y Calendario

### Objetivo
Implementar la vista "Día" tanto para Padres (ver actividades de su hijo) como para Maestras (ver programación del grupo).

### Cambios en Backend

1. **Crear endpoint `GET /day-schedule/:childId`** (para Padres):
   - Retorna la programación del día del niño combinando:
     - Plantilla de horario
     - Entradas de bitácora reales del día
     - Estado de asistencia

2. **Crear endpoint `GET /day-schedule/group/:groupId`** (para Maestras):
   - Retorna el estado general del grupo:
     - Niños presentes/ausentes
     - Actividades registradas
     - Progreso del día

3. **Crear endpoint para gestionar plantillas**:
   - `GET /day-schedule/templates`
   - `POST /day-schedule/templates`
   - `PATCH /day-schedule/templates/:id`

### Cambios en Base de Datos

- Ya incluida en Fase 3 (`DayScheduleTemplate`).

### Cambios en Frontend Web

- La vista del día ya está parcialmente cubierta por `/logs`. Mejorar para mostrar como timeline visual.

### Cambios en App Móvil

1. **Crear feature `day/`**:
   - `DayScreen` — Timeline visual del día:
     - Para Padre: muestra Entrada → Actividad educativa → Recreo → Comida → Siesta → Actividad → Salida
     - Cada evento con hora, estado (completado/pendiente), y detalle
   - Para Maestra: vista de grupo con progreso general

2. **Agregar ruta** `/day` en `app_router.dart`.
3. **Incluir en bottom navigation del Padre** (reemplaza "Activity" actual).

### Dependencias
- Fase 1 (diferenciación de rol)
- Fase 3 (registro de actividades)

---

## Fase 9 — Reportes y Supervisión

### Objetivo
Completar el sistema de reportes para todos los roles web, incluyendo reportes globales para Directora y financieros para Admin.

### Cambios en Backend

1. **Ampliar `ReportsController`** con nuevos endpoints:
   - `GET /reports/global-attendance` — Asistencia global (Directora/Admin)
   - `GET /reports/teacher-performance` — Rendimiento por maestra (Directora)
   - `GET /reports/financial-summary` — Resumen financiero (Admin)
   - `GET /reports/child/:id/progress` — Progreso individual de un niño

2. Los reportes deben ser exportables a PDF (futura mejora).

### Cambios en Base de Datos

- No se requieren cambios de schema. Los datos ya existen para generar reportes.

### Cambios en Frontend Web

1. **Mejorar página `/reports`**:
   - Tab "Asistencia" (existente)
   - Tab "Desarrollo" (existente)
   - Tab "Pagos" (existente)
   - Tab "Maestras" (nuevo — solo Directora)
   - Tab "Financiero" (nuevo — solo Admin)

### Cambios en App Móvil

- No aplica en esta fase. Reportes solo en web.

### Dependencias
- Fase 1 (roles)

---

## Fase 10 — Optimización y Experiencia de Usuario

### Objetivo
Pulir la experiencia general, agregar push notifications, mejorar rendimiento y completar flujos de UX.

### Cambios en Backend

1. **Implementar push notifications** con Firebase Cloud Messaging:
   - Registrar device tokens
   - Enviar push al recibir mensaje de chat
   - Enviar push al registrar entrada/salida del niño
   - Enviar push al crear justificante

2. **Agregar campo `device_token`** al modelo User o crear tabla `user_devices`:
   ```prisma
   model UserDevice {
     id          String   @id @default(uuid()) @db.Uuid
     userId      String   @map("user_id") @db.Uuid
     deviceToken String   @map("device_token")
     platform    String   @db.VarChar(10) // ios, android, web
     createdAt   DateTime @default(now()) @map("created_at")
     updatedAt   DateTime @updatedAt @map("updated_at")
     
     @@unique([userId, deviceToken])
     @@map("user_devices")
   }
   ```

### Cambios en Frontend Web

1. **Mejorar responsive design** para uso en tablet.
2. **Agregar indicadores de carga** (skeleton screens ya implementados parcialmente).
3. **Agregar búsqueda global** en la top bar.

### Cambios en App Móvil

1. **Integrar push notifications** con `firebase_messaging`.
2. **Mejorar estados vacíos** y mensajes de error.
3. **Agregar onboarding flow** para nuevos usuarios.
4. **Implementar pull-to-refresh** en todas las pantallas.
5. **Agregar caché offline** para datos esenciales.

### Dependencias
- Todas las fases anteriores.

---

## Resumen de Migraciones de Base de Datos

| # | Migración | Fase |
|---|---|---|
| 1 | Agregar `diagnosis` a `children` | Fase 2 |
| 2 | Agregar `medical_notes` a `child_medical_info` | Fase 2 |
| 3 | Agregar `check_in_photo_url` y `check_out_photo_url` a `attendance_records` | Fase 3 |
| 4 | Crear tabla `day_schedule_templates` | Fase 3 |
| 5 | Crear tabla `excuses` + enums `ExcuseType`, `ExcuseStatus` | Fase 4 |
| 6 | Agregar `type`, `escalated`, `escalated_at`, `group_id` a `conversations` | Fase 5 |
| 7 | Crear tablas `ai_chat_sessions` y `ai_chat_messages` | Fase 6 |
| 8 | Crear tabla `tenant_customizations` | Fase 7 |
| 9 | Crear tabla `user_devices` | Fase 10 |

---

## Resumen de Nuevos Módulos de API

| Módulo | Fase | Descripción |
|---|---|---|
| `menu` | 1 | Configuración de menú por rol |
| `excuses` | 4 | Sistema de justificantes |
| `ai-assistant` | 6 | Asistente IA con Groq/Llama 3 |
| `customization` | 7 | Personalización del sistema |
| `day-schedule` | 8 | Programación del día |

---

## Resumen de Nuevas Páginas Web

| Ruta | Fase | Acceso |
|---|---|---|
| `/users` | 1 | Admin |
| `/teachers` | 1 | Directora |
| `/customization` | 7 | Admin |
| `/ai-assistant` | 6 | Todos |
| `/groups` (como menú) | 1 | Directora, Admin |
| `/activities` (renombrar) | 3 | Maestra |

---

## Resumen de Nuevas Features Móvil

| Feature | Fase | Acceso |
|---|---|---|
| `child_profile/` | 2 | Padre, Maestra |
| `register_activity/` | 3 | Maestra |
| `groups/` | 3 | Maestra |
| `day/` | 8 | Padre, Maestra |
| `excuses/` | 4 | Padre |
| `ai_assistant/` | 6 | Todos |

---

## Variables de Entorno Nuevas

| Variable | Fase | Descripción |
|---|---|---|
| `GROQ_API_KEY` | 6 | API key para Groq |
| `GROQ_MODEL` | 6 | Modelo a usar (default: `llama3-8b-8192`) |

---

## Orden de Ejecución Recomendado

```
Fase 1 → Fase 2 → Fase 3 → Fase 4 (puede ir en paralelo con 3)
                               ↓
Fase 5 → Fase 6 → Fase 7 (puede ir en paralelo con 6)
                     ↓
              Fase 8 → Fase 9 → Fase 10
```

