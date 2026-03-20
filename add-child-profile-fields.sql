-- Migración Fase 2: Agregar campos de perfil completo de niños
-- Fecha: 2026-03-13

-- Agregar campo diagnosis a la tabla children
ALTER TABLE children 
ADD COLUMN IF NOT EXISTS diagnosis TEXT;

-- Agregar campo medical_notes a la tabla child_medical_info
ALTER TABLE child_medical_info 
ADD COLUMN IF NOT EXISTS medical_notes TEXT;

-- Comentarios para documentación
COMMENT ON COLUMN children.diagnosis IS 'Diagnóstico médico del niño (si aplica)';
COMMENT ON COLUMN child_medical_info.medical_notes IS 'Notas médicas adicionales del niño';
