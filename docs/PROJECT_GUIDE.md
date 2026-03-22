# LittleBees - Documento Guia Operativo

## 1. Objetivo del sistema

LittleBees es una plataforma para guarderias y kinders en Mexico. El sistema debe digitalizar operacion diaria, comunicacion, asistencia, pagos, seguimiento infantil y administracion escolar dentro de una misma plataforma.

No estamos construyendo tres productos distintos. Estamos construyendo un solo sistema compuesto por:

- una app movil Flutter,
- una app web Next.js,
- un backend NestJS compartido,
- una base de datos PostgreSQL remota en IONOS.

## 2. Arquitectura oficial

La arquitectura valida del proyecto es esta:

```text
App movil Flutter ----\
                        -> API NestJS -> Prisma -> PostgreSQL IONOS
App web Next.js ------/
```

Reglas fijas:

- La app web no se conecta directo a PostgreSQL.
- La app movil no se conecta directo a PostgreSQL.
- El backend es la unica capa autorizada para leer y escribir datos de negocio.
- La base de datos oficial es PostgreSQL en IONOS.
- Redis, MinIO/S3 y Socket.IO son servicios de soporte, no reemplazos de la BD.

## 3. Fuente de verdad

Las referencias que se deben respetar son:

1. Este documento como guia operativa.
2. La documentacion funcional externa compartida por el usuario.
3. El contrato real del backend NestJS.
4. El schema de Prisma como modelo real de persistencia.

Si hay conflicto entre una pantalla cliente y el backend, el cliente debe alinearse al contrato real o el backend debe completarse segun el comportamiento esperado. No deben mantenerse contratos inventados o rutas obsoletas.

## 4. Stack tecnologico

### Backend

- Node.js 20+
- NestJS 10
- TypeScript 5
- Prisma 6
- PostgreSQL
- Redis
- MinIO o S3-compatible
- JWT + refresh tokens
- Argon2
- Socket.IO
- Swagger / OpenAPI

### Web

- Next.js 15
- React 19
- TailwindCSS
- Radix UI
- TanStack Query
- React Hook Form
- Zod
- Socket.IO Client

### Movil

- Flutter 3.11+
- Dart
- Riverpod
- GoRouter
- Dio
- flutter_secure_storage
- Socket.IO Client

## 5. Estructura del repo

```text
littlebees_project/
├── docs/
│   └── PROJECT_GUIDE.md
├── littlebees-web/
│   ├── apps/
│   │   ├── api/
│   │   └── web/
│   └── packages/
└── littlebees-mobile/
```

Responsabilidades:

- `littlebees-web/apps/api`: autenticacion, reglas de negocio, persistencia, sockets, reportes, archivos.
- `littlebees-web/apps/web`: interfaz administrativa y operativa web.
- `littlebees-mobile`: experiencia diaria para padres y maestras en movil.
- `littlebees-web/packages/*`: tipos y contratos compartidos.

### Scripts operativos conservados

Los scripts que siguen vigentes despues de la limpieza del repo son:

- `check-services.sh`: validacion del backend IONOS, arranque opcional del web local y pgAdmin si se necesita.
- `open-services.sh`: acceso rapido a web local, Swagger de IONOS y pgAdmin.
- `deploy-to-ionos.sh`: despliegue del sistema al servidor IONOS.
- `littlebees-mobile/build-apk-development.sh`: build Android de desarrollo apuntando a IONOS.
- `littlebees-mobile/build-apk-production.sh`: build Android apuntando al servidor IONOS.
- `littlebees-web/packages/api-contracts/generate-client.sh`: regeneracion del cliente Dart desde el OpenAPI real de IONOS.

Regla operativa:

- No se debe depender de un backend local para web o movil.
- Si se corre la app web localmente, debe consumir el backend de IONOS.
- Si se modifica el backend, el cambio debe desplegarse y validarse sobre el backend de IONOS.

### SQL validos que se conservan

Los unicos SQL que deben considerarse vigentes son:

- `littlebees-web/apps/api/prisma/migrations/*/migration.sql`
- `littlebees-web/infrastructure/docker/init.sql`

Todo SQL manual suelto de la raiz se considera historico y fue removido para evitar usar parches fuera del flujo de Prisma.

## 6. Roles oficiales

### parent

- Acceso: solo app movil.
- Alcance: solo sus hijos.
- Funciones clave: seguimiento diario, chat, pagos, justificantes, perfil del nino, IA.

### teacher

- Acceso: app movil y web.
- Alcance: solo sus grupos asignados.
- Funciones clave: asistencia, registro de actividades, chat con padres, consulta de perfiles, reportes de grupo, revision de justificantes, IA.

### director

- Acceso: web.
- Alcance: toda la institucion.
- Funciones clave: supervision, grupos, maestras, reportes globales, pagos, chat escalado, configuracion.

### admin

- Acceso: web.
- Alcance: total sobre la institucion.
- Funciones clave: usuarios, grupos, alumnos, pagos, reportes, configuracion avanzada, personalizacion.

### super_admin

- Rol tecnico de plataforma.
- No es un rol operativo normal de una guarderia.

## 7. Comportamiento esperado por app

### App movil

#### parent

- Ver resumen del dia de sus hijos.
- Ver timeline diario.
- Ver calendario.
- Chatear con maestras.
- Consultar pagos.
- Enviar justificantes.
- Consultar perfil completo del nino.
- Usar asistente IA.

#### teacher

- Ver resumen de sus grupos.
- Ver grupos asignados.
- Ver programacion del dia.
- Registrar entrada y salida con foto.
- Registrar comida, siesta y actividades.
- Consultar perfiles de alumnos.
- Chatear con padres.
- Usar asistente IA.

### App web

#### teacher

- Dashboard de sus grupos.
- Mis grupos.
- Alumnos de sus grupos.
- Actividades y bitacora.
- Reportes de asistencia y desarrollo.
- Chat por grupo.
- IA.

#### director

- Dashboard global.
- Gestion de grupos.
- Vista global de alumnos.
- Gestion de maestras.
- Reportes globales.
- Pagos.
- Chat escalado.
- Configuracion.

#### admin

- Dashboard administrativo.
- Usuarios.
- Grupos.
- Alumnos.
- Pagos.
- Reportes.
- Configuracion.
- Personalizacion.
- IA.

## 8. Modulos esperados del backend

Los modulos funcionales esperados del sistema son:

- auth
- users
- tenants
- groups
- children
- attendance
- daily-logs
- development
- exercises
- chat
- payments
- invoicing
- notifications
- reports
- announcements
- services
- files
- audit
- health
- menu
- ai
- excuses
- customization
- day-schedule

Observacion importante:

- En el estado actual del repo, algunos modulos documentados no estan realmente habilitados o no tienen soporte completo en Prisma/API.
- No se debe asumir que una pagina cliente existe funcionalmente solo porque la ruta esta creada.

## 9. Reglas de integracion

Estas reglas deben respetarse en todo cambio futuro:

### Datos

- No usar mocks para flujos que deban persistir.
- No usar datos hardcodeados en UI para representar estados reales de negocio.
- Si un modulo depende de BD, debe leer y escribir contra la API y la BD remota.

### Contratos

- Web y movil deben consumir el mismo contrato real de API.
- Si hay rutas antiguas o inventadas, deben eliminarse o alinearse.
- Los tipos compartidos deben reflejar lo que el backend entrega de verdad.

### Seguridad

- Toda lectura y escritura debe respetar rol y tenant.
- `tenant_id` debe aislar los datos entre instituciones.
- Los clientes no deben contener secretos de infraestructura.
- Las apps no deben depender de HTTP inseguro en produccion.

### Arquitectura

- Ningun modulo cliente debe hablar directo con PostgreSQL.
- Prisma es la capa de acceso a datos del backend.
- Los sockets deben usar los mismos eventos definidos por el gateway backend.
- No deben volver a agregarse scripts para exportar o restaurar una BD local hacia IONOS como flujo normal.

## 10. Estado actual del proyecto

Resumen real observado en el codigo:

- El backend contiene la mayor parte de la base funcional.
- Web y movil tienen varias rutas, hooks y repositorios desalineados con la API real.
- Hay modulos documentados pero deshabilitados o incompletos.
- Existen placeholders, vistas temporales y contratos viejos.
- Hay documentacion historica y de sesiones que ya no debe usarse como referencia.
- El repo ya fue depurado para dejar solo scripts y SQL conectados al flujo vigente.

## 11. Problemas principales detectados

### Autenticacion

- Flujo de login web con rutas inconsistentes.
- Clientes intentando usar refresh token contra endpoint no implementado.

### Contratos API

- Web y movil consumen rutas inexistentes o viejas.
- Tipos compartidos no siempre coinciden con respuestas reales.
- Algunos clientes esperan campos que Prisma/API no exponen.

### Modulos incompletos

- excuses
- customization
- ciertos flujos de day schedule
- partes del chat y pagos
- varias pantallas moviles todavia con placeholders o logica temporal

### Seguridad y multi-tenant

- Debe verificarse de manera continua que toda operacion este filtrada por tenant y rol.
- No se puede depender de una promesa de RLS si las policies no estan realmente implementadas.

### Configuracion

- Persisten referencias a desarrollo local mezcladas con configuracion remota.
- La app movil contiene defaults remotos hardcodeados sobre HTTP.
- `deploy-to-ionos.sh` y `docker-compose.prod.yml` todavia requieren alineacion completa para operar sin asumir PostgreSQL local en produccion.

## 12. Criterio de terminado

Un modulo solo se considera terminado cuando:

- existe soporte real en Prisma,
- existe soporte real en API,
- web y/o movil consumen ese contrato correcto,
- persiste datos reales en PostgreSQL IONOS,
- respeta rol y tenant,
- no depende de mocks,
- no depende de datos fijos,
- no tiene rutas falsas o temporales.

## 13. Prioridades de implementacion

Orden recomendado:

1. Autenticacion completa y consistente.
2. Alineacion de contratos backend, web y movil.
3. Eliminar mocks y placeholders de flujos criticos.
4. Corregir chat, asistencia, daily logs, pagos y perfiles.
5. Rehabilitar justificantes, personalizacion y day schedule segun documentacion.
6. Validar permisos por rol y aislamiento multi-tenant.
7. Verificar extremo a extremo contra la BD de IONOS.

## 14. Regla de trabajo para futuras tareas

Toda tarea futura debe responder estas preguntas antes de cerrarse:

1. Que rol usa este flujo.
2. En que app debe vivir.
3. Que endpoint real lo soporta.
4. Que tablas o modelos toca.
5. Si persiste de verdad en PostgreSQL IONOS.
6. Si respeta tenant y permisos.
7. Si queda libre de mocks y rutas temporales.

## 15. Objetivo inmediato del desarrollo

Llevar ambas apps a un estado funcional y coherente end-to-end:

- sin datos mock,
- sin contratos rotos,
- sin modulos fantasma,
- sin divergencia entre documentacion y codigo,
- comunicandose correctamente con el backend,
- y alimentando la base de datos remota como unica fuente de verdad.
