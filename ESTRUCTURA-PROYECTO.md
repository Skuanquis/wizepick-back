# 🚀 Estructura del Proyecto WizePick Backend

**Generado:** Marzo 11, 2026  
**Framework:** NestJS 11.x  
**Package Manager:** pnpm

## 📁 Estructura Completa

```
wizepick-back/
├── 📄 Configuración del Proyecto
│   ├── .env                         # Variables de entorno (configuración local)
│   ├── .env.example                 # Plantilla de variables de entorno
│   ├── .gitignore                   # Archivos ignorados por Git
│   ├── .dockerignore                # Archivos ignorados por Docker
│   ├── .prettierrc                  # Configuración de Prettier
│   ├── eslint.config.mjs            # Configuración de ESLint
│   ├── nest-cli.json                # Configuración del CLI de NestJS
│   ├── tsconfig.json                # Configuración de TypeScript
│   ├── tsconfig.build.json          # Configuración de compilación
│   ├── package.json                 # Dependencias y scripts del proyecto
│   └── pnpm-lock.yaml               # Lockfile de pnpm (control de versiones)
│
├── 🐳 Docker
│   ├── Dockerfile                   # Dockerfile de producción (multi-stage)
│   ├── Dockerfile.dev               # Dockerfile de desarrollo
│   ├── docker-compose.yml           # Orquestación para producción
│   ├── docker-compose.dev.yml       # Orquestación para desarrollo (con pgAdmin)
│   └── Makefile                     # Comandos útiles para Docker y desarrollo
│
├── 📚 Documentación
│   ├── README.md                    # Documentación principal del proyecto
│   ├── plan.md                      # Plan de implementación completo (13 fases)
│   ├── INICIO-RAPIDO.md             # Guía de inicio rápido
│   ├── database-schema.md           # Documentación del esquema de base de datos
│   ├── database-init.sql            # Script SQL de inicialización (18 tablas)
│   └── entity-examples.md           # Ejemplos de entidades y DTOs
│
├── 📦 src/                          # Código fuente de la aplicación
│   │
│   ├── 🎯 app.controller.ts         # Controlador principal (health check)
│   ├── 🎯 app.service.ts            # Servicio principal
│   ├── 🎯 app.module.ts             # Módulo raíz (configuración global)
│   ├── 🎯 main.ts                   # Punto de entrada (Bootstrap)
│   │
│   ├── ⚙️ config/                   # Configuraciones
│   │   ├── database.config.ts       # Configuración de TypeORM
│   │   └── typeorm.config.ts        # DataSource para migraciones
│   │
│   ├── 🛠️ common/                   # Utilidades compartidas
│   │   ├── decorators/              # Decoradores personalizados (@CurrentUser, @Permissions, etc.)
│   │   ├── guards/                  # Guards (JwtAuthGuard, PermissionsGuard, BusinessAccessGuard)
│   │   ├── filters/                 # Filtros de excepciones
│   │   ├── interceptors/            # Interceptores de respuesta
│   │   └── dto/                     # DTOs compartidos (PaginationDto, ResponseDto)
│   │
│   ├── 💾 database/                 # Base de datos
│   │   ├── migrations/              # Migraciones de TypeORM
│   │   └── seeds/                   # Seeds (permissions, roles, superadmin)
│   │
│   └── 📂 modules/                  # Módulos de la aplicación
│       │
│       ├── 🔐 auth/                 # Autenticación y autorización
│       │   └── auth.module.ts       # (JWT, Passport, login, register, refresh)
│       │
│       ├── 👤 users/                # Gestión de usuarios
│       │   └── users.module.ts      # (CRUD, roles, permisos por usuario)
│       │
│       ├── 🏢 businesses/           # Gestión de negocios
│       │   └── businesses.module.ts # (Multi-tenant, tipos de negocio)
│       │
│       ├── 🏪 branches/             # Gestión de sucursales
│       │   └── branches.module.ts   # (Sucursales por negocio, inventario por sucursal)
│       │
│       ├── 🎭 roles/                # Gestión de roles
│       │   └── roles.module.ts      # (6 roles predefinidos + custom roles)
│       │
│       ├── 🔑 permissions/          # Gestión de permisos
│       │   └── permissions.module.ts# (50+ permisos granulares)
│       │
│       ├── 📦 products/             # Gestión de productos
│       │   └── products.module.ts   # (Categorías, SKU, precios, historial)
│       │
│       ├── 📊 inventory/            # Gestión de inventario
│       │   └── inventory.module.ts  # (Stock por sucursal, movimientos, transfers)
│       │
│       ├── 💰 sales/                # Gestión de ventas/pedidos
│       │   └── sales.module.ts      # (Transacciones, items, descuentos)
│       │
│       ├── 📈 reports/              # Reportes y estadísticas
│       │   └── reports.module.ts    # (Ventas, inventario, productos populares)
│       │
│       ├── 📱 dashboard/            # Dashboard y métricas
│       │   └── dashboard.module.ts  # (Resúmenes, KPIs, gráficas)
│       │
│       ├── ⏰ shifts/               # Gestión de turnos
│       │   └── shifts.module.ts     # (Apertura/cierre de caja)
│       │
│       ├── 🎁 promotions/           # Gestión de promociones
│       │   └── promotions.module.ts # (Descuentos, 2x1, happy hour)
│       │
│       └── 📝 audit/                # Auditoría del sistema
│           └── audit.module.ts      # (Logs de cambios, trazabilidad)
│
└── 🧪 test/                         # Pruebas
    ├── app.e2e-spec.ts              # Pruebas E2E
    └── jest-e2e.json                # Configuración de Jest para E2E
```

## 📦 Dependencias Instaladas

### Principales
- `@nestjs/core@11.x` - Framework principal
- `@nestjs/typeorm@11.x` - Integración con TypeORM
- `typeorm@0.3.28` - ORM para PostgreSQL
- `pg@8.20.0` - Driver de PostgreSQL
- `@nestjs/jwt@11.x` - Autenticación JWT
- `@nestjs/passport@11.x` - Integración con Passport
- `passport-jwt@4.x` - Estrategia JWT para Passport
- `bcrypt@6.x` - Hash de contraseñas
- `@nestjs/config@4.x` - Gestión de variables de entorno
- `class-validator@0.15.1` - Validación de DTOs
- `class-transformer@0.5.1` - Transformación de objetos
- `@nestjs/swagger@11.x` - Documentación OpenAPI/Swagger
- `helmet@8.x` - Seguridad HTTP headers
- `@nestjs/throttler@6.x` - Rate limiting
- `dotenv@17.x` - Carga de variables de entorno

### Desarrollo
- `@nestjs/cli@11.x` - CLI de NestJS
- `@types/bcrypt` - Tipos para bcrypt
- `@types/passport-jwt` - Tipos para passport-jwt
- `jest@30.x` - Framework de testing
- `typescript@5.7.x` - TypeScript
- `prettier@3.x` - Formateador de código
- `eslint@9.x` - Linter

## 🎯 Scripts Disponibles (package.json)

### Desarrollo
```bash
pnpm start:dev          # Modo desarrollo con hot reload
pnpm start:debug        # Modo debug
pnpm build              # Compilar aplicación
pnpm start:prod         # Modo producción
```

### Testing
```bash
pnpm test               # Ejecutar tests
pnpm test:watch         # Tests en modo watch
pnpm test:cov           # Cobertura de tests
pnpm test:e2e           # Tests end-to-end
```

### Base de Datos
```bash
pnpm migration:generate # Generar migración automática
pnpm migration:create   # Crear migración vacía
pnpm migration:run      # Ejecutar migraciones pendientes
pnpm migration:revert   # Revertir última migración
pnpm migration:show     # Ver estado de migraciones
```

### Seeds
```bash
pnpm seed:permissions   # Crear permisos iniciales
pnpm seed:roles         # Crear roles iniciales
pnpm seed:superadmin    # Crear usuario superadmin
pnpm seed:all           # Ejecutar todos los seeds
```

### Calidad de Código
```bash
pnpm lint               # Ejecutar ESLint
pnpm format             # Formatear código con Prettier
```

## 🐳 Comandos Docker (Makefile)

```bash
make dev                # Iniciar en desarrollo (Docker + hot reload)
make dev-local          # Iniciar en desarrollo local (sin Docker)
make start              # Iniciar en producción
make stop               # Detener contenedores
make restart            # Reiniciar contenedores
make logs               # Ver logs de la aplicación
make logs-db            # Ver logs de PostgreSQL
make shell              # Entrar al contenedor de la app
make db-shell           # Entrar a PostgreSQL
make migrate            # Ejecutar migraciones
make seed               # Ejecutar todos los seeds
make clean              # Limpiar contenedores y volúmenes
make docker-build       # Construir imagen Docker
```

## ✅ Estado Actual del Proyecto

### Completado ✅
- [x] Inicialización del proyecto NestJS con pnpm
- [x] Instalación de todas las dependencias principales
- [x] Configuración de Docker (producción y desarrollo)
- [x] Estructura de carpetas completa
- [x] Creación de 14 módulos principales
- [x] Configuración de TypeORM
- [x] Configuración del main.ts (Swagger, CORS, Validación)
- [x] Configuración del app.module (Database, Throttling, ConfigModule)
- [x] Health check endpoint
- [x] Scripts de migraciones y seeds
- [x] Compilación exitosa del proyecto

### Pendiente ⏳
- [ ] Crear entidades de TypeORM (18 tablas)
- [ ] Crear DTOs con validaciones
- [ ] Implementar servicios con lógica de negocio
- [ ] Implementar controladores con rutas
- [ ] Crear guards personalizados (JwtAuthGuard, PermissionsGuard, BusinessAccessGuard)
- [ ] Crear decoradores personalizados (@CurrentUser, @Permissions, @HasBusinessAccess)
- [ ] Crear filtros de excepciones globales
- [ ] Implementar sistema de autenticación completo
- [ ] Crear migraciones de base de datos
- [ ] Crear seeds de datos iniciales
- [ ] Implementar tests unitarios y E2E
- [ ] Configurar CI/CD
- [ ] Documentar endpoints con Swagger decorators

## 🎯 Próximos Pasos Recomendados

1. **Iniciar la base de datos:**
   ```bash
   # Con Docker:
   make dev
   
   # O manualmente:
   docker-compose -f docker-compose.dev.yml up -d postgres
   ```

2. **Crear base de datos inicial:**
   ```bash
   psql -U postgres -h localhost -f database-init.sql
   ```

3. **Comenzar desarrollo de entidades:**
   - Empezar con tablas base: businesses, users, roles, permissions
   - Luego: products, categories, branches
   - Finalmente: sales, inventory, audit

4. **Configurar autenticación:**
   - Implementar módulo auth completo
   - Crear JwtStrategy
   - Implementar guards y decoradores

5. **Crear primeros endpoints:**
   - Auth: login, register, refresh token
   - Users: CRUD básico
   - Businesses: CRUD con validación multi-tenant

## 📞 Recursos

- **Documentación NestJS:** https://docs.nestjs.com
- **TypeORM Docs:** https://typeorm.io
- **Swagger:** Disponible en `http://localhost:3000/api/docs` (una vez iniciada la app)

## 🔐 Credenciales de Desarrollo

**PostgreSQL:**
- Host: localhost
- Port: 5432
- Usuario: postgres
- Contraseña: postgres
- Base de datos: wizepick_db

**pgAdmin (Docker dev):**
- URL: http://localhost:5050
- Email: admin@wizepick.com
- Password: admin

---

**Nota:** Este es un proyecto de backend multi-tenant con arquitectura escalable. Todas las tablas incluyen `business_id` para aislamiento de datos por empresa. El sistema soporta 6 tipos de negocios: discotecas, restaurantes, bodegas, retail, bares y cafés.
