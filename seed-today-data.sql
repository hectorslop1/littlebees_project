-- ============================================
-- SEED DATA PARA HOY (2026-03-18)
-- Asistencia, Daily Logs y Conversaciones
-- ============================================

-- Obtener IDs necesarios
DO $$
DECLARE
  v_tenant_id uuid := 'd3bcd4e1-3ac0-40d7-b96a-f2b41449a92c';
  v_today date := CURRENT_DATE;
  v_ana_lopez_id uuid;
  v_sofia_id uuid;
  v_diego_id uuid;
  v_emma_id uuid;
  v_lucas_id uuid;
  v_valentina_id uuid;
  v_mateo_id uuid;
  v_juan_perez_id uuid;
  v_laura_martinez_id uuid;
  v_conversation_id uuid;
BEGIN
  -- Obtener IDs de usuarios
  SELECT id INTO v_ana_lopez_id FROM users WHERE email = 'ana.lopez@petitsoleil.com';
  SELECT id INTO v_juan_perez_id FROM users WHERE email = 'juan.perez@email.com';
  SELECT id INTO v_laura_martinez_id FROM users WHERE email = 'laura.martinez@email.com';

  -- Obtener IDs de niños
  SELECT id INTO v_sofia_id FROM children WHERE first_name = 'Sofía' AND last_name = 'Pérez Martínez';
  SELECT id INTO v_diego_id FROM children WHERE first_name = 'Diego' AND last_name = 'González';
  SELECT id INTO v_emma_id FROM children WHERE first_name = 'Emma' AND last_name = 'Rodríguez';
  SELECT id INTO v_lucas_id FROM children WHERE first_name = 'Lucas' AND last_name = 'Hernández';
  SELECT id INTO v_valentina_id FROM children WHERE first_name = 'Valentina' AND last_name = 'López';
  SELECT id INTO v_mateo_id FROM children WHERE first_name = 'Mateo' AND last_name = 'Sánchez';

  -- ============================================
  -- 1. REGISTROS DE ASISTENCIA PARA HOY
  -- ============================================
  
  -- Sofía - Presente
  INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_sofia_id,
    v_today,
    'present',
    v_today + TIME '08:30:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Diego - Presente
  INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_diego_id,
    v_today,
    'present',
    v_today + TIME '08:45:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Emma - Presente
  INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_emma_id,
    v_today,
    'present',
    v_today + TIME '09:00:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Lucas - Presente
  INSERT INTO attendance_records (id, tenant_id, child_id, date, status, check_in_at, check_in_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_lucas_id,
    v_today,
    'present',
    v_today + TIME '08:15:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- ============================================
  -- 2. DAILY LOGS PARA HOY
  -- ============================================

  -- Sofía - Desayuno
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_sofia_id,
    v_today,
    'meal',
    'Desayuno',
    'Comió muy bien. Fruta y cereal.',
    '09:30:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Sofía - Siesta
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_sofia_id,
    v_today,
    'nap',
    'Siesta matutina',
    'Durmió 1.5 horas tranquilamente',
    '11:00:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Diego - Desayuno
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_diego_id,
    v_today,
    'meal',
    'Desayuno',
    'Comió todo su desayuno. Muy buen apetito.',
    '09:30:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Diego - Actividad
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_diego_id,
    v_today,
    'activity',
    'Juego sensorial',
    'Jugó con plastilina y texturas. Muy concentrado.',
    '10:30:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Emma - Desayuno
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_emma_id,
    v_today,
    'meal',
    'Desayuno',
    'Comió bien. Le gustó mucho la fruta.',
    '09:45:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- Lucas - Cambio de pañal
  INSERT INTO daily_log_entries (id, tenant_id, child_id, date, type, title, description, time, recorded_by, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    v_tenant_id,
    v_lucas_id,
    v_today,
    'diaper',
    'Cambio de pañal',
    'Todo normal',
    '10:00:00',
    v_ana_lopez_id,
    NOW(),
    NOW()
  );

  -- ============================================
  -- 3. CONVERSACIONES Y MENSAJES
  -- ============================================

  -- Conversación entre Ana López (maestra) y Juan Pérez (padre)
  v_conversation_id := gen_random_uuid();
  
  INSERT INTO conversations (id, tenant_id, child_id, created_at, updated_at)
  VALUES (
    v_conversation_id,
    v_tenant_id,
    v_sofia_id,
    NOW() - INTERVAL '2 days',
    NOW()
  );

  -- Participantes
  INSERT INTO conversation_participants (id, conversation_id, user_id, joined_at, created_at, updated_at)
  VALUES 
    (gen_random_uuid(), v_conversation_id, v_ana_lopez_id, NOW() - INTERVAL '2 days', NOW(), NOW()),
    (gen_random_uuid(), v_conversation_id, v_juan_perez_id, NOW() - INTERVAL '2 days', NOW(), NOW());

  -- Mensajes
  INSERT INTO messages (id, tenant_id, conversation_id, sender_id, content, message_type, created_at, updated_at)
  VALUES 
    (
      gen_random_uuid(),
      v_tenant_id,
      v_conversation_id,
      v_juan_perez_id,
      'Hola maestra Ana, ¿cómo está Sofía hoy?',
      'text',
      NOW() - INTERVAL '1 day',
      NOW() - INTERVAL '1 day'
    ),
    (
      gen_random_uuid(),
      v_tenant_id,
      v_conversation_id,
      v_ana_lopez_id,
      'Hola Juan! Sofía está muy bien. Hoy comió muy bien y jugó mucho con sus compañeros.',
      'text',
      NOW() - INTERVAL '23 hours',
      NOW() - INTERVAL '23 hours'
    ),
    (
      gen_random_uuid(),
      v_tenant_id,
      v_conversation_id,
      v_juan_perez_id,
      'Qué bueno! Muchas gracias por el update 😊',
      'text',
      NOW() - INTERVAL '22 hours',
      NOW() - INTERVAL '22 hours'
    ),
    (
      gen_random_uuid(),
      v_tenant_id,
      v_conversation_id,
      v_ana_lopez_id,
      'Buenos días! Hoy Sofía llegó muy contenta. Ya desayunó y está jugando.',
      'text',
      NOW() - INTERVAL '2 hours',
      NOW() - INTERVAL '2 hours'
    );

  RAISE NOTICE '✅ Datos de prueba creados exitosamente para hoy (%)!', v_today;
  RAISE NOTICE '   - 4 registros de asistencia';
  RAISE NOTICE '   - 6 daily logs';
  RAISE NOTICE '   - 1 conversación con 4 mensajes';

END $$;
