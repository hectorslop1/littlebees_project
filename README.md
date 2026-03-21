# LittleBees

Plataforma para guarderias y kinders en Mexico compuesta por una app web, una app movil y un backend compartido.

## Arquitectura oficial

- `littlebees-web/apps/api`: backend NestJS + Prisma.
- `littlebees-web/apps/web`: app web Next.js.
- `littlebees-mobile`: app movil Flutter.
- Flujo de datos obligatorio: `web/mobile -> API NestJS -> PostgreSQL IONOS`.
- Las apps cliente no deben conectarse directo a PostgreSQL.
- La base de datos local no es fuente de verdad para este proyecto.

## Estructura

```text
littlebees_project/
├── docs/
│   └── PROJECT_GUIDE.md
├── littlebees-web/
│   ├── apps/api
│   ├── apps/web
│   └── packages/
└── littlebees-mobile/
```

## Documento guia

La referencia operativa del proyecto vive en:

- [PROJECT_GUIDE.md](/Users/hectorlopez/Desktop/Proyectos/littlebees_project/docs/PROJECT_GUIDE.md)

Ese documento resume:

- objetivo del sistema,
- roles y comportamiento esperado,
- arquitectura oficial,
- reglas de integracion,
- modulos esperados,
- brechas actuales,
- prioridades de implementacion.

## Scripts operativos

Los scripts que se conservan como parte del flujo real son:

- `./check-services.sh`: valida e inicia servicios locales de apoyo y procesos de desarrollo.
- `./open-services.sh`: abre web, Swagger, MinIO y pgAdmin.
- `./deploy-to-ionos.sh`: deployment al servidor IONOS.
- `littlebees-mobile/build-apk-development.sh`: build Android para pruebas locales.
- `littlebees-mobile/build-apk-production.sh`: build Android apuntando a IONOS.
- `littlebees-web/packages/api-contracts/generate-client.sh`: regeneracion del cliente Dart desde OpenAPI.

Los archivos SQL validos que siguen en el repo son solo:

- `littlebees-web/apps/api/prisma/migrations/*/migration.sql`
- `littlebees-web/infrastructure/docker/init.sql`

## Comandos utiles

```bash
pnpm dev
pnpm dev:api
pnpm dev:web
pnpm mobile:run
pnpm db:migrate
pnpm db:seed
pnpm generate:api-client
```

## Notas de trabajo

- La fuente de verdad funcional es el backend.
- Se debe evitar dejar flujos con mocks o placeholders cuando el modulo deba persistir en BD.
- Si hay diferencias entre web, movil y backend, la referencia de trabajo debe quedar consolidada en `docs/PROJECT_GUIDE.md`.
- `MINIO_ENDPOINT`: MinIO API endpoint
