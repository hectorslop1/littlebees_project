# Dockerfile para Frontend Web (Next.js)
FROM node:20-alpine AS base

# Instalar pnpm
RUN npm install -g pnpm@10.12.4

WORKDIR /app

# Copiar archivos de configuración del monorepo raíz
COPY package.json ./
COPY pnpm-workspace.yaml ./

# Copiar archivos de configuración de littlebees-web
COPY littlebees-web/package.json ./littlebees-web/
COPY littlebees-web/pnpm-lock.yaml ./littlebees-web/
COPY littlebees-web/pnpm-workspace.yaml ./littlebees-web/

# Copiar package.json de cada workspace
COPY littlebees-web/apps/web/package.json ./littlebees-web/apps/web/
COPY littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar dependencias desde littlebees-web
WORKDIR /app/littlebees-web
RUN pnpm install --frozen-lockfile

# Copiar código fuente
WORKDIR /app
COPY littlebees-web/apps/web ./littlebees-web/apps/web
COPY littlebees-web/packages/shared-types ./littlebees-web/packages/shared-types
COPY littlebees-web/packages/shared-validators ./littlebees-web/packages/shared-validators

# Compilar packages compartidos primero
WORKDIR /app/littlebees-web/packages/shared-types
RUN pnpm build

WORKDIR /app/littlebees-web/packages/shared-validators
RUN pnpm build

# Build de la aplicación
WORKDIR /app/littlebees-web/apps/web
RUN pnpm build

# Etapa de producción
FROM node:20-alpine AS production

RUN npm install -g pnpm@10.12.4

WORKDIR /app

# Copiar archivos de configuración
COPY --from=base /app/package.json ./
COPY --from=base /app/pnpm-workspace.yaml ./
COPY --from=base /app/littlebees-web/package.json ./littlebees-web/
COPY --from=base /app/littlebees-web/pnpm-lock.yaml ./littlebees-web/
COPY --from=base /app/littlebees-web/pnpm-workspace.yaml ./littlebees-web/
COPY --from=base /app/littlebees-web/apps/web/package.json ./littlebees-web/apps/web/
COPY --from=base /app/littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY --from=base /app/littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar dependencias de producción
WORKDIR /app/littlebees-web
RUN pnpm install --frozen-lockfile --prod

# Copiar archivos compilados y necesarios
WORKDIR /app
COPY --from=base /app/littlebees-web/apps/web/.next ./littlebees-web/apps/web/.next
COPY --from=base /app/littlebees-web/apps/web/next.config.ts ./littlebees-web/apps/web/
COPY --from=base /app/littlebees-web/packages ./littlebees-web/packages

WORKDIR /app/littlebees-web/apps/web

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["../../node_modules/.bin/next", "start"]
