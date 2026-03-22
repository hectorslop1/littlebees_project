#!/bin/bash

# Script para generar APK de desarrollo apuntando a IONOS
# Útil para probar la app con el backend real en la nube

echo "🔧 Generando APK de Desarrollo para Little Bees"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "☁️  Backend: IONOS"
echo "📍 Servidor: 216.250.125.239:3002"
echo "🌐 API URL: http://216.250.125.239:3002/api/v1"
echo ""

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar APK de desarrollo usando el backend real en la nube
echo "🔨 Generando APK..."
flutter build apk \
  --release \
  --dart-define=API_BASE_URL=http://216.250.125.239:3002/api/v1 \
  --dart-define=WS_BASE_URL=http://216.250.125.239:3002

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK de desarrollo generado exitosamente!"
    echo ""
    echo "📱 Ubicación del APK:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "☁️  Este APK usa directamente el backend de IONOS"
    echo "   - No requiere backend local"
    echo "   - No requiere red local hacia tu Mac"
    echo ""
    
    # Abrir la carpeta donde está el APK
    open build/app/outputs/flutter-apk/
else
    echo ""
    echo "❌ Error al generar el APK"
    echo "Revisa los errores arriba"
    exit 1
fi
