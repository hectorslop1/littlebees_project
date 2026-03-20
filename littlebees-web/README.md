# 🐝 LittleBees - Sistema de Gestión para Guarderías

Sistema integral de gestión para guarderías y jardines de niños, desarrollado con tecnologías modernas y enfoque en la experiencia del usuario.

![Estado del Proyecto](https://img.shields.io/badge/Estado-70%25%20Completado-green)
![Versión](https://img.shields.io/badge/Versión-1.0.0-blue)
![Licencia](https://img.shields.io/badge/Licencia-Propietaria-red)

---

## 🎯 Características Principales

### ✅ Implementadas (70%)

- **🤖 Asistente IA con Llama 3.3** - Chat inteligente con contexto personalizado por rol
- **📊 Sistema de Reportes** - 4 tipos de reportes (asistencia, actividades, desarrollo, pagos)
- **📅 Programación del Día** - Timeline visual con estado de actividades
- **✉️ Mensajería Avanzada** - Chat con escalación y detección de horario laboral
- **📝 Registro Rápido** - Captura de actividades diarias con fotos
- **📄 Sistema de Justificantes** - Gestión de excusas y ausencias
- **🎨 Personalización** - Temas y colores personalizables por institución

### ⏳ En Desarrollo (30%)

- **🔔 Push Notifications** - Notificaciones en tiempo real
- **👋 Onboarding** - Guía para nuevos usuarios
- **⚡ Optimizaciones** - Mejoras de rendimiento

---

## 🏗️ Arquitectura

### Stack Tecnológico

**Backend:**
- NestJS (Node.js framework)
- PostgreSQL (Base de datos)
- Prisma ORM
- Groq SDK (IA con Llama 3.3)
- JWT Authentication
- WebSockets (Socket.io)

**Frontend:**
- Next.js 14 (App Router)
- React 18
- TypeScript
- TailwindCSS
- shadcn/ui
- React Query (TanStack Query)
- Zustand (State management)

**Mobile:**
- Flutter
- Dart

---

## 📦 Módulos Implementados

### Backend (NestJS)

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| **ai** | Asistente IA con Groq/Llama 3.3 | ✅ Completo |
| **attendance** | Control de asistencia | ✅ Completo |
| **chat** | Sistema de mensajería | ✅ Completo |
| **children** | Gestión de alumnos | ✅ Completo |
| **daily-logs** | Registro de actividades | ✅ Completo |
| **day-schedule** | Programación del día | ✅ Completo |
| **excuses** | Sistema de justificantes | ✅ Completo |
| **groups** | Gestión de grupos | ✅ Completo |
| **menu** | Menús por rol | ✅ Completo |
| **reports** | Reportes y estadísticas | ✅ Completo |
| **users** | Gestión de usuarios | ✅ Completo |

### Frontend (Next.js)

| Página | Ruta | Roles | Estado |
|--------|------|-------|--------|
| Dashboard | `/` | Todos | ✅ |
| Programación del Día | `/day` | Teacher, Director | ✅ |
| Actividades | `/activities` | Teacher, Director | ✅ |
| Justificantes | `/excuses` | Todos | ✅ |
| Chat | `/chat` | Todos | ✅ |
| Asistente IA | `/ai-assistant` | Todos | ✅ |
| Reportes | `/reports` | Director, Admin | ✅ |
| Grupos | `/groups` | Teacher, Director, Admin | ✅ |
| Alumnos | `/children` | Todos | ✅ |
| Configuración | `/settings` | Director, Admin | ✅ |
| Personalización | `/customization` | Admin | ✅ |

---

## 🚀 Inicio Rápido

### Prerrequisitos

- Node.js 18+ 
- PostgreSQL 15+
- npm o yarn
- Cuenta de Groq (para IA)

### Instalación

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd littlebees-web

# 2. Instalar dependencias
npm install

# 3. Configurar variables de entorno
# Ver CONFIGURACION.md para detalles

# 4. Ejecutar migraciones
cd apps/api
npx prisma migrate dev
npx prisma generate

# 5. Poblar base de datos
npm run seed

# 6. Iniciar desarrollo
npm run dev
```

**Acceso:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- API Docs: http://localhost:3001/api

---

## 📚 Documentación

- **[Guía de Configuración](./CONFIGURACION.md)** - Variables de entorno y setup
- **[Plan Técnico](./PLAN_TECNICO_IMPLEMENTACION.md)** - Roadmap de implementación
- **[Guía del Sistema](./infrastructure/docker/littlebees-system-guide.md)** - Arquitectura completa

---

## 👥 Roles del Sistema

### 🎓 Super Admin
- Acceso completo al sistema
- Gestión de múltiples instituciones (tenants)
- Configuración global

### 👔 Director/a
- Gestión administrativa de la institución
- Supervisión de maestras
- Reportes y estadísticas
- Aprobación de justificantes
- Configuración institucional

### 👩‍🏫 Maestra
- Gestión de grupos asignados
- Registro de actividades diarias
- Control de asistencia
- Comunicación con padres
- Reportes de grupo

### 👨‍👩‍👧 Padre/Madre
- Visualización de información de sus hijos
- Envío de justificantes
- Mensajería con maestras
- Consulta de actividades y desarrollo

---

## 🤖 Asistente IA

### Características

- **Modelo:** Llama 3.3-70b-versatile (Groq)
- **Contexto personalizado** por rol de usuario
- **Conversaciones persistentes** con historial
- **Respuestas especializadas** en educación infantil

### Capacidades por Rol

**Maestras:**
- Planificación de actividades educativas
- Consejos pedagógicos
- Registro de desarrollo infantil
- Comunicación con padres

**Directoras:**
- Gestión administrativa
- Supervisión de personal
- Análisis de reportes
- Toma de decisiones estratégicas

**Padres:**
- Información sobre desarrollo infantil
- Actividades educativas en casa
- Consejos de crianza
- Comprensión de reportes

---

## 📊 Reportes Disponibles

### 1. Reporte de Asistencia
- Breakdown diario y por grupo
- Tasa de asistencia promedio
- Filtros por fecha y grupo

### 2. Reporte de Actividades
- Actividades por tipo
- Resumen por niño
- Breakdown diario

### 3. Reporte de Desarrollo
- Progreso por categoría
- Hitos alcanzados
- Comparativa por edad

### 4. Reporte de Pagos
- Ingresos mensuales
- Pagos pendientes
- Estado de cobranza

---

## 🔐 Seguridad

- **Autenticación:** JWT con refresh tokens
- **Autorización:** Guards basados en roles
- **Multi-tenancy:** Aislamiento de datos por institución
- **Validación:** DTOs con class-validator
- **Sanitización:** Protección contra XSS e inyección SQL

---

## 🧪 Testing

```bash
# Backend
cd apps/api
npm run test          # Unit tests
npm run test:e2e      # E2E tests
npm run test:cov      # Coverage

# Frontend
cd apps/web
npm run test          # Jest tests
npm run test:e2e      # Playwright tests
```

---

## 📈 Roadmap

### Fase Actual: Optimización y UX (30%)

- [ ] Push notifications
- [ ] Onboarding interactivo
- [ ] Optimización de queries
- [ ] Mejoras de rendimiento
- [ ] PWA (Progressive Web App)

### Futuras Mejoras

- [ ] App móvil nativa (Flutter)
- [ ] Integración con sistemas de pago
- [ ] Exportación de reportes a PDF
- [ ] Dashboard analítico avanzado
- [ ] Sistema de evaluaciones
- [ ] Galería de fotos

---

## 🤝 Contribución

Este es un proyecto propietario. Para contribuir, contacta al equipo de desarrollo.

---

## 📄 Licencia

Propietaria - Todos los derechos reservados © 2026 LittleBees

---

## 📞 Contacto y Soporte

Para soporte técnico o consultas:
- **Email:** soporte@littlebees.com
- **Documentación:** Ver archivos en `/docs`

---

## 🙏 Agradecimientos

Desarrollado con ❤️ para mejorar la gestión de guarderías y jardines de niños.

**Tecnologías principales:**
- [NestJS](https://nestjs.com/)
- [Next.js](https://nextjs.org/)
- [Prisma](https://www.prisma.io/)
- [Groq](https://groq.com/)
- [TailwindCSS](https://tailwindcss.com/)
- [shadcn/ui](https://ui.shadcn.com/)

---

**Versión:** 1.0.0  
**Última actualización:** Marzo 2026  
**Estado:** 70% Completado - Producción Beta
