# Dockerfile para Backend API (NestJS)
FROM node:20-alpine AS base

# Instalar pnpm
RUN npm install -g pnpm@10.12.4

# Instalar dependencias necesarias para Prisma
RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

# Copiar archivos de configuración del monorepo raíz
COPY package.json ./
COPY pnpm-workspace.yaml ./

# Copiar archivos de configuración de littlebees-web
COPY littlebees-web/package.json ./littlebees-web/
COPY littlebees-web/pnpm-lock.yaml ./littlebees-web/
COPY littlebees-web/pnpm-workspace.yaml ./littlebees-web/

# Copiar package.json de cada workspace
COPY littlebees-web/apps/api/package.json ./littlebees-web/apps/api/
COPY littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar dependencias desde littlebees-web
WORKDIR /app/littlebees-web
RUN pnpm install --frozen-lockfile

# Copiar código fuente
WORKDIR /app
COPY littlebees-web/apps/api ./littlebees-web/apps/api
COPY littlebees-web/packages/shared-types ./littlebees-web/packages/shared-types
COPY littlebees-web/packages/shared-validators ./littlebees-web/packages/shared-validators

# Compilar packages compartidos primero
WORKDIR /app/littlebees-web/packages/shared-types
RUN pnpm build

WORKDIR /app/littlebees-web/packages/shared-validators
RUN pnpm build

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
COPY --from=base /app/package.json ./
COPY --from=base /app/pnpm-workspace.yaml ./
COPY --from=base /app/littlebees-web/package.json ./littlebees-web/
COPY --from=base /app/littlebees-web/pnpm-lock.yaml ./littlebees-web/
COPY --from=base /app/littlebees-web/pnpm-workspace.yaml ./littlebees-web/
COPY --from=base /app/littlebees-web/apps/api/package.json ./littlebees-web/apps/api/
COPY --from=base /app/littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY --from=base /app/littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar solo dependencias de producción
WORKDIR /app/littlebees-web
RUN pnpm install --frozen-lockfile --prod

# Copiar código compilado y archivos necesarios
WORKDIR /app
COPY --from=base /app/littlebees-web/apps/api/dist ./littlebees-web/apps/api/dist
COPY --from=base /app/littlebees-web/apps/api/prisma ./littlebees-web/apps/api/prisma
COPY --from=base /app/littlebees-web/apps/api/node_modules/.prisma ./littlebees-web/apps/api/node_modules/.prisma
COPY --from=base /app/littlebees-web/packages ./littlebees-web/packages

WORKDIR /app/littlebees-web/apps/api

EXPOSE 3002

CMD ["pnpm", "start:prod"]
