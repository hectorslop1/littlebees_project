# Setup Multirepo — Little Bees

Guía completa para trabajar con la arquitectura multirepo de Little Bees.

---

## Estructura de Repositorios

```
📁 /Users/hectorlopez/Desktop/Proyectos/project/
│
├── ESTRUCTURA_MULTIREPO.md    # Diagrama visual completo
│
├── 📁 littlebees-web/          ← Backend + Frontend Web
│   ├── apps/
│   │   ├── api/                # NestJS backend (puerto 3002)
│   │   └── web/                # Next.js frontend (puerto 3001)
│   ├── packages/
│   │   ├── shared-types/       # TypeScript interfaces/enums
│   │   ├── shared-validators/  # Zod schemas
│   │   └── api-contracts/      # OpenAPI client generation
│   ├── infrastructure/
│   │   └── docker/             # PostgreSQL, Redis, MinIO
│   ├── turbo.json
│   ├── pnpm-workspace.yaml
│   └── package.json
│
└── 📁 littlebees-mobile/       ← App Flutter (este proyecto)
    ├── lib/
    │   ├── core/               # API client, config, storage
    │   ├── shared/             # Enums y models alineados con web
    │   ├── features/           # Auth, home, profile, etc.
    │   └── design_system/      # Theme, widgets
    ├── android/
    ├── ios/
    ├── pubspec.yaml
    └── README.md
```

---

## Flujo de Trabajo Completo

### 1. Levantar el Backend (littlebees-web)

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-web

# Instalar dependencias (primera vez)
pnpm install

# Levantar infraestructura (PostgreSQL, Redis, MinIO)
docker compose up -d

# Ejecutar migraciones de Prisma (primera vez)
cd apps/api
pnpm prisma migrate dev
pnpm prisma db seed  # Datos de prueba

# Volver a la raíz y levantar backend + frontend
cd ../..
pnpm run dev
```

**Servicios corriendo:**
- Backend API: http://localhost:3002
- Frontend Web: http://localhost:3001
- PostgreSQL: localhost:5437
- Redis: localhost:6383
- MinIO: http://localhost:9000

### 2. Ejecutar la App Móvil (littlebees-mobile)

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-mobile

# Instalar dependencias (primera vez)
flutter pub get

# Generar código Freezed (primera vez o cuando cambien models)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en emulador/simulador
flutter run

# O en dispositivo físico (reemplaza con tu IP local)
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3002/api/v1
```

---

## Credenciales de Prueba

| Rol | Email | Password |
|---|---|---|
| **Padre** | padre@gmail.com | Password123! |
| **Madre** | madre@gmail.com | Password123! |
| **Maestra** | maestra@petitsoleil.mx | Password123! |
| **Admin** | admin@petitsoleil.mx | Password123! |
| **Director** | director@petitsoleil.mx | Password123! |

---

## Sincronización de Modelos

Los enums y modelos de `littlebees-mobile/lib/shared/` están **manualmente alineados** con `littlebees-web/packages/shared-types/`.

### Cuando cambien los tipos en el backend:

1. **Actualizar `shared-types` en el repo web:**
   ```bash
   cd littlebees-web/packages/shared-types
   # Editar src/enums.ts, src/auth.ts, etc.
   pnpm run build
   ```

2. **Replicar cambios en el repo móvil:**
   ```bash
   cd littlebees-mobile/lib/shared
   # Actualizar manualmente enums/enums.dart, models/auth_models.dart
   ```

3. **Regenerar código Freezed:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Alternativa Futura (Recomendada):
Usar `openapi-generator-cli` para auto-generar modelos Dart desde el OpenAPI spec del backend:

```bash
# En littlebees-web/packages/api-contracts
pnpm run generate:dart  # (configurar script)
# Copiar output a littlebees-mobile/lib/generated/
```

---

## Comandos Útiles

### Backend (littlebees-web)

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-web

# Reiniciar base de datos
docker compose down -v
docker compose up -d
cd apps/api && pnpm prisma migrate reset

# Ver logs del backend
pnpm run dev --filter=api

# Generar Prisma Client después de cambios en schema
cd apps/api && pnpm prisma generate

# Ver Swagger docs
# http://localhost:3002/api/docs
```

### Mobile (littlebees-mobile)

```bash
cd /Users/hectorlopez/Desktop/Proyectos/project/littlebees-mobile

# Limpiar build
flutter clean && flutter pub get

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Build para producción
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## Troubleshooting

### Error: "Connection refused" en la app móvil

**Causa:** La app no puede conectarse al backend.

**Solución:**
1. Verifica que el backend esté corriendo: `curl http://localhost:3002/api/v1/health`
2. Si usas dispositivo físico, usa tu IP local:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3002/api/v1
   ```
3. En Android, usa `10.0.2.2` para emulador:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002/api/v1
   ```

### Error: "JWT token expired"

**Causa:** El token de acceso expiró y el refresh falló.

**Solución:**
- Cierra sesión y vuelve a iniciar sesión
- El `AuthInterceptor` debería manejar esto automáticamente

### Error: Prisma migrations fail

**Causa:** Cambios en el schema incompatibles.

**Solución:**
```bash
cd littlebees-web/apps/api
pnpm prisma migrate reset  # ⚠️ Borra todos los datos
pnpm prisma db seed
```

---

## Próximos Pasos

1. **Implementar features faltantes en mobile:**
   - Activity (galería de fotos)
   - Messaging (chat con Socket.IO)
   - Payments (integración con Stripe/Conekta)
   - Calendar (vista de eventos)

2. **Configurar CI/CD:**
   - GitHub Actions para builds automáticos
   - Fastlane para deploy a stores

3. **Tests:**
   - Unit tests en features críticos
   - Integration tests con mock API
   - E2E tests con Patrol o Maestro

4. **Optimizaciones:**
   - Implementar Drift para cache offline
   - Optimistic updates en mutations
   - Background sync con WorkManager

---

## Documentación Adicional

- **Análisis técnico completo:** `ANALISIS_TECNICO_MULTIREPO.md`
- **Migración de Supabase:** `MIGRACION_SUPABASE_A_NESTJS.md`
- **README del proyecto:** `README.md`
