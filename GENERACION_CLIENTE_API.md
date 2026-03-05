# 🔄 Generación Automática de Cliente API Dart

**Sincronización automática de endpoints NestJS → Flutter**

---

## 🎯 ¿Qué es esto?

Sistema que genera automáticamente un cliente Dart/Dio desde la especificación OpenAPI de NestJS, eliminando la necesidad de escribir endpoints manualmente y asegurando que Flutter siempre esté sincronizado con el backend.

---

## ✅ Ventajas

| Antes (Manual) | Ahora (Generado) |
|----------------|------------------|
| ❌ Escribir endpoints manualmente | ✅ Generados automáticamente |
| ❌ Sincronizar tipos TS ↔ Dart | ✅ Tipos sincronizados automáticamente |
| ❌ Errores de tipado | ✅ Type-safe end-to-end |
| ❌ Actualizar cliente en cada cambio | ✅ Un comando regenera todo |
| ❌ Documentación desactualizada | ✅ Swagger siempre actualizado |

---

## 🚀 Uso Rápido

### **1. Iniciar el API**
```bash
# Desde la raíz del monorepo
pnpm dev:api
```

### **2. Generar cliente Dart**
```bash
# Opción 1: Desde la raíz del monorepo
pnpm generate:api-client

# Opción 2: Desde littlebees-web/packages/api-contracts
./generate-client.sh

# Opción 3: Paso a paso
pnpm generate:dart-client
```

### **3. Instalar dependencias en Flutter**
```bash
cd littlebees-mobile
flutter pub get
```

### **4. Usar el cliente generado**
```dart
import 'package:littlebees_mobile/core/api/generated_api_client.dart';

// Obtener instancia
final api = GeneratedApiClient.instance;

// Usar endpoints (después de descomentar en generated_api_client.dart)
final children = await api.children.getChildren();
final loginResponse = await api.auth.login(
  loginDto: LoginDto(
    email: 'padre@gmail.com',
    password: 'Password123!',
  ),
);
```

---

## 📁 Estructura de Archivos

```
littlebees_project/
│
├── littlebees-web/
│   └── packages/
│       └── api-contracts/              ← Generador de cliente
│           ├── package.json            # Scripts de generación
│           ├── openapitools.json       # Configuración OpenAPI
│           ├── generate-client.sh      # Script bash
│           ├── README.md               # Documentación
│           └── openapi.json            # Spec descargado (gitignored)
│
└── littlebees-mobile/
    └── lib/
        ├── core/api/
        │   └── generated_api_client.dart  ← Wrapper del cliente
        │
        └── generated/api/              ← Cliente generado (gitignored)
            ├── lib/
            │   ├── api.dart            # Exporta todo
            │   ├── api/                # Controllers
            │   │   ├── auth_api.dart
            │   │   ├── children_api.dart
            │   │   └── ...
            │   └── model/              # DTOs
            │       ├── login_dto.dart
            │       ├── child_dto.dart
            │       └── ...
            └── pubspec.yaml
```

---

## 🔄 Flujo de Trabajo

### **Escenario: Agregar un nuevo campo a un DTO**

1. **Modificas el DTO en NestJS:**
```typescript
// littlebees-web/apps/api/src/modules/children/dto/child.dto.ts
export class ChildDto {
  id: string;
  firstName: string;
  lastName: string;
  // ✨ Nuevo campo
  nickname?: string;
}
```

2. **Regeneras el cliente:**
```bash
pnpm generate:api-client
```

3. **Flutter automáticamente tiene el nuevo campo:**
```dart
// El modelo generado ahora incluye:
class ChildDto {
  final String id;
  final String firstName;
  final String lastName;
  final String? nickname;  // ✨ Nuevo campo
}
```

**¡Sin escribir código Dart manualmente!** ✅

---

## 🛠️ Scripts Disponibles

### **Desde la raíz del monorepo:**
```bash
pnpm generate:api-client      # Genera cliente Dart (script bash)
pnpm generate:dart-client     # Genera cliente Dart (pnpm)
```

### **Desde littlebees-web/packages/api-contracts:**
```bash
pnpm fetch:openapi            # Descarga openapi.json
pnpm generate:dart            # Genera cliente Dart
pnpm generate                 # Fetch + Generate
pnpm clean                    # Limpia archivos generados
./generate-client.sh          # Script bash completo
```

---

## 📋 Configuración

### **openapitools.json**
Configuración del generador OpenAPI:
```json
{
  "generator-cli": {
    "version": "7.10.0",
    "generators": {
      "dart-dio": {
        "generatorName": "dart-dio",
        "output": "../../../littlebees-mobile/lib/generated/api",
        "additionalProperties": {
          "pubName": "kinderspace_api",
          "useEnumExtension": true,
          "dateLibrary": "core"
        }
      }
    }
  }
}
```

### **NestJS Swagger (ya configurado)**
```typescript
// littlebees-web/apps/api/src/main.ts
const config = new DocumentBuilder()
  .setTitle('KinderSpace MX API')
  .setVersion('1.0')
  .addBearerAuth()
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```

**URLs:**
- Swagger UI: http://localhost:3002/api/docs
- OpenAPI JSON: http://localhost:3002/api/docs-json

---

## 🎯 Próximos Pasos

### **Corto plazo (ahora):**
1. ✅ Configuración completada
2. ⏳ Generar cliente inicial (requiere API corriendo)
3. ⏳ Descomentar código en `generated_api_client.dart`
4. ⏳ Migrar features de Flutter para usar cliente generado

### **Mediano plazo:**
- Agregar tests para el cliente generado
- Configurar CI/CD para regenerar en cada cambio
- Generar cliente TypeScript para web (Orval)

### **Largo plazo:**
- Versionado de API (v1, v2)
- Múltiples clientes (admin panel, etc.)
- Publicar cliente como paquete npm/pub

---

## 🐛 Troubleshooting

### **Error: "Connection refused"**
**Causa:** El API no está corriendo  
**Solución:**
```bash
pnpm dev:api
```

### **Error: "openapi.json not found"**
**Causa:** No se descargó el spec  
**Solución:**
```bash
cd littlebees-web/packages/api-contracts
pnpm fetch:openapi
```

### **Cliente generado con errores de compilación**
**Causa:** Spec OpenAPI inválido o configuración incorrecta  
**Solución:**
1. Verifica Swagger UI: http://localhost:3002/api/docs
2. Limpia y regenera:
```bash
pnpm clean
pnpm generate
```

### **Flutter no encuentra el paquete generado**
**Causa:** Falta ejecutar `flutter pub get`  
**Solución:**
```bash
cd littlebees-mobile
flutter pub get
```

---

## 📚 Recursos

- [OpenAPI Generator](https://openapi-generator.tech/)
- [Dart/Dio Generator](https://openapi-generator.tech/docs/generators/dart-dio)
- [NestJS Swagger](https://docs.nestjs.com/openapi/introduction)
- [Swagger UI](http://localhost:3002/api/docs) (cuando API esté corriendo)

---

## 🎉 Resultado Final

**Antes:**
```dart
// Escribir manualmente cada endpoint
class Endpoints {
  static const String login = '/auth/login';
  static const String children = '/children';
  // ... 50+ endpoints más
}

// Escribir manualmente cada modelo
class ChildDto {
  final String id;
  final String firstName;
  // ... sincronizar con TypeScript manualmente
}
```

**Ahora:**
```dart
// Un solo comando:
// pnpm generate:api-client

// Usar cliente generado:
final api = GeneratedApiClient.instance;
final children = await api.children.getChildren();
// ✅ Type-safe
// ✅ Sincronizado automáticamente
// ✅ Documentado en Swagger
```

---

**¡Endpoints sincronizados automáticamente! 🚀**
