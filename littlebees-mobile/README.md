# Little Bees — App Móvil

App móvil Flutter para padres de familia del sistema de guarderías Little Bees (KinderSpace MX).

> **Sin Supabase** — Se conecta directamente a la API REST de NestJS del repositorio web.

## Stack Tecnológico

| Categoría | Tecnología |
|---|---|
| **Framework** | Flutter (SDK ≥3.11.0) |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **HTTP Client** | Dio + AuthInterceptor (JWT auto-refresh) |
| **WebSockets** | socket.io-client |
| **Secure Storage** | flutter_secure_storage |
| **Models** | Freezed + json_serializable |
| **UI** | Lucide Icons, Google Fonts, flutter_animate |
| **Charts** | fl_chart |

## Requisitos Previos

- Flutter SDK ≥ 3.11.0
- Backend NestJS corriendo (repo `littlebees-web`)
  - `docker compose up -d` (PostgreSQL, Redis, MinIO)
  - `pnpm run dev` (API en http://localhost:3002)

## Setup

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código (Freezed models)
dart run build_runner build --delete-conflicting-outputs

# 3. Configurar la URL del API (opcional, default: localhost:3002)
#    Para dispositivo físico, usar la IP de tu máquina:
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3002/api/v1

# 4. Ejecutar
flutter run
```

## Credenciales de Demo

| Rol | Email | Password |
|---|---|---|
| Director | director@petitsoleil.mx | Password123! |
| Admin | admin@petitsoleil.mx | Password123! |
| Maestra | maestra@petitsoleil.mx | Password123! |
| Padre | padre@gmail.com | Password123! |
| Madre | madre@gmail.com | Password123! |

## Arquitectura

```
lib/
├── main.dart                    # Entry point (ProviderScope)
├── app.dart                     # MaterialApp.router
├── routing/                     # GoRouter + route names
├── core/
│   ├── api/                     # ApiClient (Dio), AuthInterceptor, Endpoints, SocketClient
│   ├── config/                  # AppConfig (API URLs, timeouts)
│   ├── storage/                 # SecureTokenStorage (JWT tokens)
│   ├── i18n/                    # Translations (EN/ES)
│   ├── mocks/                   # Mock data for development
│   └── utils/                   # Haptic, transitions, performance
├── shared/
│   ├── enums/                   # Enums alineados con @kinderspace/shared-types
│   ├── models/                  # DTOs: auth, common (PaginatedResponse), child
│   ├── providers/               # Theme provider
│   └── widgets/                 # MainShell (bottom nav)
├── design_system/
│   ├── theme/                   # Colors, typography, radii, shadows, spacing
│   ├── tokens/                  # Animation tokens
│   └── widgets/                 # LBButton, LBInput, LBCard, LBAvatar, etc.
└── features/
    ├── auth/                    # Login (JWT auth via NestJS API)
    │   ├── data/                # AuthRepository
    │   ├── application/         # AuthProvider (Riverpod StateNotifier)
    │   └── presentation/        # LoginScreen
    ├── home/                    # Dashboard, daily story, timeline
    ├── activity/                # Photo gallery
    ├── messaging/               # Chat (socket.io)
    ├── calendar/                # Calendar view
    ├── payments/                # Payments
    ├── profile/                 # Profile & settings
    └── splash/                  # Splash screen
```

## Flujo de Autenticación

```
1. Login → POST /api/v1/auth/login { email, password }
2. Tokens almacenados en flutter_secure_storage
3. AuthInterceptor inyecta Bearer token en cada request
4. Si 401 → auto-refresh via POST /api/v1/auth/refresh
5. Si refresh falla → clearTokens → redirige a /auth/login
```

## Relación con el Repo Web

Este repo es la **app móvil** del enfoque multirepo:

- **littlebees-web** → API NestJS + Frontend Next.js + shared packages
- **littlebees-mobile** (este repo) → App Flutter consumiendo la misma API REST

Los enums y modelos en `lib/shared/` están alineados con `@kinderspace/shared-types` del repo web.
