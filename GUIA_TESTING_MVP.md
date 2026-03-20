# 🧪 GUÍA DE TESTING - MVP LITTLEBEES

**Fecha**: 19 de Marzo, 2026  
**Versión**: 1.0  
**Objetivo**: Validar funcionalidad end-to-end del sistema

---

## 📋 PREREQUISITOS

### Backend
```bash
cd littlebees-web/apps/api
npm install
npm run start:dev
```

**Variables de entorno requeridas** (`.env`):
```env
DATABASE_URL="postgresql://user:password@host:5432/littlebees"
JWT_SECRET="your-secret-key"
JWT_REFRESH_SECRET="your-refresh-secret"

# MinIO/S3 para archivos
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=kinderspace
MINIO_SECRET_KEY=kinderspace123
MINIO_BUCKET=kinderspace-files
```

### App Móvil
```bash
cd littlebees-mobile
flutter pub get
flutter run
```

**Permisos iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de entrada/salida</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a la galería para seleccionar fotos</string>
```

**Permisos Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## 👥 USUARIOS DE PRUEBA

### 1. Super Admin
```
Email: admin@littlebees.com
Password: admin123
Rol: super_admin
```

### 2. Directora
```
Email: directora@littlebees.com
Password: directora123
Rol: director
```

### 3. Maestra
```
Email: maestra@littlebees.com
Password: maestra123
Rol: teacher
```

### 4. Padre/Madre
```
Email: padre@littlebees.com
Password: padre123
Rol: parent
```

---

## 🧪 CASOS DE PRUEBA

### TEST 1: Autenticación y Diferenciación de Roles ✅

**Objetivo**: Verificar que cada rol ve la interfaz correcta

**Pasos**:
1. Abrir app móvil
2. Iniciar sesión como **maestra**
3. Verificar que se muestra `TeacherHomeScreen` con:
   - Saludo personalizado
   - 4 acciones rápidas
   - Lista de grupos asignados
4. Cerrar sesión
5. Iniciar sesión como **padre**
6. Verificar que se muestra `HomeScreen` de padres con:
   - Lista de hijos
   - Timeline de actividades

**Resultado Esperado**: ✅ Interfaces diferentes por rol

---

### TEST 2: Registro de Actividades (Maestra) ✅

**Objetivo**: Validar registro completo de actividades con persistencia en BD

**Pasos**:
1. Iniciar sesión como **maestra**
2. Tap en "Registrar Actividad" desde home
3. Seleccionar un niño
4. **Probar cada tipo de actividad**:

#### A. Entrada (Check-in)
- Seleccionar tipo "Entrada"
- Tap en área de foto
- Tomar foto con cámara
- Verificar que foto se sube (ver progreso)
- Seleccionar estado de ánimo (ej: 😊 Feliz)
- Agregar notas: "Llegó contento"
- Tap "Registrar Entrada"
- **Verificar**: Mensaje de éxito

#### B. Comida
- Seleccionar tipo "Comida"
- Ingresar: "Todo"
- Agregar notas: "Comió muy bien"
- Tap "Registrar Comida"
- **Verificar**: Mensaje de éxito

#### C. Siesta
- Seleccionar tipo "Siesta"
- Ingresar duración: "60" minutos
- Tap "Registrar Siesta"
- **Verificar**: Mensaje de éxito

#### D. Actividad
- Seleccionar tipo "Actividad"
- Ingresar descripción: "Pintura con acuarelas"
- Tap "Registrar Actividad"
- **Verificar**: Mensaje de éxito

#### E. Salida (Check-out)
- Seleccionar tipo "Salida"
- Tomar foto
- Tap "Registrar Salida"
- **Verificar**: Mensaje de éxito

**Validación en BD**:
```sql
-- Verificar en PostgreSQL
SELECT * FROM daily_log_entries 
WHERE child_id = 'xxx' 
AND date = CURRENT_DATE 
ORDER BY created_at DESC;

-- Verificar asistencia
SELECT * FROM attendance_records 
WHERE child_id = 'xxx' 
AND date = CURRENT_DATE;

-- Verificar fotos subidas
SELECT * FROM files 
WHERE purpose = 'attendance_photo' 
ORDER BY created_at DESC 
LIMIT 5;
```

**Resultado Esperado**: ✅ Todos los registros en BD con datos reales

---

### TEST 3: Justificantes - Flujo Completo (Padre → Maestra) ✅

**Objetivo**: Validar creación, listado y aprobación de justificantes

#### Parte 1: Creación (Padre)
1. Iniciar sesión como **padre**
2. Ir a pantalla de justificantes (agregar ruta en router)
3. Tap en botón "Nuevo"
4. Llenar formulario:
   - Niño: Seleccionar hijo
   - Tipo: "Enfermedad"
   - Fecha: Mañana
   - Título: "Consulta médica"
   - Descripción: "Cita con pediatra a las 10am"
5. Tap "Enviar Justificante"
6. **Verificar**: Mensaje de éxito
7. **Verificar**: Justificante aparece en lista con estado "Pendiente"

#### Parte 2: Revisión (Maestra)
1. Cerrar sesión
2. Iniciar sesión como **maestra**
3. Ir a pantalla de justificantes
4. **Verificar**: Justificante aparece con badge "Requiere revisión"
5. Tap en justificante
6. Revisar detalles:
   - Nombre del niño
   - Tipo: Enfermedad
   - Título y descripción
   - Enviado por: nombre del padre
7. Tap "Aprobar"
8. Agregar notas: "Aprobado, que se mejore"
9. Confirmar
10. **Verificar**: Estado cambia a "Aprobado"

#### Parte 3: Validación (Padre)
1. Cerrar sesión
2. Iniciar sesión como **padre**
3. Ir a justificantes
4. **Verificar**: Justificante muestra estado "Aprobado"
5. Tap en justificante
6. **Verificar**: Se muestran notas de la maestra

**Validación en BD**:
```sql
SELECT * FROM excuses 
WHERE status = 'approved' 
ORDER BY created_at DESC 
LIMIT 1;
```

**Resultado Esperado**: ✅ Flujo completo funcional con persistencia

---

### TEST 4: Upload de Fotos ✅

**Objetivo**: Validar que fotos se suben correctamente a MinIO/S3

**Pasos**:
1. Iniciar sesión como **maestra**
2. Registrar entrada con foto
3. **Verificar en MinIO**:
   - Abrir http://localhost:9000
   - Login con credenciales
   - Ir a bucket `kinderspace-files`
   - **Verificar**: Foto existe en carpeta `{tenantId}/attendance_photo/`
4. **Verificar tamaño**: Debe ser < 10MB
5. **Verificar formato**: JPG/PNG

**Resultado Esperado**: ✅ Foto almacenada en MinIO

---

### TEST 5: Navegación por Roles ✅

**Objetivo**: Verificar que bottom navigation muestra items correctos

#### Maestra/Directora
**Items esperados**:
- 🏠 Inicio
- 📋 Actividad
- 👥 Grupos
- 💬 Mensajes
- 👤 Perfil

#### Padre
**Items esperados**:
- 🏠 Inicio
- 📋 Actividad
- 💬 Chat
- 📅 Calendario
- 👤 Yo

**Pasos**:
1. Iniciar sesión con cada rol
2. Verificar items de navegación
3. Tap en cada item
4. **Verificar**: Navega a pantalla correcta

**Resultado Esperado**: ✅ Navegación diferenciada por rol

---

### TEST 6: Validaciones y Manejo de Errores ✅

**Objetivo**: Verificar que validaciones funcionan correctamente

#### A. Registro de Actividades
- Intentar registrar comida sin llenar campo → **Error**: "Por favor indica qué comió el niño"
- Intentar registrar siesta con duración 0 → **Error**: "Por favor indica la duración..."
- Intentar registrar actividad sin descripción → **Error**: "Por favor describe la actividad"

#### B. Justificantes
- Intentar crear sin seleccionar niño → **Error**: "Selecciona un niño"
- Intentar crear sin título → **Error**: "Ingresa un título"

#### C. Fotos
- Intentar subir foto > 10MB → **Error**: "La foto es demasiado grande..."
- Cancelar captura de foto → No debe mostrar error

**Resultado Esperado**: ✅ Validaciones funcionan correctamente

---

### TEST 7: Sincronización Web ↔ Móvil ✅

**Objetivo**: Verificar que cambios se reflejan en ambas plataformas

**Pasos**:
1. Abrir web app en navegador
2. Abrir app móvil
3. Registrar actividad desde **móvil**
4. Refrescar web app
5. **Verificar**: Actividad aparece en web
6. Crear justificante desde **web** (como padre)
7. Refrescar app móvil
8. **Verificar**: Justificante aparece en móvil

**Resultado Esperado**: ✅ Datos sincronizados en tiempo real

---

## 🐛 PROBLEMAS CONOCIDOS Y SOLUCIONES

### Error: "Connection refused"
**Causa**: Backend no está corriendo  
**Solución**: `cd littlebees-web/apps/api && npm run start:dev`

### Error: "MinIO bucket not found"
**Causa**: Bucket no creado  
**Solución**: El backend crea el bucket automáticamente al iniciar

### Error: "Camera permission denied"
**Causa**: Permisos no configurados  
**Solución**: Agregar permisos en Info.plist (iOS) o AndroidManifest.xml (Android)

### Error: "Invalid token"
**Causa**: Token expirado  
**Solución**: Cerrar sesión y volver a iniciar

---

## 📊 CHECKLIST DE VALIDACIÓN

### Funcionalidades Críticas
- [ ] Login funciona para todos los roles
- [ ] Interfaces diferentes por rol
- [ ] Registro de entrada con foto
- [ ] Registro de salida con foto
- [ ] Registro de comida
- [ ] Registro de siesta
- [ ] Registro de actividad general
- [ ] Creación de justificantes (padres)
- [ ] Aprobación de justificantes (maestras)
- [ ] Rechazo de justificantes (maestras)
- [ ] Upload de fotos a MinIO
- [ ] Validaciones de formularios
- [ ] Navegación por roles

### Persistencia de Datos
- [ ] Actividades guardadas en `daily_log_entries`
- [ ] Asistencia guardada en `attendance_records`
- [ ] Fotos guardadas en `files` y MinIO
- [ ] Justificantes guardados en `excuses`
- [ ] Estados actualizados correctamente

### UX/UI
- [ ] Loading states funcionan
- [ ] Mensajes de error claros
- [ ] Mensajes de éxito visibles
- [ ] Navegación intuitiva
- [ ] Botones deshabilitados durante carga

---

## 🎯 CRITERIOS DE ACEPTACIÓN MVP

Para considerar el MVP como **COMPLETO**, deben cumplirse:

✅ **Autenticación**: Login funcional para todos los roles  
✅ **Diferenciación**: Interfaces específicas por rol  
✅ **Registro de Actividades**: 5 tipos funcionando con BD real  
✅ **Fotos**: Upload funcional con MinIO  
✅ **Justificantes**: Flujo completo padre → maestra  
✅ **Persistencia**: Todos los datos en BD IONOS  
✅ **Validaciones**: Formularios validados  
✅ **Sin Mock Data**: 0% de datos simulados  

---

## 📝 REPORTE DE BUGS

Si encuentras bugs durante el testing, documéntalos así:

```markdown
### Bug #1: [Título descriptivo]
**Severidad**: Alta/Media/Baja
**Pasos para reproducir**:
1. ...
2. ...
3. ...

**Resultado esperado**: ...
**Resultado actual**: ...
**Screenshots**: [si aplica]
**Logs**: [si aplica]
```

---

## 🚀 PRÓXIMOS PASOS POST-MVP

Una vez validado el MVP:

1. **Performance**: Optimizar queries de BD
2. **WebSockets**: Chat en tiempo real
3. **Push Notifications**: Notificaciones móviles
4. **Asistente IA**: Integrar Groq/Llama 3
5. **Reportes**: Gráficas y estadísticas
6. **Programación del día**: Templates de horarios

---

**Estado**: ✅ Listo para testing  
**Última actualización**: 19 de Marzo, 2026  
**Responsable**: Equipo LittleBees
