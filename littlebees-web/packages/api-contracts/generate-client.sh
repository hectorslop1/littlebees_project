#!/bin/bash

# Script para generar cliente Dart desde OpenAPI
# Uso: ./generate-client.sh

set -e

OPENAPI_URL="http://216.250.125.239:3002/api/docs-json"

echo "🔍 Verificando que el API esté corriendo..."

# Verificar si el API está disponible
if ! curl -s "$OPENAPI_URL" > /dev/null 2>&1; then
    echo "❌ Error: No fue posible acceder al OpenAPI en $OPENAPI_URL"
    echo ""
    echo "Verifica que el backend de IONOS esté disponible antes de regenerar el cliente."
    exit 1
fi

echo "✅ API detectado en $OPENAPI_URL"
echo ""

echo "📥 Descargando especificación OpenAPI..."
curl -s "$OPENAPI_URL" > openapi.json

if [ ! -s openapi.json ]; then
    echo "❌ Error: No se pudo descargar openapi.json"
    exit 1
fi

echo "✅ OpenAPI spec descargado ($(wc -c < openapi.json) bytes)"
echo ""

echo "🧹 Limpiando cliente anterior..."
rm -rf ../../../littlebees-mobile/lib/generated/api

echo "🔨 Generando cliente Dart..."
pnpm openapi-generator-cli generate

if [ -d "../../../littlebees-mobile/lib/generated/api" ]; then
    echo ""
    echo "✅ Cliente Dart generado exitosamente!"
    echo ""
    echo "📁 Ubicación: littlebees-mobile/lib/generated/api/"
    echo ""
    echo "📝 Próximos pasos:"
    echo "  1. cd ../../../littlebees-mobile"
    echo "  2. flutter pub get"
    echo "  3. Importa el cliente en tu código:"
    echo "     import 'package:littlebees_mobile/generated/api/api.dart';"
    echo ""
else
    echo "❌ Error: No se generó el cliente Dart"
    exit 1
fi
