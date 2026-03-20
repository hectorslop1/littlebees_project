# 🛠️ Guía de Desarrollo - LittleBees

## 📋 Convenciones de Código

### TypeScript

**Nombres de archivos:**
- Componentes: `kebab-case.tsx` (ej: `user-profile.tsx`)
- Hooks: `use-*.ts` (ej: `use-auth.ts`)
- Utilidades: `kebab-case.ts` (ej: `format-date.ts`)
- Tipos: `*.types.ts` (ej: `user.types.ts`)

**Nombres de variables y funciones:**
```typescript
// ✅ Correcto
const userName = 'John';
function getUserById(id: string) { }

// ❌ Incorrecto
const UserName = 'John';
function GetUserById(id: string) { }
```

**Componentes React:**
```typescript
// ✅ Correcto - PascalCase
export function UserProfile() { }

// ❌ Incorrecto
export function userProfile() { }
```

---

## 🎨 Componentes UI

### Uso de shadcn/ui

Siempre usar los componentes de shadcn/ui cuando estén disponibles:

```typescript
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
```

### Estructura de Componentes

```typescript
'use client'; // Solo si usa hooks de React

import { useState } from 'react';
import { Button } from '@/components/ui/button';

interface ComponentProps {
  title: string;
  onAction?: () => void;
}

export function MyComponent({ title, onAction }: ComponentProps) {
  const [state, setState] = useState(false);

  return (
    <div className="space-y-4">
      <h2>{title}</h2>
      <Button onClick={onAction}>Acción</Button>
    </div>
  );
}
```

---

## 🔄 Manejo de Estado

### React Query (TanStack Query)

**Queries:**
```typescript
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get<User[]>('/users'),
    staleTime: 5 * 60 * 1000, // 5 minutos
  });
}
```

**Mutations:**
```typescript
export function useCreateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateUserDto) => api.post<User>('/users', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

**Optimistic Updates:**
```typescript
export function useUpdateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserDto }) =>
      api.patch<User>(`/users/${id}`, data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['users', id] });
      const previous = queryClient.getQueryData(['users', id]);
      
      queryClient.setQueryData(['users', id], (old: any) => ({
        ...old,
        ...data,
      }));
      
      return { previous };
    },
    onError: (err, variables, context) => {
      if (context?.previous) {
        queryClient.setQueryData(['users', variables.id], context.previous);
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['users', variables.id] });
    },
  });
}
```

---

## 🎯 Backend (NestJS)

### Estructura de Módulos

```
modules/
├── users/
│   ├── dto/
│   │   ├── create-user.dto.ts
│   │   ├── update-user.dto.ts
│   │   └── user-response.dto.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── users.module.ts
```

### DTOs (Data Transfer Objects)

```typescript
import { IsString, IsEmail, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @MinLength(3)
  name: string;
}
```

### Servicios

```typescript
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(tenantId: string, dto: CreateUserDto) {
    return this.prisma.user.create({
      data: {
        tenantId,
        ...dto,
      },
    });
  }

  async findAll(tenantId: string) {
    return this.prisma.user.findMany({
      where: { tenantId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
```

### Controladores

```typescript
@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Crear nuevo usuario' })
  create(
    @CurrentTenant() tenantId: string,
    @Body() dto: CreateUserDto,
  ) {
    return this.usersService.create(tenantId, dto);
  }
}
```

---

## 🗄️ Prisma

### Migraciones

```bash
# Crear migración
npx prisma migrate dev --name add_user_field

# Aplicar migraciones
npx prisma migrate deploy

# Resetear base de datos (desarrollo)
npx prisma migrate reset
```

### Queries Optimizadas

```typescript
// ✅ Correcto - Seleccionar solo campos necesarios
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
  },
});

// ❌ Incorrecto - Traer todos los campos
const users = await prisma.user.findMany();
```

### Relaciones

```typescript
// Include para relaciones
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    children: true,
    tenant: {
      select: {
        name: true,
      },
    },
  },
});
```

---

## 🔒 Seguridad

### Autenticación

Siempre usar guards en endpoints protegidos:

```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.TEACHER, UserRole.DIRECTOR)
@Get('protected')
protectedRoute() {
  return { message: 'Protected data' };
}
```

### Validación de Tenant

Siempre filtrar por `tenantId`:

```typescript
// ✅ Correcto
const users = await prisma.user.findMany({
  where: { tenantId },
});

// ❌ Incorrecto - Expone datos de otros tenants
const users = await prisma.user.findMany();
```

---

## 🧪 Testing

### Unit Tests (Backend)

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [UsersService, PrismaService],
    }).compile();

    service = module.get<UsersService>(UsersService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should create a user', async () => {
    const dto = { email: 'test@example.com', name: 'Test' };
    const result = await service.create('tenant-id', dto);
    expect(result).toBeDefined();
  });
});
```

### Component Tests (Frontend)

```typescript
import { render, screen } from '@testing-library/react';
import { UserProfile } from './user-profile';

describe('UserProfile', () => {
  it('renders user name', () => {
    render(<UserProfile name="John Doe" />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });
});
```

---

## 📊 Performance

### Optimización de Queries

**Usar índices en Prisma:**
```prisma
model User {
  id       String @id @default(uuid())
  email    String @unique
  tenantId String

  @@index([tenantId])
  @@index([email])
}
```

**Paginación:**
```typescript
async findAll(tenantId: string, page = 1, limit = 20) {
  const skip = (page - 1) * limit;
  
  const [items, total] = await Promise.all([
    this.prisma.user.findMany({
      where: { tenantId },
      skip,
      take: limit,
    }),
    this.prisma.user.count({ where: { tenantId } }),
  ]);

  return {
    items,
    total,
    page,
    totalPages: Math.ceil(total / limit),
  };
}
```

### React Performance

**Memoización:**
```typescript
import { useMemo, useCallback } from 'react';

function MyComponent({ data }) {
  const processedData = useMemo(() => {
    return data.map(item => /* expensive operation */);
  }, [data]);

  const handleClick = useCallback(() => {
    // handler logic
  }, []);

  return <div>{/* render */}</div>;
}
```

---

## 🎨 Estilos (TailwindCSS)

### Convenciones

```typescript
// ✅ Correcto - Orden lógico de clases
<div className="flex items-center justify-between gap-4 rounded-lg bg-white p-4 shadow-md">

// ❌ Incorrecto - Clases desordenadas
<div className="p-4 bg-white shadow-md flex rounded-lg gap-4 items-center justify-between">
```

### Responsive Design

```typescript
<div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
  {/* contenido */}
</div>
```

### Componentes Reutilizables

```typescript
import { cn } from '@/lib/utils';

interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export function Card({ children, className }: CardProps) {
  return (
    <div className={cn('rounded-lg border bg-card p-6', className)}>
      {children}
    </div>
  );
}
```

---

## 🚀 Deployment

### Variables de Entorno

**Nunca commitear archivos `.env`:**
```bash
# .gitignore
.env
.env.local
.env.*.local
```

**Usar variables de entorno en producción:**
```typescript
// ✅ Correcto
const apiUrl = process.env.NEXT_PUBLIC_API_URL;

// ❌ Incorrecto - Hardcoded
const apiUrl = 'http://localhost:3001';
```

### Build

```bash
# Backend
cd apps/api
npm run build

# Frontend
cd apps/web
npm run build
```

---

## 📝 Git Workflow

### Commits

Usar conventional commits:

```bash
feat: agregar sistema de notificaciones
fix: corregir error en login
docs: actualizar README
refactor: mejorar estructura de componentes
test: agregar tests para UserService
```

### Branches

```bash
main          # Producción
develop       # Desarrollo
feature/*     # Nuevas características
fix/*         # Correcciones
hotfix/*      # Correcciones urgentes
```

---

## 🔍 Debugging

### Backend

```typescript
// Usar logger de NestJS
import { Logger } from '@nestjs/common';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  async create(dto: CreateUserDto) {
    this.logger.log(`Creating user: ${dto.email}`);
    // ...
  }
}
```

### Frontend

```typescript
// Usar console en desarrollo
if (process.env.NODE_ENV === 'development') {
  console.log('Debug info:', data);
}
```

---

## 📚 Recursos

- **NestJS:** https://docs.nestjs.com/
- **Next.js:** https://nextjs.org/docs
- **Prisma:** https://www.prisma.io/docs
- **TailwindCSS:** https://tailwindcss.com/docs
- **shadcn/ui:** https://ui.shadcn.com/
- **React Query:** https://tanstack.com/query/latest

---

## ✅ Checklist de PR

Antes de crear un Pull Request, verificar:

- [ ] Código sigue las convenciones del proyecto
- [ ] Tests agregados/actualizados
- [ ] Documentación actualizada
- [ ] No hay console.logs en producción
- [ ] Variables de entorno documentadas
- [ ] Migraciones de BD incluidas (si aplica)
- [ ] Build pasa sin errores
- [ ] Linter pasa sin errores

---

**Última actualización:** Marzo 2026
