# 🆕 Primera Vez en Nueva Mac - Guía Rápida

**Instrucciones exactas para configurar LittleBees en una MacBook Pro nueva**

---

## 🎯 Tu Flujo de Trabajo

### **Paso 1: Instalaciones Manuales Básicas**

#### **1.1. Instalar Docker Desktop**
1. Ve a https://www.docker.com/products/docker-desktop
2. Descarga Docker Desktop para Mac (Apple Silicon o Intel)
3. Instala y abre Docker Desktop
4. Espera a que el ícono de Docker en la barra de menú muestre "running"

#### **1.2. Instalar Windsurf IDE**
1. Ve a https://codeium.com/windsurf
2. Descarga Windsurf para macOS
3. Instala y abre Windsurf
4. Inicia sesión con tu cuenta de Codeium

---

### **Paso 2: Configurar MCP en Windsurf**

#### **2.1. Instalar MCP desde Marketplace**

En Windsurf:
1. Abre la sección de **MCP** (Model Context Protocol)
2. Ve al **Marketplace**
3. Instala los siguientes MCP:
   - ✅ **Context7**
   - ✅ **GitHub**
   - ✅ **Chrome DevTools**
   - ✅ **Vercel**

#### **2.2. Verificar Instalación de MCP**
- Los MCP instalados deberían aparecer en la barra lateral de MCP
- Si no aparecen, reinicia Windsurf

---

### **Paso 3: Abrir Chat con Cascade**

Una vez que hayas completado los pasos 1 y 2:

#### **3.1. Abrir Windsurf**
```bash
# Si ya tienes el proyecto clonado
cd ~/Desktop/Proyectos/littlebees_project
open -a Windsurf .

# Si NO tienes el proyecto clonado aún
# Solo abre Windsurf normalmente
```

#### **3.2. Iniciar Nuevo Chat**
- Click en "New Chat" o "Nuevo Chat"
- **NO** intentes continuar conversaciones anteriores

#### **3.3. Mensaje Exacto para Cascade**

Copia y pega esto en el chat:

```
Hola Claude, estoy configurando el proyecto LittleBees en una 
MacBook Pro nueva.

Ya completé:
✅ Instalé Docker Desktop (está corriendo)
✅ Instalé Windsurf
✅ Instalé MCP desde marketplace: Context7, GitHub, Chrome DevTools, Vercel

Ahora necesito que me ayudes a:
1. Configurar los MCP servers manuales (dart, docker, postgres)
2. Clonar el repositorio del proyecto
3. Ejecutar el script de setup automático (setup.sh)
4. Verificar que todo esté funcionando correctamente

¿Por dónde empezamos?
```

---

### **Paso 4: Seguir Instrucciones de Cascade**

Cascade te guiará para:

1. **Configurar MCP servers manuales:**
   - dart-mcp-server
   - docker MCP
   - postgres MCP

2. **Clonar el proyecto:**
   ```bash
   git clone <URL_REPO> littlebees_project
   ```

3. **Ejecutar setup automático:**
   ```bash
   cd littlebees_project
   ./setup.sh
   ```

4. **Verificar instalación:**
   - Servicios Docker
   - Base de datos
   - Aplicaciones corriendo

---

## 📋 Checklist Pre-Chat

Antes de abrir el chat con Cascade, verifica:

- [ ] Docker Desktop instalado y corriendo
- [ ] Windsurf instalado
- [ ] MCP desde marketplace instalados (Context7, GitHub, Chrome DevTools, Vercel)
- [ ] Tienes acceso al repositorio del proyecto

---

## 🎯 Lo Que Cascade Hará Por Ti

Una vez que le digas que ya completaste las instalaciones manuales, Cascade:

1. ✅ Te ayudará a configurar los MCP servers manuales
2. ✅ Te guiará para clonar el proyecto
3. ✅ Ejecutará o te ayudará a ejecutar `setup.sh`
4. ✅ Instalará todas las herramientas necesarias (Node.js, pnpm, Flutter, Dart)
5. ✅ Configurará Docker y la base de datos
6. ✅ Verificará que todo esté funcionando
7. ✅ Te ayudará a iniciar las aplicaciones

---

## 🚫 Lo Que NO Debes Hacer

❌ **NO** intentes configurar todo manualmente antes de hablar con Cascade  
❌ **NO** ejecutes comandos sin entender qué hacen  
❌ **NO** copies configuraciones de la otra Mac sin verificar  
❌ **NO** intentes "transferir" conversaciones anteriores  

---

## ✅ Lo Que SÍ Debes Hacer

✅ **SÍ** instala Docker Desktop y Windsurf primero  
✅ **SÍ** instala los MCP desde marketplace  
✅ **SÍ** inicia un nuevo chat limpio  
✅ **SÍ** dile a Cascade exactamente qué ya hiciste  
✅ **SÍ** sigue las instrucciones de Cascade paso a paso  

---

## 🔄 Flujo Visual

```
┌─────────────────────────────────────────┐
│ 1. Instalar Docker Desktop             │
│    https://docker.com                   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 2. Instalar Windsurf                    │
│    https://codeium.com/windsurf         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 3. Instalar MCP desde Marketplace       │
│    • Context7                           │
│    • GitHub                             │
│    • Chrome DevTools                    │
│    • Vercel                             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 4. Abrir Windsurf → Nuevo Chat         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 5. Pegar mensaje para Cascade          │
│    (Ver sección 3.3 arriba)            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 6. Seguir instrucciones de Cascade     │
│    • Configurar MCP manuales           │
│    • Clonar proyecto                   │
│    • Ejecutar setup.sh                 │
│    • Verificar instalación             │
└─────────────────────────────────────────┘
```

---

## ⏱️ Tiempo Estimado

| Tarea | Tiempo |
|-------|--------|
| Instalar Docker Desktop | 5 min |
| Instalar Windsurf | 3 min |
| Instalar MCP marketplace | 2 min |
| Chat con Cascade + Setup | 30-45 min |
| **Total** | **40-55 min** |

---

## 💡 Tips Importantes

### **Tip 1: Docker Desktop Debe Estar Corriendo**
Antes de hablar con Cascade, asegúrate de que Docker Desktop esté completamente iniciado. Verifica el ícono en la barra de menú.

### **Tip 2: Nuevo Chat Siempre**
Cada nueva máquina = nuevo chat. No intentes continuar conversaciones de otras máquinas.

### **Tip 3: Sé Específico**
Dile a Cascade exactamente qué ya hiciste. Esto ahorra tiempo y evita confusiones.

### **Tip 4: Confía en el Proceso**
El script `setup.sh` automatiza casi todo. Deja que Cascade te guíe.

### **Tip 5: Guarda las Credenciales**
```
Email: director@petitsoleil.mx
Password: Password123!
```

---

## 🆘 Si Algo Sale Mal

Si encuentras problemas durante el setup:

1. **Dile a Cascade exactamente qué error ves**
   - Copia el mensaje de error completo
   - Menciona en qué paso estabas

2. **Verifica lo básico:**
   ```bash
   docker --version    # ¿Docker instalado?
   docker ps           # ¿Docker corriendo?
   ```

3. **Consulta la documentación:**
   - `SETUP_ENVIRONMENT.md` - Guía completa
   - `QUICK_SETUP_CHECKLIST.md` - Checklist rápido

4. **Reinicia si es necesario:**
   - Reinicia Docker Desktop
   - Reinicia Windsurf
   - Reinicia la terminal

---

## 📚 Documentación Relacionada

- **SETUP_ENVIRONMENT.md** - Guía completa paso a paso
- **QUICK_SETUP_CHECKLIST.md** - Checklist de 20 pasos
- **setup.sh** - Script de automatización
- **.windsurf/mcp_settings.example.json** - Configuración MCP

---

## ✅ Verificación Final

Cuando Cascade termine de ayudarte, deberías poder:

- [ ] Ver 4 contenedores Docker corriendo (`docker ps`)
- [ ] Abrir http://localhost:3002/api/docs (API)
- [ ] Abrir http://localhost:3001 (Web App)
- [ ] Hacer login con `director@petitsoleil.mx` / `Password123!`
- [ ] Ver el dashboard funcionando

---

**¡Listo para configurar tu nueva Mac! 🚀**

**Recuerda:** Docker Desktop + Windsurf + MCP Marketplace → Nuevo Chat con Cascade
