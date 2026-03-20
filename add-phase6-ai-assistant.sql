-- Migración Fase 6: Sistema de Asistente IA

-- Crear tabla de sesiones de chat con IA
CREATE TABLE IF NOT EXISTS ai_chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP
);

-- Crear tabla de mensajes de chat con IA
CREATE TABLE IF NOT EXISTS ai_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_ai_sessions_tenant ON ai_chat_sessions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ai_sessions_user ON ai_chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_sessions_created ON ai_chat_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_messages_session ON ai_chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_ai_messages_created ON ai_chat_messages(created_at);

-- Verificar creación
SELECT 'Tablas de AI Assistant creadas exitosamente' as resultado;

-- Ver estructura de las tablas
SELECT table_name, column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name IN ('ai_chat_sessions', 'ai_chat_messages')
ORDER BY table_name, ordinal_position;
