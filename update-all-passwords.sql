-- Actualizar TODAS las contraseñas de usuarios existentes a Password123!
-- Hash de argon2 para "Password123!"

UPDATE users 
SET password_hash = '$argon2id$v=19$m=65536,t=3,p=4$oB2RdB4GC4AVgoaLwDkW8A$1wGY8u2ois85fYiNfVdY9Z7R4WAfedwg2PuZA8Au1Ok';

-- Mostrar usuarios actualizados
SELECT 
  u.email,
  u.first_name || ' ' || u.last_name AS nombre_completo,
  ut.role AS rol
FROM users u
LEFT JOIN user_tenants ut ON u.id = ut.user_id
ORDER BY ut.role, u.email;
