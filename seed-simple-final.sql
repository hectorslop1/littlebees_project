-- Script de datos de prueba SIMPLIFICADO para LittleBees
-- Solo crea lo esencial: tenant, usuarios, grupos y niños

-- 1. Crear Tenant
INSERT INTO tenants (id, name, slug, phone, email, timezone, locale, subscription_status, settings, created_at, updated_at)
VALUES 
  ('d3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Guardería Petit Soleil', 'petit-soleil', '555-0100', 'info@petitsoleil.com', 'America/Mexico_City', 'es-MX', 'active', '{}', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- 2. Crear Usuarios
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, mfa_enabled, email_verified, created_at, updated_at)
VALUES 
  ('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'maria.garcia@petitsoleil.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'María', 'García', '555-0101', false, true, NOW(), NOW()),
  ('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'ana.lopez@petitsoleil.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Ana', 'López', '555-0102', false, true, NOW(), NOW()),
  ('c3d4e5f6-a7b8-4c5d-0e1f-2a3b4c5d6e7f', 'carmen.ruiz@petitsoleil.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Carmen', 'Ruiz', '555-0103', false, true, NOW(), NOW()),
  ('d4e5f6a7-b8c9-4d5e-1f2a-3b4c5d6e7f8a', 'juan.perez@email.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Juan', 'Pérez', '555-0201', false, true, NOW(), NOW()),
  ('e5f6a7b8-c9d0-4e5f-2a3b-4c5d6e7f8a9b', 'laura.martinez@email.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Laura', 'Martínez', '555-0202', false, true, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

-- 3. Relacionar usuarios con tenant y asignar roles
INSERT INTO user_tenants (user_id, tenant_id, role, active, joined_at)
VALUES 
  ('a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'director', true, NOW()),
  ('b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'teacher', true, NOW()),
  ('c3d4e5f6-a7b8-4c5d-0e1f-2a3b4c5d6e7f', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'teacher', true, NOW()),
  ('d4e5f6a7-b8c9-4d5e-1f2a-3b4c5d6e7f8a', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'parent', true, NOW()),
  ('e5f6a7b8-c9d0-4e5f-2a3b-4c5d6e7f8a9b', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'parent', true, NOW())
ON CONFLICT (user_id, tenant_id) DO UPDATE SET role = EXCLUDED.role;

-- 4. Crear Grupos
INSERT INTO groups (id, tenant_id, name, age_range_min, age_range_max, capacity, color, academic_year, teacher_id, created_at, updated_at)
VALUES 
  ('f6a7b8c9-d0e1-4f5a-3b4c-5d6e7f8a9b0c', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Lactantes A', 0, 12, 10, '#FF6B6B', '2025-2026', 'b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', NOW(), NOW()),
  ('a7b8c9d0-e1f2-4a5b-4c5d-6e7f8a9b0c1d', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Maternal B', 13, 24, 12, '#4ECDC4', '2025-2026', 'c3d4e5f6-a7b8-4c5d-0e1f-2a3b4c5d6e7f', NOW(), NOW()),
  ('b8c9d0e1-f2a3-4b5c-5d6e-7f8a9b0c1d2e', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Preescolar C', 25, 48, 15, '#95E1D3', '2025-2026', 'b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- 5. Crear Niños
INSERT INTO children (id, tenant_id, first_name, last_name, date_of_birth, gender, group_id, enrollment_date, status, created_at, updated_at)
VALUES 
  ('c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Sofía', 'Pérez Martínez', '2024-06-15', 'female', 'f6a7b8c9-d0e1-4f5a-3b4c-5d6e7f8a9b0c', '2025-01-15', 'active', NOW(), NOW()),
  ('d0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Diego', 'González', '2024-08-20', 'male', 'f6a7b8c9-d0e1-4f5a-3b4c-5d6e7f8a9b0c', '2025-02-01', 'active', NOW(), NOW()),
  ('e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Emma', 'Rodríguez', '2023-05-10', 'female', 'a7b8c9d0-e1f2-4a5b-4c5d-6e7f8a9b0c1d', '2024-09-01', 'active', NOW(), NOW()),
  ('f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Lucas', 'Hernández', '2023-03-22', 'male', 'a7b8c9d0-e1f2-4a5b-4c5d-6e7f8a9b0c1d', '2024-09-01', 'active', NOW(), NOW()),
  ('a3b4c5d6-e7f8-4a9b-0c1d-2e3f4a5b6c7d', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Valentina', 'López', '2022-01-15', 'female', 'b8c9d0e1-f2a3-4b5c-5d6e-7f8a9b0c1d2e', '2024-08-15', 'active', NOW(), NOW()),
  ('b4c5d6e7-f8a9-4b0c-1d2e-3f4a5b6c7d8e', 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c', 'Mateo', 'Sánchez', '2022-11-30', 'male', 'b8c9d0e1-f2a3-4b5c-5d6e-7f8a9b0c1d2e', '2024-08-15', 'active', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET first_name = EXCLUDED.first_name;

-- 6. Relacionar niños con padres
INSERT INTO child_parents (child_id, user_id, relationship, is_primary, can_pickup)
VALUES 
  ('c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f', 'd4e5f6a7-b8c9-4d5e-1f2a-3b4c5d6e7f8a', 'father', true, true),
  ('c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f', 'e5f6a7b8-c9d0-4e5f-2a3b-4c5d6e7f8a9b', 'mother', true, true),
  ('d0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a', 'd4e5f6a7-b8c9-4d5e-1f2a-3b4c5d6e7f8a', 'father', true, true),
  ('e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 'e5f6a7b8-c9d0-4e5f-2a3b-4c5d6e7f8a9b', 'mother', true, true)
ON CONFLICT (child_id, user_id) DO NOTHING;

-- Resumen
SELECT 'Datos de prueba creados exitosamente' AS status;
SELECT COUNT(*) AS total_grupos FROM groups WHERE tenant_id = 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c';
SELECT COUNT(*) AS total_ninos FROM children WHERE tenant_id = 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c';
SELECT COUNT(*) AS total_usuarios FROM user_tenants WHERE tenant_id = 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c';

-- Información de login
SELECT '=== USUARIOS PARA LOGIN ===' AS info;
SELECT 
  u.email, 
  'password123' AS password_hint,
  ut.role
FROM users u
JOIN user_tenants ut ON u.id = ut.user_id
WHERE ut.tenant_id = 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c'
ORDER BY ut.role;
