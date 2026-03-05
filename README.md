# 🐝 LittleBees - Sistema de Gestión para Guarderías

**Monorepo** que incluye Backend (NestJS), Frontend Web (Next.js) y App Móvil (Flutter)

---

## 📦 Estructura del Proyecto

```
littlebees_project/
├── littlebees-web/          # Backend + Web (pnpm workspace)
│   ├── apps/
│   │   ├── api/            # NestJS API
│   │   └── web/            # Next.js Web App
│   └── packages/           # Shared TypeScript packages
│
└── littlebees-mobile/       # Flutter Mobile App
```

---

## 🚀 Quick Start

### **¿Primera vez configurando el proyecto?**

**🆕 Nueva Mac (Flujo Recomendado):**
1. Instala Docker Desktop + Windsurf
2. Instala MCP desde marketplace (Context7, GitHub, Chrome DevTools, Vercel)
3. Abre nuevo chat con Cascade
4. Sigue: [PRIMERA_VEZ_EN_NUEVA_MAC.md](./PRIMERA_VEZ_EN_NUEVA_MAC.md) ⭐

**Opción 1: Setup Automático**
```bash
./setup.sh
```

**Opción 2: Setup Manual**
Sigue la guía completa: [SETUP_ENVIRONMENT.md](./SETUP_ENVIRONMENT.md)

**Opción 3: Checklist Rápido**
Consulta: [QUICK_SETUP_CHECKLIST.md](./QUICK_SETUP_CHECKLIST.md)

---

### **Prerequisitos**
- Node.js 20+
- pnpm 10+
- Docker Desktop
- Flutter 3.11+
- Windsurf IDE (opcional pero recomendado)

### **1. Instalar dependencias**
```bash
# Instalar dependencias del monorepo (backend + web)
pnpm install
```

### **2. Levantar infraestructura Docker**
```bash
# PostgreSQL, Redis, MinIO, pgAdmin
pnpm docker:up
```

### **3. Configurar base de datos**
```bash
# Ejecutar migraciones
pnpm db:migrate

# Cargar datos de prueba
pnpm db:seed
```

### **4. Iniciar desarrollo**

**Backend + Web:**
```bash
pnpm dev              # Ambos en paralelo
# O por separado:
pnpm dev:api          # Solo backend (puerto 3002)
pnpm dev:web          # Solo web (puerto 3001)
```

**Mobile:**
```bash
pnpm mobile:run       # Flutter app
```

---

## 🔑 Credenciales de Prueba

**Password universal:** `Password123!`

| Rol | Email |
|-----|-------|
| Director | director@petitsoleil.mx |
| Padre | padre@gmail.com |
| Madre | madre@gmail.com |

---

## 🌐 URLs de Servicios

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **API Backend** | http://localhost:3002 | - |
| **Web App** | http://localhost:3001 | Ver arriba |
| **pgAdmin** | http://localhost:5050 | admin@kinderspace.mx / kinderspace123 |
| **MinIO Console** | http://localhost:9011 | kinderspace / kinderspace123 |

---

## 📜 Scripts Disponibles

### **Desarrollo**
```bash
pnpm dev              # Backend + Web
pnpm dev:api          # Solo backend
pnpm dev:web          # Solo web
pnpm mobile:run       # Flutter app
```

### **Base de Datos**
```bash
pnpm db:migrate       # Ejecutar migraciones
pnpm db:seed          # Cargar datos de prueba
pnpm db:studio        # Abrir Prisma Studio
```

### **Docker**
```bash
pnpm docker:up        # Levantar contenedores
pnpm docker:down      # Detener contenedores
pnpm docker:logs      # Ver logs
```

### **Generación de Cliente API**
```bash
pnpm generate:api-client    # Generar cliente Dart desde OpenAPI
pnpm generate:dart-client   # Alternativa con pnpm
```

### **Build & Test**
```bash
pnpm build            # Build todo (turbo)
pnpm lint             # Lint todo
pnpm test             # Test todo
pnpm mobile:analyze   # Analizar código Flutter
pnpm mobile:test      # Tests Flutter
```

---

## 🛠️ Stack Tecnológico

### **Backend (littlebees-web/apps/api)**
- NestJS 10
- Prisma 6 + PostgreSQL 16
- JWT Auth + Argon2
- Socket.IO
- Redis (cache)
- MinIO (S3-compatible storage)

### **Web (littlebees-web/apps/web)**
- Next.js 15 + React 19
- TailwindCSS + Radix UI
- TanStack Query
- Socket.IO Client

### **Mobile (littlebees-mobile)**
- Flutter 3.11+
- Riverpod (state management)
- Dio (HTTP client)
- GoRouter (navigation)
- Socket.IO Client

---

## 📚 Documentación

### **Setup y Configuración**
- [Primera Vez en Nueva Mac](./PRIMERA_VEZ_EN_NUEVA_MAC.md) ⭐ **Recomendado**
- [Setup Environment - Guía Completa](./SETUP_ENVIRONMENT.md)
- [Quick Setup Checklist](./QUICK_SETUP_CHECKLIST.md)
- [Script de Setup Automático](./setup.sh)

### **Arquitectura y Stack**
- [Estructura del Monorepo](./ESTRUCTURA_MULTIREPO.md)
- [Guía de Stack Tecnológico](./GUIA_STACK_TECNOLOGICO.md)

### **Desarrollo**
- [Generación de Cliente API](./GENERACION_CLIENTE_API.md)
- [API Contracts](./littlebees-web/packages/api-contracts/README.md)
- [README Mobile](./littlebees-mobile/README.md)

### **Infraestructura**
- [Setup pgAdmin](./littlebees-web/infrastructure/docker/PGADMIN_SETUP.md)
- [Configuración MCP](./.windsurf/mcp_settings.example.json)

---

## 🐳 Servicios Docker

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| PostgreSQL | 5437 | Base de datos principal |
| Redis | 6383 | Cache y sesiones |
| MinIO | 9010 (API), 9011 (Console) | Almacenamiento de archivos |
| pgAdmin | 5050 | Administrador de PostgreSQL |

---

## 🔧 Configuración de Entorno

El archivo `.env` se crea automáticamente desde `.env.example` en `littlebees-web/apps/api/`

**Variables principales:**
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret para tokens JWT
- `REDIS_URL`: Redis connection string
- `MINIO_ENDPOINT`: MinIO API endpoint

---

## 🤝 Contribuir

1. Crea una rama desde `main`
2. Haz tus cambios
3. Ejecuta `pnpm lint` y `pnpm test`
4. Crea un Pull Request

---

## 📄 Licencia

Privado - Todos los derechos reservados

---

**¡Happy coding! 🚀**
