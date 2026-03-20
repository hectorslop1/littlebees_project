-- Migración Fase 5: Mejoras en Mensajería

-- Crear enum para tipos de conversación
DO $$ BEGIN
    CREATE TYPE "ConversationType" AS ENUM ('normal', 'urgent', 'escalated');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Agregar campos a la tabla conversations
ALTER TABLE conversations 
ADD COLUMN IF NOT EXISTS conversation_type "ConversationType" DEFAULT 'normal',
ADD COLUMN IF NOT EXISTS is_escalated BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS escalated_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS escalated_by UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS escalation_reason TEXT,
ADD COLUMN IF NOT EXISTS is_out_of_hours BOOLEAN DEFAULT false;

-- Crear índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_conversations_escalated ON conversations(is_escalated, escalated_at DESC) WHERE is_escalated = true;
CREATE INDEX IF NOT EXISTS idx_conversations_type ON conversations(conversation_type);

-- Verificar creación
SELECT 'Mejoras de mensajería aplicadas exitosamente' as resultado;
