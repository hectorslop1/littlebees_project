-- Verificar si hay niños en la base de datos

-- 1. Contar niños totales
SELECT 'TOTAL DE NIÑOS EN BD:' as info;
SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as activos,
  COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactivos
FROM children;

-- 2. Ver algunos niños de ejemplo
SELECT 'EJEMPLOS DE NIÑOS:' as info;
SELECT 
  c.first_name,
  c.last_name,
  c.status,
  g.friendly_name as grupo,
  c.date_of_birth,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.date_of_birth)) || ' años ' ||
  EXTRACT(MONTH FROM AGE(CURRENT_DATE, c.date_of_birth)) || ' meses' as edad
FROM children c
LEFT JOIN groups g ON c.group_id = g.id
LIMIT 10;

-- 3. Verificar niños sin grupo
SELECT 'NIÑOS SIN GRUPO ASIGNADO:' as info;
SELECT COUNT(*) as sin_grupo
FROM children
WHERE group_id IS NULL;

-- 4. Distribución por grupo
SELECT 'DISTRIBUCIÓN POR GRUPO:' as info;
SELECT 
  COALESCE(g.friendly_name, 'SIN GRUPO') as grupo,
  COUNT(c.id) as total_ninos,
  COUNT(CASE WHEN c.status = 'active' THEN 1 END) as activos
FROM children c
LEFT JOIN groups g ON c.group_id = g.id
GROUP BY g.id, g.friendly_name, g.age_range_min
ORDER BY g.age_range_min NULLS LAST;
