-- Limpiar grupos duplicados y mantener solo grupos únicos por nivel y subgrupo

-- Primero, ver qué grupos tenemos
SELECT 
  id,
  name,
  level,
  friendly_name,
  subgroup,
  capacity,
  teacher_id
FROM groups
ORDER BY level, subgroup;

-- Eliminar grupos duplicados manteniendo solo uno por cada combinación de level + subgroup
-- Esto eliminará grupos que tengan el mismo level y subgroup (o ambos NULL)
DELETE FROM groups
WHERE id NOT IN (
  SELECT DISTINCT ON (level, COALESCE(subgroup, '')) id
  FROM groups
  ORDER BY level, COALESCE(subgroup, ''), created_at ASC
);

-- Verificar grupos restantes
SELECT 
  level,
  friendly_name,
  subgroup,
  COUNT(*) as total
FROM groups
GROUP BY level, friendly_name, subgroup
ORDER BY level, subgroup;
