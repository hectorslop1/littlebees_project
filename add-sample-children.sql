-- Agregar niños de prueba sin eliminar los existentes

DO $$
DECLARE
  v_tenant_id UUID;
  v_group_lactantes UUID;
  v_group_maternal UUID;
  v_group_preescolar1 UUID;
  v_group_preescolar2 UUID;
  v_group_preescolar3 UUID;
  v_existing_count INT;
BEGIN
  -- Verificar cuántos niños existen
  SELECT COUNT(*) INTO v_existing_count FROM children;
  
  IF v_existing_count > 0 THEN
    RAISE NOTICE 'Ya existen % niños en la base de datos', v_existing_count;
    
    -- Actualizar group_id de niños existentes que no tengan grupo
    SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
    SELECT id INTO v_group_lactantes FROM groups WHERE level = 'lactantes';
    SELECT id INTO v_group_maternal FROM groups WHERE level = 'maternal';
    SELECT id INTO v_group_preescolar1 FROM groups WHERE level = 'preescolar_1';
    SELECT id INTO v_group_preescolar2 FROM groups WHERE level = 'preescolar_2';
    SELECT id INTO v_group_preescolar3 FROM groups WHERE level = 'preescolar_3';
    
    -- Asignar niños sin grupo según su edad
    UPDATE children 
    SET group_id = v_group_lactantes
    WHERE group_id IS NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
          EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 0 AND 12;

    UPDATE children 
    SET group_id = v_group_maternal
    WHERE group_id IS NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
          EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 13 AND 36;

    UPDATE children 
    SET group_id = v_group_preescolar1
    WHERE group_id IS NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
          EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 37 AND 48;

    UPDATE children 
    SET group_id = v_group_preescolar2
    WHERE group_id IS NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
          EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 49 AND 60;

    UPDATE children 
    SET group_id = v_group_preescolar3
    WHERE group_id IS NULL
      AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
          EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) > 60;
    
    RAISE NOTICE 'Niños existentes actualizados con grupos correctos';
  ELSE
    RAISE NOTICE 'No hay niños en la base de datos. Crear datos de prueba manualmente.';
  END IF;
END $$;

-- Mostrar estado actual
SELECT 'NIÑOS POR GRUPO:' as info;
SELECT 
  g.friendly_name as grupo,
  COUNT(c.id) as total_ninos,
  COUNT(CASE WHEN c.status = 'active' THEN 1 END) as activos
FROM groups g
LEFT JOIN children c ON c.group_id = g.id
GROUP BY g.id, g.friendly_name, g.age_range_min
ORDER BY g.age_range_min;

SELECT 'TOTAL DE NIÑOS:' as info;
SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as activos,
  COUNT(CASE WHEN group_id IS NOT NULL THEN 1 END) as con_grupo
FROM children;
