-- Script para corregir relaciones y agregar datos de prueba
-- Little Bees Database Fix

-- ============================================
-- 1. LIMPIAR RELACIONES EXISTENTES
-- ============================================

-- Limpiar relaciones child_parents existentes
DELETE FROM child_parents;

-- ============================================
-- 2. OBTENER IDs NECESARIOS
-- ============================================

-- Obtener tenant_id (asumiendo que hay un solo tenant)
DO $$
DECLARE
    v_tenant_id uuid;
    v_padre_id uuid;
    v_maestra_id uuid;
    v_maestra2_id uuid;
    v_group_mariposas_id uuid;
    v_group_abejas_id uuid;
    -- Children IDs
    v_diego_id uuid;
    v_isabella_id uuid;
    v_isamar_id uuid;
    v_mateo_id uuid;
    v_santiago_id uuid;
    v_sofia_id uuid;
    v_valentina_id uuid;
BEGIN
    -- Obtener tenant_id
    SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
    
    -- Obtener user IDs
    SELECT id INTO v_padre_id FROM users WHERE email = 'padre@gmail.com';
    SELECT id INTO v_maestra_id FROM users WHERE email = 'maestra@petitsoleil.mx';
    SELECT id INTO v_maestra2_id FROM users WHERE email = 'maestra2@petitsoleil.mx';
    
    -- Obtener o crear grupos
    SELECT id INTO v_group_mariposas_id FROM groups WHERE name = 'Mariposas' AND tenant_id = v_tenant_id;
    IF v_group_mariposas_id IS NULL THEN
        INSERT INTO groups (id, tenant_id, name, age_range_min, age_range_max, capacity, color, academic_year, teacher_id, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, 'Mariposas', 2, 3, 15, '#FF6B9D', '2024-2025', v_maestra_id, NOW(), NOW())
        RETURNING id INTO v_group_mariposas_id;
    END IF;
    
    SELECT id INTO v_group_abejas_id FROM groups WHERE name = 'Abejas' AND tenant_id = v_tenant_id;
    IF v_group_abejas_id IS NULL THEN
        INSERT INTO groups (id, tenant_id, name, age_range_min, age_range_max, capacity, color, academic_year, teacher_id, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, 'Abejas', 3, 4, 15, '#FFC107', '2024-2025', v_maestra2_id, NOW(), NOW())
        RETURNING id INTO v_group_abejas_id;
    END IF;
    
    -- Obtener children IDs
    SELECT id INTO v_diego_id FROM children WHERE first_name = 'Diego' AND last_name = 'Hernández';
    SELECT id INTO v_isabella_id FROM children WHERE first_name = 'Isabella' AND last_name = 'Sánchez';
    SELECT id INTO v_isamar_id FROM children WHERE first_name = 'Isamar' AND last_name = 'Ruiz';
    SELECT id INTO v_mateo_id FROM children WHERE first_name = 'Mateo' AND last_name = 'López';
    SELECT id INTO v_santiago_id FROM children WHERE first_name = 'Santiago' AND last_name = 'Ramírez';
    SELECT id INTO v_sofia_id FROM children WHERE first_name = 'Sofía' AND last_name = 'Ramírez';
    SELECT id INTO v_valentina_id FROM children WHERE first_name = 'Valentina' AND last_name = 'García';
    
    -- ============================================
    -- 3. ASIGNAR GRUPOS A LOS NIÑOS
    -- ============================================
    
    -- Grupo Mariposas (2-3 años)
    UPDATE children SET group_id = v_group_mariposas_id WHERE id IN (v_santiago_id, v_sofia_id, v_isamar_id);
    
    -- Grupo Abejas (3-4 años)
    UPDATE children SET group_id = v_group_abejas_id WHERE id IN (v_diego_id, v_isabella_id, v_mateo_id, v_valentina_id);
    
    -- ============================================
    -- 4. CREAR RELACIONES PADRE-HIJO
    -- ============================================
    
    -- Carlos Ramírez (padre@gmail.com) tiene 2 hijos: Santiago y Sofía Ramírez
    INSERT INTO child_parents (child_id, user_id, relationship, is_primary, can_pickup)
    VALUES 
        (v_santiago_id, v_padre_id, 'father', true, true),
        (v_sofia_id, v_padre_id, 'father', true, true);
    
    RAISE NOTICE 'Relaciones padre-hijo creadas exitosamente';
    
    -- ============================================
    -- 5. AGREGAR DAILY LOGS CON FOTOS
    -- ============================================
    
    -- Daily logs para Santiago Ramírez (hijo de Carlos)
    INSERT INTO daily_log_entries (id, tenant_id, child_id, date, time, type, title, description, metadata, recorded_by, created_at, updated_at)
    VALUES 
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE, '10:30', 'photo', 'Jugando en el jardín', 'Santiago disfrutando del tiempo al aire libre', 
         '{"photoUrls": ["https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800"], "tags": ["outdoor", "play"]}'::jsonb, 
         v_maestra_id, NOW(), NOW()),
        
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE, '12:30', 'meal', 'Almuerzo', 'Comió bien, terminó todo su plato', 
         '{"mealType": "lunch", "foodItems": ["pasta", "vegetables"], "portionEaten": "all"}'::jsonb, 
         v_maestra_id, NOW(), NOW()),
        
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE, '14:00', 'nap', 'Siesta', 'Durmió 2 horas', 
         '{"startTime": "14:00", "endTime": "16:00", "quality": "good"}'::jsonb, 
         v_maestra_id, NOW(), NOW()),
        
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE - INTERVAL '1 day', '11:00', 'photo', 'Arte y creatividad', 'Pintando con acuarelas', 
         '{"photoUrls": ["https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800"], "tags": ["art", "creative"]}'::jsonb, 
         v_maestra_id, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');
    
    -- Daily logs para Sofía Ramírez (hija de Carlos)
    INSERT INTO daily_log_entries (id, tenant_id, child_id, date, time, type, title, description, metadata, recorded_by, created_at, updated_at)
    VALUES 
        (gen_random_uuid(), v_tenant_id, v_sofia_id, CURRENT_DATE, '09:30', 'photo', 'Hora de lectura', 'Sofía leyendo su libro favorito', 
         '{"photoUrls": ["https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800"], "tags": ["reading", "learning"]}'::jsonb, 
         v_maestra_id, NOW(), NOW()),
        
        (gen_random_uuid(), v_tenant_id, v_sofia_id, CURRENT_DATE, '11:00', 'activity', 'Clase de música', 'Participó activamente en la clase de música', 
         '{"activityType": "music", "participation": "active"}'::jsonb, 
         v_maestra_id, NOW(), NOW()),
        
        (gen_random_uuid(), v_tenant_id, v_sofia_id, CURRENT_DATE, '08:30', 'meal', 'Desayuno', 'Comió frutas y cereal', 
         '{"mealType": "breakfast", "foodItems": ["fruits", "cereal"], "portionEaten": "most"}'::jsonb, 
         v_maestra_id, NOW(), NOW());
    
    RAISE NOTICE 'Daily logs creados exitosamente';
    
    -- ============================================
    -- 6. AGREGAR ATTENDANCE RECORDS
    -- ============================================
    
    -- Attendance para hoy
    INSERT INTO attendance_records (id, tenant_id, child_id, date, check_in_at, check_out_at, status, check_in_by, check_out_by, observations, created_at, updated_at)
    VALUES 
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE, CURRENT_DATE + TIME '08:30:00', NULL, 'present', v_padre_id, NULL, 'Llegó contento', NOW(), NOW()),
        (gen_random_uuid(), v_tenant_id, v_sofia_id, CURRENT_DATE, CURRENT_DATE + TIME '08:35:00', NULL, 'present', v_padre_id, NULL, 'Llegó con su mochila nueva', NOW(), NOW());
    
    -- Attendance para ayer
    INSERT INTO attendance_records (id, tenant_id, child_id, date, check_in_at, check_out_at, status, check_in_by, check_out_by, observations, created_at, updated_at)
    VALUES 
        (gen_random_uuid(), v_tenant_id, v_santiago_id, CURRENT_DATE - INTERVAL '1 day', (CURRENT_DATE - INTERVAL '1 day') + TIME '08:45:00', (CURRENT_DATE - INTERVAL '1 day') + TIME '16:30:00', 'present', v_padre_id, v_padre_id, NULL, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), v_tenant_id, v_sofia_id, CURRENT_DATE - INTERVAL '1 day', (CURRENT_DATE - INTERVAL '1 day') + TIME '08:40:00', (CURRENT_DATE - INTERVAL '1 day') + TIME '16:25:00', 'present', v_padre_id, v_padre_id, NULL, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');
    
    RAISE NOTICE 'Attendance records creados exitosamente';
    
    -- ============================================
    -- 7. CREAR CONVERSACIONES Y MENSAJES
    -- ============================================
    
    DECLARE
        v_conversation_santiago_id uuid;
        v_conversation_sofia_id uuid;
    BEGIN
        -- Crear conversación para Santiago (entre padre y maestra sobre Santiago)
        INSERT INTO conversations (id, tenant_id, child_id, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, v_santiago_id, NOW(), NOW())
        RETURNING id INTO v_conversation_santiago_id;
        
        -- Agregar participantes a conversación de Santiago
        INSERT INTO conversation_participants (conversation_id, user_id, joined_at)
        VALUES 
            (v_conversation_santiago_id, v_padre_id, NOW()),
            (v_conversation_santiago_id, v_maestra_id, NOW());
        
        -- Agregar mensajes sobre Santiago
        INSERT INTO messages (id, tenant_id, conversation_id, sender_id, content, created_at)
        VALUES 
            (gen_random_uuid(), v_tenant_id, v_conversation_santiago_id, v_maestra_id, 'Hola Carlos, Santiago tuvo un excelente día hoy. Participó mucho en las actividades.', NOW() - INTERVAL '2 hours'),
            (gen_random_uuid(), v_tenant_id, v_conversation_santiago_id, v_padre_id, 'Muchas gracias por el update! Me da gusto saber que está feliz.', NOW() - INTERVAL '1 hour'),
            (gen_random_uuid(), v_tenant_id, v_conversation_santiago_id, v_maestra_id, 'Le encantó jugar en el jardín hoy. Tiene mucha energía!', NOW() - INTERVAL '30 minutes');
        
        -- Crear conversación para Sofía
        INSERT INTO conversations (id, tenant_id, child_id, created_at, updated_at)
        VALUES (gen_random_uuid(), v_tenant_id, v_sofia_id, NOW(), NOW())
        RETURNING id INTO v_conversation_sofia_id;
        
        -- Agregar participantes a conversación de Sofía
        INSERT INTO conversation_participants (conversation_id, user_id, joined_at)
        VALUES 
            (v_conversation_sofia_id, v_padre_id, NOW()),
            (v_conversation_sofia_id, v_maestra_id, NOW());
        
        -- Agregar mensajes sobre Sofía
        INSERT INTO messages (id, tenant_id, conversation_id, sender_id, content, created_at)
        VALUES 
            (gen_random_uuid(), v_tenant_id, v_conversation_sofia_id, v_maestra_id, 'Sofía estuvo muy activa en la clase de música. Le encantó!', NOW() - INTERVAL '3 hours'),
            (gen_random_uuid(), v_tenant_id, v_conversation_sofia_id, v_padre_id, 'Qué bien! En casa también le gusta mucho cantar.', NOW() - INTERVAL '2 hours');
        
        RAISE NOTICE 'Conversaciones y mensajes creados exitosamente';
    END;
    
    -- ============================================
    -- 8. AGREGAR PAYMENTS (OPCIONAL)
    -- ============================================
    
    INSERT INTO payments (id, tenant_id, child_id, concept, amount, currency, status, due_date, created_at, updated_at)
    VALUES 
        (gen_random_uuid(), v_tenant_id, v_santiago_id, 'Colegiatura Marzo 2024', 3500.00, 'MXN', 'pending', CURRENT_DATE + INTERVAL '5 days', NOW(), NOW()),
        (gen_random_uuid(), v_tenant_id, v_sofia_id, 'Colegiatura Marzo 2024', 3500.00, 'MXN', 'pending', CURRENT_DATE + INTERVAL '5 days', NOW(), NOW()),
        (gen_random_uuid(), v_tenant_id, v_santiago_id, 'Colegiatura Febrero 2024', 3500.00, 'MXN', 'paid', CURRENT_DATE - INTERVAL '15 days', NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days');
    
    RAISE NOTICE 'Payments creados exitosamente';
    
    RAISE NOTICE '====================================';
    RAISE NOTICE 'SCRIPT COMPLETADO EXITOSAMENTE';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Padre: Carlos Ramírez (padre@gmail.com)';
    RAISE NOTICE 'Hijos: Santiago Ramírez, Sofía Ramírez';
    RAISE NOTICE 'Grupo: Mariposas (Maestra Ana López)';
    RAISE NOTICE '====================================';
END $$;
