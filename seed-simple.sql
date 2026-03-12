-- Script simplificado para agregar datos de prueba

-- Limpiar datos recientes
DELETE FROM attendance_records WHERE date >= CURRENT_DATE - INTERVAL '7 days';
DELETE FROM development_records WHERE evaluated_at >= CURRENT_DATE - INTERVAL '30 days';

-- Obtener IDs necesarios
DO $$
DECLARE
    v_tenant_id UUID;
    v_child_ids UUID[];
    v_user_id UUID;
    v_date DATE;
    i INT;
BEGIN
    SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
    SELECT id INTO v_user_id FROM users LIMIT 1;
    SELECT ARRAY_AGG(id) INTO v_child_ids FROM (SELECT id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 5) sub;

    -- Insertar asistencias de los últimos 7 días
    FOR i IN 0..6 LOOP
        v_date := CURRENT_DATE - i;
        
        -- Todos los niños presentes
        INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
        SELECT gen_random_uuid(), v_tenant_id, unnest(v_child_ids), v_date, 'present', v_date + TIME '08:00:00', v_user_id, 'manual', NOW(), NOW();
        
        -- Algunas tardanzas (cada 3 días)
        IF i % 3 = 0 AND array_length(v_child_ids, 1) >= 2 THEN
            UPDATE attendance_records 
            SET status = 'late', check_in_at = v_date + TIME '08:45:00'
            WHERE child_id = v_child_ids[2] AND date = v_date;
        END IF;
        
        -- Algunas ausencias
        IF i % 4 = 0 AND array_length(v_child_ids, 1) >= 4 THEN
            UPDATE attendance_records 
            SET status = 'absent', check_in_at = NULL, check_in_by = NULL, check_in_method = NULL
            WHERE child_id = v_child_ids[4] AND date = v_date;
        END IF;
    END LOOP;

    -- Insertar registros de desarrollo
    INSERT INTO development_records (id, tenant_id, child_id, milestone_id, status, evaluated_at, evaluated_by, created_at, updated_at)
    SELECT 
        gen_random_uuid(),
        v_tenant_id,
        v_child_ids[1],
        dm.id,
        'achieved',
        CURRENT_DATE - INTERVAL '5 days',
        v_user_id,
        NOW(),
        NOW()
    FROM development_milestones dm
    WHERE dm.category IN ('motor_fine', 'motor_gross', 'cognitive', 'language', 'social', 'emotional')
    ORDER BY dm.category, dm.age_range_min
    LIMIT 18;

    RAISE NOTICE 'Datos insertados correctamente: % registros de asistencia, % registros de desarrollo', 
        (SELECT COUNT(*) FROM attendance_records WHERE date >= CURRENT_DATE - INTERVAL '7 days'),
        (SELECT COUNT(*) FROM development_records WHERE evaluated_at >= CURRENT_DATE - INTERVAL '30 days');
END $$;
