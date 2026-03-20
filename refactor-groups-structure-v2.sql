-- ============================================================
-- REFACTORIZACIÓN DE ESTRUCTURA DE GRUPOS V2
-- Separación de: nivel educativo, nombre amigable, y subgrupo
-- ============================================================

-- PASO 1: Crear enum GroupLevel
DO $$ BEGIN
  CREATE TYPE "GroupLevel" AS ENUM (
    'lactantes',
    'maternal',
    'preescolar_1',
    'preescolar_2',
    'preescolar_3'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- PASO 2: Agregar nuevas columnas a la tabla groups (nullable por ahora)
ALTER TABLE groups 
  ADD COLUMN IF NOT EXISTS level "GroupLevel",
  ADD COLUMN IF NOT EXISTS friendly_name VARCHAR(100),
  ADD COLUMN IF NOT EXISTS subgroup VARCHAR(10);

-- PASO 3: Migrar datos existentes al nuevo formato
-- Usamos CASE para mapear todos los nombres posibles

UPDATE groups 
SET 
  level = CASE 
    WHEN LOWER(TRIM(name)) LIKE '%lactante%' THEN 'lactantes'::GroupLevel
    WHEN LOWER(TRIM(name)) LIKE '%maternal%' THEN 'maternal'::GroupLevel
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 1%' OR LOWER(TRIM(name)) LIKE '%preescolar1%' THEN 'preescolar_1'::GroupLevel
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 2%' OR LOWER(TRIM(name)) LIKE '%preescolar2%' THEN 'preescolar_2'::GroupLevel
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 3%' OR LOWER(TRIM(name)) LIKE '%preescolar3%' THEN 'preescolar_3'::GroupLevel
    ELSE 'lactantes'::GroupLevel -- Default fallback
  END,
  friendly_name = CASE 
    WHEN LOWER(TRIM(name)) LIKE '%lactante%' THEN 'Abejitas 🐝'
    WHEN LOWER(TRIM(name)) LIKE '%maternal%' THEN 'Mariposas 🦋'
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 1%' OR LOWER(TRIM(name)) LIKE '%preescolar1%' THEN 'Catarinas 🐞'
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 2%' OR LOWER(TRIM(name)) LIKE '%preescolar2%' THEN 'Ranitas 🐸'
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 3%' OR LOWER(TRIM(name)) LIKE '%preescolar3%' THEN 'Tortuguitas 🐢'
    ELSE 'Abejitas 🐝' -- Default fallback
  END,
  subgroup = CASE
    WHEN UPPER(TRIM(name)) LIKE '% A' OR UPPER(TRIM(name)) LIKE '%A' THEN 'A'
    WHEN UPPER(TRIM(name)) LIKE '% B' OR UPPER(TRIM(name)) LIKE '%B' THEN 'B'
    WHEN UPPER(TRIM(name)) LIKE '% C' OR UPPER(TRIM(name)) LIKE '%C' THEN 'C'
    ELSE NULL
  END,
  age_range_min = CASE 
    WHEN LOWER(TRIM(name)) LIKE '%lactante%' THEN 0
    WHEN LOWER(TRIM(name)) LIKE '%maternal%' THEN 12
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 1%' OR LOWER(TRIM(name)) LIKE '%preescolar1%' THEN 36
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 2%' OR LOWER(TRIM(name)) LIKE '%preescolar2%' THEN 48
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 3%' OR LOWER(TRIM(name)) LIKE '%preescolar3%' THEN 60
    ELSE age_range_min -- Keep existing if already set
  END,
  age_range_max = CASE 
    WHEN LOWER(TRIM(name)) LIKE '%lactante%' THEN 12
    WHEN LOWER(TRIM(name)) LIKE '%maternal%' THEN 36
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 1%' OR LOWER(TRIM(name)) LIKE '%preescolar1%' THEN 48
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 2%' OR LOWER(TRIM(name)) LIKE '%preescolar2%' THEN 60
    WHEN LOWER(TRIM(name)) LIKE '%preescolar 3%' OR LOWER(TRIM(name)) LIKE '%preescolar3%' THEN 72
    ELSE age_range_max -- Keep existing if already set
  END
WHERE level IS NULL;

-- PASO 4: Hacer las columnas NOT NULL después de migrar datos
ALTER TABLE groups 
  ALTER COLUMN level SET NOT NULL,
  ALTER COLUMN friendly_name SET NOT NULL;

-- PASO 5: Crear índices para búsquedas por nivel
CREATE INDEX IF NOT EXISTS idx_groups_level ON groups(level);
CREATE INDEX IF NOT EXISTS idx_groups_tenant_level ON groups(tenant_id, level);

-- PASO 6: Verificar migración
SELECT 
  id,
  name AS old_name,
  level,
  friendly_name,
  subgroup,
  age_range_min || '-' || age_range_max || ' meses' AS age_range,
  capacity,
  academic_year
FROM groups
ORDER BY level, subgroup;

-- Resumen de cambios
SELECT 
  level,
  COUNT(*) AS total_groups,
  STRING_AGG(DISTINCT COALESCE(subgroup, 'sin subgrupo'), ', ') AS subgroups
FROM groups
GROUP BY level
ORDER BY level;
