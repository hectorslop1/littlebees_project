-- Asignar Ana López a TODOS los grupos

DO $$
DECLARE
  v_ana_id UUID;
  v_groups_updated INT;
BEGIN
  -- Buscar ID de Ana López
  SELECT u.id INTO v_ana_id
  FROM users u
  WHERE u.first_name ILIKE '%Ana%' AND u.last_name ILIKE '%López%'
  LIMIT 1;

  IF v_ana_id IS NULL THEN
    RAISE NOTICE 'Usuario Ana López no encontrado';
  ELSE
    -- Asignar Ana López como teacher a TODOS los grupos
    UPDATE groups 
    SET teacher_id = v_ana_id;
    
    GET DIAGNOSTICS v_groups_updated = ROW_COUNT;
    
    RAISE NOTICE 'Ana López (%) asignada a % grupos', v_ana_id, v_groups_updated;
  END IF;
END $$;

-- Verificar asignación
SELECT 
  'GRUPOS ASIGNADOS A ANA LÓPEZ:' as info;

SELECT 
  g.friendly_name as grupo,
  g.age_range_min || '-' || g.age_range_max || ' meses' as rango,
  COUNT(c.id) as ninos_activos,
  g.capacity as capacidad
FROM groups g
LEFT JOIN children c ON c.group_id = g.id AND c.status = 'active'
WHERE g.teacher_id IN (
  SELECT id FROM users WHERE first_name ILIKE '%Ana%' AND last_name ILIKE '%López%'
)
GROUP BY g.id, g.friendly_name, g.age_range_min, g.age_range_max, g.capacity
ORDER BY g.age_range_min;

-- Verificar total de niños que Ana López debería ver
SELECT 
  'TOTAL DE NIÑOS QUE ANA LÓPEZ PUEDE VER:' as info;

SELECT 
  COUNT(DISTINCT c.id) as total_ninos
FROM children c
WHERE c.group_id IN (
  SELECT g.id 
  FROM groups g
  WHERE g.teacher_id IN (
    SELECT id FROM users WHERE first_name ILIKE '%Ana%' AND last_name ILIKE '%López%'
  )
)
AND c.status = 'active';
