#!/bin/bash
# ============================================================
# KinderSpace MX - Script de inicio para desarrollo
# ============================================================
# Levanta todos los servicios necesarios:
#   1. Docker (PostgreSQL, Redis, MinIO)
#   2. Backend NestJS (puerto 3002)
#   3. Frontend Next.js (puerto 3003)
# ============================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Directorio raíz del proyecto
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$PROJECT_ROOT/infrastructure/docker"
API_DIR="$PROJECT_ROOT/apps/api"
WEB_DIR="$PROJECT_ROOT/apps/web"

# Puerto del frontend (3001 está ocupado por gen_portales)
WEB_PORT=3003

# PIDs de procesos hijos para limpieza
BACKEND_PID=""
FRONTEND_PID=""

# ------------------------------------------------------------
# Función de limpieza al salir
# ------------------------------------------------------------
cleanup() {
    echo ""
    echo -e "${YELLOW}Deteniendo servicios...${NC}"

    if [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo -e "  ${CYAN}Deteniendo frontend (PID: $FRONTEND_PID)...${NC}"
        kill "$FRONTEND_PID" 2>/dev/null
        wait "$FRONTEND_PID" 2>/dev/null
    fi

    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo -e "  ${CYAN}Deteniendo backend (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null
        wait "$BACKEND_PID" 2>/dev/null
    fi

    echo -e "${YELLOW}¿Deseas detener los contenedores Docker? (s/N)${NC}"
    read -t 5 -r STOP_DOCKER || STOP_DOCKER="n"
    if [[ "$STOP_DOCKER" =~ ^[sS]$ ]]; then
        echo -e "  ${CYAN}Deteniendo Docker...${NC}"
        docker compose -f "$DOCKER_DIR/docker-compose.yml" down
        echo -e "  ${GREEN}Docker detenido.${NC}"
    else
        echo -e "  ${CYAN}Docker sigue corriendo en segundo plano.${NC}"
    fi

    echo -e "${GREEN}Todos los servicios detenidos. ¡Hasta luego!${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# ------------------------------------------------------------
# Verificar dependencias
# ------------------------------------------------------------
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  KinderSpace MX - Inicio de Desarrollo${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

echo -e "${CYAN}Verificando dependencias...${NC}"

if ! command -v docker &>/dev/null; then
    echo -e "${RED}Error: Docker no está instalado.${NC}"
    exit 1
fi

if ! command -v pnpm &>/dev/null; then
    echo -e "${RED}Error: pnpm no está instalado.${NC}"
    exit 1
fi

if ! command -v node &>/dev/null; then
    echo -e "${RED}Error: Node.js no está instalado.${NC}"
    exit 1
fi

echo -e "${GREEN}  Docker, pnpm y Node.js encontrados.${NC}"
echo ""

# ------------------------------------------------------------
# Paso 1: Levantar Docker (PostgreSQL, Redis, MinIO)
# ------------------------------------------------------------
echo -e "${CYAN}[1/5] Levantando contenedores Docker...${NC}"
docker compose -f "$DOCKER_DIR/docker-compose.yml" up -d

echo -e "${CYAN}  Esperando a que PostgreSQL esté listo...${NC}"
RETRIES=30
until docker exec kinderspace-postgres pg_isready -U kinderspace &>/dev/null || [ $RETRIES -eq 0 ]; do
    RETRIES=$((RETRIES - 1))
    sleep 1
done

if [ $RETRIES -eq 0 ]; then
    echo -e "${RED}  Error: PostgreSQL no respondió a tiempo.${NC}"
    exit 1
fi

echo -e "${GREEN}  PostgreSQL listo (puerto 5437)${NC}"
echo -e "${GREEN}  Redis listo (puerto 6383)${NC}"
echo -e "${GREEN}  MinIO listo (puertos 9010/9011)${NC}"
echo ""

# ------------------------------------------------------------
# Paso 2: Instalar dependencias si es necesario
# ------------------------------------------------------------
echo -e "${CYAN}[2/5] Verificando dependencias del proyecto...${NC}"
if [ ! -d "$PROJECT_ROOT/node_modules" ]; then
    echo -e "  ${YELLOW}Instalando dependencias con pnpm...${NC}"
    cd "$PROJECT_ROOT" && pnpm install
else
    echo -e "  ${GREEN}Dependencias ya instaladas.${NC}"
fi
echo ""

# ------------------------------------------------------------
# Paso 3: Ejecutar migraciones y seed
# ------------------------------------------------------------
echo -e "${CYAN}[3/5] Ejecutando migraciones de base de datos...${NC}"
cd "$API_DIR" && npx prisma migrate deploy 2>/dev/null || npx prisma db push --accept-data-loss 2>/dev/null
echo -e "${GREEN}  Migraciones aplicadas.${NC}"

echo -e "${CYAN}  Ejecutando seed de datos de prueba...${NC}"
cd "$API_DIR" && npx prisma db seed 2>/dev/null && echo -e "${GREEN}  Seed completado.${NC}" || echo -e "${YELLOW}  Seed ya ejecutado o no disponible.${NC}"
echo ""

# ------------------------------------------------------------
# Paso 4: Levantar Backend NestJS
# ------------------------------------------------------------
echo -e "${CYAN}[4/5] Levantando backend NestJS (puerto 3002)...${NC}"
cd "$API_DIR" && npx prisma generate 2>/dev/null
cd "$API_DIR" && ./node_modules/.bin/nest start --watch &
BACKEND_PID=$!

# Esperar a que el backend responda
RETRIES=40
until curl -s http://localhost:3002/api/v1 &>/dev/null || [ $RETRIES -eq 0 ]; do
    RETRIES=$((RETRIES - 1))
    sleep 2
done

if [ $RETRIES -eq 0 ]; then
    echo -e "${YELLOW}  Backend iniciando (puede tardar unos segundos más)...${NC}"
else
    echo -e "${GREEN}  Backend listo en http://localhost:3002${NC}"
fi
echo ""

# ------------------------------------------------------------
# Paso 5: Levantar Frontend Next.js en puerto 3003
# ------------------------------------------------------------
echo -e "${CYAN}[5/5] Levantando frontend Next.js (puerto $WEB_PORT)...${NC}"
cd "$WEB_DIR" && pnpm next dev --port $WEB_PORT &
FRONTEND_PID=$!

sleep 3

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  KinderSpace MX - Servicios Activos${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "  ${CYAN}Frontend:${NC}     http://localhost:$WEB_PORT"
echo -e "  ${CYAN}Backend API:${NC}  http://localhost:3002/api/v1"
echo -e "  ${CYAN}Swagger:${NC}      http://localhost:3002/api/docs"
echo -e "  ${CYAN}MinIO:${NC}        http://localhost:9011"
echo ""
echo -e "  ${YELLOW}Credenciales de prueba:${NC}"
echo -e "    Email:    director@petitsoleil.mx"
echo -e "    Password: Password123!"
echo ""
echo -e "  ${YELLOW}Presiona Ctrl+C para detener todos los servicios${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# Esperar a que terminen los procesos
wait
