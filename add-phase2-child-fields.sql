-- Migración Fase 2: Agregar campos diagnosis y medical_notes

-- 1. Agregar campo diagnosis a tabla children
ALTER TABLE children ADD COLUMN IF NOT EXISTS diagnosis TEXT;

-- 2. Agregar campo medical_notes a tabla child_medical_info
ALTER TABLE child_medical_info ADD COLUMN IF NOT EXISTS medical_notes TEXT;

-- Verificar cambios
SELECT 'Campos agregados exitosamente' as resultado;

-- Ver estructura actualizada de children
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'children' 
  AND column_name IN ('diagnosis', 'first_name', 'last_name')
ORDER BY ordinal_position;

-- Ver estructura actualizada de child_medical_info
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'child_medical_info' 
  AND column_name IN ('medical_notes', 'allergies', 'blood_type')
ORDER BY ordinal_position;
