-- ============================================================
-- AGREGAR CAMPOS LEVEL, FRIENDLY_NAME Y SUBGROUP A GROUPS
-- ============================================================

-- PASO 1: Crear enum GroupLevel si no existe
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

-- PASO 2: Agregar columnas (nullable temporalmente)
ALTER TABLE groups ADD COLUMN IF NOT EXISTS level "GroupLevel";
ALTER TABLE groups ADD COLUMN IF NOT EXISTS friendly_name VARCHAR(100);
ALTER TABLE groups ADD COLUMN IF NOT EXISTS subgroup VARCHAR(10);

-- PASO 3: Poblar datos basados en el nombre actual (con CAST explícito)
UPDATE groups 
SET 
  level = (CASE 
    WHEN name ILIKE '%lactante%' THEN 'lactantes'
    WHEN name ILIKE '%maternal%' THEN 'maternal'
    WHEN name ILIKE '%preescolar%1%' OR name ILIKE '%preescolar 1%' THEN 'preescolar_1'
    WHEN name ILIKE '%preescolar%2%' OR name ILIKE '%preescolar 2%' THEN 'preescolar_2'
    WHEN name ILIKE '%preescolar%3%' OR name ILIKE '%preescolar 3%' THEN 'preescolar_3'
    ELSE 'lactantes'
  END)::"GroupLevel",
  friendly_name = CASE 
    WHEN name ILIKE '%lactante%' THEN 'Abejitas 🐝'
    WHEN name ILIKE '%maternal%' THEN 'Mariposas 🦋'
    WHEN name ILIKE '%preescolar%1%' OR name ILIKE '%preescolar 1%' THEN 'Catarinas 🐞'
    WHEN name ILIKE '%preescolar%2%' OR name ILIKE '%preescolar 2%' THEN 'Ranitas 🐸'
    WHEN name ILIKE '%preescolar%3%' OR name ILIKE '%preescolar 3%' THEN 'Tortuguitas 🐢'
    ELSE 'Abejitas 🐝'
  END,
  subgroup = CASE
    WHEN name ILIKE '% A' OR name ILIKE '%A' THEN 'A'
    WHEN name ILIKE '% B' OR name ILIKE '%B' THEN 'B'
    WHEN name ILIKE '% C' OR name ILIKE '%C' THEN 'C'
    ELSE NULL
  END
WHERE level IS NULL;

-- PASO 4: Hacer NOT NULL
ALTER TABLE groups ALTER COLUMN level SET NOT NULL;
ALTER TABLE groups ALTER COLUMN friendly_name SET NOT NULL;

-- PASO 5: Crear índices
CREATE INDEX IF NOT EXISTS idx_groups_level ON groups(level);
CREATE INDEX IF NOT EXISTS idx_groups_tenant_level ON groups(tenant_id, level);

-- Verificación
SELECT 
  name AS nombre_original,
  level AS nivel,
  friendly_name AS nombre_amigable,
  subgroup AS subgrupo,
  age_range_min || '-' || age_range_max AS rango_edad_meses
FROM groups
ORDER BY level, subgroup;
