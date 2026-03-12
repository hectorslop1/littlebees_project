#!/bin/bash

# 🔄 Sincronizar Base de Datos Local → IONOS
# Este script exporta tu BD local y la restaura en el servidor IONOS

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Símbolos
CHECK="✓"
CROSS="✗"
ARROW="→"

echo ""
echo "🔄 =========================================="
echo "   Sincronización BD Local → IONOS"
echo "=========================================="
echo ""

# Configuración local
LOCAL_CONTAINER="kinderspace-postgres"
LOCAL_DB="kinderspace_dev"
LOCAL_USER="kinderspace"
LOCAL_PORT="5437"

# Configuración servidor IONOS
SERVER_IP="216.250.125.239"
SERVER_USER="cbluna"
REMOTE_DIR="/home/cbluna/littlebees_project"
REMOTE_CONTAINER="littlebees-postgres"

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

# Archivo temporal para el backup
BACKUP_FILE="db_backup_$(date +%Y%m%d_%H%M%S).sql"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 1. Verificando BD Local..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar que el contenedor local esté corriendo
if ! docker ps | grep -q "$LOCAL_CONTAINER"; then
    echo -e "${RED}${CROSS}${NC} Contenedor PostgreSQL local no está corriendo"
    echo -e "${YELLOW}${ARROW}${NC} Ejecuta: pnpm docker:up"
    exit 1
fi

echo -e "${GREEN}${CHECK}${NC} Contenedor PostgreSQL local está corriendo"

# Contar registros en la BD local
echo -e "${BLUE}${ARROW}${NC} Verificando datos en BD local..."
TABLES_COUNT=$(docker exec $LOCAL_CONTAINER psql -U $LOCAL_USER -d $LOCAL_DB -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)
echo -e "${GREEN}${CHECK}${NC} BD local tiene ${TABLES_COUNT} tablas"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 2. Exportando BD Local..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Creando backup de la base de datos..."
docker exec $LOCAL_CONTAINER pg_dump -U $LOCAL_USER -d $LOCAL_DB --clean --if-exists > "$BACKUP_FILE"

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}${CHECK}${NC} Backup creado: ${BACKUP_FILE} (${BACKUP_SIZE})"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 3. Verificando Conexión a IONOS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar llave SSH
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}${CROSS}${NC} Llave SSH no encontrada: $SSH_KEY"
    rm "$BACKUP_FILE"
    exit 1
fi

chmod 600 "$SSH_KEY"

# Probar conexión
if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "${SERVER_USER}@${SERVER_IP}" "echo 'OK'" > /dev/null 2>&1; then
    echo -e "${GREEN}${CHECK}${NC} Conexión SSH establecida"
else
    echo -e "${RED}${CROSS}${NC} No se pudo conectar al servidor"
    rm "$BACKUP_FILE"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 4. Subiendo Backup a IONOS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Copiando archivo al servidor..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$BACKUP_FILE" "${SERVER_USER}@${SERVER_IP}:/tmp/"
echo -e "${GREEN}${CHECK}${NC} Backup subido al servidor"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  5. Confirmación Requerida"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${YELLOW}⚠️  ADVERTENCIA:${NC}"
echo "   Esta operación va a:"
echo "   1. Eliminar TODOS los datos actuales en IONOS"
echo "   2. Restaurar con los datos de tu BD local"
echo ""
echo -e "${YELLOW}   ¿Estás seguro de continuar? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}${ARROW}${NC} Operación cancelada"
    rm "$BACKUP_FILE"
    ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "rm /tmp/$BACKUP_FILE"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗄️  6. Restaurando BD en IONOS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${BLUE}${ARROW}${NC} Verificando contenedor PostgreSQL en IONOS..."
REMOTE_POSTGRES_RUNNING=$(ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "docker ps --filter name=${REMOTE_CONTAINER} --format '{{.Names}}'" || echo "")

if [ -z "$REMOTE_POSTGRES_RUNNING" ]; then
    echo -e "${YELLOW}⚠${NC}  PostgreSQL no está corriendo en IONOS"
    echo -e "${BLUE}${ARROW}${NC} Iniciando PostgreSQL..."
    ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "cd ${REMOTE_DIR} && docker compose -f docker-compose.prod.yml up -d postgres"
    sleep 10
fi

echo -e "${GREEN}${CHECK}${NC} PostgreSQL corriendo en IONOS"

echo -e "${BLUE}${ARROW}${NC} Restaurando backup en la base de datos..."
ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "docker exec -i ${REMOTE_CONTAINER} psql -U kinderspace -d kinderspace_dev < /tmp/${BACKUP_FILE}"

echo -e "${GREEN}${CHECK}${NC} Base de datos restaurada exitosamente"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 7. Verificando Sincronización..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar tablas en IONOS
REMOTE_TABLES_COUNT=$(ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "docker exec ${REMOTE_CONTAINER} psql -U kinderspace -d kinderspace_dev -t -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';\"" | xargs)

echo -e "${GREEN}${CHECK}${NC} BD en IONOS tiene ${REMOTE_TABLES_COUNT} tablas"

if [ "$TABLES_COUNT" = "$REMOTE_TABLES_COUNT" ]; then
    echo -e "${GREEN}${CHECK}${NC} Número de tablas coincide (${TABLES_COUNT} tablas)"
else
    echo -e "${YELLOW}⚠${NC}  Advertencia: Número de tablas diferente (Local: ${TABLES_COUNT}, IONOS: ${REMOTE_TABLES_COUNT})"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 8. Limpieza..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Limpiar archivos temporales
rm "$BACKUP_FILE"
ssh -i "$SSH_KEY" "${SERVER_USER}@${SERVER_IP}" "rm /tmp/$BACKUP_FILE"
echo -e "${GREEN}${CHECK}${NC} Archivos temporales eliminados"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ ¡Sincronización Completada!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Resumen:"
echo "   • BD Local:  ${TABLES_COUNT} tablas"
echo "   • BD IONOS:  ${REMOTE_TABLES_COUNT} tablas"
echo "   • Backup:    ${BACKUP_SIZE}"
echo ""
echo "🌐 Verifica tu aplicación en:"
echo "   • Frontend: http://${SERVER_IP}:3000"
echo "   • Backend:  http://${SERVER_IP}:3002/api/docs"
echo ""
echo "=========================================="
echo ""
