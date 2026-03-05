# 🚀 Setup Environment - LittleBees Project

**Guía completa para configurar el entorno de desarrollo en macOS desde cero**

Esta guía te permitirá replicar exactamente el entorno de desarrollo de LittleBees en una nueva Mac.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación de Herramientas Base](#instalación-de-herramientas-base)
3. [Instalación de Windsurf IDE](#instalación-de-windsurf-ide)
4. [Configuración de MCP Servers](#configuración-de-mcp-servers)
5. [Clonar el Proyecto](#clonar-el-proyecto)
6. [Configuración de Docker](#configuración-de-docker)
7. [Configuración de Base de Datos](#configuración-de-base-de-datos)
8. [Iniciar Aplicaciones](#iniciar-aplicaciones)
9. [Verificación del Entorno](#verificación-del-entorno)
10. [Troubleshooting](#troubleshooting)

---

## 1. Requisitos Previos

### **Sistema Operativo**
- macOS 12.0 (Monterey) o superior
- Mínimo 8GB RAM (recomendado 16GB)
- 20GB de espacio libre en disco

### **Acceso**
- Cuenta de GitHub (para clonar repositorio)
- Permisos de administrador en la Mac

---

## 2. Instalación de Herramientas Base

### **2.1. Homebrew (Package Manager)**

```bash
# Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Agregar Homebrew al PATH (si es necesario)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verificar instalación
brew --version
```

### **2.2. Node.js 20+ y pnpm**

```bash
# Instalar Node.js 20 LTS
brew install node@20

# Verificar instalación
node --version  # Debe mostrar v20.x.x

# Instalar pnpm globalmente
npm install -g pnpm@10.12.4

# Verificar instalación
pnpm --version  # Debe mostrar 10.12.4
```

### **2.3. Docker Desktop**

**Opción 1: Descarga Manual (Recomendado)**
1. Ve a https://www.docker.com/products/docker-desktop
2. Descarga Docker Desktop para Mac (Apple Silicon o Intel según tu Mac)
3. Abre el archivo `.dmg` descargado
4. Arrastra Docker a la carpeta Applications
5. Abre Docker Desktop desde Applications
6. Acepta los términos y condiciones
7. Espera a que Docker inicie completamente (ícono en la barra de menú)

**Opción 2: Homebrew**
```bash
brew install --cask docker
# Luego abre Docker Desktop manualmente desde Applications
```

**Verificar instalación:**
```bash
docker --version
docker compose version
```

### **2.4. Flutter SDK 3.11+**

```bash
# Instalar Flutter
brew install --cask flutter

# Verificar instalación
flutter --version

# Ejecutar flutter doctor para verificar dependencias
flutter doctor

# Aceptar licencias de Android (si es necesario)
flutter doctor --android-licenses
```

### **2.5. Dart SDK**

```bash
# Instalar Dart SDK
brew tap dart-lang/dart
brew install dart

# Verificar instalación
dart --version  # Debe mostrar 3.11.1 o superior
```

### **2.6. Git**

```bash
# Git generalmente viene preinstalado en macOS
# Verificar instalación
git --version

# Si no está instalado:
brew install git

# Configurar Git (reemplaza con tus datos)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

---

## 3. Instalación de Windsurf IDE

### **3.1. Descargar e Instalar Windsurf**

1. Ve a https://codeium.com/windsurf
2. Descarga Windsurf para macOS
3. Abre el archivo descargado
4. Arrastra Windsurf a la carpeta Applications
5. Abre Windsurf desde Applications
6. Completa el proceso de configuración inicial

### **3.2. Configuración Inicial de Windsurf**

1. Abre Windsurf
2. Inicia sesión con tu cuenta de Codeium (o crea una)
3. Acepta los permisos necesarios
4. Configura tus preferencias de editor (opcional)

---

## 4. Configuración de MCP Servers

### **4.1. Instalar MCP desde el Marketplace de Windsurf**

1. Abre Windsurf
2. Ve a la sección de **MCP** (Model Context Protocol)
3. Busca e instala los siguientes MCP desde el marketplace:
   - ✅ **Context7**
   - ✅ **GitHub**
   - ✅ **Chrome DevTools**
   - ✅ **Vercel**

### **4.2. Configuración Manual de MCP Servers**

**Ubicación del archivo de configuración:**
```
~/Library/Application Support/Windsurf/User/globalStorage/codeium.windsurf/mcp/mcp_settings.json
```

**Pasos:**

1. Abre el archivo de configuración:
```bash
# Opción 1: Desde terminal
open ~/Library/Application\ Support/Windsurf/User/globalStorage/codeium.windsurf/mcp/mcp_settings.json

# Opción 2: Desde Windsurf
# Command Palette (⌘⇧P) → "Preferences: Open MCP Settings"
```

2. Agrega la siguiente configuración (reemplaza el contenido completo):

```json
{
  "mcpServers": {
    "dart-mcp-server": {
      "command": "dart",
      "args": ["mcp-server"],
      "env": {}
    },
    "docker": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-docker"],
      "env": {}
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://kinderspace:kinderspace@localhost:5437/kinderspace_dev"
      ],
      "env": {}
    }
  }
}
```

3. Guarda el archivo
4. Reinicia Windsurf para aplicar los cambios

**Verificar MCP Servers:**
- Abre Windsurf
- Deberías ver los MCP servers activos en la barra lateral de MCP

---

## 5. Clonar el Proyecto

### **5.1. Crear Directorio de Proyectos**

```bash
# Crear directorio (ajusta la ruta según tu preferencia)
mkdir -p ~/Desktop/Proyectos
cd ~/Desktop/Proyectos
```

### **5.2. Clonar el Repositorio**

```bash
# Clonar el proyecto (reemplaza con la URL real de tu repositorio)
git clone <URL_DEL_REPOSITORIO> littlebees_project

# Entrar al directorio
cd littlebees_project
```

### **5.3. Verificar Estructura del Proyecto**

```bash
# Listar contenido
ls -la

# Deberías ver:
# - littlebees-web/
# - littlebees-mobile/
# - package.json
# - pnpm-workspace.yaml
# - README.md
# - etc.
```

---

## 6. Configuración de Docker

### **6.1. Verificar que Docker Desktop esté Corriendo**

```bash
# Verificar estado de Docker
docker ps

# Si no está corriendo, abre Docker Desktop desde Applications
```

### **6.2. Iniciar Contenedores de Infraestructura**

```bash
# Desde la raíz del proyecto
cd ~/Desktop/Proyectos/littlebees_project

# Levantar contenedores (PostgreSQL, Redis, MinIO, pgAdmin)
pnpm docker:up

# Verificar que los contenedores estén corriendo
docker ps

# Deberías ver:
# - kinderspace-postgres (puerto 5437)
# - kinderspace-redis (puerto 6383)
# - kinderspace-minio (puertos 9010, 9011)
# - kinderspace-pgadmin (puerto 5050)
```

### **6.3. Puertos Utilizados**

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| PostgreSQL | 5437 | Base de datos principal |
| Redis | 6383 | Cache y sesiones |
| MinIO API | 9010 | Almacenamiento de archivos |
| MinIO Console | 9011 | Interfaz web de MinIO |
| pgAdmin | 5050 | Administrador de PostgreSQL |
| API Backend | 3002 | NestJS API |
| Web App | 3001 | Next.js Frontend |

**Nota:** Los puertos no estándar (5437, 6383, 9010) se usan para evitar conflictos con instalaciones locales.

---

## 7. Configuración de Base de Datos

### **7.1. Instalar Dependencias del Proyecto**

```bash
# Desde la raíz del proyecto
cd ~/Desktop/Proyectos/littlebees_project

# Instalar dependencias del monorepo
pnpm install

# Construir packages compartidos
cd littlebees-web
pnpm --filter @kinderspace/shared-types build
pnpm --filter @kinderspace/shared-validators build
```

### **7.2. Ejecutar Migraciones de Prisma**

```bash
# Desde la raíz del proyecto
pnpm db:migrate

# Esto creará todas las tablas en PostgreSQL
```

### **7.3. Cargar Datos de Prueba (Seed)**

```bash
# Desde la raíz del proyecto
pnpm db:seed

# Esto creará usuarios de prueba y datos iniciales
```

**Usuarios creados:**
- `director@petitsoleil.mx` - María González (Directora)
- `maestra@petitsoleil.mx` - Ana López (Maestra)
- `maestra2@petitsoleil.mx` - Laura Martínez (Maestra)
- `admin@petitsoleil.mx` - Roberto Sánchez (Admin)
- `padre@gmail.com` - Carlos Ramírez (Padre)

**Password universal:** `Password123!`

### **7.4. Verificar Base de Datos con pgAdmin (Opcional)**

1. Abre http://localhost:5050 en tu navegador
2. Inicia sesión con:
   - Email: `admin@kinderspace.mx`
   - Password: `kinderspace123`
3. Agrega servidor PostgreSQL:
   - Host: `host.docker.internal` (macOS/Windows) o `172.17.0.1` (Linux)
   - Port: `5437`
   - Database: `kinderspace_dev`
   - Username: `kinderspace`
   - Password: `kinderspace`

**Documentación completa:** `littlebees-web/infrastructure/docker/PGADMIN_SETUP.md`

---

## 8. Iniciar Aplicaciones

### **8.1. Iniciar Backend API (NestJS)**

```bash
# Terminal 1: Desde la raíz del proyecto
pnpm dev:api

# Espera a ver:
# "KinderSpace API running on http://localhost:3002"
# "Swagger docs at http://localhost:3002/api/docs"
```

**Verificar API:**
- Abre http://localhost:3002/api/docs en tu navegador
- Deberías ver la documentación Swagger

### **8.2. Iniciar Web App (Next.js)**

```bash
# Terminal 2: Desde la raíz del proyecto
pnpm dev:web

# Espera a ver:
# "✓ Ready in X.Xs"
# "- Local: http://localhost:3001"
```

**Verificar Web App:**
- Abre http://localhost:3001 en tu navegador
- Deberías ver la página de login
- Prueba hacer login con cualquier usuario de prueba

### **8.3. Iniciar App Móvil (Flutter)**

**Prerequisito:** Tener un simulador iOS abierto o un dispositivo Android conectado

```bash
# Terminal 3: Desde la raíz del proyecto
cd littlebees-mobile

# Instalar dependencias de Flutter
flutter pub get

# Listar dispositivos disponibles
flutter devices

# Ejecutar la app
flutter run

# O desde la raíz del proyecto:
pnpm mobile:run
```

**Verificar App Móvil:**
- La app debería abrirse en el simulador/dispositivo
- Deberías ver la pantalla de splash y luego login
- Prueba hacer login con `padre@gmail.com` / `Password123!`

---

## 9. Verificación del Entorno

### **9.1. Checklist de Verificación**

Ejecuta estos comandos para verificar que todo está instalado correctamente:

```bash
# Herramientas base
node --version          # v20.x.x
pnpm --version          # 10.12.4
docker --version        # Docker version 24.x.x
flutter --version       # Flutter 3.11.x
dart --version          # Dart 3.11.x

# Servicios Docker
docker ps               # Deberías ver 4 contenedores corriendo

# Proyecto
cd ~/Desktop/Proyectos/littlebees_project
pnpm --version          # Verificar que pnpm funciona en el proyecto
```

### **9.2. URLs de Verificación**

Abre estas URLs en tu navegador para verificar que todo funciona:

- ✅ **API Backend:** http://localhost:3002/api/docs
- ✅ **Web App:** http://localhost:3001
- ✅ **pgAdmin:** http://localhost:5050
- ✅ **MinIO Console:** http://localhost:9011

### **9.3. Test de Login Completo**

1. Abre http://localhost:3001/login
2. Haz clic en "María González (Directora)"
3. Haz clic en "Iniciar Sesión"
4. Deberías ser redirigido al dashboard
5. Verifica que ves:
   - Sidebar con navegación
   - Estadísticas en el dashboard
   - Tu nombre en el perfil (María González)

---

## 10. Troubleshooting

### **Error: "command not found: pnpm"**

**Solución:**
```bash
npm install -g pnpm@10.12.4
```

### **Error: "Docker daemon is not running"**

**Solución:**
1. Abre Docker Desktop desde Applications
2. Espera a que el ícono de Docker en la barra de menú muestre "Docker Desktop is running"
3. Intenta de nuevo

### **Error: "Port 5437 already in use"**

**Solución:**
```bash
# Detener contenedores
pnpm docker:down

# Matar proceso que usa el puerto
lsof -ti:5437 | xargs kill -9

# Reiniciar contenedores
pnpm docker:up
```

### **Error: "Module not found: @kinderspace/shared-types"**

**Solución:**
```bash
# Construir packages compartidos
cd littlebees-web
pnpm --filter @kinderspace/shared-types build
pnpm --filter @kinderspace/shared-validators build

# Reiniciar la app web
```

### **Error: Flutter "No devices found"**

**Solución:**
```bash
# Abrir simulador iOS
open -a Simulator

# O instalar Android SDK
flutter doctor --android-licenses
```

### **Error: "Connection refused" al hacer login**

**Solución:**
1. Verifica que el API esté corriendo: `curl http://localhost:3002/api/docs`
2. Verifica que PostgreSQL esté corriendo: `docker ps | grep postgres`
3. Reinicia el API: `pnpm dev:api`

### **Error: Prisma migrations fallan**

**Solución:**
```bash
# Resetear base de datos (CUIDADO: borra todos los datos)
pnpm db:migrate

# Volver a cargar datos de prueba
pnpm db:seed
```

### **Error: "EADDRINUSE: address already in use :::3002"**

**Solución:**
```bash
# Matar proceso en puerto 3002
lsof -ti:3002 | xargs kill -9

# Reiniciar API
pnpm dev:api
```

### **Error: MCP servers no aparecen en Windsurf**

**Solución:**
1. Verifica que el archivo `mcp_settings.json` esté en la ubicación correcta
2. Verifica que el JSON sea válido (sin comas extras, etc.)
3. Reinicia Windsurf completamente
4. Verifica que Dart y Node.js estén en el PATH

### **Error: pgAdmin no carga**

**Solución:**
```bash
# Verificar que el contenedor esté corriendo
docker ps | grep pgadmin

# Reiniciar contenedor
docker restart kinderspace-pgadmin

# Ver logs
docker logs kinderspace-pgadmin
```

---

## 11. Configuraciones Locales Importantes

### **11.1. Archivo .env (NO incluido en Git)**

El archivo `.env` en `littlebees-web/apps/api/.env` se crea automáticamente desde `.env.example` al ejecutar migraciones.

**Si necesitas crearlo manualmente:**
```bash
cd littlebees-web/apps/api
cp .env.example .env
```

**Variables importantes:**
- `DATABASE_URL`: Ya configurado para Docker
- `JWT_SECRET`: Generado automáticamente
- `REDIS_URL`: Ya configurado para Docker
- `MINIO_ENDPOINT`: http://localhost:9010

### **11.2. Configuración de Flutter**

El archivo `littlebees-mobile/lib/core/config/app_config.dart` ya tiene la configuración correcta para desarrollo local:

```dart
apiBaseUrl: 'http://localhost:3002/api/v1'
wsBaseUrl: 'http://localhost:3002'
```

**Para iOS Simulator:** Usa `localhost`  
**Para Android Emulator:** Usa `10.0.2.2` en lugar de `localhost`

### **11.3. Git Ignore**

Archivos que NO se sincronizan con Git (ya configurados):
- `node_modules/`
- `.env`
- `dist/`, `build/`
- `.dart_tool/`
- `littlebees-mobile/lib/generated/api/` (cliente generado)
- `littlebees-web/packages/api-contracts/openapi.json`

---

## 12. Scripts Útiles

### **Desde la raíz del proyecto:**

```bash
# Desarrollo
pnpm dev              # Backend + Web
pnpm dev:api          # Solo backend
pnpm dev:web          # Solo web
pnpm mobile:run       # Flutter app

# Base de datos
pnpm db:migrate       # Ejecutar migraciones
pnpm db:seed          # Cargar datos de prueba
pnpm db:studio        # Abrir Prisma Studio

# Docker
pnpm docker:up        # Levantar contenedores
pnpm docker:down      # Detener contenedores
pnpm docker:logs      # Ver logs

# Build
pnpm build            # Build todo
pnpm lint             # Lint todo
pnpm test             # Test todo

# Generación de cliente API
pnpm generate:api-client    # Generar cliente Dart desde OpenAPI
```

---

## 13. Próximos Pasos

Una vez que todo esté configurado:

1. ✅ Lee la documentación del proyecto: `README.md`
2. ✅ Revisa la estructura del monorepo: `ESTRUCTURA_MULTIREPO.md`
3. ✅ Aprende sobre la generación de cliente API: `GENERACION_CLIENTE_API.md`
4. ✅ Explora el código en Windsurf
5. ✅ Comienza a desarrollar nuevas features

---

## 14. Recursos Adicionales

- **Documentación del Proyecto:** `README.md`
- **Stack Tecnológico:** `GUIA_STACK_TECNOLOGICO.md`
- **Estructura del Monorepo:** `ESTRUCTURA_MULTIREPO.md`
- **Generación de Cliente API:** `GENERACION_CLIENTE_API.md`
- **Setup de pgAdmin:** `littlebees-web/infrastructure/docker/PGADMIN_SETUP.md`
- **API Contracts:** `littlebees-web/packages/api-contracts/README.md`

---

## 15. Contacto y Soporte

Si encuentras problemas no cubiertos en este documento:

1. Revisa la sección de [Troubleshooting](#10-troubleshooting)
2. Consulta los logs de Docker: `pnpm docker:logs`
3. Revisa los logs de la aplicación en la terminal
4. Consulta con el equipo de desarrollo

---

**¡Entorno configurado y listo para desarrollar! 🚀**
