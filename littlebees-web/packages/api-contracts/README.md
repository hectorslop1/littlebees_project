# 📋 API Contracts - OpenAPI Client Generation

Este package genera automáticamente clientes API desde la especificación OpenAPI de NestJS.

---

## 🎯 Propósito

Sincronizar automáticamente los endpoints de NestJS con:
- ✅ **Flutter (Dart/Dio)** - Cliente generado para `littlebees-mobile`
- ✅ **TypeScript (Axios)** - Cliente generado para `littlebees-web` (futuro)

---

## 🚀 Uso

### **1. Asegúrate de que el API esté corriendo**

```bash
# Desde la raíz del monorepo
pnpm dev:api
# O desde littlebees-web/apps/api
pnpm dev
```

El API debe estar disponible en: http://localhost:3002

### **2. Generar cliente Dart**

```bash
# Desde littlebees-web/packages/api-contracts
pnpm generate

# O paso a paso:
pnpm fetch:openapi    # Descarga openapi.json desde el API
pnpm generate:dart    # Genera cliente Dart en littlebees-mobile/lib/generated/api
```

### **3. Usar el cliente generado en Flutter**

```dart
import 'package:littlebees_mobile/generated/api/api.dart';

// Crear instancia del cliente
final api = KinderspaceApi(
  basePathOverride: 'http://localhost:3002/api/v1',
);

// Usar endpoints
final response = await api.getAuthApi().authControllerLogin(
  loginDto: LoginDto(
    email: 'padre@gmail.com',
    password: 'Password123!',
  ),
);
```

---

## 📦 Archivos Generados

```
littlebees-mobile/lib/generated/api/
├── lib/
│   ├── api.dart              # Exporta todo
│   ├── api/                  # Controllers como clases
│   │   ├── auth_api.dart
│   │   ├── children_api.dart
│   │   └── ...
│   └── model/                # DTOs y modelos
│       ├── login_dto.dart
│       ├── child_dto.dart
│       └── ...
├── pubspec.yaml              # Dependencias del cliente
└── README.md
```

---

## 🔄 Flujo de Trabajo

1. **Modificas un endpoint en NestJS** (ej: agregar campo a `ChildDto`)
2. **Regeneras el cliente:** `pnpm generate`
3. **Flutter automáticamente tiene los nuevos tipos** ✅

---

## ⚙️ Configuración

### **openapitools.json**
Configuración del generador OpenAPI:
- Versión del generador
- Opciones de generación Dart
- Ubicación de salida

### **package.json scripts**
- `fetch:openapi` - Descarga spec desde API corriendo
- `generate:dart` - Genera cliente Dart/Dio
- `generate:ts` - Genera cliente TypeScript (futuro)
- `generate` - Ejecuta todo
- `clean` - Limpia archivos generados

---

## 🛠️ Troubleshooting

### **Error: "Connection refused"**
El API no está corriendo. Ejecuta:
```bash
pnpm dev:api
```

### **Error: "openapi.json not found"**
Ejecuta primero:
```bash
pnpm fetch:openapi
```

### **Cliente generado con errores**
1. Verifica que el API esté corriendo
2. Limpia y regenera:
```bash
pnpm clean
pnpm generate
```

---

## 📚 Recursos

- [OpenAPI Generator Docs](https://openapi-generator.tech/)
- [Dart/Dio Generator](https://openapi-generator.tech/docs/generators/dart-dio)
- [NestJS Swagger](https://docs.nestjs.com/openapi/introduction)

---

**¡Cliente API sincronizado automáticamente! 🎉**
