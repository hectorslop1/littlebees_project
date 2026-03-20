-- ============================================================
-- RESET COMPLETO DE GRUPOS - CREAR SOLO GRUPOS CORRECTOS
-- ============================================================

-- PASO 1: Desvincular niños de grupos primero
UPDATE children SET group_id = NULL;

-- PASO 2: ELIMINAR TODOS LOS GRUPOS EXISTENTES
DELETE FROM groups;

-- PASO 3: CREAR GRUPOS CORRECTOS
DO $$
DECLARE
  v_tenant_id UUID;
  v_teacher_id UUID;
BEGIN
  -- Obtener el primer tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Obtener una maestra para asignar
  SELECT u.id INTO v_teacher_id 
  FROM users u 
  JOIN user_tenants ut ON u.id = ut.user_id 
  WHERE ut.role = 'teacher' 
  LIMIT 1;

  -- CREAR EXACTAMENTE 5 GRUPOS SEGÚN ESPECIFICACIÓN:

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

  -- 2. Maternal → Mariposas 🦋 (12-36 meses = 1-3 años)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Maternal', 'maternal', 'Mariposas 🦋', NULL,
    12, 36, 15, '#FF6B9D', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 3. Preescolar 1 → Catarinas 🐞 (36-48 meses = 3-4 años)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 1', 'preescolar_1', 'Catarinas 🐞', NULL,
    36, 48, 20, '#FF6B6B', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 4. Preescolar 2 → Ranitas 🐸 (48-60 meses = 4-5 años)
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id,
    created_at, updated_at
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 2', 'preescolar_2', 'Ranitas 🐸', NULL,
    48, 60, 20, '#95E1D3', '2025-2026', v_teacher_id,
    NOW(), NOW()
  );

  -- 5. Preescolar 3 → Tortuguitas 🐢 (60-72 meses = 5-6 años)
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

-- PASO 4: Verificar que SOLO hay 5 grupos
SELECT 
  'TOTAL DE GRUPOS CREADOS: ' || COUNT(*) as verificacion
FROM groups;

-- PASO 5: Mostrar grupos creados
SELECT 
  level as nivel,
  friendly_name as nombre_amigable,
  COALESCE(subgroup, 'N/A') as subgrupo,
  age_range_min || '-' || age_range_max || ' meses' as rango_edad,
  capacity as capacidad,
  color
FROM groups
ORDER BY 
  CASE level
    WHEN 'lactantes' THEN 1
    WHEN 'maternal' THEN 2
    WHEN 'preescolar_1' THEN 3
    WHEN 'preescolar_2' THEN 4
    WHEN 'preescolar_3' THEN 5
  END;

-- PASO 6: Verificar que NO hay duplicados
SELECT 
  level,
  friendly_name,
  COUNT(*) as cantidad
FROM groups
GROUP BY level, friendly_name
HAVING COUNT(*) > 1;
