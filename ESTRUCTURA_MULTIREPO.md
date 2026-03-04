# 🏗️ Estructura Multirepo — Little Bees

**Fecha:** 3 de marzo de 2026  
**Estado:** ✅ Configurado y listo para desarrollo

---

## 📁 Estructura de Directorios

```
/Users/hectorlopez/Desktop/Proyectos/project/
│
├── ESTRUCTURA_MULTIREPO.md              ← Este documento
│
├── 📦 littlebees-web/                    ← Backend + Frontend Web
│   ├── apps/
│   │   ├── api/                          # NestJS 10 + Prisma 6
│   │   │   ├── src/
│   │   │   │   ├── main.ts               # Bootstrap (puerto 3002)
│   │   │   │   ├── app.module.ts         # Root module
│   │   │   │   ├── modules/              # 16 feature modules
│   │   │   │   │   ├── auth/
│   │   │   │   │   ├── users/
│   │   │   │   │   ├── children/
│   │   │   │   │   ├── attendance/
│   │   │   │   │   ├── daily-logs/
│   │   │   │   │   ├── development/
│   │   │   │   │   ├── chat/
│   │   │   │   │   ├── payments/
│   │   │   │   │   └── ...
│   │   │   │   └── common/               # Guards, interceptors, decorators
│   │   │   ├── prisma/
│   │   │   │   ├── schema.prisma         # 20+ models
│   │   │   │   └── seed.ts
│   │   │   └── package.json
│   │   │
│   │   └── web/                          # Next.js 15 + React 19
│   │       ├── src/
│   │       │   ├── app/                  # App Router
│   │       │   │   ├── (auth)/
│   │       │   │   └── (dashboard)/
│   │       │   ├── components/
│   │       │   ├── lib/
│   │       │   │   ├── api-client.ts     # Dio equivalent
│   │       │   │   └── auth.ts
│   │       │   └── contexts/
│   │       └── package.json
│   │
│   ├── packages/
│   │   ├── shared-types/                 # TypeScript interfaces/enums
│   │   │   └── src/
│   │   │       ├── auth.ts
│   │   │       ├── children.ts
│   │   │       ├── enums.ts
│   │   │       └── common.ts
│   │   │
│   │   ├── shared-validators/            # Zod schemas
│   │   │   └── src/
│   │   │       ├── auth.schemas.ts
│   │   │       └── children.schemas.ts
│   │   │
│   │   └── api-contracts/                # OpenAPI client generation
│   │       ├── orval.config.ts           # TS client gen
│   │       └── openapi-generator.yaml    # Dart client gen
│   │
│   ├── infrastructure/
│   │   └── docker/
│   │       ├── docker-compose.yml        # PostgreSQL, Redis, MinIO
│   │       └── init.sql
│   │
│   ├── turbo.json                        # Turborepo config
│   ├── pnpm-workspace.yaml
│   ├── package.json
│   └── start-dev.sh                      # Script de inicio
│
│
└── 📱 littlebees-mobile/                 ← App Flutter
    ├── lib/
    │   ├── main.dart                     # Entry point
    │   ├── app.dart                      # MaterialApp.router
    │   │
    │   ├── core/
    │   │   ├── api/
    │   │   │   ├── api_client.dart       # Dio + interceptors
    │   │   │   ├── auth_interceptor.dart # JWT auto-refresh
    │   │   │   ├── endpoints.dart        # API routes
    │   │   │   └── socket_client.dart    # Socket.IO
    │   │   ├── config/
    │   │   │   └── app_config.dart       # API URLs
    │   │   ├── storage/
    │   │   │   └── secure_token_storage.dart
    │   │   ├── i18n/                     # EN/ES translations
    │   │   ├── mocks/                    # Mock data
    │   │   └── utils/
    │   │
    │   ├── shared/
    │   │   ├── enums/
    │   │   │   ├── user_role.dart        # ← Alineado con shared-types
    │   │   │   └── enums.dart            # ChildStatus, AttendanceStatus, etc.
    │   │   ├── models/
    │   │   │   ├── auth_models.dart      # ← Alineado con shared-types
    │   │   │   ├── common_models.dart    # PaginatedResponse, etc.
    │   │   │   └── child_model.dart
    │   │   ├── providers/
    │   │   └── widgets/
    │   │
    │   ├── design_system/
    │   │   ├── theme/                    # Colors, typography, radii
    │   │   ├── tokens/
    │   │   └── widgets/                  # LBButton, LBInput, LBCard, etc.
    │   │
    │   ├── features/
    │   │   ├── auth/
    │   │   │   ├── data/
    │   │   │   │   └── auth_repository.dart
    │   │   │   ├── application/
    │   │   │   │   └── auth_provider.dart  # Riverpod StateNotifier
    │   │   │   └── presentation/
    │   │   │       └── login_screen.dart
    │   │   ├── home/
    │   │   ├── activity/
    │   │   ├── messaging/
    │   │   ├── calendar/
    │   │   ├── payments/
    │   │   ├── profile/
    │   │   └── splash/
    │   │
    │   └── routing/
    │       ├── app_router.dart           # GoRouter + auth redirect
    │       └── route_names.dart
    │
    ├── android/
    ├── ios/
    ├── assets/
    ├── test/
    │
    ├── pubspec.yaml                      # Sin supabase_flutter ✅
    ├── analysis_options.yaml
    ├── .gitignore                        # Optimizado para Flutter
    │
    └── 📄 Documentación
        ├── README.md                     # Setup e instrucciones
        ├── ANALISIS_TECNICO_MULTIREPO.md # Análisis completo del web
        ├── MIGRACION_SUPABASE_A_NESTJS.md
        └── SETUP_MULTIREPO.md            # Esta guía
```

---

## 🔗 Flujo de Comunicación

```
┌─────────────────────────────────────────────────────────────┐
│                    littlebees-mobile                        │
│                    (Flutter App)                            │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐   ┌──────────────┐  │
│  │ AuthProvider │    │  ApiClient   │   │ SocketClient │  │
│  │  (Riverpod)  │───▶│    (Dio)     │   │ (Socket.IO)  │  │
│  └──────────────┘    └──────┬───────┘   └──────┬───────┘  │
│                             │                   │           │
└─────────────────────────────┼───────────────────┼───────────┘
                              │                   │
                         HTTP │                   │ WebSocket
                         REST │                   │
                              ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     littlebees-web                          │
│                  (NestJS Backend API)                       │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  /api/v1/*                                           │  │
│  │  ├─ /auth/login     (POST)                           │  │
│  │  ├─ /auth/refresh   (POST)                           │  │
│  │  ├─ /auth/me        (GET)                            │  │
│  │  ├─ /children       (GET, POST)                      │  │
│  │  ├─ /attendance     (GET, POST)                      │  │
│  │  ├─ /daily-logs     (GET, POST)                      │  │
│  │  └─ ...                                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│                              ▼                              │
│                    ┌──────────────────┐                     │
│                    │  Prisma ORM      │                     │
│                    └────────┬─────────┘                     │
└─────────────────────────────┼───────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  PostgreSQL 16   │
                    │  (Docker)        │
                    └──────────────────┘
```

---

## 🚀 Quick Start

### Terminal 1: Backend

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-web
docker compose up -d
pnpm install
cd apps/api && pnpm prisma migrate dev && pnpm prisma db seed
cd ../.. && pnpm run dev
```

### Terminal 2: Mobile

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Login

- Email: `padre@gmail.com`
- Password: `Password123!`

---

## ✅ Checklist de Configuración Completada

- [x] Proyecto organizado en carpeta `project/`
- [x] Backend web (`littlebees-web/`) clonado y configurado
- [x] App móvil (`littlebees-mobile/`) migrada de Supabase a NestJS
- [x] Eliminada dependencia `supabase_flutter`
- [x] Creada infraestructura core (ApiClient, AuthInterceptor, SecureTokenStorage)
- [x] Creados enums y models alineados con `@kinderspace/shared-types`
- [x] Implementado auth completo con JWT
- [x] Migradas features (auth, home, profile, splash)
- [x] Eliminados archivos Supabase obsoletos
- [x] Actualizado `.gitignore` optimizado
- [x] Eliminados documentos viejos innecesarios
- [x] Creada documentación completa (README, SETUP_MULTIREPO, MIGRACION)
- [x] Inicializado git con commit limpio
- [x] `flutter analyze` — 0 errores

---

## 📊 Estadísticas

| Métrica | Valor |
|---|---|
| **Repos** | 2 (web + mobile) |
| **Backend modules** | 16 |
| **Prisma models** | 20+ |
| **Flutter features** | 8 |
| **Shared enums** | 15+ |
| **API endpoints** | 50+ |
| **Líneas de código mobile** | ~5,000 |
| **Dependencias mobile** | 30+ packages |

---

## 🎯 Próximos Pasos

1. Implementar features faltantes en mobile
2. Configurar CI/CD (GitHub Actions + Fastlane)
3. Agregar tests (unit + integration + E2E)
4. Implementar cache offline con Drift
5. Optimizar performance y UX

---

**¡Proyecto multirepo configurado y listo para desarrollo! 🎉**
