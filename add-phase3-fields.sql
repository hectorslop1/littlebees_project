-- Migración Fase 3: Registro de Actividades del Día
-- Fecha: 2026-03-13

-- Agregar campos de foto a attendance_records
ALTER TABLE attendance_records 
ADD COLUMN IF NOT EXISTS check_in_photo_url TEXT,
ADD COLUMN IF NOT EXISTS check_out_photo_url TEXT;

-- Crear tabla day_schedule_templates
CREATE TABLE IF NOT EXISTS day_schedule_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR(100) NOT NULL,
  items JSONB NOT NULL,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_day_schedule_templates_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

-- Crear índice para búsquedas por tenant
CREATE INDEX IF NOT EXISTS idx_day_schedule_templates_tenant_id ON day_schedule_templates(tenant_id);

-- Comentarios para documentación
COMMENT ON COLUMN attendance_records.check_in_photo_url IS 'URL de la foto tomada al momento del check-in';
COMMENT ON COLUMN attendance_records.check_out_photo_url IS 'URL de la foto tomada al momento del check-out';
COMMENT ON TABLE day_schedule_templates IS 'Plantillas de programación del día para grupos';
COMMENT ON COLUMN day_schedule_templates.items IS 'Array JSON de { time, type, label } para la programación del día';
