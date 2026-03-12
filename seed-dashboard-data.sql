-- ============================================================
-- SEED DATA PARA DASHBOARD Y DESARROLLO
-- Script para agregar datos de prueba completos
-- ============================================================

-- Variables para usar en el script
DO $$
DECLARE
    v_tenant_id UUID;
    v_child1_id UUID;
    v_child2_id UUID;
    v_child3_id UUID;
    v_child4_id UUID;
    v_child5_id UUID;
    v_user_id UUID;
    v_date DATE;
    v_milestone_id UUID;
BEGIN
    -- Obtener el tenant_id
    SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
    
    -- Obtener los IDs de los niños
    SELECT id INTO v_child1_id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1 OFFSET 0;
    SELECT id INTO v_child2_id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1 OFFSET 1;
    SELECT id INTO v_child3_id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1 OFFSET 2;
    SELECT id INTO v_child4_id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1 OFFSET 3;
    SELECT id INTO v_child5_id FROM children WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1 OFFSET 4;
    
    -- Obtener un usuario para asignar como autor
    SELECT id INTO v_user_id FROM users LIMIT 1;

    -- ============================================================
    -- REGISTROS DE ASISTENCIA RECIENTES (últimos 7 días)
    -- ============================================================
    
    -- Limpiar registros de asistencia de los últimos 7 días
    DELETE FROM attendance_records WHERE date >= CURRENT_DATE - INTERVAL '7 days';
    
    -- Insertar asistencias para los últimos 7 días
    FOR i IN 0..6 LOOP
        v_date := CURRENT_DATE - i;
        
        -- Niño 1 - Presente todos los días
        INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, v_child1_id, v_date, 'present', v_date + TIME '08:00:00', v_user_id, 'manual', NOW(), NOW());
        
        -- Niño 2 - Presente con algunas tardanzas
        INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, v_child2_id, v_date, 
                (CASE WHEN i % 3 = 0 THEN 'late' ELSE 'present' END)::varchar,
                v_date + TIME '08:30:00', v_user_id, 'manual', NOW(), NOW());
        
        -- Niño 3 - Presente la mayoría de días
        IF i < 6 THEN
            INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
            VALUES (gen_random_uuid(), v_tenant_id, v_child3_id, v_date, 'present', v_date + TIME '08:15:00', v_user_id, 'manual', NOW(), NOW());
        ELSE
            INSERT INTO attendance_records (id, tenant_id, child_id, date, status, created_at, updated_at)
            VALUES (gen_random_uuid(), v_tenant_id, v_child3_id, v_date, 'absent', NOW(), NOW());
        END IF;
        
        -- Niño 4 - Presente con algunas ausencias
        IF i % 2 = 0 THEN
            INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
            VALUES (gen_random_uuid(), v_tenant_id, v_child4_id, v_date, 'present', v_date + TIME '08:00:00', v_user_id, 'manual', NOW(), NOW());
        ELSE
            INSERT INTO attendance_records (id, tenant_id, child_id, date, status, created_at, updated_at)
            VALUES (gen_random_uuid(), v_tenant_id, v_child4_id, v_date, 'absent', NOW(), NOW());
        END IF;
        
        -- Niño 5 - Presente la mayoría de días
        IF i < 5 THEN
            INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, check_in_method, created_at, updated_at)
            VALUES (gen_random_uuid(), v_tenant_id, v_child5_id, v_date, 'present', v_date + TIME '08:10:00', v_user_id, 'manual', NOW(), NOW());
        END IF;
    END LOOP;

    -- ============================================================
    -- REGISTROS DE DESARROLLO RECIENTES (último mes)
    -- ============================================================
    
    -- Limpiar registros de desarrollo del último mes
    DELETE FROM development_records WHERE evaluated_at >= CURRENT_DATE - INTERVAL '30 days';
    
    -- Insertar registros de desarrollo para cada niño en cada categoría
    -- Niño 1 - Buen progreso en todas las áreas
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'motor_fine' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by, observations)
        VALUES (v_child1_id, v_milestone_id, 'achieved', CURRENT_DATE - INTERVAL '5 days', v_user_id, 'Excelente progreso');
    END LOOP;
    
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'motor_gross' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by, observations)
        VALUES (v_child1_id, v_milestone_id, 'achieved', CURRENT_DATE - INTERVAL '5 days', v_user_id, 'Muy bien');
    END LOOP;
    
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'cognitive' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by, observations)
        VALUES (v_child1_id, v_milestone_id, 'achieved', CURRENT_DATE - INTERVAL '5 days', v_user_id, 'Progreso notable');
    END LOOP;
    
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'language' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by)
        VALUES (v_child1_id, v_milestone_id, 
                CASE WHEN random() > 0.3 THEN 'achieved' ELSE 'in_progress' END,
                CURRENT_DATE - INTERVAL '5 days', v_user_id);
    END LOOP;
    
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'social' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by)
        VALUES (v_child1_id, v_milestone_id, 'achieved', CURRENT_DATE - INTERVAL '5 days', v_user_id);
    END LOOP;
    
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category = 'emotional' 
        ORDER BY age_range_min 
        LIMIT 3
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by)
        VALUES (v_child1_id, v_milestone_id, 'achieved', CURRENT_DATE - INTERVAL '5 days', v_user_id);
    END LOOP;

    -- Niño 2 - Progreso variado
    FOR v_milestone_id IN 
        SELECT id FROM development_milestones 
        WHERE category IN ('motor_fine', 'motor_gross', 'cognitive', 'language', 'social', 'emotional')
        ORDER BY category, age_range_min 
        LIMIT 12
    LOOP
        INSERT INTO development_records (child_id, milestone_id, status, evaluated_at, evaluated_by)
        VALUES (v_child2_id, v_milestone_id, 
                CASE 
                    WHEN random() > 0.6 THEN 'achieved'
                    WHEN random() > 0.3 THEN 'in_progress'
                    ELSE 'not_achieved'
                END,
                CURRENT_DATE - INTERVAL '3 days', v_user_id);
    END LOOP;

    -- ============================================================
    -- DAILY LOG ENTRIES (Actividad Reciente)
    -- ============================================================
    
    -- Limpiar daily logs de hoy
    DELETE FROM daily_log_entries WHERE date = CURRENT_DATE;
    
    -- Insertar actividades de hoy
    INSERT INTO daily_log_entries (tenant_id, child_id, date, time, type, title, description, created_by)
    VALUES 
        (v_tenant_id, v_child1_id, CURRENT_DATE, '09:30:00', 'meal', 'Desayuno', 'Comió frutas y cereal', v_user_id),
        (v_tenant_id, v_child2_id, CURRENT_DATE, '10:00:00', 'activity', 'Juego libre', 'Jugó con bloques de construcción', v_user_id),
        (v_tenant_id, v_child3_id, CURRENT_DATE, '11:00:00', 'nap', 'Siesta', 'Durmió 1 hora', v_user_id),
        (v_tenant_id, v_child1_id, CURRENT_DATE, '12:00:00', 'meal', 'Almuerzo', 'Comió verduras y pollo', v_user_id),
        (v_tenant_id, v_child4_id, CURRENT_DATE, '14:00:00', 'bathroom', 'Cambio de pañal', 'Cambio rutinario', v_user_id);

    RAISE NOTICE 'Datos de prueba insertados exitosamente';
END $$;
