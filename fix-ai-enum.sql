-- Crear el enum AiMessageRole
DO $$ BEGIN
    CREATE TYPE "AiMessageRole" AS ENUM ('user', 'assistant', 'system');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Eliminar la tabla ai_chat_messages si existe (para recrearla con el enum)
DROP TABLE IF EXISTS ai_chat_messages CASCADE;

-- Recrear la tabla con el enum correcto
CREATE TABLE ai_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
  role "AiMessageRole" NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Recrear índices
CREATE INDEX idx_ai_messages_session ON ai_chat_messages(session_id);
CREATE INDEX idx_ai_messages_created ON ai_chat_messages(created_at);

-- Verificar
SELECT 'Enum AiMessageRole y tabla ai_chat_messages creados correctamente' as resultado;
