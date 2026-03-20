-- ============================================================
-- SOLUCIÓN COMPLETA: LIMPIAR Y CREAR GRUPOS CORRECTOS
-- ============================================================

-- PASO 1: Hacer group_id nullable temporalmente
ALTER TABLE children ALTER COLUMN group_id DROP NOT NULL;

-- PASO 2: Desvincular todos los niños de sus grupos
UPDATE children SET group_id = NULL;

-- PASO 3: ELIMINAR TODOS LOS GRUPOS EXISTENTES
DELETE FROM groups;

-- PASO 4: CREAR EXACTAMENTE 5 GRUPOS CORRECTOS
DO $$
DECLARE
  v_tenant_id UUID;
  v_teacher_id UUID;
BEGIN
  -- Obtener tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Obtener maestra
  SELECT u.id INTO v_teacher_id 
  FROM users u 
  JOIN user_tenants ut ON u.id = ut.user_id 
  WHERE ut.role = 'teacher' 
  LIMIT 1;

  -- 1. Lactantes → Abejitas 🐝 (0-12 meses)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Lactantes', 'lactantes', 'Abejitas 🐝', NULL,
    0, 12, 10, '#FFD93D', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 2. Maternal → Mariposas 🦋 (12-36 meses)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Maternal', 'maternal', 'Mariposas 🦋', NULL,
    12, 36, 15, '#FF6B9D', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 3. Preescolar 1 → Catarinas 🐞 (36-48 meses)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 1', 'preescolar_1', 'Catarinas 🐞', NULL,
    36, 48, 20, '#FF6B6B', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 4. Preescolar 2 → Ranitas 🐸 (48-60 meses)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 2', 'preescolar_2', 'Ranitas 🐸', NULL,
    48, 60, 20, '#95E1D3', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 5. Preescolar 3 → Tortuguitas 🐢 (60-72 meses)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 3', 'preescolar_3', 'Tortuguitas 🐢', NULL,
    60, 72, 20, '#4ECDC4', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

END $$;

-- PASO 5: Asignar niños a grupos según su edad
DO $$
DECLARE
  v_group_lactantes UUID;
  v_group_maternal UUID;
  v_group_preescolar1 UUID;
  v_group_preescolar2 UUID;
  v_group_preescolar3 UUID;
BEGIN
  -- Obtener IDs de grupos
  SELECT id INTO v_group_lactantes FROM groups WHERE level = 'lactantes';
  SELECT id INTO v_group_maternal FROM groups WHERE level = 'maternal';
  SELECT id INTO v_group_preescolar1 FROM groups WHERE level = 'preescolar_1';
  SELECT id INTO v_group_preescolar2 FROM groups WHERE level = 'preescolar_2';
  SELECT id INTO v_group_preescolar3 FROM groups WHERE level = 'preescolar_3';

  -- Asignar niños según edad en meses
  -- Lactantes: 0-12 meses
  UPDATE children 
  SET group_id = v_group_lactantes
  WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 0 AND 12;

  -- Maternal: 12-36 meses
  UPDATE children 
  SET group_id = v_group_maternal
  WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 12 AND 36;

  -- Preescolar 1: 36-48 meses
  UPDATE children 
  SET group_id = v_group_preescolar1
  WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 36 AND 48;

  -- Preescolar 2: 48-60 meses
  UPDATE children 
  SET group_id = v_group_preescolar2
  WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 48 AND 60;

  -- Preescolar 3: 60-72 meses
  UPDATE children 
  SET group_id = v_group_preescolar3
  WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
        EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 60 AND 72;

END $$;

-- PASO 6: Restaurar constraint NOT NULL
ALTER TABLE children ALTER COLUMN group_id SET NOT NULL;

-- VERIFICACIONES FINALES
SELECT '=== GRUPOS CREADOS ===' as info;
SELECT 
  level,
  friendly_name,
  age_range_min || '-' || age_range_max || ' meses' as rango,
  capacity,
  (SELECT COUNT(*) FROM children WHERE group_id = groups.id) as ninos_asignados
FROM groups
ORDER BY 
  CASE level
    WHEN 'lactantes' THEN 1
    WHEN 'maternal' THEN 2
    WHEN 'preescolar_1' THEN 3
    WHEN 'preescolar_2' THEN 4
    WHEN 'preescolar_3' THEN 5
  END;

SELECT '=== VERIFICACIÓN: TOTAL DE GRUPOS ===' as info;
SELECT COUNT(*) as total_grupos FROM groups;

SELECT '=== VERIFICACIÓN: DUPLICADOS (DEBE ESTAR VACÍO) ===' as info;
SELECT level, friendly_name, COUNT(*) as cantidad
FROM groups
GROUP BY level, friendly_name
HAVING COUNT(*) > 1;
