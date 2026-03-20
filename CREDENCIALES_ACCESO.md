# 🔐 Credenciales de Acceso - LittleBees

**Fecha**: 17 de Marzo, 2026  
**Base de Datos**: IONOS - Usuarios Reales

---

## 👥 Usuarios Disponibles

Todos los usuarios tienen la misma contraseña: **`Password123!`**

### 👔 Directora
- **Email**: `maria.garcia@petitsoleil.com`
- **Nombre**: María García
- **Rol**: Director
- **Permisos**: Acceso completo a todas las funcionalidades

### 👩‍🏫 Maestras

#### Maestra 1 - Ana López
- **Email**: `ana.lopez@petitsoleil.com`
- **Nombre**: Ana López
- **Rol**: Teacher
- **Grupos Asignados**: 
  - Lactantes A (10 niños, 2 activos)
  - Preescolar C (15 niños, 2 activos)

#### Maestra 2 - Carmen Ruiz
- **Email**: `carmen.ruiz@petitsoleil.com`
- **Nombre**: Carmen Ruiz
- **Rol**: Teacher
- **Grupos Asignados**: 
  - Maternal B (12 niños, 2 activos)

### 👨‍👩‍👧 Padres

#### Padre - Juan Pérez
- **Email**: `juan.perez@email.com`
- **Nombre**: Juan Pérez
- **Rol**: Parent
- **Hijos**:
  - Sofía Pérez Martínez (Lactantes A)
  - Diego González (Lactantes A)

#### Madre - Laura Martínez
- **Email**: `laura.martinez@email.com`
- **Nombre**: Laura Martínez
- **Rol**: Parent
- **Hijos**:
  - Sofía Pérez Martínez (Lactantes A) - compartida con Juan
  - Emma Rodríguez (Maternal B)

---

## 🏫 Grupos Creados

### Lactantes A
- **Maestra**: Ana López
- **Capacidad**: 10 niños
- **Edad**: 0-12 meses
- **Color**: #FF6B6B (Rojo)
- **Niños**:
  - Sofía Pérez Martínez (9 meses)
  - Diego González (7 meses)

### Maternal B
- **Maestra**: Carmen Ruiz
- **Capacidad**: 12 niños
- **Edad**: 13-24 meses
- **Color**: #4ECDC4 (Turquesa)
- **Niños**:
  - Emma Rodríguez (22 meses)
  - Lucas Hernández (24 meses)

### Preescolar C
- **Maestra**: Ana López
- **Capacidad**: 15 niños
- **Edad**: 25-48 meses
- **Color**: #95E1D3 (Verde agua)
- **Niños**:
  - Valentina López (38 meses)
  - Mateo Sánchez (28 meses)

---

## 🧒 Niños Registrados

| Nombre | Edad | Grupo | Padres |
|--------|------|-------|--------|
| Sofía Pérez Martínez | 9 meses | Lactantes A | Juan Pérez, Laura Martínez |
| Diego González | 7 meses | Lactantes A | Juan Pérez |
| Emma Rodríguez | 22 meses | Maternal B | Laura Martínez |
| Lucas Hernández | 24 meses | Maternal B | - |
| Valentina López | 38 meses | Preescolar C | - |
| Mateo Sánchez | 28 meses | Preescolar C | - |

---

## 🌐 URLs de Acceso

### Aplicación Web
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3002
- **Swagger Docs**: http://localhost:3002/api/docs

### Base de Datos
- **Host**: 216.250.125.239
- **Puerto**: 5437
- **Base de Datos**: littlebees_db
- **Usuario**: littlebees_user

---

## 🧪 Cómo Probar

### 1. Iniciar Sesión como Maestra (Ana López)
```
Email: ana.lopez@petitsoleil.com
Password: password123
```

### 2. Navegar a "Mis Grupos"
- Deberías ver 2 grupos: Lactantes A y Preescolar C
- Cada grupo muestra el número de alumnos

### 3. Ver Alumnos
- Click en "Ver Alumnos" de cualquier grupo
- Deberías ver la lista de niños del grupo

### 4. Ir a Actividades
- Click en "Actividades" en el menú lateral
- Selecciona un grupo del dropdown
- Deberías ver la programación del día

### 5. Probar como Padre (Juan Pérez)
```
Email: juan.perez@email.com
Password: password123
```
- Deberías ver información de tus hijos
- Puedes crear justificantes para ellos

---

## 📊 Datos Incluidos

✅ **1 Tenant**: Guardería Petit Soleil  
✅ **5 Usuarios**: 1 directora, 2 maestras, 2 padres  
✅ **3 Grupos**: Lactantes A, Maternal B, Preescolar C  
✅ **6 Niños**: Distribuidos en los 3 grupos  
✅ **4 Relaciones Padre-Hijo**: Configuradas correctamente  

---

## 🔧 Solución de Problemas

### Si no ves datos en la aplicación:
1. Verifica que el backend esté corriendo en puerto 3002
2. Verifica que el frontend esté corriendo en puerto 3001
3. Revisa la consola del navegador para errores
4. Verifica que iniciaste sesión correctamente

### Si el login no funciona:
- Asegúrate de usar exactamente `password123` (sin espacios)
- Verifica que el email esté correcto (copia y pega)
- Revisa que el backend esté respondiendo en http://localhost:3002

---

## 📝 Notas Importantes

1. **Contraseña Hash**: El hash `$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW` corresponde a `password123`

2. **Tenant ID**: Todos los datos pertenecen al tenant `d3bcd4e1-3ac0-40d7-b96a-f2b41449a92c`

3. **Datos Mínimos**: Este seed solo incluye lo esencial para probar. No incluye:
   - Información médica completa
   - Contactos de emergencia
   - Registros de asistencia históricos
   - Bitácoras antiguas

4. **Próximos Pasos**: Después de probar, puedes agregar más datos manualmente o ejecutar un seed más completo.

---

**Fecha de Creación**: 17 de Marzo, 2026
