# Análisis de Conexión Base de Datos - Little Bees

**Fecha:** 11 de Marzo, 2026  
**Estado:** En Progreso

## Resumen Ejecutivo

Este documento detalla el análisis completo de la base de datos PostgreSQL y la aplicación web, identificando qué datos necesita cada pantalla y cómo conectarlos correctamente.

---

## 1. Estructura de Base de Datos Analizada

### Tablas Principales (20 tablas)

#### **Gestión de Tenants y Usuarios**
- `tenants` - Guarderías (multi-tenant)
- `users` - Usuarios del sistema
- `user_tenants` - Relación usuarios-guarderías con roles
- `refresh_tokens` - Tokens de autenticación

#### **Niños y Grupos**
- `groups` - Grupos/Salones (Lactantes, Maternal, Preescolar)
- `children` - Niños registrados
- `child_medical_info` - Información médica (alergias, medicamentos, doctor)
- `emergency_contacts` - Contactos de emergencia
- `child_parents` - Relación niños-padres

#### **Asistencia y Bitácora**
- `attendance_records` - Registros de entrada/salida
- `daily_log_entries` - Bitácora diaria (comidas, siestas, actividades)

#### **Desarrollo**
- `development_milestones` - Catálogo de hitos de desarrollo (global)
- `development_records` - Evaluaciones de desarrollo por niño

#### **Comunicación**
- `conversations` - Conversaciones de chat
- `conversation_participants` - Participantes en conversaciones
- `messages` - Mensajes

#### **Pagos y Facturación**
- `payments` - Pagos y colegiaturas
- `invoices` - Facturas CFDI

#### **Servicios y Otros**
- `extra_services` - Servicios adicionales (clases, talleres)
- `notifications` - Notificaciones
- `audit_logs` - Auditoría
- `files` - Archivos y documentos

---

## 2. Páginas de la Aplicación Web y Sus Datos

### **Dashboard (`/`)**
**Datos necesarios:**
- Estadísticas de asistencia (total niños, presentes hoy, ausentes)
- Estadísticas de desarrollo (promedio de progreso)
- Estadísticas de pagos (pendientes, vencidos, cobrado este mes)
- Gráfica de asistencia últimos 7 días
- Gráfica de desarrollo por categoría

**Fuente de datos:**
- `attendance_records` - Asistencia del día y últimos 7 días
- `development_records` + `development_milestones` - Progreso de desarrollo
- `payments` - Estado de pagos
- `children` - Total de niños activos

**Estado actual:** ✅ Conectado a API real

---

### **Niños (`/children`)**
**Datos necesarios:**
- Lista de todos los niños con foto, nombre, edad, grupo
- Filtros por grupo y búsqueda por nombre
- Detalle completo del niño (info médica, padres, contactos de emergencia)

**Fuente de datos:**
- `children` (firstName, lastName, dateOfBirth, photoUrl, groupId, status)
- `groups` (name, color)
- `child_medical_info` (allergies, conditions, medications, bloodType)
- `emergency_contacts` (name, relationship, phone, priority)
- `child_parents` + `users` (padres del niño)

**Estado actual:** ✅ Conectado a API real
**Faltante:** 
- ❌ Endpoint PATCH `/children/:id` para actualizar niño
- ❌ Endpoint POST `/children/:id/medical-info` para crear/actualizar info médica
- ❌ Endpoint POST `/children/:id/emergency-contacts` para agregar contactos
- ❌ Endpoint para subir foto del niño

---

### **Asistencia (`/attendance`)**
**Datos necesarios:**
- Lista de niños con su estado de asistencia del día seleccionado
- Hora de entrada y salida
- Estadísticas del día (presentes, ausentes, tarde, excusados)
- Acciones: registrar entrada, registrar salida

**Fuente de datos:**
- `attendance_records` filtrado por `date` y `tenantId`
- Incluye relación con `children` para mostrar nombre y foto

**Estado actual:** ✅ Conectado a API real
**Funcionalidad:** ✅ Check-in y check-out funcionando

---

### **Bitácora (`/logs`)**
**Datos necesarios:**
- Entradas de bitácora del día seleccionado
- Filtros por niño y tipo (comida, siesta, actividad, baño, etc.)
- Agrupadas por hora
- Formulario para agregar nueva entrada

**Fuente de datos:**
- `daily_log_entries` filtrado por `date`, `childId` (opcional), `type` (opcional)
- Incluye relación con `children`

**Estado actual:** ✅ Conectado a API real
**Faltante:**
- ❌ Endpoint para actualizar entrada existente
- ❌ Endpoint para eliminar entrada

---

### **Desarrollo (`/development`)**
**Datos necesarios:**
- Selector de niño
- Resumen de progreso por categoría (Motriz Fina, Motriz Gruesa, Cognitivo, Lenguaje, Social, Emocional)
- Lista de hitos evaluados con estado (logrado, en progreso, no logrado)
- Formulario para agregar evaluación

**Fuente de datos:**
- `children` - Lista de niños
- `development_records` - Evaluaciones del niño seleccionado
- `development_milestones` - Catálogo de hitos disponibles
- Resumen calculado por categoría

**Estado actual:** ✅ Conectado a API real
**Faltante:**
- ❌ Endpoint PATCH `/development/records/:id` para actualizar evaluación

---

### **Chat (`/chat`)**
**Datos necesarios:**
- Lista de conversaciones con último mensaje y contador de no leídos
- Mensajes de la conversación seleccionada
- Información del niño relacionado
- Participantes de la conversación

**Fuente de datos:**
- `conversations` filtradas por participación del usuario
- `messages` de la conversación activa
- `conversation_participants` para verificar acceso
- `children` para mostrar info del niño

**Estado actual:** ✅ Conectado a API real con WebSockets
**Funcionalidad:** ✅ Enviar mensajes, marcar como leído

---

### **Pagos (`/payments`)**
**Datos necesarios:**
- Lista de pagos con estado (pendiente, pagado, vencido, cancelado)
- Filtros por estado y niño
- Estadísticas (total pendiente, vencido, cobrado)
- Acciones: marcar como pagado, cancelar, generar factura

**Fuente de datos:**
- `payments` filtrado por `tenantId`, `status`, `childId`
- Incluye relación con `children`
- `invoices` relacionadas al pago

**Estado actual:** ✅ Conectado a API real
**Funcionalidad:** ✅ Marcar como pagado, cancelar
**Faltante:**
- ❌ Endpoint POST `/payments` para crear nuevo cargo
- ❌ Endpoint PATCH `/payments/:id` para editar pago pendiente

---

### **Servicios (`/services`)**
**Datos necesarios:**
- Lista de servicios extra (clases, talleres, kits)
- Filtros por tipo y búsqueda
- Información: nombre, descripción, precio, capacidad, horario, imagen
- Formulario para crear/editar servicio

**Fuente de datos:**
- `extra_services` filtrado por `tenantId`, `type`, `search`

**Estado actual:** ✅ Conectado a API real
**Funcionalidad:** ✅ CRUD completo (crear, leer, actualizar, eliminar)

---

### **Reportes (`/reports`)**
**Datos necesarios:**
- Reporte de asistencia (por grupo, rango de fechas)
- Reporte de desarrollo (progreso por niño)
- Reporte de pagos (ingresos, pendientes, vencidos)
- Gráficas y estadísticas

**Fuente de datos:**
- `attendance_records` agregados por fecha y grupo
- `development_records` agregados por niño y categoría
- `payments` agregados por estado y mes

**Estado actual:** ✅ Conectado a API real
**Funcionalidad:** ✅ Generación de reportes completa

---

### **Perfil (`/profile`)**
**Datos necesarios:**
- Información del usuario (nombre, email, teléfono, avatar, rol)
- Información del tenant (guardería)
- Actividad reciente del usuario
- Notificaciones del usuario

**Fuente de datos:**
- `users` - Datos del usuario actual
- `user_tenants` - Rol en el tenant
- `tenants` - Información de la guardería
- `audit_logs` - Actividad reciente (filtrada por userId)
- `notifications` - Notificaciones del usuario

**Estado actual:** ⚠️ Parcialmente conectado
**Faltante:**
- ❌ **ActivityTab usa datos mock** - Necesita conectar a `audit_logs`
- ❌ **NotificationsTab usa datos mock** - Necesita conectar a `notifications`
- ❌ Endpoint PATCH `/users/:id` para actualizar perfil
- ❌ Endpoint para subir avatar

---

### **Configuración (`/settings`)**
**Datos necesarios:**
- Configuración de perfil (nombre, email, teléfono, avatar)
- Configuración de seguridad (cambiar contraseña, MFA)
- Preferencias de notificaciones

**Fuente de datos:**
- `users` - Datos del usuario
- Actualización de campos en `users`

**Estado actual:** ⚠️ Parcialmente implementado
**Faltante:**
- ❌ Endpoint PATCH `/users/me` para actualizar perfil
- ❌ Endpoint POST `/auth/change-password` para cambiar contraseña
- ❌ Endpoint para configurar MFA

---

## 3. Datos Mock Identificados

### **Componentes con datos hardcodeados:**

1. **`/components/profile/activity-tab.tsx`**
   - Usa `mockActivities` array hardcodeado
   - **Solución:** Conectar a endpoint `/audit-logs` filtrado por userId

2. **`/components/profile/notifications-tab.tsx`**
   - Usa `mockNotifications` array hardcodeado
   - **Solución:** Ya existe hook `useNotifications` pero no se está usando

---

## 4. Endpoints API Faltantes

### **Children (Niños)**
- ❌ `PATCH /children/:id` - Actualizar información del niño
- ❌ `DELETE /children/:id` - Eliminar niño (soft delete)
- ❌ `POST /children/:id/medical-info` - Crear/actualizar info médica
- ❌ `POST /children/:id/emergency-contacts` - Agregar contacto de emergencia
- ❌ `PATCH /children/:id/emergency-contacts/:contactId` - Actualizar contacto
- ❌ `DELETE /children/:id/emergency-contacts/:contactId` - Eliminar contacto

### **Daily Logs (Bitácora)**
- ❌ `PATCH /daily-logs/:id` - Actualizar entrada de bitácora
- ❌ `DELETE /daily-logs/:id` - Eliminar entrada

### **Development (Desarrollo)**
- ❌ `PATCH /development/records/:id` - Actualizar evaluación

### **Payments (Pagos)**
- ❌ `POST /payments` - Crear nuevo cargo
- ❌ `PATCH /payments/:id` - Editar pago pendiente

### **Users (Usuarios)**
- ❌ `PATCH /users/me` - Actualizar perfil del usuario actual
- ❌ `POST /auth/change-password` - Cambiar contraseña
- ❌ `POST /users/me/avatar` - Subir avatar

### **Audit Logs (Auditoría)**
- ❌ `GET /audit-logs` - Obtener logs de auditoría (para activity tab)

### **Files (Archivos)**
- ❌ `POST /files/upload` - Subir archivo (fotos, documentos)
- ❌ `GET /files/:id` - Obtener archivo
- ❌ `DELETE /files/:id` - Eliminar archivo

---

## 5. Funcionalidades de Persistencia Faltantes

### **Crear Registros**
- ✅ Niños - Implementado
- ❌ Información médica del niño - Falta endpoint
- ❌ Contactos de emergencia - Falta endpoint
- ✅ Asistencia (check-in/check-out) - Implementado
- ✅ Bitácora diaria - Implementado
- ✅ Evaluaciones de desarrollo - Implementado
- ✅ Mensajes - Implementado
- ❌ Pagos - Falta endpoint
- ✅ Servicios - Implementado

### **Actualizar Registros**
- ❌ Niños - Falta endpoint
- ❌ Información médica - Falta endpoint
- ❌ Contactos de emergencia - Falta endpoint
- ❌ Bitácora diaria - Falta endpoint
- ❌ Evaluaciones de desarrollo - Falta endpoint
- ❌ Pagos - Falta endpoint
- ✅ Servicios - Implementado
- ❌ Perfil de usuario - Falta endpoint

### **Eliminar Registros**
- ❌ Niños (soft delete) - Falta endpoint
- ❌ Contactos de emergencia - Falta endpoint
- ❌ Bitácora diaria - Falta endpoint
- ✅ Servicios (soft delete) - Implementado

---

## 6. Manejo de Archivos

### **Imágenes que necesitan persistencia:**
- Fotos de niños (`children.photoUrl`)
- Avatares de usuarios (`users.avatarUrl`)
- Imágenes de servicios (`extra_services.imageUrl`)
- Evidencias de desarrollo (`development_records.evidenceUrls[]`)
- Adjuntos en mensajes (`messages.attachmentUrl`)

### **Solución requerida:**
1. Implementar endpoint `/files/upload` que:
   - Suba archivo a MinIO (S3-compatible storage)
   - Guarde registro en tabla `files`
   - Retorne URL del archivo
2. Actualizar formularios para usar este endpoint
3. Guardar URL en el campo correspondiente de la base de datos

---

## 7. Plan de Implementación

### **Fase 1: Completar CRUD de Niños** ✅ PRIORIDAD ALTA
1. Implementar `PATCH /children/:id`
2. Implementar `DELETE /children/:id`
3. Implementar endpoints de información médica
4. Implementar endpoints de contactos de emergencia
5. Actualizar formularios en el frontend

### **Fase 2: Completar CRUD de Bitácora y Desarrollo** ✅ PRIORIDAD ALTA
1. Implementar `PATCH /daily-logs/:id`
2. Implementar `DELETE /daily-logs/:id`
3. Implementar `PATCH /development/records/:id`
4. Actualizar componentes en el frontend

### **Fase 3: Completar CRUD de Pagos** ✅ PRIORIDAD ALTA
1. Implementar `POST /payments`
2. Implementar `PATCH /payments/:id`
3. Actualizar componente de pagos

### **Fase 4: Implementar Manejo de Archivos** ✅ PRIORIDAD ALTA
1. Configurar MinIO
2. Implementar servicio de archivos
3. Implementar endpoint `/files/upload`
4. Actualizar formularios para subir imágenes

### **Fase 5: Conectar Perfil y Configuración** ✅ PRIORIDAD MEDIA
1. Implementar `PATCH /users/me`
2. Implementar `POST /auth/change-password`
3. Implementar endpoint de avatar
4. Conectar ActivityTab a audit logs
5. Conectar NotificationsTab (ya existe el hook)

### **Fase 6: Implementar Audit Logs** ✅ PRIORIDAD BAJA
1. Implementar `GET /audit-logs`
2. Conectar ActivityTab

---

## 8. Verificación de Integridad

### **Relaciones a verificar:**
- ✅ `children.groupId` → `groups.id`
- ✅ `children.tenantId` → `tenants.id`
- ✅ `child_medical_info.childId` → `children.id`
- ✅ `emergency_contacts.childId` → `children.id`
- ✅ `child_parents.childId` → `children.id`
- ✅ `child_parents.userId` → `users.id`
- ✅ `attendance_records.childId` → `children.id`
- ✅ `daily_log_entries.childId` → `children.id`
- ✅ `development_records.childId` → `children.id`
- ✅ `development_records.milestoneId` → `development_milestones.id`
- ✅ `payments.childId` → `children.id`
- ✅ `conversations.childId` → `children.id`
- ✅ `messages.conversationId` → `conversations.id`

---

## 9. Conclusiones

### **Estado General:**
- ✅ **Base de datos:** Correctamente poblada con datos de demostración
- ✅ **Backend API:** Corriendo en puerto 3002
- ✅ **Frontend Web:** Corriendo en puerto 3001
- ⚠️ **Conexión:** Mayormente conectada, faltan endpoints CRUD

### **Datos Mock a Eliminar:**
1. `activity-tab.tsx` - mockActivities
2. `notifications-tab.tsx` - mockNotifications (hook ya existe)

### **Próximos Pasos Inmediatos:**
1. Implementar endpoints faltantes de Children
2. Implementar endpoints faltantes de Daily Logs y Development
3. Implementar endpoints faltantes de Payments
4. Implementar sistema de archivos
5. Eliminar datos mock de perfil
6. Probar flujo completo de datos

---

**Última actualización:** 11 de Marzo, 2026
