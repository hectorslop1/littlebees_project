-- Asignar maestras a grupos para que puedan ver niños

-- Ver maestras disponibles
SELECT 
  'MAESTRAS DISPONIBLES:' as info;

SELECT 
  u.id,
  u.first_name,
  u.last_name,
  u.email,
  ut.role
FROM users u
JOIN user_tenants ut ON u.id = ut.user_id
WHERE ut.role = 'teacher';

-- Asignar una maestra a cada grupo
DO $$
DECLARE
  v_teacher_id UUID;
BEGIN
  -- Obtener primera maestra disponible
  SELECT u.id INTO v_teacher_id
  FROM users u
  JOIN user_tenants ut ON u.id = ut.user_id
  WHERE ut.role = 'teacher'
  LIMIT 1;

  -- Si hay maestra, asignarla a todos los grupos
  IF v_teacher_id IS NOT NULL THEN
    UPDATE groups SET teacher_id = v_teacher_id;
    
    RAISE NOTICE 'Maestra asignada a todos los grupos: %', v_teacher_id;
  ELSE
    RAISE NOTICE 'No hay maestras disponibles';
  END IF;
END $$;

-- Verificar asignación
SELECT 
  'GRUPOS CON MAESTRAS ASIGNADAS:' as info;

SELECT 
  g.friendly_name,
  COALESCE(u.first_name || ' ' || u.last_name, 'Sin maestra') as maestra,
  COUNT(c.id) as ninos
FROM groups g
LEFT JOIN users u ON g.teacher_id = u.id
LEFT JOIN children c ON c.group_id = g.id AND c.status = 'active'
GROUP BY g.id, g.friendly_name, u.first_name, u.last_name
ORDER BY g.age_range_min;
