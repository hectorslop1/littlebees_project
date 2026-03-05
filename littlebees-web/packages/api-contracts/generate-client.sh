#!/bin/bash

# Script para generar cliente Dart desde OpenAPI
# Uso: ./generate-client.sh

set -e

echo "🔍 Verificando que el API esté corriendo..."

# Verificar si el API está disponible
if ! curl -s http://localhost:3002/api/docs-json > /dev/null 2>&1; then
    echo "❌ Error: El API no está corriendo en http://localhost:3002"
    echo ""
    echo "Por favor, inicia el API primero:"
    echo "  cd ../../apps/api"
    echo "  pnpm dev"
    echo ""
    echo "O desde la raíz del monorepo:"
    echo "  pnpm dev:api"
    exit 1
fi

echo "✅ API detectado en http://localhost:3002"
echo ""

echo "📥 Descargando especificación OpenAPI..."
curl -s http://localhost:3002/api/docs-json > openapi.json

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
