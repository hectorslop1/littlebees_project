-- Actualizar contraseñas con hash argon2 correcto
-- Hash de argon2 para "password123"

UPDATE users 
SET password_hash = '$argon2id$v=19$m=65536,t=3,p=4$PHT0o6cS1oWLxLxSmKXYYw$Ov4Bfdvd2jyCsGdl7fnicS5HHEAXnVrrRcgHjBe5IhQ'
WHERE id IN (
  'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
  'b2c3d4e5-f6a7-4b5c-9d0e-1f2a3b4c5d6e',
  'c3d4e5f6-a7b8-4c5d-0e1f-2a3b4c5d6e7f',
  'd4e5f6a7-b8c9-4d5e-1f2a-3b4c5d6e7f8a',
  'e5f6a7b8-c9d0-4e5f-2a3b-4c5d6e7f8a9b'
);

SELECT 'Contraseñas actualizadas con argon2' AS status;
SELECT COUNT(*) AS usuarios_actualizados FROM users 
WHERE password_hash = '$argon2id$v=19$m=65536,t=3,p=4$PHT0o6cS1oWLxLxSmKXYYw$Ov4Bfdvd2jyCsGdl7fnicS5HHEAXnVrrRcgHjBe5IhQ';
