-- Verificar estado actual de niños
SELECT 
  'ESTADO ACTUAL DE NIÑOS:' as info;

SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN group_id IS NOT NULL THEN 1 END) as con_grupo,
  COUNT(CASE WHEN group_id IS NULL THEN 1 END) as sin_grupo,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as activos
FROM children;

-- Ver niños sin grupo
SELECT 
  'NIÑOS SIN GRUPO:' as info;
  
SELECT 
  id,
  first_name,
  last_name,
  date_of_birth,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
  EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) as edad_meses,
  status
FROM children
WHERE group_id IS NULL
LIMIT 5;

-- Reasignar niños a grupos según edad
DO $$
DECLARE
  v_group_lactantes UUID;
  v_group_maternal UUID;
  v_group_preescolar1 UUID;
  v_group_preescolar2 UUID;
  v_group_preescolar3 UUID;
  v_edad_meses INT;
BEGIN
  -- Obtener IDs de grupos
  SELECT id INTO v_group_lactantes FROM groups WHERE level = 'lactantes' LIMIT 1;
  SELECT id INTO v_group_maternal FROM groups WHERE level = 'maternal' LIMIT 1;
  SELECT id INTO v_group_preescolar1 FROM groups WHERE level = 'preescolar_1' LIMIT 1;
  SELECT id INTO v_group_preescolar2 FROM groups WHERE level = 'preescolar_2' LIMIT 1;
  SELECT id INTO v_group_preescolar3 FROM groups WHERE level = 'preescolar_3' LIMIT 1;

  -- Asignar cada niño según su edad
  FOR v_edad_meses IN 
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
           EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth))
    FROM children
  LOOP
    IF v_edad_meses >= 0 AND v_edad_meses <= 12 THEN
      UPDATE children 
      SET group_id = v_group_lactantes
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    ELSIF v_edad_meses > 12 AND v_edad_meses <= 36 THEN
      UPDATE children 
      SET group_id = v_group_maternal
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    ELSIF v_edad_meses > 36 AND v_edad_meses <= 48 THEN
      UPDATE children 
      SET group_id = v_group_preescolar1
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    ELSIF v_edad_meses > 48 AND v_edad_meses <= 60 THEN
      UPDATE children 
      SET group_id = v_group_preescolar2
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    ELSIF v_edad_meses > 60 AND v_edad_meses <= 72 THEN
      UPDATE children 
      SET group_id = v_group_preescolar3
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    ELSE
      -- Niños mayores de 72 meses van a Preescolar 3
      UPDATE children 
      SET group_id = v_group_preescolar3
      WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) = v_edad_meses
        AND group_id IS NULL;
    END IF;
  END LOOP;
END $$;

-- Verificar asignación final
SELECT 
  'RESULTADO FINAL:' as info;

SELECT 
  g.friendly_name,
  g.age_range_min || '-' || g.age_range_max || ' meses' as rango,
  COUNT(c.id) as ninos_asignados,
  g.capacity
FROM groups g
LEFT JOIN children c ON c.group_id = g.id AND c.status = 'active'
GROUP BY g.id, g.friendly_name, g.age_range_min, g.age_range_max, g.capacity
ORDER BY g.age_range_min;
