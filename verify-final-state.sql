-- Verificación final del estado del sistema

-- 1. Total de grupos
SELECT '=== GRUPOS CREADOS ===' as info;
SELECT 
  level,
  friendly_name,
  age_range_min || '-' || age_range_max || ' meses' as rango,
  capacity,
  (SELECT COUNT(*) FROM children WHERE group_id = groups.id AND status = 'active') as ninos_activos
FROM groups
ORDER BY age_range_min;

-- 2. Total de niños por estado
SELECT '=== NIÑOS POR ESTADO ===' as info;
SELECT 
  status,
  COUNT(*) as total
FROM children
GROUP BY status;

-- 3. Niños por grupo
SELECT '=== NIÑOS POR GRUPO ===' as info;
SELECT 
  g.friendly_name as grupo,
  COUNT(c.id) as total_ninos,
  COUNT(CASE WHEN c.status = 'active' THEN 1 END) as activos,
  COUNT(CASE WHEN c.status = 'inactive' THEN 1 END) as inactivos
FROM groups g
LEFT JOIN children c ON c.group_id = g.id
GROUP BY g.id, g.friendly_name, g.age_range_min
ORDER BY g.age_range_min;

-- 4. Verificar que todos los niños tengan grupo
SELECT '=== NIÑOS SIN GRUPO ===' as info;
SELECT COUNT(*) as ninos_sin_grupo
FROM children
WHERE group_id IS NULL;

-- 5. Maestras asignadas
SELECT '=== MAESTRAS POR GRUPO ===' as info;
SELECT 
  g.friendly_name as grupo,
  COALESCE(u.first_name || ' ' || u.last_name, 'Sin maestra') as maestra
FROM groups g
LEFT JOIN users u ON g.teacher_id = u.id
ORDER BY g.age_range_min;
