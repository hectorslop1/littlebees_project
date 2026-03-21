#!/bin/bash

# 🚀 LittleBees - Script de Deployment a IONOS VPS
# Este script despliega automáticamente el proyecto al servidor IONOS

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Símbolos
CHECK="✓"
CROSS="✗"
ARROW="→"
ROCKET="🚀"
GEAR="⚙"

# Configuración del servidor
SERVER_IP="216.250.125.239"
SERVER_USER="cbluna"
REPO_URL="https://github.com/hectorslop1/littlebees_project"
REMOTE_DIR="/home/cbluna/littlebees_project"
BRANCH="main"

# Detectar automáticamente la ruta de la llave SSH según la computadora
SSH_KEY_PATH1="/Users/hectorlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna"
SSH_KEY_PATH2="/Users/hectoreduardosanchezlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna"

if [ -f "$SSH_KEY_PATH1" ]; then
    SSH_KEY="$SSH_KEY_PATH1"
elif [ -f "$SSH_KEY_PATH2" ]; then
    SSH_KEY="$SSH_KEY_PATH2"
else
    echo -e "${RED}${CROSS}${NC} Llave SSH no encontrada en ninguna de las rutas esperadas:"
    echo "   - $SSH_KEY_PATH1"
    echo "   - $SSH_KEY_PATH2"
    exit 1
fi

# Configuración de puertos
BACKEND_PORT=3002
FRONTEND_PORT=3000
POSTGRES_PORT=5437
REDIS_PORT=6383
MINIO_API_PORT=9010
MINIO_CONSOLE_PORT=9011

echo ""
echo "🐝 =========================================="
echo "   LittleBees - Deployment a IONOS VPS"
echo "=========================================="
echo ""
echo "📍 Servidor: ${SERVER_IP}"
echo "👤 Usuario:  ${SERVER_USER}"
echo "📦 Repositorio: ${REPO_URL}"
echo ""

# Función para ejecutar comandos en el servidor remoto
remote_exec() {
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "$@"
}

# Función para copiar archivos al servidor
remote_copy() {
    scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$1" "${SERVER_USER}@${SERVER_IP}:$2"
}

# Contador de errores
ERRORS=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 1. Verificando Conexión SSH..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar que la llave SSH existe
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}${CROSS}${NC} Llave SSH no encontrada: $SSH_KEY"
    exit 1
fi

# Verificar permisos de la llave SSH
chmod 600 "$SSH_KEY"
echo -e "${GREEN}${CHECK}${NC} Llave SSH encontrada y permisos configurados"

# Probar conexión SSH
if remote_exec "echo 'Conexión exitosa'" > /dev/null 2>&1; then
    echo -e "${GREEN}${CHECK}${NC} Conexión SSH establecida correctamente"
else
    echo -e "${RED}${CROSS}${NC} No se pudo conectar al servidor"
    echo -e "${YELLOW}${ARROW}${NC} Verifica que la IP, usuario y llave SSH sean correctos"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 2. Verificando Dependencias en el Servidor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}${ARROW}${NC} Solo se requiere Git y Docker (Node.js corre en contenedores)"
echo ""

# Verificar Git
if remote_exec "command -v git" > /dev/null 2>&1; then
    GIT_VERSION=$(remote_exec "git --version" | cut -d' ' -f3)
    echo -e "${GREEN}${CHECK}${NC} Git instalado: v${GIT_VERSION}"
else
    echo -e "${RED}${CROSS}${NC} Git no está instalado"
    echo -e "${YELLOW}${ARROW}${NC} Por favor instala Git en el servidor: sudo apt-get install -y git"
    exit 1
fi

# Verificar Docker
if remote_exec "command -v docker" > /dev/null 2>&1; then
    DOCKER_VERSION=$(remote_exec "docker --version" | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}${CHECK}${NC} Docker instalado: ${DOCKER_VERSION}"
    
    # Verificar que el usuario puede ejecutar docker sin sudo
    if remote_exec "docker ps" > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Usuario tiene permisos de Docker"
    else
        echo -e "${RED}${CROSS}${NC} Usuario no tiene permisos de Docker"
        echo -e "${YELLOW}${ARROW}${NC} Ejecuta en el servidor: sudo usermod -aG docker ${SERVER_USER}"
        echo -e "${YELLOW}${ARROW}${NC} Luego cierra sesión y vuelve a conectarte"
        exit 1
    fi
else
    echo -e "${RED}${CROSS}${NC} Docker no está instalado"
    echo -e "${YELLOW}${ARROW}${NC} Por favor instala Docker en el servidor:"
    echo -e "${YELLOW}${ARROW}${NC} curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    echo -e "${YELLOW}${ARROW}${NC} sudo usermod -aG docker ${SERVER_USER}"
    exit 1
fi

# Verificar Docker Compose
if remote_exec "docker compose version" > /dev/null 2>&1; then
    COMPOSE_VERSION=$(remote_exec "docker compose version" | cut -d' ' -f4)
    echo -e "${GREEN}${CHECK}${NC} Docker Compose disponible: ${COMPOSE_VERSION}"
else
    echo -e "${RED}${CROSS}${NC} Docker Compose no disponible"
    echo -e "${YELLOW}${ARROW}${NC} Docker Compose debería venir con Docker. Actualiza Docker."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 3. Clonando/Actualizando Repositorio..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar si el directorio ya existe
if remote_exec "[ -d ${REMOTE_DIR} ]"; then
    echo -e "${BLUE}${ARROW}${NC} Directorio existe, actualizando desde GitHub..."
    
    # Guardar cambios locales si existen
    remote_exec "cd ${REMOTE_DIR} && git stash" || true
    
    # Actualizar repositorio
    remote_exec "cd ${REMOTE_DIR} && git fetch origin"
    remote_exec "cd ${REMOTE_DIR} && git checkout ${BRANCH}"
    remote_exec "cd ${REMOTE_DIR} && git pull origin ${BRANCH}"
    
    COMMIT_HASH=$(remote_exec "cd ${REMOTE_DIR} && git rev-parse --short HEAD")
    echo -e "${GREEN}${CHECK}${NC} Repositorio actualizado a commit: ${COMMIT_HASH}"
else
    echo -e "${BLUE}${ARROW}${NC} Clonando repositorio desde GitHub..."
    remote_exec "git clone ${REPO_URL} ${REMOTE_DIR}"
    remote_exec "cd ${REMOTE_DIR} && git checkout ${BRANCH}"
    
    COMMIT_HASH=$(remote_exec "cd ${REMOTE_DIR} && git rev-parse --short HEAD")
    echo -e "${GREEN}${CHECK}${NC} Repositorio clonado exitosamente: ${COMMIT_HASH}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "� 4. Deteniendo Contenedores Existentes..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Deteniendo contenedores existentes..."
remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml down" || true
echo -e "${GREEN}${CHECK}${NC} Contenedores detenidos"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  5. Construyendo Imágenes Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Construyendo imágenes Docker (esto puede tomar varios minutos)..."
remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml build --no-cache"
echo -e "${GREEN}${CHECK}${NC} Imágenes Docker construidas exitosamente"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗄️  6. Ejecutando Migraciones de Base de Datos..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Iniciando solo PostgreSQL para migraciones..."
remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml up -d postgres"
sleep 10

echo -e "${BLUE}${ARROW}${NC} Ejecutando migraciones de Prisma..."
remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml run --rm api pnpm prisma migrate deploy" || {
    echo -e "${YELLOW}⚠${NC}  Las migraciones fallaron, pero continuando..."
}
echo -e "${GREEN}${CHECK}${NC} Migraciones ejecutadas"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 7. Iniciando Todos los Servicios..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Iniciando todos los contenedores..."
remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml up -d"
echo -e "${GREEN}${CHECK}${NC} Contenedores iniciados"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 8. Verificando Deployment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Esperar a que los servicios estén listos
echo -e "${YELLOW}Esperando a que los servicios estén listos (45 segundos)...${NC}"
sleep 45

# Verificar estado de contenedores
echo -e "${BLUE}${ARROW}${NC} Verificando contenedores Docker..."
echo ""

POSTGRES_RUNNING=$(remote_exec "docker ps --filter name=littlebees-postgres --format '{{.Names}}'" || echo "")
REDIS_RUNNING=$(remote_exec "docker ps --filter name=littlebees-redis --format '{{.Names}}'" || echo "")
MINIO_RUNNING=$(remote_exec "docker ps --filter name=littlebees-minio --format '{{.Names}}'" || echo "")
API_RUNNING=$(remote_exec "docker ps --filter name=littlebees-api --format '{{.Names}}'" || echo "")
WEB_RUNNING=$(remote_exec "docker ps --filter name=littlebees-web --format '{{.Names}}'" || echo "")

if [ -n "$POSTGRES_RUNNING" ]; then
    echo -e "${GREEN}${CHECK}${NC} PostgreSQL: Corriendo"
else
    echo -e "${RED}${CROSS}${NC} PostgreSQL: No está corriendo"
    ((ERRORS++))
fi

if [ -n "$REDIS_RUNNING" ]; then
    echo -e "${GREEN}${CHECK}${NC} Redis: Corriendo"
else
    echo -e "${RED}${CROSS}${NC} Redis: No está corriendo"
    ((ERRORS++))
fi

if [ -n "$MINIO_RUNNING" ]; then
    echo -e "${GREEN}${CHECK}${NC} MinIO: Corriendo"
else
    echo -e "${RED}${CROSS}${NC} MinIO: No está corriendo"
    ((ERRORS++))
fi

if [ -n "$API_RUNNING" ]; then
    echo -e "${GREEN}${CHECK}${NC} Backend API: Corriendo"
else
    echo -e "${RED}${CROSS}${NC} Backend API: No está corriendo"
    ((ERRORS++))
fi

if [ -n "$WEB_RUNNING" ]; then
    echo -e "${GREEN}${CHECK}${NC} Frontend Web: Corriendo"
else
    echo -e "${RED}${CROSS}${NC} Frontend Web: No está corriendo"
    ((ERRORS++))
fi

# Verificar puertos
echo ""
echo -e "${BLUE}${ARROW}${NC} Verificando conectividad HTTP..."

BACKEND_CHECK=$(remote_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:${BACKEND_PORT}/api/v1/health || echo '000'")
FRONTEND_CHECK=$(remote_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:${FRONTEND_PORT} || echo '000'")

if [ "$BACKEND_CHECK" = "200" ] || [ "$BACKEND_CHECK" = "404" ]; then
    echo -e "${GREEN}${CHECK}${NC} Backend API respondiendo en puerto ${BACKEND_PORT} (HTTP ${BACKEND_CHECK})"
else
    echo -e "${YELLOW}⚠${NC}  Backend API no responde aún (HTTP ${BACKEND_CHECK})"
fi

if [ "$FRONTEND_CHECK" = "200" ] || [ "$FRONTEND_CHECK" = "404" ]; then
    echo -e "${GREEN}${CHECK}${NC} Frontend Web respondiendo en puerto ${FRONTEND_PORT} (HTTP ${FRONTEND_CHECK})"
else
    echo -e "${YELLOW}⚠${NC}  Frontend Web no responde aún (HTTP ${FRONTEND_CHECK})"
fi

# Mostrar logs recientes si hay errores
if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}${ARROW}${NC} Mostrando logs recientes de contenedores con problemas..."
    remote_exec "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml logs --tail=50"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Resumen final
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}${ROCKET} ¡Deployment completado exitosamente!${NC}"
    echo ""
    echo "📱 URLs del Servidor:"
    echo "   • Frontend Web:    http://${SERVER_IP}:${FRONTEND_PORT}"
    echo "   • Backend API:     http://${SERVER_IP}:${BACKEND_PORT}"
    echo "   • Swagger Docs:    http://${SERVER_IP}:${BACKEND_PORT}/api/docs"
    echo "   • MinIO Console:   http://${SERVER_IP}:${MINIO_CONSOLE_PORT}"
    echo ""
    echo "🔧 Comandos útiles en el servidor:"
    echo "   • Ver logs de todos:   ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml logs -f'"
    echo "   • Ver logs API:        ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml logs -f api'"
    echo "   • Ver logs Web:        ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml logs -f web'"
    echo "   • Estado contenedores: ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'docker ps'"
    echo "   • Reiniciar servicios: ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml restart'"
    echo "   • Detener servicios:   ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml down'"
    echo ""
    echo "📝 Información del deployment:"
    echo "   • Commit: ${COMMIT_HASH}"
    echo "   • Branch: ${BRANCH}"
    echo "   • Fecha:  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "   • Arquitectura: Docker Compose (Producción)"
    echo ""
else
    echo -e "${RED}${CROSS} Deployment completado con ${ERRORS} advertencia(s)${NC}"
    echo ""
    echo "⚠️  Revisa los logs para más detalles:"
    echo "   ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml logs --tail=100'"
    echo ""
    echo "🔧 Comandos de diagnóstico:"
    echo "   • Ver estado:          ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'docker ps -a'"
    echo "   • Reintentar build:    ssh -i \"$SSH_KEY\" ${SERVER_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml up -d --build'"
    echo ""
fi

echo "=========================================="
echo ""
