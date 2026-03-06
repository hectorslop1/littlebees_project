# Prueba de Login - Little Bees Mobile

## Cambios Realizados

### 1. **Login Screen** (`lib/features/auth/presentation/login_screen.dart`)
- ✅ Agregado manejo correcto del estado `_isLoading` después del login exitoso
- ✅ El estado se resetea correctamente tanto en éxito como en error

### 2. **App Router** (`lib/routing/app_router.dart`)
- ✅ Agregado `_AuthStateNotifier` para hacer el router reactivo a cambios de estado de autenticación
- ✅ El router ahora escucha cambios en `authProvider` y actualiza automáticamente
- ✅ La redirección a `/home` ocurre automáticamente cuando `isAuthenticated` cambia a `true`

## Configuración Verificada

### Backend API
- ✅ Web app usa: `http://localhost:3002/api/v1`
- ✅ Mobile app usa: `http://localhost:3002/api/v1` (default)
- ✅ Ambas apps usan el **mismo backend NestJS**

### Endpoints de Autenticación
- Login: `POST /api/v1/auth/login`
- Me: `GET /api/v1/auth/me`
- Refresh: `POST /api/v1/auth/refresh`

## Pasos para Probar

### 1. Asegúrate que el backend esté corriendo
```bash
cd littlebees-web
docker compose up -d
pnpm run dev
```

### 2. Ejecuta la app móvil

**Para emulador iOS/Android:**
```bash
cd littlebees-mobile
flutter run
```

**Para dispositivo físico (reemplaza con tu IP):**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3002/api/v1
```

**Para emulador Android (usa IP especial):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002/api/v1
```

### 3. Prueba el login

Usa cualquiera de estas credenciales:

| Rol | Email | Password |
|---|---|---|
| Director | director@petitsoleil.mx | Password123! |
| Admin | admin@petitsoleil.mx | Password123! |
| Maestra | maestra@petitsoleil.mx | Password123! |
| Padre | padre@gmail.com | Password123! |
| Madre | madre@gmail.com | Password123! |

### 4. Comportamiento Esperado

1. **Splash Screen** → Se muestra brevemente mientras se verifica la sesión
2. **Login Screen** → Si no hay sesión activa
3. **Ingresar credenciales** → Email y contraseña
4. **Click "Sign In"** → Botón muestra "Signing in..."
5. **Login exitoso** → **Redirección automática a Home Screen** ✅
6. **Login fallido** → Mensaje de error en SnackBar

## Flujo de Autenticación

```
┌─────────────┐
│   Splash    │
└──────┬──────┘
       │
       ├─ isLoading? → Stay on Splash
       │
       ├─ isAuthenticated? → /home
       │
       └─ else → /auth/login
              │
              ├─ Login Success
              │  ├─ Store tokens
              │  ├─ Update authProvider state
              │  └─ Router auto-redirect to /home ✅
              │
              └─ Login Error
                 └─ Show error message
```

## Debugging

Si el login sigue redirigiendo al login:

1. **Verifica que el backend esté corriendo:**
   ```bash
   curl http://localhost:3002/api/v1/health
   ```

2. **Revisa los logs de la app móvil** (busca `[API]` en la consola)

3. **Verifica la respuesta del login:**
   - Debe incluir: `accessToken`, `refreshToken`, `user`, `tenant`

4. **Verifica que los tokens se guarden:**
   - Los tokens se guardan en `flutter_secure_storage`
   - El `AuthInterceptor` debe agregar el header `Authorization: Bearer <token>`

5. **Verifica el estado de autenticación:**
   - `authProvider.isAuthenticated` debe ser `true` después del login
   - El router debe detectar este cambio y redirigir a `/home`
