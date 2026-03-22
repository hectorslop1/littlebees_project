# LittleBees

Plataforma para guarderias y kinders en Mexico compuesta por una app web, una app movil y un backend compartido.

## Arquitectura oficial

- `littlebees-web/apps/api`: backend NestJS + Prisma.
- `littlebees-web/apps/web`: app web Next.js.
- `littlebees-mobile`: app movil Flutter.
- Flujo de datos obligatorio: `web/mobile -> API NestJS -> PostgreSQL IONOS`.
- Las apps cliente no deben conectarse directo a PostgreSQL.
- La base de datos local no es fuente de verdad para este proyecto.
- El backend operativo oficial vive en IONOS: `http://216.250.125.239:3002`.

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
- `./open-services.sh`: abre web local, Swagger de IONOS y pgAdmin si esta disponible.
- `./deploy-to-ionos.sh`: deployment al servidor IONOS.
- `littlebees-mobile/build-apk-development.sh`: build Android de desarrollo apuntando a IONOS.
- `littlebees-mobile/build-apk-production.sh`: build Android apuntando a IONOS.
- `littlebees-web/packages/api-contracts/generate-client.sh`: regeneracion del cliente Dart desde el OpenAPI de IONOS.

Los archivos SQL validos que siguen en el repo son solo:

- `littlebees-web/apps/api/prisma/migrations/*/migration.sql`
- `littlebees-web/infrastructure/docker/init.sql`

## Comandos utiles

```bash
./check-services.sh
NEXT_PUBLIC_API_URL=http://216.250.125.239:3002/api/v1 NEXT_PUBLIC_WS_URL=http://216.250.125.239:3002 pnpm dev:web
pnpm mobile:run
pnpm generate:api-client
```

## Notas de trabajo

- La fuente de verdad funcional es el backend.
- Para desarrollo diario se asume backend remoto en IONOS, no un API local.
- Se debe evitar dejar flujos con mocks o placeholders cuando el modulo deba persistir en BD.
- Si hay diferencias entre web, movil y backend, la referencia de trabajo debe quedar consolidada en `docs/PROJECT_GUIDE.md`.
- `MINIO_ENDPOINT`: MinIO API endpoint
