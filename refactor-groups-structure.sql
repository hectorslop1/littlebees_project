-- ============================================================
-- REFACTORIZACIÓN DE ESTRUCTURA DE GRUPOS
-- Separación de: nivel educativo, nombre amigable, y subgrupo
-- ============================================================

-- PASO 1: Crear enum GroupLevel
CREATE TYPE "GroupLevel" AS ENUM (
  'lactantes',
  'maternal',
  'preescolar_1',
  'preescolar_2',
  'preescolar_3'
);

-- PASO 2: Agregar nuevas columnas a la tabla groups
ALTER TABLE groups 
  ADD COLUMN level "GroupLevel",
  ADD COLUMN friendly_name VARCHAR(100),
  ADD COLUMN subgroup VARCHAR(10);

-- PASO 3: Migrar datos existentes al nuevo formato
-- Mapeo de nombres actuales a niveles y nombres amigables

-- Lactantes
UPDATE groups 
SET 
  level = 'lactantes',
  friendly_name = 'Abejitas 🐝',
  subgroup = NULL,
  age_range_min = 0,
  age_range_max = 12
WHERE LOWER(name) = 'lactantes' AND subgroup IS NULL;

-- Lactantes A
UPDATE groups 
SET 
  level = 'lactantes',
  friendly_name = 'Abejitas 🐝',
  subgroup = 'A',
  age_range_min = 0,
  age_range_max = 12
WHERE LOWER(name) = 'lactantes a';

-- Maternal
UPDATE groups 
SET 
  level = 'maternal',
  friendly_name = 'Mariposas 🦋',
  subgroup = NULL,
  age_range_min = 12,
  age_range_max = 36
WHERE LOWER(name) = 'maternal' AND subgroup IS NULL;

-- Maternal B
UPDATE groups 
SET 
  level = 'maternal',
  friendly_name = 'Mariposas 🦋',
  subgroup = 'B',
  age_range_min = 12,
  age_range_max = 36
WHERE LOWER(name) = 'maternal b';

-- Preescolar 1
UPDATE groups 
SET 
  level = 'preescolar_1',
  friendly_name = 'Catarinas 🐞',
  subgroup = NULL,
  age_range_min = 36,
  age_range_max = 48
WHERE LOWER(name) = 'preescolar 1';

-- Preescolar 2
UPDATE groups 
SET 
  level = 'preescolar_2',
  friendly_name = 'Ranitas 🐸',
  subgroup = NULL,
  age_range_min = 48,
  age_range_max = 60
WHERE LOWER(name) = 'preescolar 2';

-- Preescolar 3
UPDATE groups 
SET 
  level = 'preescolar_3',
  friendly_name = 'Tortuguitas 🐢',
  subgroup = NULL,
  age_range_min = 60,
  age_range_max = 72
WHERE LOWER(name) = 'preescolar 3';

-- PASO 4: Hacer las columnas NOT NULL después de migrar datos
ALTER TABLE groups 
  ALTER COLUMN level SET NOT NULL,
  ALTER COLUMN friendly_name SET NOT NULL;

-- PASO 5: Crear índice para búsquedas por nivel
CREATE INDEX idx_groups_level ON groups(level);
CREATE INDEX idx_groups_tenant_level ON groups(tenant_id, level);

-- PASO 6: Verificar migración
SELECT 
  id,
  name AS old_name,
  level,
  friendly_name,
  subgroup,
  age_range_min || '-' || age_range_max || ' meses' AS age_range,
  capacity
FROM groups
ORDER BY level, subgroup;

-- Resumen de cambios
SELECT 
  level,
  COUNT(*) AS total_groups,
  STRING_AGG(DISTINCT subgroup, ', ') AS subgroups
FROM groups
GROUP BY level
ORDER BY level;
