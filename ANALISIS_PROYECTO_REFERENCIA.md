# Análisis Proyecto de Referencia - KinderSpace

## 📊 Dashboard - Estructura Visual Exacta

### 1. Stats Grid (4 tarjetas en fila)
```
[Total Niños] [Asistencia Hoy] [Ingresos Mes] [Pagos Pendientes]
```

**Cada tarjeta incluye:**
- Título
- Valor principal (grande)
- Tendencia con % (verde/rojo)
- Texto "vs mes anterior"
- Icono en círculo de color

**Datos necesarios de BD:**
- ✅ `totalChildren` - COUNT de children activos
- ✅ `attendanceRate` - % de asistencia del día actual
- ✅ `monthlyRevenue` - SUM de payments del mes actual con status='paid'
- ✅ `pendingPayments` - COUNT de payments con status='pending'
- ❌ **FALTA**: Tendencias (comparación con mes anterior)

### 2. Charts Row (2 columnas iguales)

#### A. Asistencia Semanal (BarChart)
**Datos mostrados:**
- 3 barras por día: Presentes (verde), Tardes (amarillo), Ausentes (rojo)
- Últimos 7 días

**Datos necesarios de BD:**
- ✅ `attendance_records` con `status` (present/late/absent)
- ❌ **FALTA**: Campo `status` solo tiene 'present'/'absent', no tiene 'late'

#### B. Desarrollo Promedio (RadarChart)
**Datos mostrados:**
- 6 áreas: Motor Fino, Motor Grueso, Cognitivo, Lenguaje, Social, Emocional
- Promedio de todos los niños

**Datos necesarios de BD:**
- ✅ `development_records` con `milestone_id`
- ✅ `development_milestones` con `category`
- ✅ Cálculo de % por categoría (achieved/total)

### 3. Development Trend & Groups (2:1 proporción)

#### A. Evolución del Desarrollo (LineChart - 2/3 ancho)
**Datos mostrados:**
- 4 líneas: Motor Fino, Cognitivo, Lenguaje, Social
- Últimos 6 meses
- Dominio Y: 60-100%

**Datos necesarios de BD:**
- ✅ `development_records` agrupados por mes
- ❌ **FALTA**: Datos históricos por mes (solo tenemos datos actuales)

#### B. Grupos (1/3 ancho)
**Datos mostrados:**
- Lista de grupos con:
  - Nombre + color
  - Capacidad (enrolled/capacity)
  - CircularProgress

**Datos necesarios de BD:**
- ✅ `groups` con `capacity`
- ✅ COUNT de `children` por `group_id`
- ✅ `color` del grupo

### 4. Recent Activity & Announcements (2 columnas)

#### A. Actividad Reciente
**Datos mostrados:**
- Últimos 3 logs
- Avatar del niño
- Tipo de actividad (Alimentación/Siesta/Actividad)
- Hora
- Nombre del maestro

**Datos necesarios de BD:**
- ✅ `daily_log_entries` con `type`, `title`, `time`
- ✅ `children` con `photo_url`
- ✅ `users` (maestro que registró)

#### B. Anuncios Recientes
**Datos mostrados:**
- Título + contenido
- Tipo (General/Evento/Alerta/Logro)
- Prioridad (high/medium/low) con colores
- Autor + fecha

**Datos necesarios de BD:**
- ❌ **FALTA**: Tabla `announcements` completa
- Necesitamos: title, content, type, priority, author_id, created_at

---

## 🧠 Desarrollo - Estructura Visual Exacta

### 1. Header Actions
```
[Select: Niño] [Select: Categoría] [Btn: Exportar] [Btn: Agregar]
```

### 2. Overview Cards (Grid 3 columnas, 6 tarjetas)

**Cada tarjeta incluye:**
- Icono + nombre de categoría
- CircularProgress grande (derecha)
- Progress bar lineal
- Texto: "X% del progreso esperado"

**Categorías:**
1. Motor Fino (Hand, azul)
2. Motor Grueso (Activity, verde)
3. Cognitivo (Brain, morado)
4. Lenguaje (MessageSquare, naranja)
5. Social (Users, rosa)
6. Emocional (TrendingUp, amarillo)

**Datos necesarios de BD:**
- ✅ `development_records` por categoría
- ❌ **FALTA**: "progreso esperado" - necesitamos definir qué es esto
  - Opción 1: % de milestones logrados vs total de milestones para la edad
  - Opción 2: Comparación con promedio del grupo

### 3. Charts (2 columnas iguales)

#### A. Resumen de Desarrollo (RadarChart)
- Igual que en Dashboard
- 6 áreas con valores actuales

#### B. Evolución del Desarrollo (LineChart)
- 3 líneas: Motor Fino, Cognitivo, Lenguaje
- Últimos 6 meses
- Dominio Y: 60-100%

### 4. Hitos de Desarrollo

**Datos mostrados:**
- Lista de milestones con:
  - Icono de categoría
  - Título del milestone
  - Categoría
  - Fecha
  - Estado (Logrado/En Progreso/No Logrado)

**Datos necesarios de BD:**
- ✅ `development_records` con `status`
- ✅ `development_milestones` con `title`, `category`
- ✅ `evaluated_at` fecha

### 5. Ejercicios en Casa (Grid 3 columnas)

**Datos mostrados:**
- Título
- Descripción
- Categoría
- Estado (Completado/Pendiente)
- Duración (min)
- Rango de edad (min-max meses)
- Botón "Ver"

**Datos necesarios de BD:**
- ❌ **FALTA**: Tabla `exercises` completa
- Necesitamos: title, description, category, duration, age_range_min, age_range_max, completed

---

## 🔴 Datos Faltantes en BD

### Críticos (para funcionalidad básica):

1. **`attendance_records.status`** - Agregar valor 'late'
   ```sql
   ALTER TYPE attendance_status ADD VALUE 'late';
   ```

2. **Tabla `announcements`**
   ```sql
   CREATE TABLE announcements (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     tenant_id UUID NOT NULL REFERENCES tenants(id),
     title VARCHAR(255) NOT NULL,
     content TEXT NOT NULL,
     type VARCHAR(50) NOT NULL, -- 'general', 'event', 'alert', 'achievement'
     priority VARCHAR(20) NOT NULL, -- 'high', 'medium', 'low'
     author_id UUID NOT NULL REFERENCES users(id),
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
   );
   ```

3. **Tabla `exercises`**
   ```sql
   CREATE TABLE exercises (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     tenant_id UUID NOT NULL REFERENCES tenants(id),
     title VARCHAR(255) NOT NULL,
     description TEXT NOT NULL,
     category development_category NOT NULL,
     duration INT NOT NULL, -- minutos
     age_range_min INT NOT NULL, -- meses
     age_range_max INT NOT NULL, -- meses
     video_url TEXT,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
   );
   
   CREATE TABLE child_exercises (
     child_id UUID REFERENCES children(id),
     exercise_id UUID REFERENCES exercises(id),
     completed BOOLEAN DEFAULT FALSE,
     completed_at TIMESTAMP,
     PRIMARY KEY (child_id, exercise_id)
   );
   ```

### Importantes (para métricas completas):

4. **Tendencias mensuales** - Necesitamos calcular:
   - Comparación mes actual vs mes anterior para stats
   - Datos históricos de desarrollo por mes

5. **"Progreso esperado"** - Definir lógica:
   - Opción recomendada: % de milestones logrados para la edad del niño
   - Fórmula: (milestones_achieved / milestones_for_age) * 100

---

## 📝 Plan de Implementación

### Fase 1: Agregar datos faltantes a BD
1. Crear migraciones para nuevas tablas
2. Agregar 'late' a attendance_status
3. Insertar datos de prueba

### Fase 2: Actualizar API
1. Agregar endpoints para announcements
2. Agregar endpoints para exercises
3. Modificar reports para incluir 'late' en asistencia
4. Agregar cálculo de tendencias mensuales

### Fase 3: Replicar Dashboard
1. Actualizar StatCardsRow con tendencias
2. Modificar AttendanceChart para 3 barras
3. Agregar componente de Grupos
4. Agregar componente de Actividad Reciente
5. Agregar componente de Anuncios

### Fase 4: Replicar Desarrollo
1. Actualizar Overview Cards con progreso esperado
2. Agregar componente de Hitos
3. Agregar componente de Ejercicios
4. Agregar filtros de niño y categoría

### Fase 5: Eliminar datos mock
1. Verificar que todos los componentes usen datos de BD
2. Eliminar cualquier dato hardcodeado
3. Agregar estados de loading/error apropiados
