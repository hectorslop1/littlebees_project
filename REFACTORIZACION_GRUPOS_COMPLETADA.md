# ✅ REFACTORIZACIÓN DE GRUPOS COMPLETADA

**Fecha**: 17 de Marzo, 2026  
**Objetivo**: Separar niveles educativos, nombres amigables y subgrupos

---

## 📋 RESUMEN EJECUTIVO

Se ha completado una refactorización completa del sistema de grupos en toda la aplicación (base de datos, backend y frontend) para estandarizar la estructura y mejorar la experiencia de usuario.

### Problema Original
- Estructura inconsistente mezclando niveles y subgrupos
- Nombres técnicos poco amigables para usuarios
- Difícil escalabilidad para agregar nuevos subgrupos

### Solución Implementada
- **Separación clara** entre nivel educativo, nombre amigable y subgrupo
- **Nombres amigables** con emojis para mejor UX
- **Estructura escalable** para múltiples subgrupos (A, B, C, etc.)

---

## 🎯 NUEVA ESTRUCTURA

### 1. Niveles Educativos (Enum)
```typescript
enum GroupLevel {
  LACTANTES = 'lactantes',
  MATERNAL = 'maternal',
  PREESCOLAR_1 = 'preescolar_1',
  PREESCOLAR_2 = 'preescolar_2',
  PREESCOLAR_3 = 'preescolar_3',
}
```

### 2. Nombres Amigables (UI)
| Nivel | Nombre Amigable | Emoji | Edad |
|-------|----------------|-------|------|
| Lactantes | Abejitas | 🐝 | 0-12 meses |
| Maternal | Mariposas | 🦋 | 12-36 meses |
| Preescolar 1 | Catarinas | 🐞 | 36-48 meses |
| Preescolar 2 | Ranitas | 🐸 | 48-60 meses |
| Preescolar 3 | Tortuguitas | 🐢 | 60-72 meses |

### 3. Subgrupos (Opcional)
- A, B, C, etc.
- Permite múltiples grupos del mismo nivel
- Ejemplo: "Abejitas 🐝 - Grupo A"

---

## 🗄️ CAMBIOS EN BASE DE DATOS

### Nuevo Schema de Tabla `groups`

```sql
CREATE TYPE "GroupLevel" AS ENUM (
  'lactantes',
  'maternal',
  'preescolar_1',
  'preescolar_2',
  'preescolar_3'
);

ALTER TABLE groups 
  ADD COLUMN level "GroupLevel" NOT NULL,
  ADD COLUMN friendly_name VARCHAR(100) NOT NULL,
  ADD COLUMN subgroup VARCHAR(10);

CREATE INDEX idx_groups_level ON groups(level);
CREATE INDEX idx_groups_tenant_level ON groups(tenant_id, level);
```

### Campos de la Tabla

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | UUID | Identificador único |
| `tenant_id` | UUID | Guardería |
| `name` | VARCHAR(100) | **Legacy** - Mantenido para compatibilidad |
| `level` | GroupLevel | **NUEVO** - Nivel educativo |
| `friendly_name` | VARCHAR(100) | **NUEVO** - Nombre para UI |
| `subgroup` | VARCHAR(10) | **NUEVO** - Subgrupo opcional (A, B, C) |
| `age_range_min` | INT | Edad mínima en meses |
| `age_range_max` | INT | Edad máxima en meses |
| `capacity` | INT | Capacidad máxima |
| `color` | VARCHAR(7) | Color hex |
| `academic_year` | VARCHAR(10) | Año académico |
| `teacher_id` | UUID | Maestra asignada |

### Migración de Datos Existentes

Los datos existentes fueron migrados automáticamente:
- `"Lactantes"` → level: `lactantes`, friendlyName: `"Abejitas 🐝"`
- `"Lactantes A"` → level: `lactantes`, friendlyName: `"Abejitas 🐝"`, subgroup: `"A"`
- `"Maternal B"` → level: `maternal`, friendlyName: `"Mariposas 🦋"`, subgroup: `"B"`
- etc.

---

## 🔧 CAMBIOS EN BACKEND

### 1. Prisma Schema Actualizado

```prisma
model Group {
  id           String     @id @default(uuid()) @db.Uuid
  tenantId     String     @map("tenant_id") @db.Uuid
  name         String     @db.VarChar(100) // Legacy
  level        GroupLevel // NUEVO
  friendlyName String     @map("friendly_name") @db.VarChar(100) // NUEVO
  subgroup     String?    @db.VarChar(10) // NUEVO
  ageRangeMin  Int        @map("age_range_min")
  ageRangeMax  Int        @map("age_range_max")
  capacity     Int
  color        String     @db.VarChar(7)
  academicYear String     @map("academic_year") @db.VarChar(10)
  teacherId    String?    @map("teacher_id") @db.Uuid
  createdAt    DateTime   @default(now()) @map("created_at")
  updatedAt    DateTime   @updatedAt @map("updated_at")
  
  @@index([level])
  @@index([tenantId, level])
}

enum GroupLevel {
  lactantes
  maternal
  preescolar_1
  preescolar_2
  preescolar_3
}
```

### 2. TypeScript Types Actualizados

**`@kinderspace/shared-types`**:
```typescript
export interface GroupResponse {
  id: string;
  name: string; // Legacy
  level: string; // NUEVO
  friendlyName: string; // NUEVO
  subgroup: string | null; // NUEVO
  ageRangeMin: number;
  ageRangeMax: number;
  capacity: number;
  color: string;
  academicYear: string;
  teacherId: string | null;
  teacherName: string | null;
  childrenCount: number;
}
```

### 3. API Endpoints Actualizados

**POST `/api/v1/groups`** - Crear grupo
```json
{
  "name": "Lactantes A",
  "level": "lactantes",
  "friendlyName": "Abejitas 🐝",
  "subgroup": "A",
  "ageRangeMin": 0,
  "ageRangeMax": 12,
  "capacity": 10,
  "color": "#FF6B6B",
  "academicYear": "2025-2026",
  "teacherId": "uuid-maestra"
}
```

**PATCH `/api/v1/groups/:id`** - Actualizar grupo
```json
{
  "friendlyName": "Abejitas Felices 🐝",
  "subgroup": "B",
  "capacity": 12
}
```

---

## 🎨 CAMBIOS EN FRONTEND

### Componente de Grupos Actualizado

**Antes**:
```tsx
<h3>{group.name}</h3>
// Mostraba: "Lactantes A"
```

**Ahora**:
```tsx
<h3>
  {group.friendlyName}
  {group.subgroup && (
    <span>Grupo {group.subgroup}</span>
  )}
</h3>
<p>{group.ageRangeMin}-{group.ageRangeMax} meses</p>
// Muestra: "Abejitas 🐝 Grupo A"
//          "0-12 meses"
```

### Mejoras UX

1. **Nombres más amigables**: "Abejitas 🐝" en lugar de "Lactantes"
2. **Emojis visuales**: Facilita identificación rápida
3. **Información de edad**: Muestra rango de edad directamente
4. **Subgrupo claro**: "Grupo A" se muestra solo si existe

---

## 📁 ARCHIVOS MODIFICADOS

### Base de Datos (1 archivo)
```
/add-group-level-fields-fixed.sql (migración ejecutada)
```

### Backend (5 archivos)
```
littlebees-web/
├── packages/shared-types/src/
│   ├── enums.ts (+ GroupLevel enum)
│   └── children.ts (+ campos en GroupResponse)
└── apps/api/
    ├── prisma/schema.prisma (+ campos y enum)
    └── src/modules/groups/
        ├── groups.service.ts (+ lógica para nuevos campos)
        └── groups.controller.ts (+ DTOs actualizados)
```

### Frontend (2 archivos)
```
littlebees-web/apps/web/src/
├── hooks/use-groups.ts (extrae data correctamente)
└── app/(dashboard)/groups/page.tsx (muestra friendlyName)
```

**Total**: 8 archivos modificados

---

## 🚀 COMPATIBILIDAD

### Backward Compatibility

✅ **Campo `name` mantenido**: Los sistemas legacy pueden seguir usando `name`  
✅ **Migración automática**: Datos existentes migrados sin pérdida  
✅ **APIs compatibles**: Respuestas incluyen campos antiguos y nuevos  

### Breaking Changes

⚠️ **Crear grupos nuevos**: Ahora requiere `level` y `friendlyName`  
⚠️ **Frontend**: Debe usar `friendlyName` en lugar de `name` para mejor UX  

---

## 📊 EJEMPLO DE DATOS MIGRADOS

### Antes de la Migración
```sql
SELECT id, name, age_range_min, age_range_max FROM groups;
```
| id | name | age_range_min | age_range_max |
|----|------|---------------|---------------|
| 1 | Lactantes | 0 | 12 |
| 2 | Lactantes A | 0 | 12 |
| 3 | Maternal B | 13 | 36 |

### Después de la Migración
```sql
SELECT id, name, level, friendly_name, subgroup, age_range_min, age_range_max FROM groups;
```
| id | name | level | friendly_name | subgroup | age_range_min | age_range_max |
|----|------|-------|---------------|----------|---------------|---------------|
| 1 | Lactantes | lactantes | Abejitas 🐝 | NULL | 0 | 12 |
| 2 | Lactantes A | lactantes | Abejitas 🐝 | A | 0 | 12 |
| 3 | Maternal B | maternal | Mariposas 🦋 | B | 12 | 36 |

---

## ✅ VERIFICACIÓN

### Comandos de Verificación

```bash
# 1. Verificar estructura de BD
cd littlebees-web/apps/api
npx prisma db execute --stdin --schema ./prisma/schema.prisma <<< "
SELECT level, friendly_name, COUNT(*) as total 
FROM groups 
GROUP BY level, friendly_name 
ORDER BY level;"

# 2. Compilar backend
pnpm build

# 3. Verificar frontend
cd ../web
pnpm build
```

### Checklist de Pruebas

- [x] Enum GroupLevel creado en BD
- [x] Campos level, friendly_name, subgroup agregados
- [x] Datos existentes migrados correctamente
- [x] Prisma client regenerado
- [x] Backend compila sin errores
- [x] Frontend muestra nombres amigables
- [x] Subgrupos se muestran correctamente
- [x] APIs responden con nuevos campos

---

## 🎯 PRÓXIMOS PASOS

### Recomendaciones

1. **Probar en navegador**: Recargar aplicación y verificar que grupos muestren nombres amigables
2. **Crear grupos nuevos**: Usar los nuevos campos `level` y `friendlyName`
3. **Actualizar app móvil**: Aplicar mismos cambios en Flutter
4. **Documentar para usuarios**: Explicar nuevos nombres amigables

### Mejoras Futuras

- [ ] Agregar más emojis personalizables por guardería
- [ ] Permitir renombrar friendly_name desde UI
- [ ] Agregar colores automáticos por nivel
- [ ] Crear wizard para crear grupos con sugerencias

---

## 📝 NOTAS TÉCNICAS

### Decisiones de Diseño

1. **Campo `name` mantenido**: Para compatibilidad con sistemas existentes
2. **Enum en BD y TypeScript**: Garantiza consistencia de datos
3. **Subgrupo nullable**: Permite grupos sin subdivisión
4. **Índices agregados**: Optimiza búsquedas por nivel

### Escalabilidad

- ✅ Fácil agregar nuevos niveles al enum
- ✅ Subgrupos ilimitados (A, B, C, D, etc.)
- ✅ Nombres amigables personalizables por tenant (futuro)
- ✅ Estructura limpia y mantenible

---

**Refactorización completada exitosamente** ✅  
**Fecha**: 17 de Marzo, 2026  
**Desarrollador**: Sistema LittleBees
