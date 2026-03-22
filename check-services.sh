#!/bin/bash

# 🐝 LittleBees - Script de Validación y Auto-inicio de Servicios
# Este script verifica que todos los servicios necesarios estén corriendo correctamente
# y automáticamente levanta los que falten

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Símbolos
CHECK="✓"
CROSS="✗"
ARROW="→"
ROCKET="🚀"

# Flags
AUTO_FIX=${1:-"--auto-fix"}  # Por defecto auto-arregla
SERVICES_STARTED=false
DOCKER_AVAILABLE=false
CLOUD_API_URL="http://216.250.125.239:3002"
CLOUD_HEALTH_URL="${CLOUD_API_URL}/api/v1/health"
CLOUD_SWAGGER_URL="${CLOUD_API_URL}/api/docs"

echo ""
echo "🐝 =========================================="
echo "   LittleBees - Validación de Servicios"
if [ "$AUTO_FIX" = "--auto-fix" ]; then
    echo "   Modo: Auto-inicio activado"
else
    echo "   Modo: Solo verificación"
fi
echo "=========================================="
echo ""

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    lsof -i :$port >/dev/null 2>&1
}

# Función para verificar respuesta HTTP
check_http() {
    local url=$1
    local timeout=${2:-5}
    curl -s -f -m $timeout "$url" >/dev/null 2>&1
}

# Función para limpiar procesos duplicados
cleanup_duplicate_processes() {
    echo "🧹 Limpiando procesos duplicados..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local cleaned=false
    
    # Verificar procesos en puerto 3002 (Backend)
    if lsof -ti:3002 >/dev/null 2>&1; then
        local pids=$(lsof -ti:3002)
        local count=$(echo "$pids" | wc -l | tr -d ' ')
        
        if [ "$count" -gt 1 ]; then
            echo -e "${YELLOW}⚠${NC}  Detectados $count procesos en puerto 3002"
            echo -e "${BLUE}${ARROW}${NC} Deteniendo procesos duplicados..."
            echo "$pids" | xargs kill -9 2>/dev/null
            cleaned=true
        fi
    fi
    
    # Verificar procesos en puerto 3001 (Frontend)
    if lsof -ti:3001 >/dev/null 2>&1; then
        local pids=$(lsof -ti:3001)
        local count=$(echo "$pids" | wc -l | tr -d ' ')
        
        if [ "$count" -gt 1 ]; then
            echo -e "${YELLOW}⚠${NC}  Detectados $count procesos en puerto 3001"
            echo -e "${BLUE}${ARROW}${NC} Deteniendo procesos duplicados..."
            echo "$pids" | xargs kill -9 2>/dev/null
            cleaned=true
        fi
    fi
    
    # Limpiar procesos huérfanos de pnpm dev
    local orphan_count=$(ps aux | grep -E "pnpm.*dev|nest.js start|next dev" | grep -v grep | wc -l | tr -d ' ')
    
    if [ "$orphan_count" -gt 2 ]; then
        echo -e "${YELLOW}⚠${NC}  Detectados $orphan_count procesos de desarrollo"
        echo -e "${BLUE}${ARROW}${NC} Limpiando procesos huérfanos..."
        pkill -f "nest.js start" 2>/dev/null
        pkill -f "next dev" 2>/dev/null
        pkill -f "pnpm.*dev" 2>/dev/null
        cleaned=true
        sleep 2
    fi
    
    if [ "$cleaned" = true ]; then
        echo -e "${GREEN}${CHECK}${NC} Procesos duplicados limpiados"
        sleep 1
    else
        echo -e "${GREEN}${CHECK}${NC} No se encontraron procesos duplicados"
    fi
    
    echo ""
}

# Ejecutar limpieza de procesos duplicados si auto-fix está activado
if [ "$AUTO_FIX" = "--auto-fix" ]; then
    cleanup_duplicate_processes
fi

# Contador de errores
ERRORS=0

echo "📦 1. Verificando Herramientas Base..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}${CHECK}${NC} Node.js: ${NODE_VERSION}"
else
    echo -e "${RED}${CROSS}${NC} Node.js: No instalado"
    ((ERRORS++))
fi

# pnpm
if command_exists pnpm; then
    PNPM_VERSION=$(pnpm --version)
    echo -e "${GREEN}${CHECK}${NC} pnpm: v${PNPM_VERSION}"
else
    echo -e "${RED}${CROSS}${NC} pnpm: No instalado"
    ((ERRORS++))
fi

# Docker
if command_exists docker; then
    DOCKER_AVAILABLE=true
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}${CHECK}${NC} Docker: ${DOCKER_VERSION}"
    
    # Verificar si Docker está corriendo
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Docker Daemon: Corriendo"
    else
        DOCKER_AVAILABLE=false
        echo -e "${YELLOW}${CROSS}${NC} Docker Daemon: No está corriendo"
        echo -e "${BLUE}${ARROW}${NC} Docker Desktop solo es necesario para herramientas opcionales como pgAdmin"
    fi
else
    echo -e "${YELLOW}${CROSS}${NC} Docker: No instalado"
    echo -e "${BLUE}${ARROW}${NC} Se puede trabajar sin Docker si solo usaras el backend de IONOS"
fi

echo ""
echo "🐳 2. Verificando Servicios de Apoyo..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}ℹ${NC}  PostgreSQL: Usando BD remota en IONOS (216.250.125.239:5437)"
echo -e "${BLUE}ℹ${NC}  Backend oficial: ${CLOUD_API_URL}"

if [ "$DOCKER_AVAILABLE" = true ]; then
    if ! docker ps --format '{{.Names}}' | grep -q "kinderspace-pgadmin" && [ "$AUTO_FIX" = "--auto-fix" ]; then
        echo -e "${MAGENTA}${ROCKET}${NC} Iniciando pgAdmin para administrar la BD de IONOS..."
        cd littlebees-web/infrastructure/docker && docker compose up -d pgadmin && cd ../../..
        echo -e "${GREEN}${CHECK}${NC} pgAdmin iniciado"
        echo ""
        sleep 2
    fi

    if docker ps --format '{{.Names}}' | grep -q "kinderspace-postgres"; then
        echo -e "${YELLOW}⚠${NC}  PostgreSQL local detectado (no necesario, se usa IONOS)"
    fi

    if docker ps --format '{{.Names}}' | grep -q "kinderspace-pgadmin"; then
        echo -e "${GREEN}${CHECK}${NC} pgAdmin Container: Corriendo"
        if check_port 5050; then
            echo -e "${GREEN}${CHECK}${NC} pgAdmin Puerto 5050: Activo"
            echo -e "${BLUE}${ARROW}${NC} Conectado a BD de IONOS (216.250.125.239:5437)"
        else
            echo -e "${YELLOW}${CROSS}${NC} pgAdmin Puerto 5050: No responde"
        fi
    else
        echo -e "${YELLOW}${CROSS}${NC} pgAdmin Container: No está corriendo"
    fi
else
    echo -e "${BLUE}${ARROW}${NC} Saltando servicios locales de apoyo; backend y BD corren en IONOS"
fi

echo ""
echo "🚀 3. Verificando Aplicaciones..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FRONTEND_RUNNING=false
CLOUD_BACKEND_RUNNING=false

if check_http "$CLOUD_HEALTH_URL" 5; then
    CLOUD_BACKEND_RUNNING=true
fi

if check_port 3001; then
    FRONTEND_RUNNING=true
fi

# Si el frontend no está corriendo y auto-fix está activado, iniciarlo conectado a IONOS
if [ "$AUTO_FIX" = "--auto-fix" ] && [ "$FRONTEND_RUNNING" = false ]; then
    echo -e "${MAGENTA}${ROCKET}${NC} Iniciando app web local conectada al backend de IONOS..."
    echo -e "${BLUE}${ARROW}${NC} Esto puede tomar 20-40 segundos..."
    echo ""
    
    nohup env NEXT_PUBLIC_API_URL="${CLOUD_API_URL}/api/v1" NEXT_PUBLIC_WS_URL="${CLOUD_API_URL}" pnpm dev:web > /tmp/littlebees-dev.log 2>&1 &
    WEB_PID=$!
    
    echo -e "${GREEN}${CHECK}${NC} App web iniciada en background (PID: $WEB_PID)"
    echo -e "${BLUE}${ARROW}${NC} Logs: /tmp/littlebees-dev.log"
    echo ""
    
    echo -e "${YELLOW}Esperando a que la app web esté lista...${NC}"
    
    WAIT_TIME=0
    MAX_WAIT=45
    
    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        if check_port 3001; then
            echo -e "${GREEN}${CHECK}${NC} App web lista!"
            FRONTEND_RUNNING=true
            SERVICES_STARTED=true
            break
        fi
        sleep 2
        WAIT_TIME=$((WAIT_TIME + 2))
        echo -n "."
    done
    echo ""
    
    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        echo -e "${YELLOW}⚠${NC}  Timeout esperando servicios. Revisa los logs en /tmp/littlebees-dev.log"
    fi
    echo ""
fi

# Backend API (IONOS)
if [ "$CLOUD_BACKEND_RUNNING" = true ]; then
    echo -e "${GREEN}${CHECK}${NC} Backend API IONOS: Activo"
    echo -e "${GREEN}${CHECK}${NC} Backend API Health Check: OK"
    echo -e "${BLUE}${ARROW}${NC} Swagger Docs: ${CLOUD_SWAGGER_URL}"
else
    echo -e "${RED}${CROSS}${NC} Backend API IONOS: No responde"
    ((ERRORS++))
fi

# Frontend Web (Next.js)
if check_port 3001; then
    echo -e "${GREEN}${CHECK}${NC} Frontend Web Puerto 3001: Activo"
    echo -e "${BLUE}${ARROW}${NC} Web App: http://localhost:3001"
else
    echo -e "${RED}${CROSS}${NC} Frontend Web Puerto 3001: No está corriendo"
    if [ "$AUTO_FIX" != "--auto-fix" ]; then
        echo -e "${YELLOW}${ARROW}${NC} Ejecuta: pnpm dev (o pnpm dev:web)"
    fi
    ((ERRORS++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Resumen final
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}${CHECK} ¡Todos los servicios están corriendo correctamente!${NC}"
    echo ""
    
    if [ "$SERVICES_STARTED" = true ]; then
        echo -e "${MAGENTA}${ROCKET}${NC} Servicios iniciados automáticamente por el script"
        echo -e "${BLUE}${ARROW}${NC} Las aplicaciones están corriendo en background"
        echo -e "${BLUE}${ARROW}${NC} Logs disponibles en: /tmp/littlebees-dev.log"
        echo ""
        echo "💡 Para ver los logs en tiempo real:"
        echo "   tail -f /tmp/littlebees-dev.log"
        echo ""
        echo "💡 Para detener la app web local:"
        echo "   pkill -f 'pnpm --filter @kinderspace/web dev'"
        echo ""
    fi
    
    echo "📱 URLs Disponibles:"
    echo "   • Frontend Web:    http://localhost:3001"
    echo "   • Backend API:     ${CLOUD_API_URL}"
    echo "   • Swagger Docs:    ${CLOUD_SWAGGER_URL}"
    if check_port 5050; then
        echo "   • pgAdmin:         http://localhost:5050"
    fi
    echo ""
else
    echo -e "${RED}${CROSS} Se encontraron ${ERRORS} problema(s)${NC}"
    echo ""
    
    if [ "$AUTO_FIX" = "--auto-fix" ]; then
        echo -e "${YELLOW}⚠${NC}  Algunos servicios no pudieron iniciarse automáticamente"
        echo ""
    fi
    
    echo "🔧 Comandos útiles:"
    echo "   • Iniciar app web:      NEXT_PUBLIC_API_URL=${CLOUD_API_URL}/api/v1 NEXT_PUBLIC_WS_URL=${CLOUD_API_URL} pnpm dev:web"
    echo "   • Ver logs app web:     tail -f /tmp/littlebees-dev.log"
    if [ "$DOCKER_AVAILABLE" = true ]; then
        echo "   • Iniciar pgAdmin:      cd littlebees-web/infrastructure/docker && docker compose up -d pgadmin"
    fi
    echo ""
    echo "💡 Para ejecutar sin auto-inicio:"
    echo "   ./check-services.sh --check-only"
    echo ""
    exit 1
fi

echo "=========================================="
echo ""
