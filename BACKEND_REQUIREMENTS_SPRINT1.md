# Backend Requirements - Sprint 1
## Endpoints y Datos Necesarios para Mobile App

**Fecha:** 20 de marzo, 2026  
**Versión:** 1.0

---

## 📋 Resumen

Este documento detalla los requisitos de backend necesarios para soportar las funcionalidades implementadas en Sprint 1 de la app móvil.

---

## 🔌 Endpoints Requeridos

### ✅ Endpoints Existentes (Verificar Formato de Respuesta)

#### 1. GET `/api/children`
**Usado en:** `myChildrenProvider`, lista de hijos/alumnos

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": "uuid",
      "tenantId": "uuid",
      "firstName": "string",
      "lastName": "string",
      "dateOfBirth": "2020-01-15T00:00:00.000Z",
      "gender": "male" | "female",
      "photoUrl": "https://...",
      "groupId": "uuid",
      "group": {
        "id": "uuid",
        "name": "Lactantes",
        "friendlyName": "Abejitas"
      },
      "enrollmentDate": "2023-09-01T00:00:00.000Z",
      "status": "active",
      "qrCodeHash": "string",
      "allergies": ["Maní", "Lactosa"],
      "conditions": ["Asma"],
      "medications": ["Salbutamol"],
      "bloodType": "O+",
      "createdAt": "2023-08-15T00:00:00.000Z",
      "updatedAt": "2024-03-20T00:00:00.000Z"
    }
  ]
}
```

**Filtrado por rol:**
- Padre: Solo sus hijos (via `child_parents` table)
- Maestra: Alumnos de sus grupos asignados
- Director: Todos los alumnos de la escuela

---

#### 2. GET `/api/children/:childId`
**Usado en:** `childProfileProvider`, perfil detallado del niño

**Respuesta esperada:**
```json
{
  "id": "uuid",
  "tenantId": "uuid",
  "firstName": "string",
  "lastName": "string",
  "dateOfBirth": "2020-01-15T00:00:00.000Z",
  "gender": "male" | "female",
  "photoUrl": "https://...",
  "groupId": "uuid",
  "groupName": "Abejitas",
  "enrollmentDate": "2023-09-01T00:00:00.000Z",
  "status": "active",
  "qrCodeHash": "string",
  "allergies": ["Maní", "Lactosa"],
  "conditions": ["Asma"],
  "medications": ["Salbutamol"],
  "bloodType": "O+",
  "authorizedPickups": [
    {
      "id": "uuid",
      "name": "María López",
      "relation": "Madre",
      "phone": "+52 555-1234",
      "photoUrl": "https://...",
      "idNumber": "ABC123456",
      "notes": "Contacto principal"
    }
  ],
  "createdAt": "2023-08-15T00:00:00.000Z",
  "updatedAt": "2024-03-20T00:00:00.000Z"
}
```

**Nota:** `authorizedPickups` actualmente retorna `null` en el repository. Necesita implementación.

---

#### 3. GET `/api/groups`
**Usado en:** `groupsProvider`, lista de grupos

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Lactantes",
      "friendlyName": "Abejitas",
      "description": "Grupo de lactantes 0-12 meses",
      "ageRangeMin": 0,
      "ageRangeMax": 12,
      "capacity": 15,
      "_count": {
        "children": 12
      },
      "teacherNames": ["Ana García", "Luis Martínez"],
      "academicYear": "2023-2024",
      "color": "#FFD700"
    }
  ]
}
```

**Alternativa aceptada:**
```json
[
  {
    "id": "uuid",
    "name": "Lactantes",
    // ... resto de campos
  }
]
```

---

#### 4. GET `/api/groups/:groupId`
**Usado en:** `groupByIdProvider`, detalle de grupo

**Respuesta esperada:**
```json
{
  "id": "uuid",
  "name": "Lactantes",
  "friendlyName": "Abejitas",
  "description": "Grupo de lactantes 0-12 meses",
  "ageRangeStart": 0,
  "ageRangeEnd": 12,
  "maxCapacity": 15,
  "currentCapacity": 12,
  "teacherNames": ["Ana García", "Luis Martínez"],
  "academicYear": "2023-2024",
  "color": "#FFD700"
}
```

**Nota:** El modelo acepta tanto `ageRangeMin/Max` como `ageRangeStart/End`.

---

#### 5. GET `/api/excuses`
**Usado en:** `excusesListProvider`, lista de justificantes

**Query params:**
- `childId` (opcional): Filtrar por niño
- `status` (opcional): `pending` | `approved` | `rejected`
- `startDate` (opcional): Fecha inicio (ISO 8601)
- `endDate` (opcional): Fecha fin (ISO 8601)

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": "uuid",
      "tenantId": "uuid",
      "childId": "uuid",
      "childName": "Juan Pérez",
      "submittedBy": "uuid",
      "submittedByName": "María López",
      "type": "sick" | "medical" | "family" | "travel" | "other",
      "title": "Cita médica",
      "description": "Consulta con pediatra",
      "date": "2024-03-21",
      "status": "pending" | "approved" | "rejected",
      "reviewedBy": "uuid",
      "reviewedByName": "Ana García",
      "reviewedAt": "2024-03-20T10:30:00.000Z",
      "reviewNotes": "Aprobado",
      "attachments": ["https://..."],
      "createdAt": "2024-03-20T08:00:00.000Z",
      "updatedAt": "2024-03-20T10:30:00.000Z"
    }
  ]
}
```

**Manejo de respuesta vacía:**
- ✅ Retornar `{ "data": [] }` cuando no hay datos
- ✅ Retornar `404` es aceptable (app maneja retornando lista vacía)
- ❌ NO lanzar error 500 en datos vacíos

---

### 🆕 Endpoints Nuevos Requeridos

#### 6. GET `/api/notifications`
**Prioridad:** Alta  
**Usado en:** NotificationsScreen (actualmente muestra estado vacío)

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": "uuid",
      "userId": "uuid",
      "type": "message" | "announcement" | "reminder" | "ai_recommendation",
      "title": "Nuevo mensaje",
      "body": "Tienes un mensaje de la maestra Ana",
      "read": false,
      "actionUrl": "/messages/uuid",
      "createdAt": "2024-03-20T14:30:00.000Z"
    }
  ]
}
```

**Query params:**
- `read` (opcional): `true` | `false`
- `type` (opcional): Filtrar por tipo
- `limit` (opcional): Número de notificaciones (default: 50)

---

#### 7. PATCH `/api/notifications/:notificationId/read`
**Prioridad:** Alta  
**Descripción:** Marcar notificación como leída

**Request body:**
```json
{
  "read": true
}
```

**Respuesta:**
```json
{
  "id": "uuid",
  "read": true,
  "updatedAt": "2024-03-20T14:35:00.000Z"
}
```

---

#### 8. GET `/api/children/:childId/authorized-pickups`
**Prioridad:** Media  
**Descripción:** Obtener recogidas autorizadas de un niño

**Respuesta esperada:**
```json
{
  "data": [
    {
      "id": "uuid",
      "childId": "uuid",
      "name": "María López",
      "relation": "Madre",
      "phone": "+52 555-1234",
      "email": "maria@example.com",
      "photoUrl": "https://...",
      "idNumber": "ABC123456",
      "isPrimary": true,
      "notes": "Contacto principal",
      "createdAt": "2023-09-01T00:00:00.000Z",
      "updatedAt": "2024-03-20T00:00:00.000Z"
    }
  ]
}
```

---

#### 9. POST `/api/children/:childId/authorized-pickups`
**Prioridad:** Media  
**Descripción:** Agregar persona autorizada para recoger

**Request body:**
```json
{
  "name": "Juan López",
  "relation": "Padre",
  "phone": "+52 555-5678",
  "email": "juan@example.com",
  "photoUrl": "https://...",
  "idNumber": "XYZ789012",
  "isPrimary": false,
  "notes": "Disponible después de las 5pm"
}
```

---

## 🔐 Autenticación y Autorización

### Headers Requeridos
```
Authorization: Bearer <jwt_token>
```

### Validaciones por Rol

#### Padre
- ✅ Puede ver solo sus hijos
- ✅ Puede ver grupos de sus hijos
- ✅ Puede crear justificantes para sus hijos
- ❌ NO puede ver otros niños
- ❌ NO puede aprobar justificantes

#### Maestra
- ✅ Puede ver alumnos de sus grupos
- ✅ Puede ver todos sus grupos asignados
- ✅ Puede revisar justificantes de sus alumnos
- ✅ Puede crear actividades
- ❌ NO puede ver alumnos de otros grupos

#### Director
- ✅ Puede ver todos los alumnos de la escuela
- ✅ Puede ver todos los grupos
- ✅ Puede revisar todos los justificantes
- ✅ Puede ver estadísticas generales
- ✅ Acceso completo a reportes y finanzas

---

## 📊 Estadísticas para Dashboard de Director

### GET `/api/dashboard/stats`
**Prioridad:** Media  
**Descripción:** Estadísticas generales para el dashboard del director

**Respuesta esperada:**
```json
{
  "totalStudents": 120,
  "totalGroups": 8,
  "attendanceToday": {
    "present": 95,
    "absent": 15,
    "late": 10,
    "percentage": 79.2
  },
  "pendingExcuses": 5,
  "activeTeachers": 12,
  "monthlyRevenue": 450000,
  "pendingPayments": 25000
}
```

---

## 🐛 Manejo de Errores

### Códigos de Estado Esperados

#### 200 OK
- Operación exitosa con datos

#### 201 Created
- Recurso creado exitosamente

#### 204 No Content
- Operación exitosa sin datos de retorno

#### 400 Bad Request
```json
{
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

#### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

#### 403 Forbidden
```json
{
  "error": "Forbidden",
  "message": "You don't have permission to access this resource"
}
```

#### 404 Not Found
```json
{
  "error": "Not Found",
  "message": "Resource not found"
}
```

**Nota:** Para listas vacías, preferir `200` con `{ "data": [] }` en lugar de `404`.

#### 500 Internal Server Error
```json
{
  "error": "Internal Server Error",
  "message": "An unexpected error occurred"
}
```

---

## 🔄 Formatos de Fecha

### Envío (Request)
- Fechas: `YYYY-MM-DD` (ej: `2024-03-20`)
- Timestamps: ISO 8601 (ej: `2024-03-20T14:30:00.000Z`)

### Recepción (Response)
- Aceptado: ISO 8601 completo
- La app parsea automáticamente con `DateTime.parse()`

---

## 📝 Notas de Implementación

### Paginación (Futuro)
Actualmente no implementada en mobile, pero recomendado para listas grandes:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalItems": 95
  }
}
```

### Caché
- La app usa Riverpod providers con caché automático
- `ref.refresh()` fuerza recarga de datos
- No se requiere caché adicional en backend

### Rate Limiting
- Recomendado: 100 requests/minuto por usuario
- Headers informativos opcionales:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 87
  X-RateLimit-Reset: 1710950400
  ```

---

## ✅ Checklist de Verificación

### Endpoints Existentes
- [ ] `/api/children` retorna formato correcto
- [ ] `/api/children/:childId` incluye `authorizedPickups`
- [ ] `/api/groups` retorna `_count.children` o `currentCapacity`
- [ ] `/api/groups/:groupId` funciona correctamente
- [ ] `/api/excuses` maneja filtros correctamente
- [ ] Filtrado por rol funciona en todos los endpoints

### Endpoints Nuevos
- [ ] `/api/notifications` implementado
- [ ] `/api/notifications/:id/read` implementado
- [ ] `/api/children/:childId/authorized-pickups` GET implementado
- [ ] `/api/children/:childId/authorized-pickups` POST implementado
- [ ] `/api/dashboard/stats` implementado

### Seguridad
- [ ] JWT validation en todos los endpoints
- [ ] Role-based access control implementado
- [ ] Validación de permisos por recurso
- [ ] Rate limiting configurado

### Datos de Prueba
- [ ] Al menos 3 niños por grupo
- [ ] Al menos 2 grupos por maestra
- [ ] Al menos 5 justificantes (varios estados)
- [ ] Datos de recogidas autorizadas
- [ ] Notificaciones de prueba

---

## 🚀 Prioridades de Implementación

### Crítico (Bloquea funcionalidad)
1. Verificar formato de respuesta de endpoints existentes
2. Agregar `authorizedPickups` a `/api/children/:childId`
3. Implementar `/api/notifications`

### Alta (Mejora experiencia)
4. Implementar `/api/dashboard/stats`
5. Implementar CRUD de authorized pickups
6. Mejorar manejo de errores

### Media (Features adicionales)
7. Implementar paginación
8. Agregar rate limiting
9. Optimizar queries de base de datos

---

## 📞 Contacto

Para dudas sobre este documento o los requisitos de backend:
- **Mobile Team Lead:** [Nombre]
- **Backend Team Lead:** [Nombre]
- **Slack Channel:** #littlebees-mobile-backend

---

**Última actualización:** 20 de marzo, 2026
