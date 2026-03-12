-- ============================================================
-- AGREGAR TABLAS FALTANTES PARA PROYECTO REFERENCIA
-- ============================================================

-- 1. Verificar que 'late' existe en AttendanceStatus (ya está en Prisma schema)
-- No es necesario agregarlo, ya existe

-- 2. Crear tabla de Anuncios
CREATE TABLE IF NOT EXISTS announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('general', 'event', 'alert', 'achievement')),
    priority VARCHAR(20) NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
    author_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_announcements_tenant_created ON announcements(tenant_id, created_at DESC);

-- 3. Crear tabla de Ejercicios
CREATE TABLE IF NOT EXISTS exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('motor_fine', 'motor_gross', 'cognitive', 'language', 'social', 'emotional')),
    duration INT NOT NULL CHECK (duration > 0), -- minutos
    age_range_min INT NOT NULL CHECK (age_range_min >= 0), -- meses
    age_range_max INT NOT NULL CHECK (age_range_max >= age_range_min), -- meses
    video_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercises_tenant_category ON exercises(tenant_id, category);
CREATE INDEX IF NOT EXISTS idx_exercises_age_range ON exercises(age_range_min, age_range_max);

-- 4. Crear tabla de relación Child-Exercise (para tracking de completados)
CREATE TABLE IF NOT EXISTS child_exercises (
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    PRIMARY KEY (child_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_child_exercises_child ON child_exercises(child_id);
CREATE INDEX IF NOT EXISTS idx_child_exercises_completed ON child_exercises(child_id, completed);

-- ============================================================
-- INSERTAR DATOS DE PRUEBA
-- ============================================================

-- Insertar algunos anuncios de ejemplo
INSERT INTO announcements (tenant_id, title, content, type, priority, author_id)
SELECT 
    t.id,
    'Feria del Día del Niño',
    'Les informamos que el próximo 30 de abril celebraremos el Día del Niño con una feria especial. Habrá actividades, refrigerios y sorpresas para todos nuestros pequeños.',
    'event',
    'high',
    u.id
FROM tenants t
CROSS JOIN LATERAL (
    SELECT id FROM users WHERE email LIKE '%@%' LIMIT 1
) u
WHERE NOT EXISTS (SELECT 1 FROM announcements WHERE title = 'Feria del Día del Niño')
LIMIT 1;

INSERT INTO announcements (tenant_id, title, content, type, priority, author_id)
SELECT 
    t.id,
    'Taller para Padres: Disciplina Positiva',
    'Invitamos a todos los padres a nuestro taller de Disciplina Positiva el próximo sábado 15 de marzo a las 10:00 AM.',
    'general',
    'medium',
    u.id
FROM tenants t
CROSS JOIN LATERAL (
    SELECT id FROM users WHERE email LIKE '%@%' LIMIT 1
) u
WHERE NOT EXISTS (SELECT 1 FROM announcements WHERE title LIKE '%Disciplina Positiva%')
LIMIT 1;

INSERT INTO announcements (tenant_id, title, content, type, priority, author_id)
SELECT 
    t.id,
    'Recordatorio de Vacunas',
    'Recordamos a los padres revisar el esquema de vacunación de sus hijos. Cualquier duda, favor de consultar con nuestra enfermera.',
    'alert',
    'high',
    u.id
FROM tenants t
CROSS JOIN LATERAL (
    SELECT id FROM users WHERE email LIKE '%@%' LIMIT 1
) u
WHERE NOT EXISTS (SELECT 1 FROM announcements WHERE title LIKE '%Vacunas%')
LIMIT 1;

-- Insertar ejercicios de ejemplo para cada categoría
INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Títeres de Dedo',
    'Usa títeres de dedo para contar historias y desarrollar el lenguaje',
    'language',
    15,
    12,
    48
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Títeres de Dedo')
LIMIT 1;

INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Construcción con Bloques',
    'Ejercita la motricidad fina construyendo torres',
    'motor_fine',
    20,
    12,
    72
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Construcción con Bloques')
LIMIT 1;

INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Caminata en Línea',
    'Camina en línea recta para mejorar el equilibrio',
    'motor_gross',
    10,
    24,
    72
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Caminata en Línea')
LIMIT 1;

INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Rompecabezas Simples',
    'Resuelve puzzles de 4-6 piezas para desarrollar habilidades cognitivas',
    'cognitive',
    15,
    18,
    48
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Rompecabezas Simples')
LIMIT 1;

INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Juego Cooperativo',
    'Juega con otros niños compartiendo juguetes',
    'social',
    20,
    24,
    60
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Juego Cooperativo')
LIMIT 1;

INSERT INTO exercises (tenant_id, title, description, category, duration, age_range_min, age_range_max)
SELECT 
    t.id,
    'Identificar Emociones',
    'Usa tarjetas con caras para identificar y nombrar emociones',
    'emotional',
    10,
    24,
    60
FROM tenants t
WHERE NOT EXISTS (SELECT 1 FROM exercises WHERE title = 'Identificar Emociones')
LIMIT 1;

-- Asignar algunos ejercicios a niños (algunos completados, otros pendientes)
INSERT INTO child_exercises (child_id, exercise_id, completed, completed_at)
SELECT 
    c.id,
    e.id,
    (random() > 0.5),
    CASE WHEN random() > 0.5 THEN NOW() - INTERVAL '3 days' ELSE NULL END
FROM children c
CROSS JOIN exercises e
WHERE c.deleted_at IS NULL
AND NOT EXISTS (
    SELECT 1 FROM child_exercises ce 
    WHERE ce.child_id = c.id AND ce.exercise_id = e.id
)
LIMIT 20;

COMMIT;
