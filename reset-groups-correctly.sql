-- ============================================================
-- RESET COMPLETO DE GRUPOS - CREAR SOLO GRUPOS CORRECTOS
-- ============================================================

-- PASO 1: Ver grupos actuales (para referencia)
SELECT 'GRUPOS ACTUALES (ANTES DE LIMPIAR):' as info;
SELECT id, name, level, friendly_name, subgroup, age_range_min, age_range_max 
FROM groups 
ORDER BY level, subgroup;

-- PASO 2: Desvincular niños de grupos (temporal)
UPDATE children SET group_id = NULL WHERE group_id IS NOT NULL;

-- PASO 3: ELIMINAR TODOS LOS GRUPOS EXISTENTES
DELETE FROM groups;

-- PASO 4: Obtener tenant_id (asumiendo que hay un solo tenant)
DO $$
DECLARE
  v_tenant_id UUID;
  v_teacher_id UUID;
BEGIN
  -- Obtener el primer tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Obtener una maestra para asignar (opcional)
  SELECT u.id INTO v_teacher_id 
  FROM users u 
  JOIN user_tenants ut ON u.id = ut.user_id 
  WHERE ut.role = 'teacher' 
  LIMIT 1;

  -- PASO 5: CREAR GRUPOS CORRECTOS
  -- Según especificación:
  -- Lactantes → Abejitas 🐝 (0-12 meses)
  -- Maternal → Mariposas 🦋 (12-36 meses)
  -- Preescolar 1 → Catarinas 🐞 (36-48 meses)
  -- Preescolar 2 → Ranitas 🐸 (48-60 meses)
  -- Preescolar 3 → Tortuguitas 🐢 (60-72 meses)

  -- Lactantes - Abejitas 🐝
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Lactantes', 'lactantes', 'Abejitas 🐝', NULL,
    0, 12, 10, '#FFD93D', '2025-2026', v_teacher_id
  );

  -- Maternal - Mariposas 🦋
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Maternal', 'maternal', 'Mariposas 🦋', NULL,
    12, 36, 15, '#FF6B9D', '2025-2026', v_teacher_id
  );

  -- Preescolar 1 - Catarinas 🐞
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 1', 'preescolar_1', 'Catarinas 🐞', NULL,
    36, 48, 20, '#FF6B6B', '2025-2026', v_teacher_id
  );

  -- Preescolar 2 - Ranitas 🐸
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 2', 'preescolar_2', 'Ranitas 🐸', NULL,
    48, 60, 20, '#95E1D3', '2025-2026', v_teacher_id
  );

  -- Preescolar 3 - Tortuguitas 🐢
  INSERT INTO groups (
    id, tenant_id, name, level, friendly_name, subgroup,
    age_range_min, age_range_max, capacity, color, academic_year, teacher_id
  ) VALUES (
    gen_random_uuid(), v_tenant_id, 'Preescolar 3', 'preescolar_3', 'Tortuguitas 🐢', NULL,
    60, 72, 20, '#4ECDC4', '2025-2026', v_teacher_id
  );

END $$;

-- PASO 6: Verificar grupos creados
SELECT 'GRUPOS CREADOS (CORRECTOS):' as info;
SELECT 
  level,
  friendly_name,
  subgroup,
  age_range_min || '-' || age_range_max || ' meses' as rango_edad,
  capacity,
  color
FROM groups
ORDER BY level;

-- PASO 7: Contar grupos por nivel
SELECT 'RESUMEN POR NIVEL:' as info;
SELECT 
  level,
  friendly_name,
  COUNT(*) as total
FROM groups
GROUP BY level, friendly_name
ORDER BY level;
