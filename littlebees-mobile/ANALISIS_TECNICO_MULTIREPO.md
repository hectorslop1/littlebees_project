# Little Bees — Análisis Técnico y Estrategia Multirepo

> **Fecha:** 3 de marzo de 2026
> **Repositorio analizado:** [CB-Luna/littlebees](https://github.com/CB-Luna/littlebees)
> **Autor:** Análisis generado para el equipo de desarrollo Little Bees

---

## Tabla de Contenidos

1. [Diagnóstico Completo del Proyecto Web](#1-diagnóstico-completo-del-proyecto-web)
2. [Stack Tecnológico Completo](#2-stack-tecnológico-completo)
3. [Arquitectura Implementada](#3-arquitectura-implementada)
4. [Estructura de Carpetas](#4-estructura-de-carpetas)
5. [Patrones de Diseño Utilizados](#5-patrones-de-diseño-utilizados)
6. [Modelo de Datos](#6-modelo-de-datos)
7. [Sistema de Autenticación](#7-sistema-de-autenticación)
8. [Buenas Prácticas Implementadas](#8-buenas-prácticas-implementadas)
9. [Nivel de Escalabilidad y Mantenibilidad](#9-nivel-de-escalabilidad-y-mantenibilidad)
10. [Estrategia Multirepo](#10-estrategia-multirepo)
11. [Lineamientos Técnicos Compartidos](#11-lineamientos-técnicos-compartidos)
12. [Mejoras Estructurales Propuestas](#12-mejoras-estructurales-propuestas)
13. [Confirmación: Sin Supabase](#13-confirmación-sin-supabase)

---

## 1. Diagnóstico Completo del Proyecto Web

### Resumen Ejecutivo

El proyecto web de Little Bees (internamente llamado **KinderSpace MX**) es un **monorepo maduro y bien estructurado** construido con tecnologías modernas y enterprise-ready. Utiliza **Turborepo + pnpm workspaces** como orquestador, con tres aplicaciones (`api`, `web`, `mobile`) y tres paquetes compartidos (`shared-types`, `shared-validators`, `api-contracts`).

### Estado Actual

| Aspecto | Estado | Observación |
|---|---|---|
| **Backend (API)** | ✅ Completo | NestJS con 16 módulos funcionales |
| **Frontend (Web)** | ✅ Completo | Next.js 15 con App Router y 10+ páginas |
| **Mobile (Flutter)** | 🟡 Scaffold | Estructura base, placeholders en tabs |
| **Infraestructura** | ✅ Completo | Docker Compose con PostgreSQL, Redis, MinIO |
| **Shared packages** | ✅ Completo | Types, validators y API contracts |

---

## 2. Stack Tecnológico Completo

### 2.1 Backend (API)

| Categoría | Tecnología | Versión |
|---|---|---|
| **Runtime** | Node.js | ≥ 20.0.0 |
| **Framework** | NestJS | ^10.4.15 |
| **Lenguaje** | TypeScript | ^5.7.3 |
| **ORM** | Prisma | ^6.2.1 |
| **Base de Datos** | PostgreSQL | 16 (Alpine) |
| **Cache** | Redis | 7 (Alpine) |
| **Object Storage** | MinIO (S3-compatible) | latest |
| **Autenticación** | Passport.js + JWT | ^0.7.0 / ^10.2.0 |
| **Hashing** | Argon2 | ^0.41.1 |
| **Validación** | class-validator + Zod | ^0.14.1 / ^3.24.1 |
| **Documentación API** | Swagger / OpenAPI | ^7.4.2 |
| **WebSockets** | Socket.IO | ^4.8.3 |
| **Rate Limiting** | @nestjs/throttler | ^6.3.0 |
| **Tenant Context** | nestjs-cls (CLS) | ^4.5.0 |
| **MFA** | otplib | ^12.0.1 |
| **Testing** | Jest | ^29.7.0 |

### 2.2 Frontend (Web)

| Categoría | Tecnología | Versión |
|---|---|---|
| **Framework** | Next.js (App Router) | ^15.1.6 |
| **Lenguaje** | TypeScript | ^5.7.3 |
| **UI Library** | React | ^19.0.0 |
| **Styling** | TailwindCSS | ^3.4.17 |
| **Component primitives** | Radix UI | Múltiples (^1.x / ^2.x) |
| **Icons** | Lucide React | ^0.468.0 |
| **State Management** | TanStack React Query | ^5.90.21 |
| **Auth State** | React Context + custom hooks | — |
| **Forms** | React Hook Form + Zod resolver | ^7.54.2 |
| **Charts** | Recharts | ^2.15.0 |
| **Date utils** | date-fns | ^3.0.0 |
| **Toasts** | Sonner | ^1.7.2 |
| **WebSockets** | socket.io-client | ^4.8.3 |
| **E2E Testing** | Playwright | ^1.58.2 |
| **CSS utilities** | class-variance-authority, clsx, tailwind-merge | — |

### 2.3 Mobile (Flutter — scaffold existente)

| Categoría | Tecnología | Versión |
|---|---|---|
| **Framework** | Flutter | SDK ≥3.5.0 |
| **Lenguaje** | Dart | — |
| **State Management** | Riverpod | ^2.6.1 |
| **Routing** | GoRouter | ^14.6.2 |
| **HTTP Client** | Dio | ^5.7.0 |
| **Local DB (offline-first)** | Drift (SQLite) | ^2.22.1 |
| **Secure Storage** | flutter_secure_storage | ^9.2.3 |
| **Push Notifications** | Firebase Messaging | ^15.1.6 |
| **QR Code** | mobile_scanner + qr_flutter | — |
| **Charts** | fl_chart | ^0.70.2 |

### 2.4 Herramientas de Desarrollo

| Herramienta | Propósito |
|---|---|
| **Turborepo** (^2.3.3) | Orquestación del monorepo, build caching |
| **pnpm** (10.12.4) | Package manager con workspaces |
| **Docker Compose** | Infraestructura local (PostgreSQL, Redis, MinIO) |
| **Prettier** (^3.4.2) | Code formatting |
| **ESLint** (^9.15.0) | Linting |
| **Orval** (^7.3.0) | Generación de cliente TypeScript desde OpenAPI |
| **OpenAPI Generator CLI** (^2.15.3) | Generación de cliente Dart desde OpenAPI |

---

## 3. Arquitectura Implementada

### 3.1 Patrón Arquitectónico General

**Monorepo con separación clara de concerns:**

```
┌──────────────────────────────────────────────────────┐
│                    MONOREPO (Turborepo)               │
├──────────────┬──────────────┬────────────────────────┤
│   apps/api   │   apps/web   │     apps/mobile        │
│   (NestJS)   │  (Next.js)   │     (Flutter)          │
├──────────────┴──────────────┴────────────────────────┤
│              packages/ (compartidos)                   │
│  shared-types │ shared-validators │ api-contracts     │
├──────────────────────────────────────────────────────┤
│           infrastructure/docker                       │
│     PostgreSQL │ Redis │ MinIO                        │
└──────────────────────────────────────────────────────┘
```

### 3.2 Backend — Modular Architecture (NestJS)

El API sigue una **arquitectura modular por features** con 16 módulos:

```
src/
├── main.ts                          # Bootstrap + Swagger + CORS + Validation
├── app.module.ts                    # Root module (importa todos los módulos)
├── common/                          # Cross-cutting concerns
│   ├── decorators/                  # @CurrentUser, @CurrentTenant, @Roles
│   ├── filters/                     # HttpExceptionFilter
│   ├── guards/                      # JwtAuthGuard, RolesGuard
│   └── interceptors/                # AuditLogInterceptor, TenantContextInterceptor
└── modules/
    ├── prisma/                      # PrismaService (DB client)
    ├── health/                      # Health check endpoint
    ├── auth/                        # Login, JWT, MFA, refresh tokens
    ├── users/                       # User management
    ├── tenants/                     # Multi-tenancy
    ├── children/                    # Child records
    ├── attendance/                  # Check-in/out
    ├── daily-logs/                  # Daily activity logs
    ├── development/                 # Milestone tracking
    ├── chat/                        # Real-time messaging (WebSocket)
    ├── payments/                    # Payment management
    ├── invoicing/                   # CFDI 4.0 (Mexico)
    ├── services/                    # Extra services marketplace
    ├── notifications/               # Multi-channel notifications
    ├── files/                       # File upload (MinIO/S3)
    ├── audit/                       # Audit logging
    └── reports/                     # Reporting
```

**Cada módulo sigue el patrón:**
- `*.module.ts` — Declaración del módulo NestJS
- `*.controller.ts` — Endpoints REST (con decoradores Swagger)
- `*.service.ts` — Lógica de negocio

### 3.3 Frontend — Feature-based + Domain-driven Components

```
src/
├── app/                             # Next.js App Router
│   ├── (auth)/                      # Route group: login
│   │   ├── layout.tsx               # Auth layout (centrado)
│   │   └── login/page.tsx
│   ├── (dashboard)/                 # Route group: app principal
│   │   ├── layout.tsx               # Dashboard layout (sidebar + topbar)
│   │   ├── page.tsx                 # Dashboard home
│   │   ├── attendance/page.tsx
│   │   ├── children/page.tsx
│   │   ├── chat/page.tsx
│   │   ├── development/page.tsx
│   │   ├── logs/page.tsx
│   │   ├── payments/page.tsx
│   │   ├── reports/page.tsx
│   │   ├── services/page.tsx
│   │   ├── settings/page.tsx
│   │   ├── error.tsx
│   │   ├── loading.tsx
│   │   └── not-found.tsx
│   ├── globals.css
│   └── layout.tsx                   # Root layout (providers)
├── components/
│   ├── auth/                        # Role guard
│   ├── domain/                      # Feature-specific components
│   │   ├── attendance/              # (filters, stats, table)
│   │   ├── chat/                    # (conversations, messages, bubbles)
│   │   ├── children/                # (card, detail, form, filters)
│   │   ├── dashboard/               # (stat-cards, charts)
│   │   ├── development/             # (categories, evaluation, milestones)
│   │   ├── logs/                    # (entry, filters, form, timeline)
│   │   ├── payments/                # (invoice, pay, list, stats)
│   │   ├── reports/                 # (attendance, development, payments)
│   │   ├── services/
│   │   └── settings/
│   ├── layout/                      # Sidebar, TopBar, MobileHeader
│   └── ui/                          # 24 componentes base reutilizables
├── contexts/                        # AuthContext
├── hooks/                           # 14 custom hooks (use-auth, use-children, etc.)
├── lib/                             # Utilidades core
│   ├── api-client.ts                # HTTP client con refresh automático
│   ├── auth.ts                      # Token management (cookies)
│   ├── socket.ts                    # WebSocket client
│   └── utils.ts                     # cn() utility
└── providers/                       # QueryClient + AuthProvider + Toaster
```

---

## 4. Estructura de Carpetas (Monorepo Completo)

```
littlebees/
├── apps/
│   ├── api/                         # Backend NestJS
│   │   ├── prisma/
│   │   │   ├── schema.prisma        # 560 líneas, 20+ modelos
│   │   │   ├── migrations/
│   │   │   └── seed.ts              # 773 líneas, datos completos de demo
│   │   ├── src/                     # 58 archivos TypeScript
│   │   ├── .env.example
│   │   ├── nest-cli.json
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── web/                         # Frontend Next.js
│   │   ├── src/                     # 52+ archivos TSX/TS
│   │   ├── e2e/                     # Playwright tests
│   │   ├── next.config.ts
│   │   ├── tailwind.config.ts
│   │   ├── playwright.config.ts
│   │   ├── postcss.config.js
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── mobile/                      # Flutter app (scaffold)
│       ├── lib/                     # 12 archivos Dart
│       │   ├── app/                 # (app, router, theme)
│       │   ├── core/api/            # (client, interceptors, endpoints)
│       │   ├── features/            # (auth, home)
│       │   └── main.dart
│       └── pubspec.yaml
├── packages/
│   ├── shared-types/                # 16 archivos TS de interfaces/enums
│   │   └── src/                     # (auth, children, attendance, etc.)
│   ├── shared-validators/           # 8 archivos Zod schemas
│   │   └── src/                     # (auth, children, payments, etc.)
│   └── api-contracts/               # OpenAPI → TS/Dart client generator
├── infrastructure/
│   └── docker/
│       ├── docker-compose.yml       # PostgreSQL + Redis + MinIO
│       └── init.sql                 # UUID + pgcrypto extensions
├── package.json                     # Root: turbo scripts
├── pnpm-workspace.yaml
├── turbo.json                       # Build pipeline configuration
├── start-dev.sh                     # Script de inicio completo
├── .prettierrc
└── .gitignore
```

---

## 5. Patrones de Diseño Utilizados

### Backend (NestJS)

| Patrón | Implementación |
|---|---|
| **Dependency Injection** | Core de NestJS — todos los servicios se inyectan |
| **Module Pattern** | Cada feature es un módulo independiente |
| **Repository Pattern** | PrismaService como abstracción de acceso a datos |
| **Guard Pattern** | JwtAuthGuard, RolesGuard para autorización |
| **Decorator Pattern** | @CurrentUser, @CurrentTenant, @Roles (custom) |
| **Interceptor Pattern** | TenantContextInterceptor, AuditLogInterceptor |
| **Filter Pattern** | HttpExceptionFilter para manejo uniforme de errores |
| **Strategy Pattern** | Passport JWT Strategy para autenticación |
| **Multi-tenancy (tenant-per-row)** | Cada registro tiene `tenantId`, CLS para contexto |
| **API Versioning** | Prefijo global `/api/v1` |

### Frontend (Next.js)

| Patrón | Implementación |
|---|---|
| **Provider Pattern** | AuthProvider, QueryClientProvider wrapping app |
| **Context + Hook** | AuthContext → useAuth() hook |
| **Custom Hook per Feature** | 14 hooks: useChildren, useAttendance, useChat, etc. |
| **Compound Components** | Componentes UI basados en Radix UI primitives |
| **Container/Presentational** | Pages (containers) → Domain components (presentational) |
| **Route Groups** | (auth) y (dashboard) en App Router |
| **Singleton API Client** | ApiClientClass con refresh token automático |
| **Optimistic Updates** | React Query mutations con invalidación de queries |

### Transversales

| Patrón | Implementación |
|---|---|
| **Contract-First** | shared-types + shared-validators consumidos por API y Web |
| **Auto-generated Clients** | OpenAPI → orval (TS) + openapi-generator (Dart) |
| **Shared Validation** | Zod schemas reutilizados en frontend y backend |

---

## 6. Modelo de Datos

### Entidades Principales (20+ modelos Prisma)

```
GLOBAL:
  └── Tenant (multi-tenancy root)
  └── DevelopmentMilestone (catálogo global)

AUTH & USERS:
  ├── User
  ├── UserTenant (role per tenant, M:N)
  └── RefreshToken

CHILDREN & GROUPS:
  ├── Group (por tenant)
  ├── Child (por tenant + grupo)
  ├── ChildMedicalInfo (1:1)
  ├── EmergencyContact (1:N)
  └── ChildParent (M:N con User)

OPERATIONS:
  ├── AttendanceRecord
  ├── DailyLogEntry
  └── DevelopmentRecord

COMMUNICATION:
  ├── Conversation
  ├── ConversationParticipant
  └── Message

BILLING:
  ├── Payment (Conekta)
  └── Invoice (Facturapi CFDI 4.0)

PLATFORM:
  ├── ExtraService (marketplace)
  ├── Notification (multi-channel)
  ├── AuditLog (append-only)
  └── File (MinIO/S3)
```

### Enums del Dominio
- `UserRole`: super_admin, director, admin, teacher, parent
- `ChildStatus`: active, inactive, graduated
- `AttendanceStatus`: present, absent, late, excused
- `PaymentStatus`: pending, paid, overdue, cancelled
- `DevelopmentCategory`: motor_fine, motor_gross, cognitive, language, social, emotional
- `MilestoneStatus`: achieved, in_progress, not_achieved
- Y más: Gender, InvoiceStatus, SubscriptionStatus, etc.

---

## 7. Sistema de Autenticación

### Flujo Completo

```
1. POST /api/v1/auth/login { email, password }
   │
   ├─→ Buscar usuario + userTenants activos
   ├─→ Verificar password con Argon2
   ├─→ Si MFA habilitado → retorna tempToken (5min)
   └─→ Generar tokens:
       ├── Access Token (JWT, 15min)
       │   Payload: { sub: userId, tid: tenantId, role }
       └── Refresh Token (JWT, 7d)
           Se almacena hash (Argon2) en DB

2. GET /api/v1/auth/me  [Authorization: Bearer <token>]
   └─→ Retorna { user, tenant }

3. POST /api/v1/auth/refresh { refreshToken }
   └─→ Renueva ambos tokens
```

### Características de Seguridad
- **Argon2** para hash de passwords y refresh tokens
- **JWT con expiración corta** (15min access, 7d refresh)
- **MFA con TOTP** (otplib)
- **Rate limiting** (100 req/min global)
- **RBAC** (Role-Based Access Control) con guards
- **Multi-tenancy** aislada por tenant ID en cada request
- **Cookie-based token storage** en frontend (SameSite=Strict)
- **Automatic token refresh** en API client

---

## 8. Buenas Prácticas Implementadas

### Código
- ✅ **TypeScript strict mode** en API y Web
- ✅ **Path aliases** (`@/*` → `./src/*`) en ambos proyectos
- ✅ **Shared types** — contratos tipados entre frontend y backend
- ✅ **Shared validators** — Zod schemas reutilizados
- ✅ **Prettier** configurado para formato consistente
- ✅ **ESLint** en API y Web

### Arquitectura
- ✅ **Separación de concerns** — API, Web, Mobile como apps independientes
- ✅ **Multi-tenancy por row** con CLS (Continuation Local Storage)
- ✅ **API versionada** (`/api/v1`)
- ✅ **Swagger/OpenAPI auto-generado** desde NestJS
- ✅ **Auto-generación de clientes** (TypeScript y Dart)
- ✅ **Custom hooks por feature** — encapsulan React Query
- ✅ **Componentes UI reutilizables** (24 componentes en `/ui`)
- ✅ **Domain-specific components** separados de UI genérica

### Infraestructura
- ✅ **Docker Compose** para desarrollo local reproducible
- ✅ **Script de inicio** (`start-dev.sh`) que orquesta todo
- ✅ **Variables de entorno** bien separadas (`.env.example`)
- ✅ **Turborepo** para build caching y task orchestration
- ✅ **pnpm workspaces** para dependency management eficiente

### Base de Datos
- ✅ **Prisma Migrations** para schema versioning
- ✅ **Seed completo** con datos realistas de demo
- ✅ **Índices estratégicos** (tenant + fecha, tenant + child, etc.)
- ✅ **Soft deletes** (`deletedAt`) en entidades principales
- ✅ **Audit logging** (append-only AuditLog)
- ✅ **UUID** como primary keys

---

## 9. Nivel de Escalabilidad y Mantenibilidad

### Escalabilidad: ⭐⭐⭐⭐ (4/5)

| Factor | Evaluación |
|---|---|
| **Multi-tenancy** | Excelente — tenant-per-row con CLS context |
| **Modularidad** | Excelente — cada feature es un módulo independiente |
| **API Design** | Buena — versionada, documentada, paginada |
| **Real-time** | Buena — WebSockets para chat |
| **Storage** | Buena — MinIO/S3 compatible (escalable a AWS) |
| **Caching** | Redis disponible (infraestructura lista) |

### Mantenibilidad: ⭐⭐⭐⭐⭐ (5/5)

| Factor | Evaluación |
|---|---|
| **Tipado** | Excelente — TypeScript strict + shared types |
| **Consistencia** | Excelente — patrones repetibles en cada módulo |
| **Documentación** | Buena — Swagger auto-generado, .env.example |
| **Testing** | Base — Jest configurado, Playwright para E2E |
| **Onboarding** | Excelente — un script levanta todo el entorno |

---

## 10. Estrategia Multirepo

### 10.1 Justificación del Cambio

El proyecto actual es un **monorepo** que contiene web, api y mobile. Para el enfoque **multirepo**, se propone la siguiente separación:

```
REPOSITORIO 1: littlebees-web
├── apps/web/         → Frontend Next.js
├── apps/api/         → Backend NestJS
├── packages/         → shared-types, shared-validators, api-contracts
├── infrastructure/   → Docker Compose
└── (configuración raíz: turbo, pnpm, prettier, etc.)

REPOSITORIO 2: littlebees-mobile
├── (proyecto Flutter independiente)
├── lib/
│   ├── app/          → App config, router, theme
│   ├── core/         → API client, interceptors, storage, DI
│   ├── features/     → Feature modules (auth, home, children, etc.)
│   ├── shared/       → Models, enums, validators (generados desde OpenAPI)
│   └── generated/    → Client auto-generado desde OpenAPI spec
├── pubspec.yaml
└── README.md
```

### 10.2 Puente de Comunicación: OpenAPI Contract

```
┌────────────────────┐         ┌────────────────────┐
│   littlebees-web   │         │  littlebees-mobile  │
│   (Next.js + API)  │         │     (Flutter)       │
│                    │         │                     │
│  API genera spec   │───────→ │  Consume spec       │
│  openapi.yaml      │  (Git)  │  Auto-genera client │
│                    │         │                     │
│  Swagger UI live   │         │  Dio + generated    │
│  /api/docs         │         │  API client         │
└────────────────────┘         └────────────────────┘
         │                              │
         └──────────┬───────────────────┘
                    │
              Misma API REST
              /api/v1/*
```

### 10.3 Cómo Compartir el Contrato API

**Opción recomendada: Repositorio de contratos o Git submodule**

1. El backend (en `littlebees-web`) genera el archivo `openapi.yaml` al hacer build.
2. Se publica el spec en un **repositorio compartido** o como **artefacto CI**.
3. El mobile (`littlebees-mobile`) consume el spec y genera el cliente Dart automáticamente con `openapi-generator-cli`.

**Alternativa simplificada:** Incluir un script en el mobile que descargue el spec directamente desde el Swagger del API desplegado.

### 10.4 Estructura Detallada del Repo Mobile

```
littlebees-mobile/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 # MaterialApp.router
│   │   ├── router/
│   │   │   └── app_router.dart      # GoRouter config
│   │   └── theme/
│   │       ├── app_theme.dart       # ThemeData
│   │       └── colors.dart          # KsColors (misma paleta que web)
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart      # Dio client
│   │   │   ├── api_interceptors.dart # Auth interceptor + refresh
│   │   │   └── endpoints.dart       # Endpoint constants
│   │   ├── storage/
│   │   │   └── secure_storage.dart  # Token storage
│   │   ├── database/
│   │   │   └── app_database.dart    # Drift (SQLite offline)
│   │   └── di/
│   │       └── providers.dart       # Riverpod providers globales
│   ├── shared/
│   │   ├── models/                  # DTOs (o generados desde OpenAPI)
│   │   ├── enums/                   # Mismos enums que shared-types
│   │   └── validators/              # Validaciones equivalentes
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_local_source.dart
│   │   │   ├── domain/
│   │   │   │   └── auth_state.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart
│   │   │       └── widgets/
│   │   ├── home/
│   │   │   └── presentation/screens/home_screen.dart
│   │   ├── children/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── attendance/
│   │   ├── daily_logs/
│   │   ├── development/
│   │   ├── chat/
│   │   ├── payments/
│   │   ├── notifications/
│   │   └── settings/
│   └── generated/                   # Auto-generado desde OpenAPI
│       └── kinderspace_api/
├── assets/
│   └── fonts/                       # Quicksand + Nunito
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 11. Lineamientos Técnicos Compartidos

### 11.1 Convenciones de Naming

| Contexto | Convención | Ejemplo |
|---|---|---|
| **Archivos (TS/Dart)** | kebab-case | `auth-service.ts`, `auth_service.dart` |
| **Componentes React** | PascalCase | `AttendanceTable` |
| **Widgets Flutter** | PascalCase | `AttendanceTable` |
| **Funciones/métodos** | camelCase | `getAttendanceByDate()` |
| **Variables** | camelCase | `isAuthenticated` |
| **Constantes** | UPPER_SNAKE_CASE | `API_BASE_URL` |
| **Enums** | PascalCase (nombre), UPPER_SNAKE (valores) | `UserRole.SUPER_ADMIN` |
| **DB columns** | snake_case (Prisma @map) | `tenant_id`, `created_at` |
| **API endpoints** | kebab-case, plural | `/api/v1/daily-logs` |
| **Paquetes/módulos** | kebab-case | `@kinderspace/shared-types` |

### 11.2 Convenciones de Arquitectura

**Backend (NestJS):**
- Un módulo por feature: `*.module.ts`, `*.controller.ts`, `*.service.ts`
- Guards para autenticación y autorización
- Decoradores custom para extraer contexto del request
- Interceptors para cross-cutting concerns

**Frontend Web (Next.js):**
- Route groups en App Router: `(auth)`, `(dashboard)`
- Un hook custom por feature: `use-{feature}.ts`
- Componentes en tres niveles: `ui/` → `layout/` → `domain/{feature}/`
- API client centralizado con auto-refresh

**Mobile (Flutter):**
- Feature-based con Clean Architecture simplificada: `data/` → `domain/` → `presentation/`
- Riverpod para state management (equivalente a React Query + Context)
- GoRouter para navegación (equivalente a Next.js App Router)
- Dio para HTTP (equivalente al ApiClientClass de web)

### 11.3 Paleta de Colores Compartida

```
Primary (Verde Menta):  #4ECDC4
Secondary (Coral):      #FF6B6B
Accent (Amarillo):      #FFE66D
Success:                #00B894
Warning:                #FDCB6E
Destructive/Error:      #E17055
Background:             #F7F9FC
Foreground:             #2D3436
Muted:                  #636E72
Card:                   #FFFFFF
Border:                 #DFE6E9
```

### 11.4 Tipografías Compartidas

- **Headings:** Quicksand (400, 500, 600, 700)
- **Body:** Nunito (400, 500, 600, 700)

### 11.5 Reglas de Validación Compartidas

Las validaciones Zod de `shared-validators` deben replicarse en Dart para la app móvil:

| Schema | Reglas |
|---|---|
| **loginSchema** | email: valid email; password: min 8 chars |
| **registerSchema** | +uppercase, +lowercase, +number, +special char |
| **mfaVerifySchema** | code: exactamente 6 dígitos |
| **childSchema** | firstName/lastName: 2-100 chars |

### 11.6 Manejo de Entornos

**Variables de entorno mínimas para cada app:**

| Variable | Web | Mobile |
|---|---|---|
| `API_URL` | `NEXT_PUBLIC_API_URL` | En config/flavors |
| `WS_URL` | `NEXT_PUBLIC_WS_URL` | En config/flavors |
| Entornos | `.env.local` / `.env.production` | Dart define + flavors |

---

## 12. Mejoras Estructurales Propuestas

### 12.1 Para el Backend (API)

1. **Agregar DTOs formales** con class-validator en cada controller (actualmente algunos usan tipos inline).
2. **Implementar unit tests** por servicio — Jest está configurado pero sin tests.
3. **Agregar health check más completo** (DB, Redis, MinIO).
4. **Implementar logging estructurado** (Winston o Pino).
5. **Agregar rate limiting granular** por endpoint (actualmente es global).

### 12.2 Para el Frontend Web

1. **Implementar middleware de Next.js** para protección de rutas server-side.
2. **Agregar loading states** más consistentes (Skeleton components).
3. **Implementar error boundaries** por feature.
4. **Agregar tests unitarios** para hooks y componentes.
5. **Considerar Zustand** como alternativa a Context para auth state (mejor DevTools).

### 12.3 Para el Mobile (Nuevo Repo)

1. **Implementar offline-first completo** con Drift — la infraestructura ya existe en pubspec.
2. **Configurar flavors** (development, staging, production).
3. **Implementar deep linking**.
4. **Agregar push notifications handler** completo.
5. **Implementar biometric auth** para login rápido.
6. **Configurar CI/CD** (Fastlane + GitHub Actions).

### 12.4 Para la Estrategia Multirepo

1. **CI Pipeline compartido:** GitHub Actions template para lint, test, build.
2. **Contract testing:** Validar que el mobile siempre consuma un spec compatible.
3. **Versioning del API:** Semantic versioning del spec OpenAPI.
4. **Shared design tokens:** Exportar la paleta y tipografía como JSON consumible por ambos repos.
5. **Documentation site:** Considerar un tercer repo o carpeta `docs/` para documentación compartida.

---

## 13. Confirmación: Sin Supabase

**✅ CONFIRMADO: Ninguno de los dos proyectos (web ni móvil) utiliza ni deberá utilizar Supabase.**

El stack actual del proyecto web es completamente independiente:

| Necesidad | Solución Actual (sin Supabase) |
|---|---|
| **Base de datos** | PostgreSQL 16 (self-hosted vía Docker) |
| **ORM** | Prisma |
| **Autenticación** | Custom JWT + Passport.js + Argon2 |
| **Autorización** | RBAC custom con guards NestJS |
| **Storage** | MinIO (S3-compatible, self-hosted) |
| **Real-time** | Socket.IO (WebSockets nativos) |
| **Push Notifications** | Firebase Cloud Messaging |
| **Email** | Resend |
| **SMS** | Twilio |
| **Payments** | Conekta |
| **Invoicing** | Facturapi |

Esta arquitectura es **más robusta, flexible y profesional** que Supabase porque:
- Control total sobre la lógica de negocio
- Multi-tenancy real con aislamiento por tenant
- Sin vendor lock-in
- Escalabilidad horizontal independiente por componente
- Seguridad enterprise-grade (Argon2, JWT con refresh, MFA)

---

## Resumen Ejecutivo Final

| Aspecto | Decisión |
|---|---|
| **Enfoque** | Multirepo (web+api en uno, mobile en otro) |
| **Backend** | NestJS + Prisma + PostgreSQL (sin Supabase) |
| **Frontend Web** | Next.js 15 + React 19 + TailwindCSS + Radix UI |
| **Mobile** | Flutter + Riverpod + GoRouter + Dio + Drift |
| **Puente API** | OpenAPI spec auto-generado → client Dart auto-generado |
| **Auth** | JWT + Argon2 + MFA (TOTP) — custom, sin Supabase Auth |
| **Validación** | Zod (web/api) → replicar en Dart (mobile) |
| **Design System** | Paleta y tipografía compartida entre web y mobile |
| **Infraestructura** | Docker (PostgreSQL + Redis + MinIO) |
| **CI/CD** | GitHub Actions (por definir en cada repo) |
