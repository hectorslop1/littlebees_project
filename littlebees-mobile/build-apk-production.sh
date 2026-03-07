#!/bin/bash

# Script para generar APK de producción apuntando al servidor IONOS
# Este APK puede ser compartido con el equipo para testing

echo "🚀 Generando APK de Producción para Little Bees"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Servidor: 216.250.125.239:3002"
echo "🌐 API URL: http://216.250.125.239:3002/api/v1"
echo ""

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar APK con la URL del servidor IONOS
echo "🔨 Generando APK..."
flutter build apk \
  --release \
  --dart-define=API_BASE_URL=http://216.250.125.239:3002/api/v1 \
  --dart-define=WS_BASE_URL=http://216.250.125.239:3002

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK generado exitosamente!"
    echo ""
    echo "📱 Ubicación del APK:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📤 Para compartir con el equipo:"
    echo "   1. Sube el APK a Google Drive, Dropbox, o similar"
    echo "   2. Comparte el link con el equipo"
    echo "   3. El equipo puede instalar directamente en Android"
    echo ""
    echo "🔐 Credenciales de prueba:"
    echo "   - Padre: padre@gmail.com / Password123!"
    echo "   - Madre: madre@gmail.com / Password123!"
    echo "   - Director: director@petitsoleil.mx / Password123!"
    echo ""
    
    # Abrir la carpeta donde está el APK
    open build/app/outputs/flutter-apk/
else
    echo ""
    echo "❌ Error al generar el APK"
    echo "Revisa los errores arriba"
    exit 1
fi
