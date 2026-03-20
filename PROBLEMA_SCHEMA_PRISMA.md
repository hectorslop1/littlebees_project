# 🚨 PROBLEMA CRÍTICO: Schema de Prisma Desincronizado

**Fecha**: 19 de Marzo, 2026  
**Estado**: ⚠️ BLOQUEANTE - Backend no compila

---

## 📋 RESUMEN DEL PROBLEMA

El schema de Prisma (`schema.prisma`) define campos y modelos que **NO EXISTEN** en la base de datos real de producción. Esto causa errores de compilación de TypeScript y errores en runtime cuando se intenta acceder a estos campos.

---

## 🔴 ERRORES ENCONTRADOS

### 1. Modelo `Group` - Campo `level` no existe
```
The column `groups.level` does not exist in the current database.
```

**Archivos afectados**:
- `src/modules/groups/groups.service.ts` (líneas 63, 98)
- `src/modules/ai/services/context-builder.service.ts`

### 2. Modelo `Excuse` no existe en Prisma Client
```
Property 'excuse' does not exist on type 'PrismaService'
```

**Archivos afectados**:
- `src/modules/excuses/excuses.service.ts` (múltiples líneas)

### 3. Otros campos problemáticos
- `Child.groupName` - No existe (solo existe `groupId`)
- `Group.level` - No existe en BD
- `Group.friendlyName` - No existe en BD
- `Group.subgroup` - No existe en BD
- `Tenant.slug` - No es unique key en BD

---

## 🎯 IMPACTO

### ❌ **Backend NO COMPILA**
- 49 errores de TypeScript
- Imposible iniciar el servidor API
- Todas las funcionalidades bloqueadas

### ❌ **Funcionalidades Afectadas**
1. **Chat con IA** - No puede acceder a datos de grupos
2. **Módulo de Excuses** - Completamente roto
3. **Módulo de Groups** - Create/Update no funcionan
4. **Reportes** - Intentan acceder a `child.group.name`
5. **Web App** - Errores 500 en múltiples endpoints

---

## 🔍 CAUSA RAÍZ

El schema de Prisma fue diseñado con una estructura ideal/futura, pero la base de datos real en producción tiene una estructura diferente (más simple). Nadie sincronizó el schema con la BD real.

**Evidencia**:
```bash
# Al hacer prisma db pull, se generan 154 líneas de warnings
# indicando que muchos campos del schema no existen en la BD
```

---

## ✅ SOLUCIONES POSIBLES

### Opción 1: Migrar la BD a la estructura del Schema (RECOMENDADO)
**Ventajas**:
- El código ya está escrito para esta estructura
- Funcionalidades más ricas (levels, friendly names, etc.)
- Mejor organización

**Desventajas**:
- Requiere crear y ejecutar migraciones
- Riesgo de pérdida de datos si no se hace bien
- Requiere downtime

**Pasos**:
```bash
cd littlebees-web/apps/api

# 1. Crear migración desde el schema actual
npx prisma migrate dev --name sync_schema_with_code

# 2. Revisar la migración generada
# 3. Aplicar a producción
npx prisma migrate deploy
```

### Opción 2: Actualizar Schema desde la BD (MÁS RÁPIDO)
**Ventajas**:
- No requiere cambios en BD
- Funciona inmediatamente
- Sin riesgo de pérdida de datos

**Desventajas**:
- Requiere actualizar TODO el código
- Perder funcionalidades diseñadas
- Mucho trabajo de refactoring

**Pasos**:
```bash
cd littlebees-web/apps/api

# 1. Hacer backup del schema actual
cp prisma/schema.prisma prisma/schema.prisma.backup

# 2. Pull desde BD
npx prisma db pull

# 3. Regenerar cliente
npx prisma generate

# 4. Actualizar TODO el código que usa campos inexistentes
# (Esto puede tomar horas)
```

### Opción 3: Solución Temporal - Comentar Código Roto
**Ventajas**:
- Backend compila y funciona parcialmente
- Permite seguir trabajando en otras cosas

**Desventajas**:
- Funcionalidades rotas (excuses, groups create/update, AI)
- No es una solución real
- Deuda técnica

---

## 🚀 RECOMENDACIÓN

**Opción 1: Migrar la BD** es la mejor solución a largo plazo.

**Plan de acción**:

1. **Hacer backup completo de la BD de producción**
   ```bash
   pg_dump -h 216.250.125.239 -U postgres -d littlebees > backup_$(date +%Y%m%d).sql
   ```

2. **Crear migración en desarrollo**
   ```bash
   cd littlebees-web/apps/api
   npx prisma migrate dev --name add_missing_group_fields --create-only
   ```

3. **Revisar SQL generado** - Asegurarse que:
   - No borra datos existentes
   - Agrega campos con valores por defecto apropiados
   - Maneja foreign keys correctamente

4. **Probar en desarrollo**
   ```bash
   npx prisma migrate dev
   npm run dev
   # Probar todas las funcionalidades
   ```

5. **Aplicar a producción**
   ```bash
   npx prisma migrate deploy
   ```

6. **Verificar**
   - Backend compila sin errores
   - Todas las funcionalidades funcionan
   - No hay pérdida de datos

---

## 📊 ESTADO ACTUAL DE LA IMPLEMENTACIÓN DE IA

### ✅ Completado
- Context Builder Service (código escrito)
- AI Functions Service (código escrito)
- Integración en AI Service (código escrito)
- Documentación completa

### ⚠️ Bloqueado
- No se puede probar porque backend no compila
- Schema mismatch impide acceso a datos de grupos
- Funcionalidades de excuses también bloqueadas

### 🎯 Próximos Pasos
1. **URGENTE**: Decidir qué opción tomar para el schema
2. Ejecutar la solución elegida
3. Probar que backend compila
4. Probar chat de IA con datos reales
5. Deploy a producción

---

## ⏱️ ESTIMACIÓN DE TIEMPO

- **Opción 1 (Migración)**: 2-3 horas (incluye testing)
- **Opción 2 (Pull + Refactor)**: 4-6 horas
- **Opción 3 (Temporal)**: 30 minutos (pero no resuelve nada)

---

## 💡 DECISIÓN REQUERIDA

**¿Qué opción prefieres?**

1. Migrar la BD para que coincida con el schema (RECOMENDADO)
2. Actualizar el schema para que coincida con la BD
3. Solución temporal para desbloquear (no resuelve el problema)

Una vez que decidas, puedo ejecutar la solución inmediatamente.
