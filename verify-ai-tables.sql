-- Verificar que las tablas de AI existan
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN ('ai_chat_sessions', 'ai_chat_messages')
ORDER BY table_name;

-- Si las tablas existen, mostrar su estructura
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name IN ('ai_chat_sessions', 'ai_chat_messages')
ORDER BY table_name, ordinal_position;
