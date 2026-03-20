-- Verificar estado de los niños
SELECT 
  COUNT(*) as total_ninos,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as activos,
  COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactivos,
  COUNT(CASE WHEN group_id IS NOT NULL THEN 1 END) as con_grupo,
  COUNT(CASE WHEN group_id IS NULL THEN 1 END) as sin_grupo
FROM children;

-- Ver algunos niños de ejemplo
SELECT 
  first_name,
  last_name,
  status,
  group_id,
  date_of_birth,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) * 12 + 
  EXTRACT(MONTH FROM AGE(CURRENT_DATE, date_of_birth)) as edad_meses
FROM children
LIMIT 10;
