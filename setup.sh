#!/bin/bash

# ============================================================================
# LittleBees Project - Automated Setup Script for macOS
# ============================================================================
# Este script automatiza la instalación del entorno de desarrollo
# Para más detalles, consulta SETUP_ENVIRONMENT.md
# ============================================================================

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# INICIO DEL SCRIPT
# ============================================================================

print_header "🐝 LittleBees - Setup Automático"

echo "Este script instalará y configurará:"
echo "  • Homebrew (si no está instalado)"
echo "  • Node.js 20+"
echo "  • pnpm"
echo "  • Docker Desktop (requiere instalación manual)"
echo "  • Flutter SDK"
echo "  • Dart SDK"
echo "  • Dependencias del proyecto"
echo "  • Configuración de Docker"
echo "  • Base de datos y datos de prueba"
echo ""
read -p "¿Continuar con la instalación? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Instalación cancelada."
    exit 1
fi

# ============================================================================
# 1. VERIFICAR/INSTALAR HOMEBREW
# ============================================================================

print_header "1. Verificando Homebrew"

if command_exists brew; then
    print_success "Homebrew ya está instalado"
    brew --version
else
    print_warning "Homebrew no encontrado. Instalando..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Agregar Homebrew al PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    print_success "Homebrew instalado correctamente"
fi

# ============================================================================
# 2. INSTALAR NODE.JS
# ============================================================================

print_header "2. Verificando Node.js"

if command_exists node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js ya está instalado: $NODE_VERSION"
else
    print_warning "Node.js no encontrado. Instalando Node.js 20..."
    brew install node@20
    print_success "Node.js instalado correctamente"
fi

# ============================================================================
# 3. INSTALAR PNPM
# ============================================================================

print_header "3. Verificando pnpm"

if command_exists pnpm; then
    PNPM_VERSION=$(pnpm --version)
    print_success "pnpm ya está instalado: $PNPM_VERSION"
else
    print_warning "pnpm no encontrado. Instalando..."
    npm install -g pnpm@10.12.4
    print_success "pnpm instalado correctamente"
fi

# ============================================================================
# 4. VERIFICAR DOCKER DESKTOP
# ============================================================================

print_header "4. Verificando Docker Desktop"

if command_exists docker; then
    print_success "Docker ya está instalado"
    docker --version
    
    # Verificar si Docker está corriendo
    if docker ps >/dev/null 2>&1; then
        print_success "Docker Desktop está corriendo"
    else
        print_warning "Docker está instalado pero no está corriendo"
        echo "Por favor, abre Docker Desktop desde Applications y espera a que inicie"
        read -p "Presiona Enter cuando Docker esté corriendo..."
    fi
else
    print_error "Docker Desktop no está instalado"
    echo ""
    echo "Por favor, instala Docker Desktop manualmente:"
    echo "1. Ve a https://www.docker.com/products/docker-desktop"
    echo "2. Descarga Docker Desktop para Mac"
    echo "3. Instala y abre Docker Desktop"
    echo "4. Ejecuta este script nuevamente"
    echo ""
    exit 1
fi

# ============================================================================
# 5. INSTALAR FLUTTER
# ============================================================================

print_header "5. Verificando Flutter"

if command_exists flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter ya está instalado: $FLUTTER_VERSION"
else
    print_warning "Flutter no encontrado. Instalando..."
    brew install --cask flutter
    print_success "Flutter instalado correctamente"
fi

# Ejecutar flutter doctor
echo ""
echo "Ejecutando flutter doctor..."
flutter doctor

# ============================================================================
# 6. INSTALAR DART SDK
# ============================================================================

print_header "6. Verificando Dart SDK"

if command_exists dart; then
    DART_VERSION=$(dart --version 2>&1 | head -n 1)
    print_success "Dart SDK ya está instalado: $DART_VERSION"
else
    print_warning "Dart SDK no encontrado. Instalando..."
    brew tap dart-lang/dart
    brew install dart
    print_success "Dart SDK instalado correctamente"
fi

# ============================================================================
# 7. VERIFICAR GIT
# ============================================================================

print_header "7. Verificando Git"

if command_exists git; then
    GIT_VERSION=$(git --version)
    print_success "Git ya está instalado: $GIT_VERSION"
else
    print_warning "Git no encontrado. Instalando..."
    brew install git
    print_success "Git instalado correctamente"
fi

# ============================================================================
# 8. CONFIGURAR PROYECTO
# ============================================================================

print_header "8. Configurando Proyecto"

# Verificar que estamos en el directorio del proyecto
if [ ! -f "package.json" ]; then
    print_error "No se encontró package.json"
    echo "Por favor, ejecuta este script desde la raíz del proyecto littlebees_project"
    exit 1
fi

print_success "Directorio del proyecto verificado"

# ============================================================================
# 9. INSTALAR DEPENDENCIAS
# ============================================================================

print_header "9. Instalando Dependencias del Proyecto"

echo "Instalando dependencias del monorepo..."
pnpm install

echo ""
echo "Construyendo packages compartidos..."
cd littlebees-web
pnpm --filter @kinderspace/shared-types build
pnpm --filter @kinderspace/shared-validators build
cd ..

print_success "Dependencias instaladas correctamente"

# ============================================================================
# 10. INSTALAR DEPENDENCIAS DE FLUTTER
# ============================================================================

print_header "10. Instalando Dependencias de Flutter"

cd littlebees-mobile
flutter pub get
cd ..

print_success "Dependencias de Flutter instaladas"

# ============================================================================
# 11. CONFIGURAR DOCKER
# ============================================================================

print_header "11. Configurando Docker"

echo "Levantando contenedores de Docker..."
pnpm docker:up

echo ""
echo "Esperando a que los contenedores estén listos..."
sleep 10

# Verificar contenedores
if docker ps | grep -q "kinderspace-postgres"; then
    print_success "PostgreSQL está corriendo"
else
    print_error "PostgreSQL no está corriendo"
fi

if docker ps | grep -q "kinderspace-redis"; then
    print_success "Redis está corriendo"
else
    print_error "Redis no está corriendo"
fi

if docker ps | grep -q "kinderspace-minio"; then
    print_success "MinIO está corriendo"
else
    print_error "MinIO no está corriendo"
fi

if docker ps | grep -q "kinderspace-pgadmin"; then
    print_success "pgAdmin está corriendo"
else
    print_error "pgAdmin no está corriendo"
fi

# ============================================================================
# 12. CONFIGURAR BASE DE DATOS
# ============================================================================

print_header "12. Configurando Base de Datos"

echo "Esperando a que PostgreSQL esté listo..."
sleep 5

echo "Ejecutando migraciones de Prisma..."
pnpm db:migrate

echo ""
echo "Cargando datos de prueba..."
pnpm db:seed

print_success "Base de datos configurada correctamente"

# ============================================================================
# RESUMEN FINAL
# ============================================================================

print_header "✅ Instalación Completada"

echo ""
echo "Herramientas instaladas:"
echo "  ✓ Homebrew: $(brew --version | head -n 1)"
echo "  ✓ Node.js: $(node --version)"
echo "  ✓ pnpm: $(pnpm --version)"
echo "  ✓ Docker: $(docker --version | head -n 1)"
echo "  ✓ Flutter: $(flutter --version | head -n 1)"
echo "  ✓ Dart: $(dart --version 2>&1 | head -n 1)"
echo "  ✓ Git: $(git --version)"
echo ""

echo "Servicios Docker corriendo:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep kinderspace

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Próximos pasos:${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "1. Instalar Windsurf IDE:"
echo "   https://codeium.com/windsurf"
echo ""
echo "2. Configurar MCP servers en Windsurf:"
echo "   Consulta SETUP_ENVIRONMENT.md sección 4"
echo ""
echo "3. Iniciar aplicaciones:"
echo "   Terminal 1: pnpm dev:api    # Backend (puerto 3002)"
echo "   Terminal 2: pnpm dev:web    # Frontend (puerto 3001)"
echo "   Terminal 3: pnpm mobile:run # Flutter app"
echo ""
echo "4. Verificar instalación:"
echo "   • API: http://localhost:3002/api/docs"
echo "   • Web: http://localhost:3001"
echo "   • pgAdmin: http://localhost:5050"
echo "   • MinIO: http://localhost:9011"
echo ""
echo "5. Credenciales de prueba:"
echo "   Email: director@petitsoleil.mx"
echo "   Password: Password123!"
echo ""
echo -e "${GREEN}¡Entorno configurado exitosamente! 🚀${NC}"
echo ""
