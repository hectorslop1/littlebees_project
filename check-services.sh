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
    
    # Verificar procesos en puerto 3000 (Frontend)
    if lsof -ti:3000 >/dev/null 2>&1; then
        local pids=$(lsof -ti:3000)
        local count=$(echo "$pids" | wc -l | tr -d ' ')
        
        if [ "$count" -gt 1 ]; then
            echo -e "${YELLOW}⚠${NC}  Detectados $count procesos en puerto 3000"
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
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}${CHECK}${NC} Docker: ${DOCKER_VERSION}"
    
    # Verificar si Docker está corriendo
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Docker Daemon: Corriendo"
    else
        echo -e "${RED}${CROSS}${NC} Docker Daemon: No está corriendo"
        echo -e "${YELLOW}${ARROW}${NC} Inicia Docker Desktop desde Applications"
        ((ERRORS++))
    fi
else
    echo -e "${RED}${CROSS}${NC} Docker: No instalado"
    ((ERRORS++))
fi

echo ""
echo "🐳 2. Verificando Contenedores Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar si algún contenedor falta
DOCKER_CONTAINERS_MISSING=false

if ! docker ps --format '{{.Names}}' | grep -q "kinderspace-postgres"; then
    DOCKER_CONTAINERS_MISSING=true
fi
if ! docker ps --format '{{.Names}}' | grep -q "kinderspace-redis"; then
    DOCKER_CONTAINERS_MISSING=true
fi
if ! docker ps --format '{{.Names}}' | grep -q "kinderspace-minio"; then
    DOCKER_CONTAINERS_MISSING=true
fi

# Si faltan contenedores y auto-fix está activado, levantarlos
if [ "$DOCKER_CONTAINERS_MISSING" = true ] && [ "$AUTO_FIX" = "--auto-fix" ]; then
    echo -e "${MAGENTA}${ROCKET}${NC} Iniciando contenedores Docker..."
    pnpm docker:up
    echo -e "${GREEN}${CHECK}${NC} Contenedores Docker iniciados"
    echo ""
    sleep 3  # Esperar a que los contenedores se inicien
fi

# PostgreSQL
if docker ps --format '{{.Names}}' | grep -q "kinderspace-postgres"; then
    echo -e "${GREEN}${CHECK}${NC} PostgreSQL Container: Corriendo"
    if check_port 5437; then
        echo -e "${GREEN}${CHECK}${NC} PostgreSQL Puerto 5437: Activo"
    else
        echo -e "${RED}${CROSS}${NC} PostgreSQL Puerto 5437: No responde"
        ((ERRORS++))
    fi
else
    echo -e "${RED}${CROSS}${NC} PostgreSQL Container: No está corriendo"
    ((ERRORS++))
fi

# Redis
if docker ps --format '{{.Names}}' | grep -q "kinderspace-redis"; then
    echo -e "${GREEN}${CHECK}${NC} Redis Container: Corriendo"
    if check_port 6383; then
        echo -e "${GREEN}${CHECK}${NC} Redis Puerto 6383: Activo"
    else
        echo -e "${RED}${CROSS}${NC} Redis Puerto 6383: No responde"
        ((ERRORS++))
    fi
else
    echo -e "${RED}${CROSS}${NC} Redis Container: No está corriendo"
    ((ERRORS++))
fi

# MinIO
if docker ps --format '{{.Names}}' | grep -q "kinderspace-minio"; then
    echo -e "${GREEN}${CHECK}${NC} MinIO Container: Corriendo"
    if check_port 9010; then
        echo -e "${GREEN}${CHECK}${NC} MinIO API Puerto 9010: Activo"
    else
        echo -e "${RED}${CROSS}${NC} MinIO API Puerto 9010: No responde"
        ((ERRORS++))
    fi
    if check_port 9011; then
        echo -e "${GREEN}${CHECK}${NC} MinIO Console Puerto 9011: Activo"
    else
        echo -e "${RED}${CROSS}${NC} MinIO Console Puerto 9011: No responde"
        ((ERRORS++))
    fi
else
    echo -e "${RED}${CROSS}${NC} MinIO Container: No está corriendo"
    ((ERRORS++))
fi

# pgAdmin
if docker ps --format '{{.Names}}' | grep -q "kinderspace-pgadmin"; then
    echo -e "${GREEN}${CHECK}${NC} pgAdmin Container: Corriendo"
    if check_port 5050; then
        echo -e "${GREEN}${CHECK}${NC} pgAdmin Puerto 5050: Activo"
    else
        echo -e "${RED}${CROSS}${NC} pgAdmin Puerto 5050: No responde"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}${CROSS}${NC} pgAdmin Container: No está corriendo (opcional)"
fi

echo ""
echo "🚀 3. Verificando Aplicaciones..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar si las aplicaciones están corriendo
BACKEND_RUNNING=false
FRONTEND_RUNNING=false

if check_port 3002; then
    BACKEND_RUNNING=true
fi

if check_port 3000; then
    FRONTEND_RUNNING=true
fi

# Si alguna aplicación no está corriendo y auto-fix está activado, iniciarlas
if [ "$AUTO_FIX" = "--auto-fix" ] && ([ "$BACKEND_RUNNING" = false ] || [ "$FRONTEND_RUNNING" = false ]); then
    echo -e "${MAGENTA}${ROCKET}${NC} Iniciando aplicaciones (Backend + Frontend)..."
    echo -e "${BLUE}${ARROW}${NC} Esto puede tomar 30-60 segundos..."
    echo ""
    
    # Iniciar en background usando nohup
    nohup pnpm dev > /tmp/littlebees-dev.log 2>&1 &
    DEV_PID=$!
    
    echo -e "${GREEN}${CHECK}${NC} Aplicaciones iniciadas en background (PID: $DEV_PID)"
    echo -e "${BLUE}${ARROW}${NC} Logs: /tmp/littlebees-dev.log"
    echo ""
    
    # Esperar a que los servicios estén disponibles (máximo 60 segundos)
    echo -e "${YELLOW}Esperando a que los servicios estén listos...${NC}"
    
    WAIT_TIME=0
    MAX_WAIT=60
    
    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        if check_port 3002 && check_port 3000; then
            echo -e "${GREEN}${CHECK}${NC} Servicios listos!"
            BACKEND_RUNNING=true
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

# Backend API (NestJS)
if check_port 3002; then
    echo -e "${GREEN}${CHECK}${NC} Backend API Puerto 3002: Activo"
    
    # Verificar endpoint de salud
    if check_http "http://localhost:3002/api/health" 3; then
        echo -e "${GREEN}${CHECK}${NC} Backend API Health Check: OK"
        echo -e "${BLUE}${ARROW}${NC} Swagger Docs: http://localhost:3002/api/docs"
    else
        echo -e "${YELLOW}${CROSS}${NC} Backend API Health Check: No responde (puede estar iniciando)"
    fi
else
    echo -e "${RED}${CROSS}${NC} Backend API Puerto 3002: No está corriendo"
    if [ "$AUTO_FIX" != "--auto-fix" ]; then
        echo -e "${YELLOW}${ARROW}${NC} Ejecuta: pnpm dev (o pnpm dev:api)"
    fi
    ((ERRORS++))
fi

# Frontend Web (Next.js)
if check_port 3000; then
    echo -e "${GREEN}${CHECK}${NC} Frontend Web Puerto 3000: Activo"
    echo -e "${BLUE}${ARROW}${NC} Web App: http://localhost:3000"
else
    echo -e "${RED}${CROSS}${NC} Frontend Web Puerto 3000: No está corriendo"
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
        echo "� Para detener los servicios:"
        echo "   pkill -f 'pnpm dev'"
        echo ""
    fi
    
    echo "�📱 URLs Disponibles:"
    echo "   • Frontend Web:    http://localhost:3000"
    echo "   • Backend API:     http://localhost:3002"
    echo "   • Swagger Docs:    http://localhost:3002/api/docs"
    echo "   • MinIO Console:   http://localhost:9011"
    echo "   • pgAdmin:         http://localhost:5050"
    echo ""
else
    echo -e "${RED}${CROSS} Se encontraron ${ERRORS} problema(s)${NC}"
    echo ""
    
    if [ "$AUTO_FIX" = "--auto-fix" ]; then
        echo -e "${YELLOW}⚠${NC}  Algunos servicios no pudieron iniciarse automáticamente"
        echo ""
    fi
    
    echo "🔧 Comandos útiles:"
    echo "   • Iniciar Docker:       Abre Docker Desktop"
    echo "   • Iniciar contenedores: pnpm docker:up"
    echo "   • Iniciar aplicaciones: pnpm dev"
    echo "   • Ver logs Docker:      docker compose logs -f"
    echo "   • Ver logs apps:        tail -f /tmp/littlebees-dev.log"
    echo ""
    echo "💡 Para ejecutar sin auto-inicio:"
    echo "   ./check-services.sh --check-only"
    echo ""
    exit 1
fi

echo "=========================================="
echo ""
