# 🐝 LittleBees — Guía de Arquitectura del Sistema

## Descripción General

LittleBees es una plataforma digital para guarderías y kinders en México que permite la comunicación y gestión entre padres, maestras y administración escolar.

El sistema está compuesto por dos aplicaciones que comparten la misma base de datos:

### 📱 App Móvil (Flutter)
Usuarios principales:
- Padres de familia
- Maestras

Propósito:
- Uso diario
- Comunicación rápida
- Registro de actividades
- Seguimiento del niño

Plataformas:
- iOS
- Android

---

### 💻 App Web (Next.js)

Usuarios principales:
- Maestras
- Directora
- Administradores

Propósito:
- Gestión administrativa
- Control del sistema
- Reportes
- Gestión de usuarios
- Configuración del sistema

---

# Roles del Sistema

El sistema tiene 4 roles principales.

## 👨‍👩‍👧 Padre

Acceso:
- App móvil

Permisos:
- Solo información de sus hijos

Funciones principales:
- Ver actividades del día
- Recibir notificaciones
- Ver fotos del niño
- Comunicarse con maestras
- Ver pagos
- Ver reportes
- Enviar justificantes
- Usar asistente IA

---

## 👩‍🏫 Maestra

Acceso:
- App móvil
- App web

Permisos:
- Solo información de sus grupos

Funciones principales:
- Registrar actividades del día
- Marcar asistencias
- Registrar comidas
- Registrar siestas
- Subir fotos (entrada y salida)
- Comunicarse con padres
- Ver perfiles de alumnos
- Generar reportes
- Usar asistente IA

---

## 👩‍💼 Directora

Acceso:
- App web

Permisos:
- Supervisión general de la guardería

Funciones principales:
- Ver todos los alumnos
- Ver maestras
- Ver reportes globales
- Revisar pagos
- Gestionar grupos
- Comunicarse con padres
- Supervisar actividades

No puede:
- Cambiar personalización visual del sistema

---

## ⚙️ Administrador

Acceso:
- App web

Permisos:
- Control total del sistema

Funciones principales:
- Gestión de usuarios
- Gestión de alumnos
- Gestión de grupos
- Configuración del sistema
- Reportes financieros
- Personalización del sistema
- Administración completa

---

# App Móvil — Menú Padre

Menú principal:

- Inicio
- Día
- Calendario
- Mensajes
- Pagos
- Perfil del Niño
- Justificantes
- Asistente IA

---

## Inicio

Resumen rápido del niño:

- Foto del niño
- Estado del día
- Actividades recientes
- Notificaciones

---

## Día

Planeación del día del niño.

Ejemplo:

Entrada  
Actividad educativa  
Recreo  
Comida  
Siesta  
Actividad  
Salida  

---

## Calendario

Eventos generales:

- Festivos
- Eventos escolares
- Actividades especiales

---

## Mensajes

Chat con maestras.

Características:

- Chat separado por clase
- Aviso automático fuera de horario
- Opción de escalar conversación a dirección

---

## Pagos

Información financiera:

- Mensualidades
- Historial de pagos
- Estado de cuenta

---

## Perfil del Niño

Información importante del alumno.

Campos importantes:

- Nombre
- Edad
- Foto
- Alergias
- Tipo de sangre
- Contactos de emergencia
- Diagnóstico (si aplica)
- Notas médicas

---

## Justificantes

Padres pueden enviar:

- Avisos
- Fotos
- Notas

Ejemplos:

- El niño está enfermo
- Llegará tarde
- No asistirá hoy

---

## Asistente IA

Permite a los padres:

- Obtener consejos educativos
- Recibir ideas de actividades
- Preguntar dudas sobre desarrollo infantil
- Obtener recomendaciones para el hogar

---

# App Móvil — Menú Maestra

Menú principal:

- Inicio
- Grupos
- Día
- Registrar Actividad
- Mensajes
- Perfil de Alumno
- Asistente IA

---

## Inicio

Resumen del día:

- alumnos presentes
- actividades programadas
- mensajes

---

## Grupos

Lista de grupos asignados.

Ejemplo:

Maternal A  
Preescolar 1  
Preescolar 2  

---

## Día

Ver programación del día para el grupo.

---

## Registrar Actividad

Acciones rápidas:

- Registrar entrada
- Registrar comida
- Registrar siesta
- Registrar actividad
- Registrar salida

Fotos solo en:

- Entrada
- Salida

---

## Perfil de Alumno

Información rápida del niño:

- Foto
- Alergias
- Tipo de sangre
- Contactos de emergencia
- Notas importantes

---

## Mensajes

Chat con padres de sus alumnos.

---

## Asistente IA

Opciones sugeridas:

- Ideas de actividades
- Planear clase
- Manejo de comportamiento
- Crear reporte del día
- Preguntar a la IA

---

# App Web — Menú Maestra

- Dashboard
- Mis Grupos
- Alumnos
- Actividades
- Reportes
- Mensajes
- Asistente IA
- Perfil

---

# App Web — Menú Directora

- Dashboard
- Grupos
- Alumnos
- Maestras
- Reportes
- Pagos
- Mensajes
- Configuración
- Asistente IA

---

# App Web — Menú Administrador

- Dashboard
- Usuarios
- Grupos
- Alumnos
- Pagos
- Reportes
- Configuración
- Personalización
- Asistente IA

---

# Personalización del Sistema

Solo disponible para Administrador.

Opciones:

- Cambiar logo
- Cambiar colores del tema
- Cambiar nombre de menús
- Configurar branding del sistema

Los cambios deben ser persistentes en base de datos.

---

# Asistente IA del Sistema

El sistema incluye un chatbot integrado en ambas aplicaciones.

Ubicación:

- Botón flotante
- Abre una interfaz tipo chat

El chatbot también debe mostrar **acciones rápidas** además de permitir escribir.

Ejemplo:

Acciones rápidas:

- Actividades educativas
- Ideas para clase
- Consejos para padres
- Crear reporte
- Preguntar algo

---

# Uso de IA

La IA funciona como asistente educativo y administrativo.

Funciones por rol:

Padres:
- Consejos educativos
- Actividades para el hogar
- Desarrollo infantil

Maestras:
- Ideas de actividades
- Planeación de clases
- Manejo de comportamiento
- Generación de reportes

Directora:
- Redacción de comunicados
- Recomendaciones educativas

Administrador:
- Redacción de avisos
- Apoyo administrativo

---

# Reglas del Sistema

## Roles estrictos

Cada usuario solo puede ver información acorde a su rol.

---

## Privacidad de datos

Información médica solo visible para:

- maestras
- dirección

---

## Fotos del día

Para reducir carga de trabajo:

solo se requieren fotos en:

- entrada
- salida

---

# Regla de Desarrollo — Base de Datos (LittleBees)

Cuando se implemente cualquier nueva funcionalidad en el sistema LittleBees (App Móvil Flutter o App Web Next.js), se debe cumplir la siguiente regla obligatoria:

1. Analizar qué datos necesita la nueva funcionalidad para funcionar correctamente.

2. Verificar si esos datos ya existen en la base de datos actual.

3. Si los campos, tablas o relaciones NO existen en la base de datos:

   - Crear las nuevas tablas necesarias.
   - Crear los nuevos campos requeridos.
   - Crear relaciones (foreign keys) si aplica.
   - Definir tipos de datos correctos.
   - Agregar valores por defecto cuando sea necesario.

4. Las modificaciones deben incluir:

   - Migración de base de datos.
   - Actualización del modelo de datos.
   - Actualización de API o endpoints que consumen esos datos.

5. Nunca asumir que un campo existe en la base de datos.
   Siempre validar y, si falta, crearlo.

6. Todas las nuevas estructuras de datos deben:

   - Mantener consistencia con el esquema existente.
   - Seguir buenas prácticas de normalización.
   - Tener nombres claros y en inglés.

7. Si una nueva funcionalidad requiere datos iniciales (por ejemplo configuraciones, estados, tipos o categorías):

   - Insertar registros iniciales (seed data) automáticamente en la base de datos.

8. Evitar soluciones temporales en frontend.
   Todos los datos deben almacenarse correctamente en la base de datos.

Objetivo:
Garantizar que cada funcionalidad del sistema tenga soporte completo en la base de datos y evitar errores por datos inexistentes.

# Modelo de IA del Sistema

El sistema LittleBees utiliza un modelo de lenguaje para ofrecer asistencia educativa y administrativa dentro de la aplicación.

## Modelo seleccionado

Llama 3 8B

Proveedor de inferencia:
Groq

Razones de elección:

- Uso gratuito o de muy bajo costo
- Alta velocidad de respuesta
- Ideal para chatbots y asistentes
- Suficiente capacidad para generar recomendaciones educativas
- Fácil integración vía API

---

## Casos de uso de la IA dentro del sistema

La IA funciona como un asistente dentro de ambas aplicaciones (App Móvil y App Web).

### Para Padres

La IA puede ayudar con:

- Consejos de desarrollo infantil
- Actividades educativas para casa
- Juegos para niños según edad
- Recomendaciones de aprendizaje
- Responder preguntas generales sobre crianza

---

### Para Maestras

La IA puede ayudar con:

- Ideas de actividades educativas
- Planeación de clases
- Manejo de comportamiento infantil
- Creación de reportes para padres
- Sugerencias de dinámicas de grupo

---

### Para Directora

La IA puede ayudar con:

- Redacción de comunicados para padres
- Sugerencias pedagógicas
- Ideas para mejorar procesos educativos

---

### Para Administrador

La IA puede ayudar con:

- Redacción de avisos generales
- Generación de mensajes administrativos
- Asistencia general del sistema

---

## Interfaz del chatbot

El chatbot debe estar disponible en ambas aplicaciones mediante un botón flotante.

Al abrirse debe mostrar:

1. Acciones rápidas (botones predefinidos)
2. Campo de chat libre

Ejemplo de acciones rápidas:

- Actividades educativas
- Ideas para clase
- Consejos para padres
- Crear reporte
- Preguntar algo

---

## Reglas de uso de IA

La IA debe:

- Responder de forma clara y corta
- Adaptarse al rol del usuario
- Evitar respuestas médicas o diagnósticos profesionales
- Enfocarse en educación infantil y apoyo pedagógico
