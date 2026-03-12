# 🔄 Sincronización de Base de Datos Local ↔ IONOS

Guía para mantener sincronizadas las bases de datos entre tu entorno local y el servidor IONOS.

---

## 📋 Contexto

Tu proyecto tiene **DOS bases de datos PostgreSQL separadas**:

1. **Local (Mac)**: Para desarrollo
   - Host: `localhost:5437`
   - Contenedor: `kinderspace-postgres`
   - Datos: Volumen Docker local

2. **IONOS (Producción)**: En el servidor VPS
   - Host: `216.250.125.239:5437`
   - Contenedor: `littlebees-postgres`
   - Datos: Volumen Docker en servidor

**Importante**: Los datos NO se sincronizan automáticamente. Debes hacerlo manualmente.

---

## 🚀 Sincronizar Local → IONOS (Recomendado)

### Cuándo usar:
- Después de crear nuevos datos de prueba localmente
- Después de hacer cambios en la estructura (migraciones)
- Cuando quieres que IONOS tenga exactamente lo mismo que tu Mac

### Comando:

```bash
./sync-db-to-ionos.sh
```

### Qué hace el script:

1. ✅ Verifica que tu BD local esté corriendo
2. 💾 Exporta toda tu BD local (estructura + datos)
3. 📤 Sube el backup al servidor IONOS
4. ⚠️  Te pide confirmación (porque va a borrar datos en IONOS)
5. 🗄️  Restaura el backup en IONOS
6. ✅ Verifica que todo se copió correctamente
7. 🧹 Limpia archivos temporales

### Ejemplo de uso:

```bash
cd ~/Desktop/Proyectos/littlebees_project

# Asegúrate de que tu BD local esté corriendo
pnpm docker:up

# Ejecuta la sincronización
./sync-db-to-ionos.sh

# Te pedirá confirmación:
# ⚠️  ADVERTENCIA:
#    Esta operación va a:
#    1. Eliminar TODOS los datos actuales en IONOS
#    2. Restaurar con los datos de tu BD local
#
#    ¿Estás seguro de continuar? (yes/no)

# Escribe: yes
```

---

## 📥 Sincronizar IONOS → Local

### Cuándo usar:
- Cuando trabajas en otra computadora y quieres los datos de IONOS
- Cuando quieres probar con datos reales de producción

### Comando Manual:

```bash
# 1. Exportar desde IONOS
ssh -i "/Users/hectoreduardosanchezlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna" \
  cbluna@216.250.125.239 \
  'docker exec littlebees-postgres pg_dump -U kinderspace kinderspace_dev' > ionos_backup.sql

# 2. Importar a tu BD local
docker exec -i kinderspace-postgres psql -U kinderspace -d kinderspace_dev < ionos_backup.sql

# 3. Limpiar
rm ionos_backup.sql
```

---

## 🔄 Flujo de Trabajo Recomendado

### Desarrollo Normal:

```bash
# 1. Trabajas en tu Mac con BD local
pnpm docker:up
pnpm dev:api
pnpm dev:web

# 2. Haces cambios, creas datos de prueba, etc.
pnpm db:seed

# 3. Cuando estés listo para desplegar a IONOS:
./sync-db-to-ionos.sh    # Sincroniza BD
./deploy-to-ionos.sh     # Despliega código
```

### Trabajar en Otra Computadora:

**Opción A: Trabajar con BD local independiente**
```bash
# En la nueva Mac
git clone <repo>
pnpm install
pnpm docker:up
pnpm db:migrate
pnpm db:seed
# Ahora tienes tu propia BD local
```

**Opción B: Sincronizar desde IONOS**
```bash
# En la nueva Mac
git clone <repo>
pnpm install
pnpm docker:up
pnpm db:migrate

# Descargar datos de IONOS
ssh -i "$SSH_KEY" cbluna@216.250.125.239 \
  'docker exec littlebees-postgres pg_dump -U kinderspace kinderspace_dev' > backup.sql

# Restaurar localmente
docker exec -i kinderspace-postgres psql -U kinderspace -d kinderspace_dev < backup.sql
```

---

## ⚠️ Advertencias Importantes

### 🔴 NUNCA hagas esto en producción real:
- Este script es para desarrollo/staging
- En producción real, usa backups programados y estrategias de migración seguras

### 🟡 Antes de sincronizar Local → IONOS:
- ✅ Verifica que tu BD local tenga los datos correctos
- ✅ Asegúrate de que no hay usuarios trabajando en IONOS
- ✅ Considera hacer un backup de IONOS primero

### 🟡 Datos que se sobrescriben:
- **TODO**: Usuarios, niños, grupos, asistencias, logs, etc.
- No hay merge, es reemplazo completo

---

## 🛠️ Troubleshooting

### Error: "Contenedor PostgreSQL local no está corriendo"

**Solución:**
```bash
pnpm docker:up
```

### Error: "No se pudo conectar al servidor"

**Solución:**
```bash
# Verifica la llave SSH
ls -la "/Users/hectoreduardosanchezlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna"

# Prueba la conexión
ssh -i "$SSH_KEY" cbluna@216.250.125.239 "echo 'OK'"
```

### Error: "PostgreSQL no está corriendo en IONOS"

**Solución:**
El script lo inicia automáticamente, pero si falla:
```bash
ssh -i "$SSH_KEY" cbluna@216.250.125.239 \
  'cd /home/cbluna/littlebees_project && docker compose -f docker-compose.prod.yml up -d postgres'
```

### Backup manual de IONOS (por seguridad)

```bash
# Crear backup de IONOS antes de sincronizar
ssh -i "$SSH_KEY" cbluna@216.250.125.239 \
  'docker exec littlebees-postgres pg_dump -U kinderspace kinderspace_dev' > ionos_backup_$(date +%Y%m%d).sql

# Guardar en lugar seguro
mv ionos_backup_*.sql ~/Desktop/backups/
```

---

## 📊 Verificar Sincronización

### Después de sincronizar, verifica:

**1. Número de tablas:**
```bash
# Local
docker exec kinderspace-postgres psql -U kinderspace -d kinderspace_dev \
  -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"

# IONOS
ssh -i "$SSH_KEY" cbluna@216.250.125.239 \
  'docker exec littlebees-postgres psql -U kinderspace -d kinderspace_dev \
  -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '\''public'\'';"'
```

**2. Usuarios en la aplicación:**
- Abre: http://216.250.125.239:3000
- Intenta hacer login con usuarios de prueba
- Verifica que veas los mismos datos que localmente

**3. API Swagger:**
- Abre: http://216.250.125.239:3002/api/docs
- Prueba endpoints de lectura (GET)
- Verifica que los datos coincidan

---

## 🔐 Seguridad

### Llave SSH:
- **Ubicación**: `/Users/hectoreduardosanchezlopez/Documents/Archivo Servidor (NO COMPARTIR)/sshcbluna`
- **Permisos**: 600 (solo lectura para ti)
- **NUNCA** la subas a Git
- **NUNCA** la compartas

### Credenciales de BD:
- Usuario: `kinderspace`
- Password: `kinderspace`
- **Cambiar en producción real**

---

## 📝 Scripts Relacionados

| Script | Propósito |
|--------|-----------|
| `sync-db-to-ionos.sh` | Sincroniza BD local → IONOS |
| `deploy-to-ionos.sh` | Despliega código a IONOS |
| `pnpm docker:up` | Inicia BD local |
| `pnpm db:migrate` | Ejecuta migraciones |
| `pnpm db:seed` | Carga datos de prueba |

---

## 🎯 Casos de Uso Comunes

### Caso 1: Nueva computadora, quiero los datos de IONOS

```bash
# 1. Clonar proyecto
git clone <repo>
cd littlebees_project

# 2. Instalar dependencias
pnpm install

# 3. Iniciar BD local
pnpm docker:up

# 4. Crear estructura
pnpm db:migrate

# 5. Descargar datos de IONOS
ssh -i "$SSH_KEY" cbluna@216.250.125.239 \
  'docker exec littlebees-postgres pg_dump -U kinderspace kinderspace_dev' > backup.sql

# 6. Restaurar
docker exec -i kinderspace-postgres psql -U kinderspace -d kinderspace_dev < backup.sql

# 7. Listo!
pnpm dev
```

### Caso 2: Hice cambios locales, quiero subirlos a IONOS

```bash
# 1. Sincronizar BD
./sync-db-to-ionos.sh

# 2. Desplegar código
./deploy-to-ionos.sh

# 3. Verificar
open http://216.250.125.239:3000
```

### Caso 3: Solo quiero actualizar el código, no la BD

```bash
# Solo desplegar código (no tocar BD)
./deploy-to-ionos.sh

# La BD en IONOS permanece intacta
```

---

## 🚨 Preguntas Frecuentes

**Q: ¿Puedo trabajar directamente contra la BD de IONOS desde mi Mac?**  
A: Sí, pero NO es recomendado. Tendrías que:
- Abrir el puerto 5437 en el firewall de IONOS
- Cambiar `DATABASE_URL` en tu `.env` local
- Riesgo de afectar datos en servidor

**Q: ¿Los datos se sincronizan automáticamente?**  
A: No, debes ejecutar `sync-db-to-ionos.sh` manualmente.

**Q: ¿Puedo sincronizar solo algunas tablas?**  
A: El script actual sincroniza todo. Para tablas específicas, usa `pg_dump` con opciones `-t`.

**Q: ¿Qué pasa con los archivos (imágenes, PDFs)?**  
A: Los archivos están en MinIO, no en PostgreSQL. Se sincronizan por separado (no cubierto en este script).

**Q: ¿Puedo hacer rollback si algo sale mal?**  
A: Sí, si hiciste un backup antes. Usa el mismo proceso pero restaurando el backup anterior.

---

**¡Listo para sincronizar! 🚀**
