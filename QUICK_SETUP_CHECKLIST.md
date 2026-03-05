# ⚡ Quick Setup Checklist

**Configuración rápida del entorno LittleBees en macOS**

---

## 📋 Checklist de Instalación

### **Opción A: Instalación Automática (Recomendado)**

```bash
# 1. Clonar el proyecto
git clone <URL_REPO> littlebees_project
cd littlebees_project

# 2. Ejecutar script de setup
./setup.sh

# 3. Instalar Windsurf manualmente
# Descargar de: https://codeium.com/windsurf

# 4. Configurar MCP servers en Windsurf
# Ver sección "Configuración Manual" abajo
```

---

### **Opción B: Instalación Manual Paso a Paso**

#### **Pre-requisitos (Instalar en orden)**

- [ ] **1. Instalar Homebrew**
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- [ ] **2. Instalar Node.js 20+**
  ```bash
  brew install node@20
  ```

- [ ] **3. Instalar pnpm**
  ```bash
  npm install -g pnpm@10.12.4
  ```

- [ ] **4. Instalar Docker Desktop**
  - Descargar: https://www.docker.com/products/docker-desktop
  - Instalar y abrir Docker Desktop

- [ ] **5. Instalar Flutter**
  ```bash
  brew install --cask flutter
  flutter doctor
  ```

- [ ] **6. Instalar Dart SDK**
  ```bash
  brew tap dart-lang/dart
  brew install dart
  ```

- [ ] **7. Instalar Windsurf IDE**
  - Descargar: https://codeium.com/windsurf
  - Instalar y abrir Windsurf

---

#### **Configuración del Proyecto**

- [ ] **8. Clonar repositorio**
  ```bash
  mkdir -p ~/Desktop/Proyectos
  cd ~/Desktop/Proyectos
  git clone <URL_REPO> littlebees_project
  cd littlebees_project
  ```

- [ ] **9. Instalar dependencias**
  ```bash
  pnpm install
  cd littlebees-web
  pnpm --filter @kinderspace/shared-types build
  pnpm --filter @kinderspace/shared-validators build
  cd ..
  ```

- [ ] **10. Instalar dependencias Flutter**
  ```bash
  cd littlebees-mobile
  flutter pub get
  cd ..
  ```

---

#### **Configuración de Docker**

- [ ] **11. Levantar contenedores**
  ```bash
  pnpm docker:up
  ```

- [ ] **12. Verificar contenedores**
  ```bash
  docker ps
  # Deberías ver: postgres, redis, minio, pgadmin
  ```

---

#### **Configuración de Base de Datos**

- [ ] **13. Ejecutar migraciones**
  ```bash
  pnpm db:migrate
  ```

- [ ] **14. Cargar datos de prueba**
  ```bash
  pnpm db:seed
  ```

---

#### **Configuración de MCP Servers en Windsurf**

- [ ] **15. Instalar MCP desde Marketplace**
  - Abrir Windsurf → MCP → Marketplace
  - Instalar: Context7, GitHub, Chrome DevTools, Vercel

- [ ] **16. Configurar MCP servers manualmente**
  
  **Ubicación del archivo:**
  ```
  ~/Library/Application Support/Windsurf/User/globalStorage/codeium.windsurf/mcp/mcp_settings.json
  ```
  
  **Contenido:**
  ```json
  {
    "mcpServers": {
      "dart-mcp-server": {
        "command": "dart",
        "args": ["mcp-server"],
        "env": {}
      },
      "docker": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-docker"],
        "env": {}
      },
      "postgres": {
        "command": "npx",
        "args": [
          "-y",
          "@modelcontextprotocol/server-postgres",
          "postgresql://kinderspace:kinderspace@localhost:5437/kinderspace_dev"
        ],
        "env": {}
      }
    }
  }
  ```

- [ ] **17. Reiniciar Windsurf**

---

#### **Iniciar Aplicaciones**

- [ ] **18. Iniciar Backend API**
  ```bash
  # Terminal 1
  pnpm dev:api
  # Espera: "KinderSpace API running on http://localhost:3002"
  ```

- [ ] **19. Iniciar Web App**
  ```bash
  # Terminal 2
  pnpm dev:web
  # Espera: "✓ Ready in X.Xs"
  ```

- [ ] **20. Iniciar App Móvil (opcional)**
  ```bash
  # Terminal 3
  pnpm mobile:run
  # O: cd littlebees-mobile && flutter run
  ```

---

## ✅ Verificación Final

### **URLs a verificar:**

- [ ] **API Backend:** http://localhost:3002/api/docs
- [ ] **Web App:** http://localhost:3001
- [ ] **pgAdmin:** http://localhost:5050
- [ ] **MinIO Console:** http://localhost:9011

### **Test de Login:**

- [ ] Abrir http://localhost:3001/login
- [ ] Click en "María González (Directora)"
- [ ] Click en "Iniciar Sesión"
- [ ] Verificar redirección al dashboard

### **Credenciales de Prueba:**

```
Email: director@petitsoleil.mx
Password: Password123!
```

---

## 🔧 Comandos de Verificación Rápida

```bash
# Verificar herramientas instaladas
node --version          # v20.x.x
pnpm --version          # 10.12.4
docker --version        # Docker version 24.x.x
flutter --version       # Flutter 3.11.x
dart --version          # Dart 3.11.x

# Verificar servicios Docker
docker ps               # 4 contenedores corriendo

# Verificar proyecto
cd ~/Desktop/Proyectos/littlebees_project
ls -la                  # Ver estructura del proyecto
```

---

## 🚨 Problemas Comunes

| Problema | Solución Rápida |
|----------|-----------------|
| `command not found: pnpm` | `npm install -g pnpm@10.12.4` |
| Docker no corre | Abrir Docker Desktop desde Applications |
| Puerto ocupado | `lsof -ti:PUERTO \| xargs kill -9` |
| MCP no aparece | Reiniciar Windsurf completamente |
| Migraciones fallan | `pnpm docker:down && pnpm docker:up` |

**Documentación completa:** `SETUP_ENVIRONMENT.md`

---

## 📊 Tiempo Estimado

| Tarea | Tiempo |
|-------|--------|
| Instalación de herramientas | 20-30 min |
| Configuración del proyecto | 10-15 min |
| Configuración de Docker/DB | 5-10 min |
| Configuración de Windsurf/MCP | 5-10 min |
| **Total** | **40-65 min** |

---

## 🎯 Siguiente Paso

Una vez completado el checklist:

1. ✅ Lee `README.md` para entender el proyecto
2. ✅ Revisa `ESTRUCTURA_MULTIREPO.md` para la arquitectura
3. ✅ Explora el código en Windsurf
4. ✅ ¡Comienza a desarrollar!

---

**¿Problemas? Consulta `SETUP_ENVIRONMENT.md` para instrucciones detalladas.**
