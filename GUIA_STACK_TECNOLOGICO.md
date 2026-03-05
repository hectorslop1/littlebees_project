# 🛠️ Stack Tecnológico LittleBees - Guía de Instalación

## 📦 Stack Compartido (Backend + Web + Mobile)

### 🗄️ **Base de Datos**
- **PostgreSQL 16** (reemplaza Supabase)
  - Base de datos relacional SQL
  - Se ejecuta en Docker (no instalación manual)
  - Acceso: `localhost:5432`

### 🔐 **Autenticación**
- **JWT (JSON Web Tokens)**
  - Access token (15 min)
  - Refresh token (7 días)
  - Almacenamiento seguro: `flutter_secure_storage`

### 🌐 **Comunicación en Tiempo Real**
- **Socket.IO** (WebSockets)
  - Chat en vivo
  - Notificaciones push
  - Puerto: `3002` (mismo que API)

---

## 🖥️ Backend (littlebees-web/apps/api)

### **Runtime & Framework**
```bash
Node.js v20+          # Runtime JavaScript
NestJS 10             # Framework backend (como Express pero enterprise)
TypeScript 5          # JavaScript con tipos
```

### **Base de Datos & ORM**
```bash
PostgreSQL 16         # Base de datos (en Docker)
Prisma 6              # ORM (como Supabase client pero para PostgreSQL)
Redis 7               # Cache en memoria (en Docker)
```

### **Almacenamiento de Archivos**
```bash
MinIO                 # S3-compatible (fotos, documentos) - en Docker
```

### **Seguridad**
```bash
Argon2                # Hash de passwords (más seguro que bcrypt)
Passport.js           # Autenticación
JWT                   # Tokens
```

### **Instalación Backend**
```bash
# 1. Instalar Node.js 20+
# Descarga: https://nodejs.org/

# 2. Instalar pnpm (gestor de paquetes)
npm install -g pnpm

# 3. Instalar Docker Desktop
# Descarga: https://www.docker.com/products/docker-desktop/

# 4. Clonar e instalar
cd littlebees-web
pnpm install

# 5. Levantar infraestructura (PostgreSQL, Redis, MinIO)
docker compose up -d

# 6. Configurar base de datos
cd apps/api
pnpm prisma migrate dev
pnpm prisma db seed

# 7. Iniciar backend
cd ../..
pnpm run dev
# API corriendo en: http://localhost:3002
```

---

## 🌐 Frontend Web (littlebees-web/apps/web)

### **Framework & UI**
```bash
Next.js 15            # Framework React con SSR
React 19              # Librería UI
TailwindCSS 3         # Estilos (como Bootstrap pero utility-first)
Radix UI              # Componentes accesibles (headless)
```

### **Estado & Datos**
```bash
TanStack Query 5      # Manejo de estado servidor (cache, refetch)
React Hook Form       # Formularios
Zod                   # Validación de datos
```

### **Gráficas & Utilidades**
```bash
Recharts              # Gráficas y charts
Lucide React          # Iconos
date-fns              # Manejo de fechas
```

### **Instalación Web**
```bash
# Ya está en el mismo proyecto
cd littlebees-web
pnpm install
pnpm run dev
# Web corriendo en: http://localhost:3001
```

---

## 📱 Mobile (littlebees-mobile)

### **Framework**
```bash
Flutter 3.11+         # Framework multiplataforma (iOS + Android)
Dart                  # Lenguaje de programación
```

### **Estado & Navegación**
```bash
Riverpod 2            # State management (como Provider pero mejorado)
GoRouter 14           # Navegación declarativa
```

### **Networking**
```bash
Dio 5                 # HTTP client (como axios)
socket_io_client 3    # WebSockets (mismo que web)
```

### **Storage & Datos**
```bash
flutter_secure_storage 9    # Tokens seguros (Keychain/Keystore)
shared_preferences 2        # Preferencias locales
Hive 1                      # Base de datos local NoSQL
```

### **UI & Diseño**
```bash
Lucide Icons          # Iconos (mismo que web)
Google Fonts          # Fuentes
fl_chart              # Gráficas (equivalente a Recharts)
flutter_animate       # Animaciones
```

### **Instalación Mobile**
```bash
# 1. Instalar Flutter SDK
# Descarga: https://docs.flutter.dev/get-started/install

# 2. Verificar instalación
flutter doctor

# 3. Instalar dependencias
cd littlebees-mobile
flutter pub get

# 4. Generar código (modelos Freezed)
dart run build_runner build --delete-conflicting-outputs

# 5. Ejecutar app
flutter run
# O para dispositivo físico con IP de tu Mac:
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3002/api/v1
```

---

## 🔄 Flujo de Datos (Sin Supabase)

```
┌─────────────────────────────────────────────────────┐
│  Flutter App (Mobile)                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │   Dio    │───▶│   JWT    │───▶│  Secure  │      │
│  │ (HTTP)   │    │  Tokens  │    │ Storage  │      │
│  └──────────┘    └──────────┘    └──────────┘      │
└─────────────────────────────────────────────────────┘
                         │
                    HTTP REST
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│  NestJS API (Backend)                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │  Prisma  │───▶│PostgreSQL│    │  MinIO   │      │
│  │  (ORM)   │    │   (DB)   │    │ (Files)  │      │
│  └──────────┘    └──────────┘    └──────────┘      │
└─────────────────────────────────────────────────────┘
```

---

## 📥 Checklist de Instalación

### **Herramientas Globales**
- [ ] Node.js 20+ instalado
- [ ] pnpm instalado (`npm install -g pnpm`)
- [ ] Docker Desktop instalado y corriendo
- [ ] Flutter SDK instalado
- [ ] Editor: VS Code con extensiones:
  - Flutter
  - Dart
  - Prisma
  - ESLint

### **Backend Setup**
- [ ] `cd littlebees-web && pnpm install`
- [ ] `docker compose up -d` (PostgreSQL, Redis, MinIO)
- [ ] `cd apps/api && pnpm prisma migrate dev`
- [ ] `pnpm prisma db seed` (datos de prueba)
- [ ] `cd ../.. && pnpm run dev`
- [ ] Verificar: http://localhost:3002/health

### **Mobile Setup**
- [ ] `cd littlebees-mobile && flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter run`
- [ ] Login con: `padre@gmail.com` / `Password123!`

---

## 🆚 Comparación con Supabase

| Concepto | Supabase | LittleBees Stack |
|----------|----------|------------------|
| **Base de datos** | PostgreSQL (cloud) | PostgreSQL (Docker local) |
| **ORM/Client** | `supabase_flutter` | Prisma + API REST |
| **Auth** | Supabase Auth | JWT custom (NestJS) |
| **Storage** | Supabase Storage | MinIO (S3-compatible) |
| **Realtime** | Supabase Realtime | Socket.IO |
| **Backend** | Serverless functions | NestJS (full control) |

**Ventajas del stack actual:**
- ✅ Control total del backend
- ✅ No vendor lock-in
- ✅ Gratis (todo local/self-hosted)
- ✅ Mismo stack web + mobile
- ✅ TypeScript end-to-end

---

## 🔗 URLs Importantes

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| **API Backend** | http://localhost:3002 | - |
| **API Docs (Swagger)** | http://localhost:3002/api | - |
| **Web App** | http://localhost:3001 | padre@gmail.com / Password123! |
| **PostgreSQL** | localhost:5432 | postgres / postgres |
| **MinIO Console** | http://localhost:9001 | minioadmin / minioadmin |
| **Redis** | localhost:6379 | - |

---

## 🚀 Comandos Rápidos

```bash
# Backend
cd littlebees-web
docker compose up -d              # Levantar infraestructura
pnpm run dev                      # Iniciar API + Web
pnpm run dev:api                  # Solo API
pnpm run dev:web                  # Solo Web

# Mobile
cd littlebees-mobile
flutter run                       # Ejecutar app
flutter analyze                   # Verificar código
dart run build_runner watch       # Auto-generar modelos
```

---

## 📚 Recursos de Aprendizaje

- **NestJS:** https://docs.nestjs.com/
- **Prisma:** https://www.prisma.io/docs
- **Flutter:** https://docs.flutter.dev/
- **Riverpod:** https://riverpod.dev/
- **TailwindCSS:** https://tailwindcss.com/docs

---

**¡Stack configurado y listo! 🎉**
