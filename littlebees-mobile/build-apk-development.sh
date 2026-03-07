#!/bin/bash

# Script para generar APK de desarrollo apuntando a localhost
# Útil para desarrollo y testing local

echo "🔧 Generando APK de Desarrollo para Little Bees"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  NOTA: Este APK requiere que el backend corra en tu computadora"
echo "📍 Servidor: localhost:3002"
echo "🌐 API URL: http://localhost:3002/api/v1"
echo ""

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar APK con localhost (para desarrollo)
echo "🔨 Generando APK..."
flutter build apk \
  --release \
  --dart-define=API_BASE_URL=http://localhost:3002/api/v1 \
  --dart-define=WS_BASE_URL=http://localhost:3002

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK de desarrollo generado exitosamente!"
    echo ""
    echo "📱 Ubicación del APK:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "⚠️  Recuerda:"
    echo "   - El backend debe estar corriendo en tu computadora"
    echo "   - El dispositivo debe estar en la misma red WiFi"
    echo "   - Usa la IP local de tu Mac en lugar de localhost si es necesario"
    echo ""
    
    # Abrir la carpeta donde está el APK
    open build/app/outputs/flutter-apk/
else
    echo ""
    echo "❌ Error al generar el APK"
    echo "Revisa los errores arriba"
    exit 1
fi
