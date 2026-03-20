-- Verificar usuario Ana López y sus asignaciones

-- 1. Buscar usuario Ana López
SELECT '=== USUARIO ANA LÓPEZ ===' as info;
SELECT 
  u.id,
  u.first_name,
  u.last_name,
  u.email,
  ut.role,
  ut.tenant_id
FROM users u
JOIN user_tenants ut ON u.id = ut.user_id
WHERE u.first_name ILIKE '%Ana%' AND u.last_name ILIKE '%López%';

-- 2. Verificar grupos asignados a Ana López como teacher
SELECT '=== GRUPOS ASIGNADOS A ANA LÓPEZ ===' as info;
SELECT 
  g.id,
  g.friendly_name,
  g.age_range_min || '-' || g.age_range_max || ' meses' as rango,
  g.teacher_id,
  (SELECT COUNT(*) FROM children WHERE group_id = g.id AND status = 'active') as ninos_activos
FROM groups g
WHERE g.teacher_id IN (
  SELECT u.id 
  FROM users u 
  WHERE u.first_name ILIKE '%Ana%' AND u.last_name ILIKE '%López%'
);

-- 3. Ver todos los grupos y sus maestras
SELECT '=== TODOS LOS GRUPOS Y SUS MAESTRAS ===' as info;
SELECT 
  g.friendly_name as grupo,
  COALESCE(u.first_name || ' ' || u.last_name, 'Sin maestra') as maestra,
  g.teacher_id,
  (SELECT COUNT(*) FROM children WHERE group_id = g.id AND status = 'active') as ninos_activos
FROM groups g
LEFT JOIN users u ON g.teacher_id = u.id
ORDER BY g.age_range_min;

-- 4. Ver niños activos en total
SELECT '=== TOTAL DE NIÑOS ACTIVOS ===' as info;
SELECT 
  COUNT(*) as total_ninos_activos,
  COUNT(CASE WHEN group_id IS NOT NULL THEN 1 END) as con_grupo,
  COUNT(CASE WHEN group_id IS NULL THEN 1 END) as sin_grupo
FROM children
WHERE status = 'active';

-- 5. Ver distribución de niños por grupo
SELECT '=== NIÑOS POR GRUPO ===' as info;
SELECT 
  g.friendly_name,
  COUNT(c.id) as total_ninos
FROM groups g
LEFT JOIN children c ON c.group_id = g.id AND c.status = 'active'
GROUP BY g.id, g.friendly_name, g.age_range_min
ORDER BY g.age_range_min;
