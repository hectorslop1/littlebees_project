# Dockerfile para Backend API (NestJS)
FROM node:20-alpine AS base

# Instalar pnpm
RUN npm install -g pnpm@10.12.4

# Instalar dependencias necesarias para Prisma
RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

# Copiar archivos de configuración de workspace
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY littlebees-web/apps/api/package.json ./littlebees-web/apps/api/
COPY littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar código fuente
COPY littlebees-web/apps/api ./littlebees-web/apps/api
COPY littlebees-web/packages/shared-types ./littlebees-web/packages/shared-types
COPY littlebees-web/packages/shared-validators ./littlebees-web/packages/shared-validators

# Generar Prisma Client
WORKDIR /app/littlebees-web/apps/api
RUN pnpm prisma generate

# Build de la aplicación
RUN pnpm build

# Etapa de producción
FROM node:20-alpine AS production

RUN npm install -g pnpm@10.12.4
RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

# Copiar archivos necesarios desde la etapa de build
COPY --from=base /app/package.json /app/pnpm-workspace.yaml /app/pnpm-lock.yaml ./
COPY --from=base /app/littlebees-web/apps/api/package.json ./littlebees-web/apps/api/
COPY --from=base /app/littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY --from=base /app/littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar solo dependencias de producción
RUN pnpm install --frozen-lockfile --prod

# Copiar código compilado y archivos necesarios
COPY --from=base /app/littlebees-web/apps/api/dist ./littlebees-web/apps/api/dist
COPY --from=base /app/littlebees-web/apps/api/prisma ./littlebees-web/apps/api/prisma
COPY --from=base /app/littlebees-web/apps/api/node_modules/.prisma ./littlebees-web/apps/api/node_modules/.prisma
COPY --from=base /app/littlebees-web/packages ./littlebees-web/packages

WORKDIR /app/littlebees-web/apps/api

EXPOSE 3002

CMD ["pnpm", "start:prod"]
