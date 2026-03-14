# 🎯 WizePick Backend

Sistema de control de inventarios multi-negocio desarrollado con NestJS y PostgreSQL.

## 📋 Descripción

WizePick es una plataforma SaaS para gestión integral de inventarios, ventas y reportes, diseñada para múltiples tipos de negocios:
- 🍺 Discotecas y Bares
- 🍽️ Restaurantes
- 📦 Bodegas y Almacenes
- 🛒 Tiendas Retail
- ☕ Cafeterías

## ✨ Características Principales

### 🏢 Multi-Negocio (Multi-Tenant)
- Soporte para múltiples empresas en una sola instancia
- Aislamiento completo de datos por negocio
- Configuraciones personalizables

### 🏪 Multi-Sucursal
- Gestión de inventario separado por sucursal
- Transferencias entre sucursales
- Reportes comparativos

### 🔐 Sistema de Permisos Granulares
- Roles personalizables por negocio
- Permisos a nivel de módulo y acción
- 6 roles predefinidos del sistema

### 📦 Control de Inventario
- Stock en tiempo real por sucursal
- Movimientos de inventario trazables
- Alertas de stock bajo
- Reposiciones con historial
- Transferencias entre ubicaciones

### 💰 Gestión de Ventas
- Ventas con items múltiples
- Actualización automática de stock
- Múltiples métodos de pago
- Devoluciones y cancelaciones
- Generación de recibos

### 📊 Reportes y Estadísticas
- Reportes de ventas (diario, semanal, mensual)
- Estadísticas por producto, categoría, usuario, sucursal
- Valorización de inventario
- Dashboard ejecutivo
- Exportación a PDF/Excel

### 🕐 Control de Turnos
- Apertura y cierre de turno
- Conciliación de efectivo
- Ventas por turno

### 🎁 Promociones
- Descuentos porcentuales o fijos
- Vigencia configurable
- Aplicación automática

## 🛠️ Stack Tecnológico

- **Framework**: NestJS 10.x
- **Base de Datos**: PostgreSQL 15+
- **ORM**: TypeORM
- **Autenticación**: JWT + Passport
- **Validación**: class-validator
- **Documentación**: Swagger/OpenAPI
- **Seguridad**: Helmet, CORS, Rate Limiting

## 📦 Requisitos Previos

- Node.js >= 18.x
- pnpm >= 8.x (se instala con `npm install -g pnpm`)
- PostgreSQL >= 15.x
- Git

## 🚀 Instalación

### 1. Clonar repositorio
```bash
git clone <repository-url>
cd wizepick-back
```

### 2. Instalar pnpm globalmente (si no lo tienes)
```bash
npm install -g pnpm
# O usando corepack (recomendado)
corepack enable
corepack prepare pnpm@latest --activate
```

### 3. Instalar dependencias
```bash
pnpm install
```

### 3. Configurar variables de entorno
```bash
cp .env.example .env
```

Editar `.env` con tus credenciales:
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=wizepick_db
DATABASE_SYNCHRONIZE=false

JWT_SECRET=your-super-secret-jwt-key-min-32-characters-long
JWT_EXPIRATION=24h
JWT_REFRESH_SECRET=your-refresh-secret-key-min-32-characters
JWT_REFRESH_EXPIRATION=7d

PORT=3000
NODE_ENV=development
```

### 4. Crear base de datos
```bash
# Conectar a PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE wizepick_db;
\q
```

### 5. Ejecutar migraciones
```bash
pnpm migration:run
```

### 6. Ejecutar seeds
```bash
pnpm seed:permissions
pnpm seed:roles
pnpm seed:superadmin
```

### 7. Iniciar servidor
```bash
# Desarrollo
pnpm start:dev

# Producción
pnpm build
pnpm start:prod
```

## 📚 Documentación API

Una vez iniciado el servidor, la documentación Swagger estará disponible en:
```
http://localhost:3000/api/docs
```

## 🔑 Credenciales Iniciales

Después de ejecutar los seeds, podrás iniciar sesión con:

```
Username: superadmin
Password: Admin@2026
```

**⚠️ IMPORTANTE**: Cambiar estas credenciales en producción.

## 📁 Estructura del Proyecto

```
src/
├── common/           # Utilities, guards, decorators compartidos
├── config/           # Configuraciones (database, jwt, app)
├── modules/          # Módulos de la aplicación
│   ├── auth/         # Autenticación y JWT
│   ├── businesses/   # Gestión de negocios
│   ├── branches/     # Gestión de sucursales
│   ├── roles/        # Roles y permisos
│   ├── users/        # Usuarios
│   ├── products/     # Productos y categorías
│   ├── inventory/    # Control de inventario
│   ├── sales/        # Ventas
│   ├── reports/      # Reportes
│   ├── dashboard/    # Dashboard
│   ├── shifts/       # Turnos
│   ├── promotions/   # Promociones
│   └── audit/        # Auditoría
├── database/         # Migraciones y seeds
├── main.ts           # Entry point
└── app.module.ts     # Módulo raíz
```

## 🧪 Testing

```bash
# Tests unitarios
pnpm test

# Tests e2e
pnpm test:e2e

# Cobertura
pnpm test:cov
```

## 📊 Scripts Disponibles

```bash
pnpm start          # Iniciar en modo normal
pnpm start:dev      # Iniciar en modo desarrollo (watch)
pnpm start:prod     # Iniciar en producción
pnpm build          # Compilar proyecto
pnpm lint           # Ejecutar linter
pnpm format         # Formatear código

# Migraciones
pnpm migration:generate <name>  # Generar migración
pnpm migration:run              # Ejecutar migraciones
pnpm migration:revert           # Revertir última migración

# Seeds
pnpm seed:permissions  # Crear permisos
pnpm seed:roles        # Crear roles
pnpm seed:superadmin   # Crear superadmin
```

## 🔐 Sistema de Permisos

### Roles Predefinidos

1. **Superadmin**: Control total del sistema
2. **Business Owner**: Gestión completa del negocio
3. **Manager**: Gerente con acceso amplio
4. **Cashier**: Cajero con permisos de venta
5. **Staff**: Personal con permisos limitados
6. **Warehouse**: Encargado de almacén

### Formato de Permisos

Los permisos siguen el formato: `module.action`

Ejemplos:
- `products.create` - Crear productos
- `sales.read` - Ver ventas
- `inventory.adjust` - Ajustar inventario
- `reports.export` - Exportar reportes

## 🌐 Endpoints Principales

### Autenticación
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Registro
- `GET /api/auth/profile` - Perfil actual

### Productos
- `GET /api/products` - Listar productos
- `POST /api/products` - Crear producto
- `PATCH /api/products/:id` - Actualizar producto

### Ventas
- `POST /api/sales` - Registrar venta
- `GET /api/sales` - Listar ventas
- `GET /api/sales/:id` - Detalle de venta

### Inventario
- `GET /api/inventory/stock` - Stock actual
- `POST /api/inventory/replenish` - Reposición
- `POST /api/inventory/transfer` - Transferencia

Ver documentación completa en Swagger.

## 🐳 Docker

### Desarrollo
```bash
# Iniciar todo (backend + PostgreSQL)
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f

# Detener
docker-compose -f docker-compose.dev.yml down
```

### Producción
```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Comandos útiles
```bash
# Ejecutar migraciones en container
docker-compose exec api pnpm migration:run

# Ejecutar seeds
docker-compose exec api pnpm seed:permissions

# Acceder al container
docker-compose exec api sh

# Ver base de datos
docker-compose exec postgres psql -U postgres -d wizepick_db
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto es privado y propietario.

## 👥 Equipo

- **Desarrollador Principal**: [Tu Nombre]
- **Arquitectura**: GitHub Copilot

## 📞 Soporte

Para soporte, enviar email a: support@wizepick.com

---

**Versión**: 2.0.0  
**Última actualización**: Marzo 2026
