# 🚀 Setup MacBook Pro - LittleBees Project

**Guía rápida para configurar el entorno de desarrollo en tu MacBook Pro y trabajar directamente con la base de datos de IONOS**

---

## 📋 Instrucción para Windsurf

Cuando abras Windsurf en tu MacBook Pro, simplemente dile:

> **"Analiza SETUP_MACBOOK_PRO.md y ayúdame a configurar todo lo necesario"**

---

## ✅ Pre-requisitos

Asegúrate de tener instalado:
- ✅ Homebrew
- ✅ Node.js 20+
- ✅ pnpm 10.12.4
- ✅ Docker Desktop
- ✅ Flutter SDK 3.11+
- ✅ Git
- ✅ Windsurf IDE

**Si no tienes algo instalado**, consulta `SETUP_ENVIRONMENT.md` para instrucciones detalladas.

---

## 🎯 Configuración Rápida (Paso a Paso)

### 1. Clonar el Proyecto

```bash
# Abre Terminal
cd ~/Desktop/Proyectos

# Si no tienes el proyecto clonado:
git clone https://github.com/hectorslop1/littlebees_project.git
cd littlebees_project

# Si ya lo tienes, actualiza:
cd littlebees_project
git pull origin main
```

### 2. Instalar Dependencias

```bash
# Instalar dependencias del monorepo
pnpm install

# Construir packages compartidos
cd littlebees-web
pnpm --filter @kinderspace/shared-types build
pnpm --filter @kinderspace/shared-validators build
cd ..
```

### 3. Iniciar Docker

```bash
# Abrir Docker Desktop
open -a Docker

# Esperar 10-15 segundos a que Docker inicie

# Verificar que Docker esté corriendo
docker ps
```

### 4. Configurar Base de Datos (Conectar a IONOS)

**⚠️ IMPORTANTE: Trabajarás directamente con la BD de IONOS, NO con BD local**

```bash
# Crear archivo .env para el API
cd littlebees-web/apps/api
cp .env.example .env
```

**Edita el archivo `.env` y cambia la línea de `DATABASE_URL`:**

```bash
# ANTES (BD local):
# DATABASE_URL="postgresql://kinderspace:kinderspace@localhost:5437/kinderspace_dev?schema=public"

# DESPUÉS (BD en IONOS):
DATABASE_URL="postgresql://kinderspace:kinderspace@216.250.125.239:5437/kinderspace_dev?schema=public"
```

**Otras variables importantes en `.env`:**
```bash
# JWT
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_SECRET="your-super-secret-refresh-key-change-in-production"
JWT_REFRESH_EXPIRES_IN="7d"

# App
PORT=3002
NODE_ENV=development
CORS_ORIGINS="http://localhost:3001,http://localhost:3003"

# Redis (local para cache)
REDIS_URL="redis://localhost:6383"

# MinIO (local para archivos)
MINIO_ENDPOINT="http://localhost:9010"
MINIO_ACCESS_KEY="kinderspace"
MINIO_SECRET_KEY="kinderspace123"
MINIO_BUCKET="kinderspace-files"
MINIO_USE_SSL="false"
```

### 5. Iniciar Servicios Locales (Solo Redis y MinIO)

```bash
# Volver a la raíz del proyecto
cd ~/Desktop/Proyectos/littlebees_project

# Iniciar solo Redis y MinIO (NO PostgreSQL)
docker compose -f littlebees-web/infrastructure/docker/docker-compose.yml up -d redis minio
```

**Nota**: No necesitas PostgreSQL local porque usarás el de IONOS.

### 6. Generar Cliente Prisma

```bash
cd littlebees-web/apps/api
pnpm prisma generate
cd ../..
```

### 7. Iniciar las Aplicaciones

**Terminal 1: Backend API**
```bash
pnpm dev:api
```

**Terminal 2: Frontend Web**
```bash
pnpm dev:web
```

**Terminal 3: App Móvil (Opcional)**
```bash
cd littlebees-mobile
flutter run
```

---

## 🌐 URLs de Desarrollo

Una vez que todo esté corriendo:

- **Frontend Web**: http://localhost:3001
- **Backend API**: http://localhost:3002
- **Swagger Docs**: http://localhost:3002/api/docs
- **MinIO Console**: http://localhost:9011

---

## 🔐 Usuarios de Prueba

Puedes hacer login con cualquiera de estos usuarios:

| Email | Password | Rol |
|-------|----------|-----|
| `director@petitsoleil.mx` | `Password123!` | Directora |
| `maestra@petitsoleil.mx` | `Password123!` | Maestra |
| `maestra2@petitsoleil.mx` | `Password123!` | Maestra |
| `admin@petitsoleil.mx` | `Password123!` | Admin |
| `padre@gmail.com` | `Password123!` | Padre |

---

## 🔄 Flujo de Trabajo Recomendado

### Desarrollo Normal:

1. **Hacer cambios en el código** (frontend, backend, mobile)
2. **Probar localmente** con la BD de IONOS
3. **Hacer commit y push**:
   ```bash
   git add .
   git commit -m "Descripción de cambios"
   git push origin main
   ```
4. **Desplegar a IONOS** (cuando estés listo):
   ```bash
   ./deploy-to-ionos.sh
   ```

### Si Necesitas Sincronizar Datos:

**De IONOS → Local** (si trabajaras con BD local):
```bash
# Exportar desde IONOS
ssh -i "/Users/hectoreduardosanchezlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna" \
  cbluna@216.250.125.239 \
  'docker exec littlebees-postgres pg_dump -U kinderspace kinderspace_dev' > backup.sql

# Importar a BD local
docker exec -i kinderspace-postgres psql -U kinderspace -d kinderspace_dev < backup.sql
```

**De Local → IONOS**:
```bash
./sync-db-to-ionos.sh
```

---

## 🛠️ Troubleshooting

### Error: "Cannot connect to database"

**Solución**: Verifica que el firewall de IONOS permita conexiones al puerto 5437.

```bash
# Prueba la conexión
telnet 216.250.125.239 5437
```

Si no conecta, contacta al administrador del servidor.

### Error: "Docker daemon is not running"

**Solución**:
```bash
open -a Docker
# Espera 10-15 segundos
docker ps
```

### Error: "Module not found: @kinderspace/shared-types"

**Solución**:
```bash
cd littlebees-web
pnpm --filter @kinderspace/shared-types build
pnpm --filter @kinderspace/shared-validators build
```

### Error: "Port 3002 already in use"

**Solución**:
```bash
lsof -ti:3002 | xargs kill -9
pnpm dev:api
```

---

## 📝 Archivos Importantes

- `SETUP_ENVIRONMENT.md` - Setup completo desde cero
- `SINCRONIZACION_BD.md` - Cómo sincronizar bases de datos
- `README.md` - Documentación general del proyecto
- `ESTRUCTURA_MULTIREPO.md` - Estructura del monorepo
- `deploy-to-ionos.sh` - Script de despliegue
- `sync-db-to-ionos.sh` - Script de sincronización de BD

---

## ⚡ Comandos Rápidos

```bash
# Desarrollo
pnpm dev              # Backend + Web
pnpm dev:api          # Solo backend
pnpm dev:web          # Solo web
pnpm mobile:run       # Flutter app

# Base de datos
pnpm db:migrate       # Ejecutar migraciones (en IONOS)
pnpm db:studio        # Abrir Prisma Studio

# Docker (solo servicios locales)
docker compose -f littlebees-web/infrastructure/docker/docker-compose.yml up -d redis minio
docker compose -f littlebees-web/infrastructure/docker/docker-compose.yml down

# Despliegue
./deploy-to-ionos.sh  # Desplegar a IONOS
```

---

## 🎯 Diferencias con iMac

| Aspecto | iMac | MacBook Pro |
|---------|------|-------------|
| **Base de Datos** | Puede usar local o IONOS | Usa IONOS directamente |
| **Ruta SSH** | `/Users/hectorlopez/...` | `/Users/hectoreduardosanchezlopez/...` |
| **Scripts** | Detectan automáticamente | Detectan automáticamente |
| **Datos** | Independientes si usa BD local | Mismos datos que IONOS |

---

## ✅ Checklist de Verificación

Antes de empezar a desarrollar, verifica:

- [ ] Docker Desktop está corriendo
- [ ] Redis y MinIO están corriendo localmente
- [ ] Archivo `.env` configurado con BD de IONOS
- [ ] `pnpm install` completado
- [ ] Packages compartidos construidos
- [ ] Backend API corriendo en puerto 3002
- [ ] Frontend Web corriendo en puerto 3001
- [ ] Puedes hacer login en http://localhost:3001

---

## 🚀 ¡Listo para Desarrollar!

Una vez completados todos los pasos, estarás listo para:
- ✅ Desarrollar nuevas features
- ✅ Probar cambios con datos reales de IONOS
- ✅ Desplegar a producción cuando estés listo
- ✅ Trabajar con la misma BD desde cualquier computadora

---

**Última actualización**: 12 de Marzo, 2026
