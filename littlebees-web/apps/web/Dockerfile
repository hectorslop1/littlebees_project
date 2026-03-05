# Dockerfile para Frontend Web (Next.js)
FROM node:20-alpine AS base

# Instalar pnpm
RUN npm install -g pnpm@10.12.4

WORKDIR /app

# Copiar archivos de configuración de workspace
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY littlebees-web/apps/web/package.json ./littlebees-web/apps/web/
COPY littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar código fuente
COPY littlebees-web/apps/web ./littlebees-web/apps/web
COPY littlebees-web/packages/shared-types ./littlebees-web/packages/shared-types
COPY littlebees-web/packages/shared-validators ./littlebees-web/packages/shared-validators

# Build de la aplicación
WORKDIR /app/littlebees-web/apps/web
RUN pnpm build

# Etapa de producción
FROM node:20-alpine AS production

RUN npm install -g pnpm@10.12.4

WORKDIR /app

# Copiar archivos necesarios desde la etapa de build
COPY --from=base /app/package.json /app/pnpm-workspace.yaml /app/pnpm-lock.yaml ./
COPY --from=base /app/littlebees-web/apps/web/package.json ./littlebees-web/apps/web/
COPY --from=base /app/littlebees-web/packages/shared-types/package.json ./littlebees-web/packages/shared-types/
COPY --from=base /app/littlebees-web/packages/shared-validators/package.json ./littlebees-web/packages/shared-validators/

# Instalar solo dependencias de producción
RUN pnpm install --frozen-lockfile --prod

# Copiar archivos compilados
COPY --from=base /app/littlebees-web/apps/web/.next ./littlebees-web/apps/web/.next
COPY --from=base /app/littlebees-web/apps/web/public ./littlebees-web/apps/web/public
COPY --from=base /app/littlebees-web/apps/web/next.config.js ./littlebees-web/apps/web/
COPY --from=base /app/littlebees-web/packages ./littlebees-web/packages

WORKDIR /app/littlebees-web/apps/web

EXPOSE 3000

CMD ["pnpm", "start"]
