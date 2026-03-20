-- Migración Fase 7: Personalización del Sistema

-- Crear tabla tenant_customizations
CREATE TABLE IF NOT EXISTS tenant_customizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL UNIQUE REFERENCES tenants(id) ON DELETE CASCADE,
  logo_url TEXT,
  primary_color VARCHAR(7) NOT NULL DEFAULT '#D4A853',
  secondary_color VARCHAR(7) NOT NULL DEFAULT '#4ECDC4',
  accent_color VARCHAR(7),
  system_name VARCHAR(100) NOT NULL DEFAULT 'LittleBees',
  menu_labels JSONB DEFAULT '{}',
  custom_css TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Crear índice para búsqueda por tenant
CREATE INDEX IF NOT EXISTS idx_customizations_tenant ON tenant_customizations(tenant_id);

-- Insertar customización por defecto para el tenant existente
INSERT INTO tenant_customizations (tenant_id, system_name, primary_color, secondary_color)
SELECT id, 'Petit Soleil', '#D4A853', '#4ECDC4'
FROM tenants
WHERE slug = 'petit-soleil'
ON CONFLICT (tenant_id) DO NOTHING;

-- Verificar creación
SELECT 'Tabla tenant_customizations creada exitosamente' as resultado;
