# 🐝 LittleBees - Guía de Configuración

## 📋 Variables de Entorno Requeridas

### Backend (apps/api)

Crea un archivo `.env` en `apps/api/` con las siguientes variables:

```env
# Base de datos PostgreSQL
DATABASE_URL="postgresql://usuario:contraseña@localhost:5432/littlebees"

# JWT Authentication
JWT_SECRET="tu-secreto-jwt-muy-seguro-aqui"
JWT_EXPIRES_IN="7d"

# Groq API para Asistente IA (Llama 3.3)
GROQ_API_KEY="gsk_tu_api_key_de_groq_aqui"

# Puerto del servidor
PORT=3001

# CORS (Frontend URL)
FRONTEND_URL="http://localhost:3000"

# Uploads (opcional)
UPLOAD_DIR="./uploads"
MAX_FILE_SIZE=5242880
```

### Frontend (apps/web)

Crea un archivo `.env.local` en `apps/web/` con las siguientes variables:

```env
# API Backend URL
NEXT_PUBLIC_API_URL="http://localhost:3001"

# Otras configuraciones (opcional)
NEXT_PUBLIC_APP_NAME="LittleBees"
```

---

## 🤖 Configuración del Asistente IA (Groq)

### 1. Obtener API Key de Groq

1. Visita [https://console.groq.com](https://console.groq.com)
2. Crea una cuenta o inicia sesión
3. Ve a "API Keys" en el menú
4. Crea una nueva API Key
5. Copia la key (comienza con `gsk_`)

### 2. Configurar en el Backend

Agrega la key al archivo `.env` del backend:

```env
GROQ_API_KEY="gsk_tu_api_key_aqui"
```

### 3. Verificar Funcionamiento

El asistente IA está disponible en:
- **Ruta Web:** `/ai-assistant`
- **API Endpoint:** `POST /ai/sessions/:id/chat`

**Modelo utilizado:** Llama 3.3-70b-versatile

**Contexto personalizado por rol:**
- **Maestras:** Planificación de actividades, desarrollo infantil, comunicación con padres
- **Directoras:** Gestión administrativa, supervisión, reportes, toma de decisiones
- **Administradores:** Configuración del sistema, gestión de usuarios, soporte técnico
- **Padres:** Desarrollo del hijo/a, actividades en casa, consejos de crianza

---

## 🗄️ Configuración de Base de Datos

### Instalación de PostgreSQL

**macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Crear Base de Datos

```bash
# Conectar a PostgreSQL
psql postgres

# Crear base de datos
CREATE DATABASE littlebees;

# Crear usuario (opcional)
CREATE USER littlebees_user WITH PASSWORD 'tu_contraseña';
GRANT ALL PRIVILEGES ON DATABASE littlebees TO littlebees_user;
```

### Ejecutar Migraciones

```bash
cd apps/api
npx prisma migrate dev
npx prisma generate
```

### Poblar con Datos de Prueba

```bash
cd apps/api
npm run seed
```

---

## 🚀 Instalación y Ejecución

### 1. Instalar Dependencias

```bash
# Desde la raíz del proyecto
npm install
```

### 2. Configurar Variables de Entorno

Crea los archivos `.env` según las instrucciones anteriores.

### 3. Ejecutar Migraciones

```bash
cd apps/api
npx prisma migrate dev
npx prisma generate
npm run seed
```

### 4. Iniciar el Proyecto

**Opción 1: Desarrollo (ambos servicios)**
```bash
# Desde la raíz
npm run dev
```

**Opción 2: Servicios separados**
```bash
# Terminal 1 - Backend
cd apps/api
npm run dev

# Terminal 2 - Frontend
cd apps/web
npm run dev
```

### 5. Acceder a la Aplicación

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:3001
- **API Docs (Swagger):** http://localhost:3001/api

---

## 👥 Usuarios de Prueba (después del seed)

```
Super Admin:
- Email: admin@littlebees.com
- Password: Admin123!

Directora:
- Email: directora@littlebees.com
- Password: Director123!

Maestra:
- Email: maestra@littlebees.com
- Password: Teacher123!

Padre:
- Email: padre@littlebees.com
- Password: Parent123!
```

---

## 🔧 Comandos Útiles

### Backend

```bash
# Generar cliente Prisma
npx prisma generate

# Crear migración
npx prisma migrate dev --name nombre_migracion

# Abrir Prisma Studio
npx prisma studio

# Ejecutar seed
npm run seed

# Linting
npm run lint

# Tests
npm run test
```

### Frontend

```bash
# Desarrollo
npm run dev

# Build producción
npm run build

# Iniciar producción
npm run start

# Linting
npm run lint
```

---

## 📦 Estructura del Proyecto

```
littlebees-web/
├── apps/
│   ├── api/                 # Backend NestJS
│   │   ├── src/
│   │   │   ├── modules/     # Módulos de la aplicación
│   │   │   │   ├── ai/      # Asistente IA (Groq)
│   │   │   │   ├── chat/    # Sistema de mensajería
│   │   │   │   ├── daily-logs/  # Registro de actividades
│   │   │   │   ├── excuses/     # Justificantes
│   │   │   │   ├── reports/     # Reportes
│   │   │   │   └── ...
│   │   │   └── ...
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   └── seed.ts
│   │   └── .env             # Variables de entorno
│   │
│   └── web/                 # Frontend Next.js
│       ├── src/
│       │   ├── app/         # Páginas (App Router)
│       │   ├── components/  # Componentes React
│       │   ├── hooks/       # Custom hooks
│       │   └── lib/         # Utilidades
│       └── .env.local       # Variables de entorno
│
└── packages/
    └── shared-types/        # Tipos compartidos
```

---

## 🎨 Funcionalidades Implementadas

### ✅ Completadas (70%)

1. **Registro de Actividades del Día** - Registro rápido con fotos
2. **Sistema de Justificantes** - Padres pueden enviar excusas
3. **Mensajería Mejorada** - Escalación y detección de horario
4. **Asistente IA** - Chat con Llama 3.3 (contexto por rol)
5. **Personalización** - Temas y colores personalizables
6. **Programación del Día** - Timeline visual de actividades
7. **Reportes** - Asistencia, actividades, desarrollo, pagos

### ⏳ En Desarrollo (30%)

8. **Roles y Menús** - Navegación diferenciada (en progreso)
9. **Perfiles Completos** - Información detallada de niños
10. **Optimización UX** - Push notifications, onboarding

---

## 🐛 Troubleshooting

### Error: "GROQ_API_KEY not found"

**Solución:** Verifica que el archivo `.env` en `apps/api/` contenga:
```env
GROQ_API_KEY="gsk_tu_api_key_aqui"
```

### Error: "Database connection failed"

**Solución:** 
1. Verifica que PostgreSQL esté corriendo
2. Verifica la URL de conexión en `DATABASE_URL`
3. Asegúrate de que la base de datos exista

### Error: "Port 3000 already in use"

**Solución:**
```bash
# Encuentra el proceso
lsof -ti:3000

# Mata el proceso
kill -9 $(lsof -ti:3000)
```

---

## 📞 Soporte

Para más información, consulta:
- **Guía del Sistema:** `infrastructure/docker/littlebees-system-guide.md`
- **Plan Técnico:** `PLAN_TECNICO_IMPLEMENTACION.md`

---

**Última actualización:** Marzo 2026
**Versión:** 1.0.0
