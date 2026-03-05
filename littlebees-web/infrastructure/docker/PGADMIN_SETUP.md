# 🐘 pgAdmin Setup - Guía de Configuración

## 📋 Información de Acceso

### **pgAdmin Web Interface**
- **URL:** http://localhost:5050
- **Email:** admin@kinderspace.mx
- **Password:** kinderspace123

---

## 🔌 Conectar a PostgreSQL

### **Paso 1: Acceder a pgAdmin**
1. Abre tu navegador en: http://localhost:5050
2. Inicia sesión con las credenciales arriba

### **Paso 2: Agregar Servidor PostgreSQL**

1. **Click derecho en "Servers"** → **Register** → **Server**

2. **Pestaña "General":**
   - **Name:** `LittleBees Local`

3. **Pestaña "Connection":**
   - **Host name/address:** `host.docker.internal` (macOS/Windows) o `172.17.0.1` (Linux)
   - **Port:** `5437`
   - **Maintenance database:** `kinderspace_dev`
   - **Username:** `kinderspace`
   - **Password:** `kinderspace`
   - ✅ **Save password:** Activar

4. **Click "Save"**

---

## 🔍 Alternativa: Usar nombre del contenedor

Si `host.docker.internal` no funciona, usa el nombre del contenedor:

- **Host name/address:** `kinderspace-postgres`
- **Port:** `5432` (puerto interno, no el mapeado)

---

## 📊 Explorar la Base de Datos

Una vez conectado, podrás:

1. **Ver todas las tablas:**
   - Servers → LittleBees Local → Databases → kinderspace_dev → Schemas → public → Tables

2. **Ejecutar queries:**
   - Click derecho en `kinderspace_dev` → **Query Tool**

3. **Ver datos:**
   - Click derecho en cualquier tabla → **View/Edit Data** → **All Rows**

---

## 🧪 Queries de Prueba

```sql
-- Ver todos los tenants
SELECT * FROM tenants;

-- Ver todos los usuarios
SELECT id, email, first_name, last_name FROM users;

-- Ver niños registrados
SELECT c.first_name, c.last_name, c.date_of_birth, g.name as classroom
FROM children c
LEFT JOIN groups g ON c.group_id = g.id;

-- Ver registros de asistencia de hoy
SELECT 
  c.first_name || ' ' || c.last_name as child_name,
  ar.status,
  ar.check_in_at,
  ar.check_out_at
FROM attendance_records ar
JOIN children c ON ar.child_id = c.id
WHERE DATE(ar.date) = CURRENT_DATE;
```

---

## 🛠️ Comandos Docker Útiles

```bash
# Ver logs de pgAdmin
docker logs kinderspace-pgadmin

# Reiniciar pgAdmin
docker restart kinderspace-pgadmin

# Detener pgAdmin
docker stop kinderspace-pgadmin

# Iniciar pgAdmin
docker start kinderspace-pgadmin
```

---

## ⚙️ Configuración Avanzada

### **Cambiar el puerto de pgAdmin**

Si el puerto 5050 está ocupado, edita `docker-compose.yml`:

```yaml
pgadmin:
  ports:
    - "5051:80"  # Cambia 5050 por otro puerto
```

Luego ejecuta:
```bash
docker compose up -d pgadmin
```

---

## 🔐 Credenciales de Resumen

| Servicio | Host | Puerto | Usuario | Password | Base de Datos |
|----------|------|--------|---------|----------|---------------|
| **pgAdmin** | localhost | 5050 | admin@kinderspace.mx | kinderspace123 | - |
| **PostgreSQL** | host.docker.internal | 5437 | kinderspace | kinderspace | kinderspace_dev |

---

## 🎯 Troubleshooting

### **No puedo conectar a PostgreSQL desde pgAdmin**

**Solución 1:** Usa `host.docker.internal` en lugar de `localhost`

**Solución 2:** Usa el nombre del contenedor `kinderspace-postgres` y puerto `5432`

**Solución 3:** Verifica que PostgreSQL esté corriendo:
```bash
docker ps | grep postgres
```

### **pgAdmin muestra error de permisos**

Reinicia el contenedor:
```bash
docker compose restart pgadmin
```

---

**¡pgAdmin configurado y listo para usar! 🎉**
