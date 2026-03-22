#!/bin/bash

# 🌐 LittleBees - Script para Abrir Servicios en el Navegador
# Este script abre automáticamente todos los servicios web en el navegador

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Símbolos
CHECK="✓"
ARROW="→"
BROWSER="🌐"

CLOUD_API_URL="http://216.250.125.239:3002"

# URLs de los servicios
FRONTEND_URL="http://localhost:3001"
BACKEND_API_URL="${CLOUD_API_URL}"
SWAGGER_URL="${CLOUD_API_URL}/api/docs"
PGADMIN_URL="http://localhost:5050"

echo ""
echo "🐝 =========================================="
echo "   LittleBees - Abriendo Servicios"
echo "=========================================="
echo ""

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

# Función para abrir URL en el navegador
open_url() {
    local url=$1
    local name=$2
    
    echo -e "${BLUE}${BROWSER}${NC} Abriendo ${name}..."
    echo -e "${ARROW} ${url}"
    open "$url"
    sleep 1
}

# Verificar servicios antes de abrir
echo -e "${YELLOW}Verificando servicios...${NC}"
echo ""

SERVICES_RUNNING=true

if check_port 3001; then
    echo -e "${GREEN}${CHECK}${NC} Frontend Web (puerto 3001): Activo"
else
    echo -e "${YELLOW}⚠${NC}  Frontend Web (puerto 3001): No está corriendo"
    SERVICES_RUNNING=false
fi

if check_http "${CLOUD_API_URL}/api/v1/health" 5; then
    echo -e "${GREEN}${CHECK}${NC} Backend API IONOS: Activo"
else
    echo -e "${YELLOW}⚠${NC}  Backend API IONOS: No responde"
    SERVICES_RUNNING=false
fi

if check_port 5050; then
    echo -e "${GREEN}${CHECK}${NC} pgAdmin (puerto 5050): Activo"
else
    echo -e "${YELLOW}⚠${NC}  pgAdmin (puerto 5050): No está corriendo"
fi

echo ""

if [ "$SERVICES_RUNNING" = false ]; then
    echo -e "${YELLOW}⚠  Algunos servicios no están corriendo${NC}"
    echo -e "${ARROW} Ejecuta primero: ${BLUE}./check-services.sh${NC}"
    echo ""
    echo "¿Deseas abrir los servicios disponibles de todos modos? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelado."
        exit 0
    fi
    echo ""
fi

# Abrir servicios en el navegador
echo "🌐 Abriendo servicios en el navegador..."
echo ""

# 1. Frontend Web
if check_port 3001; then
    open_url "$FRONTEND_URL" "Frontend Web"
fi

# 2. Swagger API Docs
if check_http "${CLOUD_API_URL}/api/v1/health" 5; then
    open_url "$SWAGGER_URL" "Swagger API Docs"
fi

# 3. pgAdmin
if check_port 5050; then
    open_url "$PGADMIN_URL" "pgAdmin"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${CHECK} Servicios abiertos en el navegador${NC}"
echo ""
echo "📱 URLs de los servicios:"
echo "   • Frontend Web:    $FRONTEND_URL"
echo "   • Backend API:     $BACKEND_API_URL"
echo "   • Swagger Docs:    $SWAGGER_URL"
echo "   • pgAdmin:         $PGADMIN_URL"
echo ""
echo "=========================================="
echo ""
