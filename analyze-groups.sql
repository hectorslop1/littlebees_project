-- Analizar todos los grupos actuales en la base de datos
SELECT 
  id,
  name,
  level,
  friendly_name,
  subgroup,
  age_range_min,
  age_range_max,
  capacity,
  academic_year,
  created_at
FROM groups
ORDER BY level, subgroup, created_at;
