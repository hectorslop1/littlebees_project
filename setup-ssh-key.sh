#!/bin/bash

# Script para configurar la llave SSH en el servidor IONOS
# Este script debe ejecutarse DESPUÉS de conectarte al servidor

echo "🔑 Configurando llave SSH en el servidor IONOS..."
echo ""
echo "Por favor, ejecuta los siguientes comandos en el servidor:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Conéctate al servidor con contraseña:"
echo "   ssh cbluna@216.250.125.239"
echo ""
echo "2. Una vez dentro del servidor, ejecuta:"
echo ""
cat << 'EOF'
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXkixatf/xPgeKOzjvPLXNZbLJGMWsoocabbEVZmqIp hectoreduardosanchezlopez@littlebees-ionos" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
EOF
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "3. Prueba la conexión SSH (sin contraseña):"
echo "   ssh cbluna@216.250.125.239"
echo ""
echo "Si funciona sin pedir contraseña, ¡estás listo para el deployment!"
echo ""
