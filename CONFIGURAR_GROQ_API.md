# 🔑 Configurar GROQ API Key para Asistente IA

El Asistente IA de LittleBees utiliza Groq API con el modelo Llama 3.3 70B. Para que funcione, necesitas configurar tu API Key.

---

## 📝 Paso 1: Obtener API Key de Groq

1. Ve a https://console.groq.com
2. Crea una cuenta o inicia sesión
3. Navega a la sección **API Keys**
4. Click en **Create API Key**
5. Copia la key generada (empieza con `gsk_...`)

---

## ⚙️ Paso 2: Configurar en el Backend

### **Opción A: Archivo .env (Recomendado)**

1. Abre el archivo `.env` en `littlebees-web/apps/api/.env`
2. Agrega la siguiente línea:

```env
GROQ_API_KEY=gsk_tu_api_key_aqui
```

3. Guarda el archivo

### **Opción B: Crear archivo .env desde .env.example**

Si no tienes archivo `.env`, crea uno:

```bash
cd littlebees-web/apps/api
cp .env.example .env
```

Luego edita `.env` y agrega tu API Key.

---

## 🔄 Paso 3: Reiniciar el Servidor Backend

**IMPORTANTE**: Después de agregar la API Key, debes reiniciar el servidor:

```bash
# Detener el servidor (Ctrl+C)
# Luego reiniciar:
cd littlebees-web/apps/api
pnpm run dev
```

---

## ✅ Paso 4: Verificar que Funciona

1. Recarga la página del navegador
2. Ve a `/ai-assistant`
3. Crea una nueva conversación
4. Envía un mensaje (ej: "Hola")
5. Deberías recibir una respuesta del asistente

---

## ⚠️ Solución de Problemas

### **Error: "GROQ_API_KEY not found"**
- Verifica que agregaste la key en el archivo `.env`
- Asegúrate de reiniciar el servidor backend
- Verifica que no haya espacios extra en la línea

### **Error al enviar mensaje**
- Verifica que la API Key sea válida
- Revisa los logs del servidor backend
- Asegúrate de tener créditos en tu cuenta de Groq

### **No aparece respuesta**
- Abre la consola del navegador (F12)
- Revisa los logs del servidor backend
- Verifica tu conexión a internet

---

## 📊 Límites de Groq (Plan Gratuito)

- **Requests por minuto**: 30
- **Requests por día**: 14,400
- **Tokens por minuto**: 6,000

Si necesitas más, considera actualizar tu plan en Groq.

---

## 🔐 Seguridad

- **NUNCA** compartas tu API Key públicamente
- **NO** la subas a repositorios públicos
- Agrega `.env` a tu `.gitignore` (ya está configurado)
- Rota la key periódicamente desde la consola de Groq

---

## 📚 Recursos

- Documentación Groq: https://console.groq.com/docs
- Modelos disponibles: https://console.groq.com/docs/models
- Precios: https://console.groq.com/pricing

---

**Una vez configurado, el Asistente IA estará completamente funcional** ✅
