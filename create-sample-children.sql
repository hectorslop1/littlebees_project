-- Crear niños de prueba para cada grupo

DO $$
DECLARE
  v_tenant_id UUID;
  v_group_lactantes UUID;
  v_group_maternal UUID;
  v_group_preescolar1 UUID;
  v_group_preescolar2 UUID;
  v_group_preescolar3 UUID;
BEGIN
  -- Obtener tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Obtener IDs de grupos
  SELECT id INTO v_group_lactantes FROM groups WHERE level = 'lactantes';
  SELECT id INTO v_group_maternal FROM groups WHERE level = 'maternal';
  SELECT id INTO v_group_preescolar1 FROM groups WHERE level = 'preescolar_1';
  SELECT id INTO v_group_preescolar2 FROM groups WHERE level = 'preescolar_2';
  SELECT id INTO v_group_preescolar3 FROM groups WHERE level = 'preescolar_3';

  -- Eliminar niños existentes para empezar limpio
  DELETE FROM children;

  -- LACTANTES (0-12 meses) - 3 niños
  INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_tenant_id, 'Emma', 'García', CURRENT_DATE - INTERVAL '6 months', 'female', v_group_lactantes, CURRENT_DATE - INTERVAL '1 month', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Lucas', 'Martínez', CURRENT_DATE - INTERVAL '9 months', 'male', v_group_lactantes, CURRENT_DATE - INTERVAL '2 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Sofía', 'López', CURRENT_DATE - INTERVAL '11 months', 'female', v_group_lactantes, CURRENT_DATE - INTERVAL '3 months', 'active', NOW(), NOW());

  -- MATERNAL (12-36 meses) - 4 niños
  INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_tenant_id, 'Mateo', 'Rodríguez', CURRENT_DATE - INTERVAL '18 months', 'male', v_group_maternal, CURRENT_DATE - INTERVAL '6 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Valentina', 'Hernández', CURRENT_DATE - INTERVAL '24 months', 'female', v_group_maternal, CURRENT_DATE - INTERVAL '8 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Diego', 'González', CURRENT_DATE - INTERVAL '30 months', 'male', v_group_maternal, CURRENT_DATE - INTERVAL '10 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Isabella', 'Pérez', CURRENT_DATE - INTERVAL '20 months', 'female', v_group_maternal, CURRENT_DATE - INTERVAL '5 months', 'active', NOW(), NOW());

  -- PREESCOLAR 1 (36-48 meses) - 5 niños
  INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_tenant_id, 'Santiago', 'Ramírez', CURRENT_DATE - INTERVAL '40 months', 'male', v_group_preescolar1, CURRENT_DATE - INTERVAL '12 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Camila', 'Torres', CURRENT_DATE - INTERVAL '42 months', 'female', v_group_preescolar1, CURRENT_DATE - INTERVAL '14 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Sebastián', 'Flores', CURRENT_DATE - INTERVAL '38 months', 'male', v_group_preescolar1, CURRENT_DATE - INTERVAL '10 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Mía', 'Sánchez', CURRENT_DATE - INTERVAL '45 months', 'female', v_group_preescolar1, CURRENT_DATE - INTERVAL '16 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Alejandro', 'Morales', CURRENT_DATE - INTERVAL '37 months', 'male', v_group_preescolar1, CURRENT_DATE - INTERVAL '9 months', 'active', NOW(), NOW());

  -- PREESCOLAR 2 (48-60 meses) - 5 niños
  INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_tenant_id, 'Emiliano', 'Castro', CURRENT_DATE - INTERVAL '52 months', 'male', v_group_preescolar2, CURRENT_DATE - INTERVAL '18 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Regina', 'Ortiz', CURRENT_DATE - INTERVAL '55 months', 'female', v_group_preescolar2, CURRENT_DATE - INTERVAL '20 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Maximiliano', 'Vargas', CURRENT_DATE - INTERVAL '50 months', 'male', v_group_preescolar2, CURRENT_DATE - INTERVAL '16 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Renata', 'Mendoza', CURRENT_DATE - INTERVAL '58 months', 'female', v_group_preescolar2, CURRENT_DATE - INTERVAL '22 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Joaquín', 'Ruiz', CURRENT_DATE - INTERVAL '49 months', 'male', v_group_preescolar2, CURRENT_DATE - INTERVAL '15 months', 'active', NOW(), NOW());

  -- PREESCOLAR 3 (60-72 meses) - 5 niños
  INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_tenant_id, 'Ángel', 'Jiménez', CURRENT_DATE - INTERVAL '65 months', 'male', v_group_preescolar3, CURRENT_DATE - INTERVAL '24 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Daniela', 'Romero', CURRENT_DATE - INTERVAL '68 months', 'female', v_group_preescolar3, CURRENT_DATE - INTERVAL '26 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Gabriel', 'Gutiérrez', CURRENT_DATE - INTERVAL '62 months', 'male', v_group_preescolar3, CURRENT_DATE - INTERVAL '22 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Valeria', 'Medina', CURRENT_DATE - INTERVAL '70 months', 'female', v_group_preescolar3, CURRENT_DATE - INTERVAL '28 months', 'active', NOW(), NOW()),
    (gen_random_uuid(), v_tenant_id, 'Leonardo', 'Aguilar', CURRENT_DATE - INTERVAL '64 months', 'male', v_group_preescolar3, CURRENT_DATE - INTERVAL '23 months', 'active', NOW(), NOW());

  RAISE NOTICE 'Creados 22 niños de prueba distribuidos en 5 grupos';
END $$;

-- Verificar creación
SELECT 'RESUMEN DE NIÑOS CREADOS:' as info;
SELECT 
  g.friendly_name as grupo,
  COUNT(c.id) as total_ninos,
  STRING_AGG(c.first_name || ' ' || c.last_name, ', ' ORDER BY c.first_name) as nombres
FROM groups g
LEFT JOIN children c ON c.group_id = g.id AND c.status = 'active'
GROUP BY g.id, g.friendly_name, g.age_range_min
ORDER BY g.age_range_min;

SELECT 'TOTAL GENERAL:' as info;
SELECT COUNT(*) as total_ninos_activos FROM children WHERE status = 'active';
