# 📋 Plan de Implementación - Sistema de Control de Inventarios
## Proyecto WizePick - Backend NestJS + PostgreSQL

---

## 🎯 Resumen Ejecutivo

Sistema de control de inventarios en tiempo real **multi-negocio** (discotecas, restaurantes, bodegas, tiendas), desarrollado con NestJS y PostgreSQL, enfocado en gestión de productos, ventas por personal, control de roles y permisos personalizables, y reportería avanzada. Arquitectura escalable y modular.

---

## 🛠️ Stack Tecnológico

### Backend
- **Framework**: NestJS 10.x (Node.js + TypeScript)
- **Base de Datos**: PostgreSQL 15+
- **ORM**: TypeORM / Prisma (recomendado TypeORM por integración nativa con NestJS)
- **Autenticación**: JWT (JSON Web Tokens) + Passport
- **Validación**: class-validator, class-transformer
- **Documentación API**: Swagger/OpenAPI

### Dependencias Principales
```json
{
  "@nestjs/core": "^10.0.0",
  "@nestjs/typeorm": "^10.0.0",
  "@nestjs/jwt": "^10.0.0",
  "@nestjs/passport": "^10.0.0",
  "typeorm": "^0.3.0",
  "pg": "^8.11.0",
  "bcrypt": "^5.1.0",
  "passport-jwt": "^4.0.1",
  "class-validator": "^0.14.0",
  "class-transformer": "^0.5.1"
}
```

### Herramientas de Desarrollo
- **Testing**: Jest
- **Linting**: ESLint + Prettier
- **Control de Versiones**: Git
- **Manejo de Variables**: dotenv / @nestjs/config

---

## 🗄️ Diseño de Base de Datos

### Principios de Diseño
- **IDs Numéricos**: Uso de SERIAL/BIGSERIAL para mejor rendimiento
- **Multi-Negocio**: Preparado para soportar múltiples empresas/sucursales
- **Escalabilidad**: Estructura flexible para diferentes tipos de negocios
- **Roles y Permisos**: Sistema granular y personalizable
- **Auditoría Completa**: Trazabilidad de todas las operaciones

### Tablas Principales

#### 1. **businesses** (Negocios/Empresas)
```sql
CREATE TABLE businesses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  business_type VARCHAR(50) NOT NULL, -- 'nightclub', 'restaurant', 'warehouse', 'retail', 'bar', 'cafe'
  tax_id VARCHAR(50) UNIQUE,
  address TEXT,
  phone VARCHAR(20),
  email VARCHAR(100),
  settings JSONB DEFAULT '{}', -- Configuraciones específicas del negocio
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_businesses_type ON businesses(business_type);
CREATE INDEX idx_businesses_active ON businesses(is_active);
```

#### 2. **branches** (Sucursales/Ubicaciones)
```sql
CREATE TABLE branches (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL,
  address TEXT,
  phone VARCHAR(20),
  manager_name VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_branches_business ON branches(business_id);
CREATE INDEX idx_branches_active ON branches(is_active);
```

#### 3. **roles** (Roles del Sistema)
```sql
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  code VARCHAR(50) NOT NULL, -- 'superadmin', 'admin', 'manager', 'staff', 'cashier', 'waiter'
  description TEXT,
  is_system_role BOOLEAN DEFAULT false, -- true para roles predefinidos del sistema
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(business_id, code)
);

CREATE INDEX idx_roles_business ON roles(business_id);
CREATE INDEX idx_roles_code ON roles(code);
```

#### 4. **permissions** (Permisos Granulares)
```sql
CREATE TABLE permissions (
  id SERIAL PRIMARY KEY,
  module VARCHAR(50) NOT NULL, -- 'products', 'sales', 'inventory', 'users', 'reports', 'settings'
  action VARCHAR(50) NOT NULL, -- 'create', 'read', 'update', 'delete', 'export', 'approve'
  code VARCHAR(100) UNIQUE NOT NULL, -- 'products.create', 'sales.read', 'inventory.adjust'
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_permissions_module ON permissions(module);
CREATE INDEX idx_permissions_code ON permissions(code);
```

#### 5. **role_permissions** (Relación Roles-Permisos)
```sql
CREATE TABLE role_permissions (
  id SERIAL PRIMARY KEY,
  role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);
```

#### 6. **users** (Usuarios del Sistema)
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER REFERENCES branches(id) ON DELETE SET NULL,
  role_id INTEGER NOT NULL REFERENCES roles(id),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  employee_code VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_business ON users(business_id);
CREATE INDEX idx_users_branch ON users(branch_id);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_users_username ON users(username);
```

#### 7. **product_categories** (Categorías de Productos)
```sql
CREATE TABLE product_categories (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  parent_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  icon VARCHAR(50),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_categories_business ON product_categories(business_id);
CREATE INDEX idx_categories_parent ON product_categories(parent_id);
CREATE INDEX idx_categories_active ON product_categories(is_active);
```

#### 8. **products** (Productos del Inventario)
```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
  sku VARCHAR(50), -- Stock Keeping Unit
  barcode VARCHAR(100),
  name VARCHAR(150) NOT NULL,
  description TEXT,
  unit_type VARCHAR(30) NOT NULL, -- 'unit', 'kg', 'liter', 'box', 'pack', 'dozen'
  units_per_package INTEGER DEFAULT 1,
  cost_price DECIMAL(12,2) DEFAULT 0,
  sale_price DECIMAL(12,2) NOT NULL,
  tax_rate DECIMAL(5,2) DEFAULT 0,
  min_stock_alert INTEGER DEFAULT 10,
  max_stock_limit INTEGER,
  image_url VARCHAR(255),
  supplier VARCHAR(150),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(business_id, sku)
);

CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_sku ON products(sku);
```

#### 9. **branch_stock** (Stock por Sucursal)
```sql
CREATE TABLE branch_stock (
  id SERIAL PRIMARY KEY,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  current_stock DECIMAL(12,3) DEFAULT 0,
  reserved_stock DECIMAL(12,3) DEFAULT 0, -- Stock reservado/comprometido
  available_stock DECIMAL(12,3) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
  last_updated TIMESTAMP DEFAULT NOW(),
  UNIQUE(branch_id, product_id)
);

CREATE INDEX idx_branch_stock_branch ON branch_stock(branch_id);
CREATE INDEX idx_branch_stock_product ON branch_stock(product_id);
CREATE INDEX idx_branch_stock_available ON branch_stock(available_stock);
```

#### 10. **sales** (Registro de Ventas)
```sql
CREATE TABLE sales (
  id BIGSERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id),
  sale_number VARCHAR(50) UNIQUE NOT NULL,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  customer_phone VARCHAR(20),
  subtotal DECIMAL(12,2) NOT NULL,
  tax_amount DECIMAL(12,2) DEFAULT 0,
  discount_amount DECIMAL(12,2) DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(30), -- 'cash', 'card', 'transfer', 'mixed'
  status VARCHAR(20) DEFAULT 'completed', -- 'pending', 'completed', 'cancelled', 'refunded'
  sale_date TIMESTAMP DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sales_business ON sales(business_id);
CREATE INDEX idx_sales_branch ON sales(branch_id);
CREATE INDEX idx_sales_user ON sales(user_id);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sales_number ON sales(sale_number);
```

#### 11. **sale_items** (Detalle de Ventas)
```sql
CREATE TABLE sale_items (
  id BIGSERIAL PRIMARY KEY,
  sale_id BIGINT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity DECIMAL(12,3) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  tax_rate DECIMAL(5,2) DEFAULT 0,
  discount_percent DECIMAL(5,2) DEFAULT 0,
  subtotal DECIMAL(12,2) NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);
```

#### 12. **inventory_movements** (Movimientos de Inventario)
```sql
CREATE TABLE inventory_movements (
  id BIGSERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  movement_type VARCHAR(30) NOT NULL, -- 'entry', 'exit', 'adjustment', 'transfer', 'sale', 'return', 'loss'
  quantity DECIMAL(12,3) NOT NULL,
  previous_stock DECIMAL(12,3) NOT NULL,
  new_stock DECIMAL(12,3) NOT NULL,
  unit_cost DECIMAL(12,2),
  reference_type VARCHAR(50), -- 'sale', 'purchase', 'adjustment', 'transfer'
  reference_id BIGINT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_movements_business ON inventory_movements(business_id);
CREATE INDEX idx_movements_branch ON inventory_movements(branch_id);
CREATE INDEX idx_movements_product ON inventory_movements(product_id);
CREATE INDEX idx_movements_type ON inventory_movements(movement_type);
CREATE INDEX idx_movements_date ON inventory_movements(created_at);
CREATE INDEX idx_movements_reference ON inventory_movements(reference_type, reference_id);
```

#### 13. **stock_replenishments** (Reposiciones de Stock)
```sql
CREATE TABLE stock_replenishments (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id),
  replenishment_number VARCHAR(50) UNIQUE NOT NULL,
  supplier VARCHAR(150),
  invoice_number VARCHAR(50),
  total_cost DECIMAL(12,2),
  payment_method VARCHAR(30),
  status VARCHAR(20) DEFAULT 'completed', -- 'pending', 'completed', 'cancelled'
  replenishment_date TIMESTAMP DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_replenishments_business ON stock_replenishments(business_id);
CREATE INDEX idx_replenishments_branch ON stock_replenishments(branch_id);
CREATE INDEX idx_replenishments_date ON stock_replenishments(replenishment_date);
CREATE INDEX idx_replenishments_number ON stock_replenishments(replenishment_number);
```

#### 14. **replenishment_items** (Detalle de Reposiciones)
```sql
CREATE TABLE replenishment_items (
  id SERIAL PRIMARY KEY,
  replenishment_id INTEGER NOT NULL REFERENCES stock_replenishments(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity DECIMAL(12,3) NOT NULL,
  unit_cost DECIMAL(12,2),
  total_cost DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_replenishment_items_replenishment ON replenishment_items(replenishment_id);
CREATE INDEX idx_replenishment_items_product ON replenishment_items(product_id);
```

#### 15. **audit_logs** (Auditoría del Sistema)
```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(50) NOT NULL, -- 'create', 'update', 'delete', 'login', 'logout'
  entity_type VARCHAR(50) NOT NULL, -- 'product', 'sale', 'user', etc.
  entity_id INTEGER,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_business ON audit_logs(business_id);
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_date ON audit_logs(created_at);
```

#### 16. **price_history** (Historial de Precios)
```sql
CREATE TABLE price_history (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  old_cost_price DECIMAL(12,2),
  new_cost_price DECIMAL(12,2),
  old_sale_price DECIMAL(12,2),
  new_sale_price DECIMAL(12,2),
  changed_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  reason TEXT,
  changed_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_price_history_product ON price_history(product_id);
CREATE INDEX idx_price_history_date ON price_history(changed_at);
```

#### 17. **shifts** (Turnos de Trabajo)
```sql
CREATE TABLE shifts (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id),
  shift_number VARCHAR(50) UNIQUE NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  initial_cash DECIMAL(12,2) DEFAULT 0,
  final_cash DECIMAL(12,2),
  expected_cash DECIMAL(12,2),
  cash_difference DECIMAL(12,2),
  total_sales DECIMAL(12,2),
  status VARCHAR(20) DEFAULT 'open', -- 'open', 'closed', 'reviewed'
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_shifts_business ON shifts(business_id);
CREATE INDEX idx_shifts_branch ON shifts(branch_id);
CREATE INDEX idx_shifts_user ON shifts(user_id);
CREATE INDEX idx_shifts_status ON shifts(status);
CREATE INDEX idx_shifts_start ON shifts(start_time);
```

#### 18. **promotions** (Promociones y Descuentos)
```sql
CREATE TABLE promotions (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed_amount'
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase_amount DECIMAL(12,2),
  applies_to VARCHAR(20) DEFAULT 'all', -- 'all', 'category', 'product'
  target_id INTEGER, -- ID de categoría o producto si aplica
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_promotions_business ON promotions(business_id);
CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date);
CREATE INDEX idx_promotions_active ON promotions(is_active);
```

---

## 🏗️ Arquitectura de Módulos NestJS

### Estructura del Proyecto
```
src/
├── main.ts
├── app.module.ts
├── config/
│   ├── database.config.ts
│   ├── jwt.config.ts
│   ├── app.config.ts
│   └── permissions.config.ts
├── common/
│   ├── decorators/
│   │   ├── permissions.decorator.ts
│   │   ├── roles.decorator.ts
│   │   ├── current-user.decorator.ts
│   │   └── business-context.decorator.ts
│   ├── guards/
│   │   ├── jwt-auth.guard.ts
│   │   ├── permissions.guard.ts
│   │   ├── roles.guard.ts
│   │   └── business-access.guard.ts
│   ├── interceptors/
│   │   ├── logging.interceptor.ts
│   │   ├── transform.interceptor.ts
│   │   └── audit.interceptor.ts
│   ├── filters/
│   │   └── http-exception.filter.ts
│   ├── interfaces/
│   │   ├── pagination.interface.ts
│   │   └── business-context.interface.ts
│   └── utils/
│       ├── number-generator.util.ts
│       └── date.util.ts
├── modules/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── strategies/
│   │   │   ├── jwt.strategy.ts
│   │   │   └── local.strategy.ts
│   │   └── dto/
│   │       ├── login.dto.ts
│   │       ├── register.dto.ts
│   │       └── refresh-token.dto.ts
│   ├── businesses/
│   │   ├── businesses.controller.ts
│   │   ├── businesses.service.ts
│   │   ├── businesses.module.ts
│   │   ├── entities/
│   │   │   └── business.entity.ts
│   │   └── dto/
│   │       ├── create-business.dto.ts
│   │       └── update-business.dto.ts
│   ├── branches/
│   │   ├── branches.controller.ts
│   │   ├── branches.service.ts
│   │   ├── branches.module.ts
│   │   ├── entities/
│   │   │   └── branch.entity.ts
│   │   └── dto/
│   │       ├── create-branch.dto.ts
│   │       └── update-branch.dto.ts
│   ├── roles/
│   │   ├── roles.controller.ts
│   │   ├── roles.service.ts
│   │   ├── roles.module.ts
│   │   ├── entities/
│   │   │   ├── role.entity.ts
│   │   │   ├── permission.entity.ts
│   │   │   └── role-permission.entity.ts
│   │   └── dto/
│   │       ├── create-role.dto.ts
│   │       ├── update-role.dto.ts
│   │       └── assign-permissions.dto.ts
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.module.ts
│   │   ├── entities/
│   │   │   └── user.entity.ts
│   │   └── dto/
│   │       ├── create-user.dto.ts
│   │       ├── update-user.dto.ts
│   │       └── change-password.dto.ts
│   ├── products/
│   │   ├── products.controller.ts
│   │   ├── products.service.ts
│   │   ├── products.module.ts
│   │   ├── categories.controller.ts
│   │   ├── categories.service.ts
│   │   ├── entities/
│   │   │   ├── product.entity.ts
│   │   │   └── product-category.entity.ts
│   │   └── dto/
│   │       ├── create-product.dto.ts
│   │       ├── update-product.dto.ts
│   │       ├── create-category.dto.ts
│   │       └── filter-product.dto.ts
│   ├── inventory/
│   │   ├── inventory.controller.ts
│   │   ├── inventory.service.ts
│   │   ├── inventory.module.ts
│   │   ├── entities/
│   │   │   ├── branch-stock.entity.ts
│   │   │   ├── inventory-movement.entity.ts
│   │   │   ├── stock-replenishment.entity.ts
│   │   │   └── replenishment-item.entity.ts
│   │   └── dto/
│   │       ├── replenish-stock.dto.ts
│   │       ├── adjust-stock.dto.ts
│   │       └── transfer-stock.dto.ts
│   ├── sales/
│   │   ├── sales.controller.ts
│   │   ├── sales.service.ts
│   │   ├── sales.module.ts
│   │   ├── entities/
│   │   │   ├── sale.entity.ts
│   │   │   └── sale-item.entity.ts
│   │   └── dto/
│   │       ├── create-sale.dto.ts
│   │       ├── create-sale-item.dto.ts
│   │       └── sales-report.dto.ts
│   ├── reports/
│   │   ├── reports.controller.ts
│   │   ├── reports.service.ts
│   │   ├── reports.module.ts
│   │   └── dto/
│   │       ├── date-range.dto.ts
│   │       ├── sales-stats.dto.ts
│   │       └── inventory-stats.dto.ts
│   ├── dashboard/
│   │   ├── dashboard.controller.ts
│   │   ├── dashboard.service.ts
│   │   └── dashboard.module.ts
│   ├── shifts/
│   │   ├── shifts.controller.ts
│   │   ├── shifts.service.ts
│   │   ├── shifts.module.ts
│   │   ├── entities/
│   │   │   └── shift.entity.ts
│   │   └── dto/
│   │       ├── open-shift.dto.ts
│   │       └── close-shift.dto.ts
│   ├── promotions/
│   │   ├── promotions.controller.ts
│   │   ├── promotions.service.ts
│   │   ├── promotions.module.ts
│   │   ├── entities/
│   │   │   └── promotion.entity.ts
│   │   └── dto/
│   │       ├── create-promotion.dto.ts
│   │       └── update-promotion.dto.ts
│   └── audit/
│       ├── audit.service.ts
│       ├── audit.module.ts
│       └── entities/
│           └── audit-log.entity.ts
└── database/
    ├── migrations/
    └── seeds/
        ├── 001-permissions.seed.ts
        ├── 002-roles.seed.ts
        └── 003-superadmin.seed.ts
```

---

## 📡 Definición de APIs REST

### 1. **Autenticación** (`/api/auth`)
```typescript
POST   /auth/login           // Login de usuario
POST   /auth/register        // Registro de nuevo negocio
POST   /auth/refresh         // Refresh token
GET    /auth/profile         // Obtener perfil del usuario autenticado
POST   /auth/logout          // Cerrar sesión
PATCH  /auth/change-password // Cambiar contraseña propia
```

### 2. **Negocios** (`/api/businesses`)
```typescript
GET    /businesses           // Listar negocios
GET    /businesses/:id       // Obtener negocio por ID
POST   /businesses           // Crear negocio (solo superadmin)
PATCH  /businesses/:id       // Actualizar negocio
DELETE /businesses/:id       // Desactivar negocio
GET    /businesses/:id/stats // Estadísticas del negocio
```

### 3. **Sucursales** (`/api/branches`)
```typescript
GET    /branches             // Listar sucursales del negocio
GET    /branches/:id         // Obtener sucursal por ID
POST   /branches             // Crear sucursal
PATCH  /branches/:id         // Actualizar sucursal
DELETE /branches/:id         // Desactivar sucursal
GET    /branches/:id/stock   // Stock de la sucursal
```

### 4. **Roles y Permisos** (`/api/roles`, `/api/permissions`)
```typescript
GET    /roles                // Listar roles del negocio
GET    /roles/:id            // Obtener rol por ID
POST   /roles                // Crear rol personalizado
PATCH  /roles/:id            // Actualizar rol
DELETE /roles/:id            // Eliminar rol
POST   /roles/:id/permissions // Asignar permisos a rol
GET    /permissions          // Listar permisos disponibles
GET    /permissions/by-module // Permisos agrupados por módulo
```

### 5. **Usuarios** (`/api/users`)
```typescript
GET    /users                // Listar usuarios (paginado, filtrado)
GET    /users/:id            // Obtener usuario por ID
POST   /users                // Crear usuario
PATCH  /users/:id            // Actualizar usuario
DELETE /users/:id            // Desactivar usuario (soft delete)
PATCH  /users/:id/role       // Cambiar rol de usuario
GET    /users/:id/permissions // Ver permisos del usuario
```

### 6. **Categorías de Productos** (`/api/categories`)
```typescript
GET    /categories           // Listar categorías (con jerarquía)
GET    /categories/:id       // Obtener categoría por ID
POST   /categories           // Crear categoría
PATCH  /categories/:id       // Actualizar categoría
DELETE /categories/:id       // Eliminar categoría
GET    /categories/:id/products // Productos de la categoría
```

### 7. **Productos** (`/api/products`)
```typescript
GET    /products             // Listar productos (con filtros)
GET    /products/:id         // Obtener producto por ID
POST   /products             // Crear producto
PATCH  /products/:id         // Actualizar producto
DELETE /products/:id         // Desactivar producto
GET    /products/low-stock   // Productos con stock bajo
GET    /products/:id/stock-by-branch // Stock por sucursal
GET Sistema de Permisos Granulares

El sistema utiliza un enfoque basado en **permisos granulares**, no solo roles. Cada rol puede tener múltiples permisos asignados.

#### Módulos y Acciones

| Módulo | Acciones Disponibles |
|--------|---------------------|
| **businesses** | create, read, update, delete, manage_settings |
| **branches** | create, read, update, delete, view_stock |
| **users** | create, read, update, delete, change_role, reset_password |
| **roles** | create, read, update, delete, assign_permissions |
| **products** | create, read, update, delete, adjust_price, bulk_import |
| **categories** | create, read, update, delete |
| **inventory** | view_stock, replenish, adjust, transfer, approve_adjustment |
| **sales** | create, read, update, cancel, refund, view_all, view_own |
| **reports** | view_sales, view_inventory, view_financial, export |
| **dashboard** | view_general, view_detailed |
| **shifts** | open, close, view_own, view_all |
| **promotions** | create, read, update, delete, activate |
| **audit** | view_logs |

#### Formato de Permisos

Los permisos siguen el formato: `module.action`

Ejemplos:
- `products.create` - Crear productos
- `sales.read` - Ver ventas
- `inventory.adjust` - Ajustar inventario
- `reports.export` - Exportar reportes

### Roles Predefinidos del Sistema

#### 1. **Superadmin** (Administrador Global)
```typescript
Permisos: ['*'] // Todos los permisos
Descripción: Control total del sistema, gestión de múltiples negocios
```

#### 2. **Business Owner** (Dueño del Negocio)
```typescript
Permisos: [
  'businesses.read', 'businesses.update',
  'branches.*', // Control total de sucursales
  'users.*', 'roles.*',
  'products.*', 'categories.*',
  'inventory.*', 'sales.*',
  'reports.*', 'dashboard.*',
  'shifts.view_all',
  'promotions.*',
  'audit.view_logs'
]
```

#### 3. **Manager** (Gerente/Encargado)
```typescript
Permisos: [
  'branches.read', 'branches.view_stock',
  'users.read', 'users.update',
  'products.*', 'categories.read',
  'inventory.*',
  'sales.*',
  'reports.view_sales', 'reports.view_inventory', 'reports.export',
  'dashboard.view_general',
  'shifts.*',
  'promotions.read'
]
```

#### 4. **Cashier** (Cajero)
```typescript
Permisos: [
  'products.read',
  'inventory.view_stock',
  'sales.create', 'sales.read', 'sales.view_own',
  'shifts.open', 'shifts.close', 'shifts.view_own'
]
```

#### 5. **Staff** (Personal/Mesero)
```typescript
Permisos: [
  'products.read',
  'inventory.view_stock',
  'sales.create', 'sales.view_own'
]
```

#### 6. **Warehouse** (Almacén/Bodeguero)
```typescript
Permisos: [
  'products.read', 'products.update',
  'categories.read',
  'inventory.*',
  'reports.view_inventory'
]
```

### Implementación de Guards

#### 1. **PermissionsGuard** (Recomendado)
```typescript
// permissions.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.get<string[]>(
      'permissions',
      context.getHandler(),
    );
    
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }
    
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    
    if (!user || !user.permissions) {
      return false;
    }
    
    // Superadmin tiene todos los permisos
    if (user.permissions.includes('*')) {
      return true;
    }
    
    // Verificar si el usuario tiene alguno de los permisos requeridos
    return requiredPermissions.some(permission => 
      user.permissions.includes(permission)
    );
  }
}

// permissions.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const RequirePermissions = (...permissions: string[]) => 
  SetMetadata('permissions', permissions);

// Uso en controladores
@Post()
@RequirePermissions('products.create')
@UseGuards(JwtAuthGuard, PermissionsGuard)
async createProduct(@Body() dto: CreateProductDto) {
  return this.productsService.create(dto);
}

@Get()
@RequirePermissions('products.read')
@UseGuards(JwtAuthGuard, PermissionsGuard)
async findAll() {
  return this.productsService.findAll();
}
```

#### 2. **BusinessAccessGuard** (Control Multi-Negocio)
```typescript
// business-access.guard.ts
@Injectable()
export class BusinessAccessGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const businessId = request.params.businessId || request.body.businessId;
    
    // Superadmin puede acceder a todos los negocios
    if (user.isSuperadmin) return true;
    
    // Verificar que el usuario pertenezca al negocio
    return user.businessId === parseInt(businessId);
  }
}
```

### JWT Payload Extendido

```typescript
interface JwtPayload {
  sub: number;           // user.id
  username: string;
  email: string;
  businessId: number;
  branchId?: number;
  roleId: number;
  roleCode: string;
  permissions: string[]; // Lista de permisos del usuario
  isSuperadmin: boolean;
  iat: number;
  exp: number
```typescript
GET    /reports/sales/daily        // Reporte de ventas diarias
GET    /reports/sales/weekly       // Reporte semanal
GET    /reports/sales/monthly      // Reporte mensual
GET    /reports/sales/by-product   // Ventas por producto
GET    /reports/sales/by-user      // Ventas por usuario
GET    /reports/sales/by-branch    // Ventas por sucursal
GET    /reports/sales/by-category  // Ventas por categoría
GET    /reports/inventory/valuation // Valorización de inventario
GET    /reports/inventory/movements // Reporte de movimientos
GET    /reports/export/pdf         // Exportar reporte a PDF
GET    /reports/export/excel       // Exportar a Excel
```

### 11. **Dashboard** (`/api/dashboard`)
```typescript
GET    /dashboard/overview       // Resumen general (ventas, stock, ingresos)
GET    /dashboard/top-products   // Productos más vendidos
GET    /dashboard/sales-trends   // Tendencias de ventas
GET    /dashboard/revenue        // Ingresos por período
GET    /dashboard/low-stock      // Resumen de productos con stock bajo
GET    /dashboard/by-branch      // Comparativa entre sucursales
```

### 12. **Turnos** (`/api/shifts`)
```typescript
GET    /shifts               // Listar turnos
GET    /shifts/:id           // Obtener turno por ID
POST   /shifts/open          // Abrir turno
PATCH  /shifts/:id/close     // Cerrar turno
GET    /shifts/active        // Turnos activos
GET    /shifts/:id/sales     // Ventas del turno
```

### 13. **Promociones** (`/api/promotions`)
```typescript
GET    /promotions           // Listar promociones
GET    /promotions/:id       // Obtener promoción por ID
POST   /promotions           // Crear promoción
PATCH  /promotions/:id       // Actualizar promoción
DELETE /promotions/:id       // Eliminar promoción
GET    /promotions/active    // Promociones activas
```

### 14. **Auditoría** (`/api/audit`)
```typescript
GET    /audit/logs           // Listar logs de auditoría
GET    /audit/logs/:id       // Detalle de log
GET    /audit/user/:userId   // Logs por usuario
GET    /audit/entity/:type/:id // Logs de una entidad específica
```

---

## 🔐 Sistema de Autenticación y Autorización

### Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **Superadmin** | • Acceso total al sistema<br>• Crear/editar/eliminar usuarios<br>• Ver todos los reportes<br>• Gestionar productos y precios<br>• Acceso a auditoría completa |
| **Bar Manager** | • Control de stock completo<br>• Registrar ventas<br>• Reposiciones de inventario<br>• Ver reportes de su turno<br>• Ajustes de inventario |
| **Waiter** | • Registrar ventas personales<br>• Ver stock disponible (solo lectura)<br>• Ver historial propio de ventas |

### Implementación de Guards

```typescript
// roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) return true;
    
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    
    return requiredRoles.some((role) => user.role === role);
  }
}

// Uso en controladores
@Post()
@Roles('superadmin', 'bar_manager')
@UseGuards(JwtAuthGuard, RolesGuard)
createProduct(@Body() dto: CreateProductDto) {
  return this.productsService.create(dto);
}
```

---

## 📅 Plan de Implementación por Fases

### **FASE 1: Configuración Inicial y Base** (Semana 1)
**Duración estimada: 5-7 días**

#### Tareas:
- ✅ Inicializar proyecto NestJS
  ```bash
  npm i -g @nestjs/cli
  nest new wizepick-back
  ```
- ✅ Configurar TypeORM + PostgreSQL (IDs numéricos)
- ✅ Configurar variables de entorno (.env)
- ✅ Crear esquema de base de datos completo
- ✅ Configurar Swagger para documentación API
- ✅ Configurar ESLint y Prettier
- ✅ Setup de Git y .gitignore
- ✅ Configurar estructura modular

#### Entregables:
- Proyecto NestJS funcionando
- Conexión a PostgreSQL establecida
- Base de datos con 18 tablas creadas
- Documentación Swagger disponible en `/api/docs`

---

### **FASE 2: Sistema de Permisos y Roles** (Semana 1-2)
**Duración estimada: 6-8 días**

#### Tareas:
- ✅ Crear módulo de permisos
- ✅ Crear módulo de roles
- ✅ Implementar relación roles-permisos (muchos a muchos)
- ✅ Crear seeds de permisos base del sistema
- ✅ Crear seeds de roles predefinidos (superadmin, owner, manager, cashier, staff, warehouse)
- ✅ Implementar PermissionsGuard
- ✅ Implementar decorador @RequirePermissions
- ✅ API CRUD de roles
- ✅ API para asignar/remover permisos a roles

#### Entregables:
- Sistema de permisos granulares funcional
- 6 roles predefinidos con sus permisos
- Guards para validación de permisos
- Endpoints de gestión de roles y permisos

#### Endpoints Completados:
- `GET /roles`
- `POST /roles`
- `PATCH /roles/:id`
- `POST /roles/:id/permissions`
- `GET /permissions`
- `GET /permissions/by-module`

---

### **FASE 3: Negocios y Sucursales** (Semana 2)
**Duración estimada: 4-5 días**

#### Tareas:
- ✅ Crear módulo de negocios (businesses)
- ✅ Crear módulo de sucursales (branches)
- ✅ Implementar CRUD de negocios
- ✅ Implementar CRUD de sucursales
- ✅ Configuración de tipos de negocio
- ✅ Implementar BusinessAccessGuard
- ✅ Relación negocio-sucursales
- ✅ Validaciones de contexto de negocio

#### Entregables:
- Multi-tenant básico funcional
- Gestión de negocios y sucursales
- Control de acceso por negocio

#### Endpoints Completados:
- `GET /businesses`
- `POST /businesses`
- `PATCH /businesses/:id`
- `GET /branches`
- `POST /branches`
- `PATCH /branches/:id`

---

### **FASE 4: Autenticación y Usuarios** (Semana 2-3)
**Duración estimada: 5-7 días**

#### Tareas:
- ✅ Crear módulo de usuarios (con relaciones a business, branch, role)
- ✅ Implementar módulo de autenticación (JWT extendido)
- ✅ Configurar Passport + JWT Strategy
- ✅ Implementar Guards (JwtAuthGuard, PermissionsGuard, BusinessAccessGuard)
- ✅ Implementar registro de negocios
- ✅ Login con carga de permisos en JWT
- ✅ Hash de contraseñas con bcrypt
- ✅ Sistema de refresh tokens
- ✅ Crear seed inicial de superadmin
- ✅ Endpoint de cambio de contraseña

#### Entregables:
- API de autenticación funcional
- Sistema de permisos integrado en JWT
- Usuarios vinculados a negocios y roles
- Control de acceso multi-negocio

#### Endpoints Completados:
- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/profile`
- `POST /auth/refresh`
- `PATCH /auth/change-password`
- `GET /users`
- `POST /users`
- `PATCH /users/:id`
- `GET /users/:id/permissions`

---

### **FASE 5: Categorías y Productos** (Semana 3-4)
**Duración estimada: 6-7 días**

#### Tareas:
- ✅ Crear entidad ProductCategory (jerárquica)
- ✅ Implementar CRUD de categorías
- ✅ Crear entidad Product con relaciones
- ✅ Implementar CRUD completo de productos
- ✅ Validaciones con class-validator
- ✅ Filtros y búsqueda de productos
- ✅ Sistema de SKU único por negocio
- ✅ Soporte para códigos de barras
- ✅ Categorización jerárquica
- ✅ Importación masiva de productos
- ✅ Historial de precios

#### Entregables:
- Módulo de categorías con jerarquía
- Módulo de productos completo
- Sistema de SKU y códigos de barras
- Importación masiva

#### Endpoints Completados:
- `GET /categories`
- `POST /categories`
- `GET /categories/:id/products`
- `GET /products`
- `GET /products/:id`
- `POST /products`
- `PATCH /products/:id`
- `DELETE /products/:id`
- `POST /products/bulk-import`

---

### **FASE 6: Control de Inventario Multi-Sucursal** (Semana 4-5)
**Duración estimada: 7-9 días**

#### Tareas:
- ✅ Crear entidad BranchStock (stock por sucursal)
- ✅ Crear entidad InventoryMovement
- ✅ Crear entidades StockReplenishment y ReplenishmentItem
- ✅ Implementar servicio de gestión de inventario
- ✅ Stock separado por sucursal
- ✅ Registro automático de movimientos
- ✅ Reposición de stock con detalles
- ✅ Ajustes manuales de inventario
- ✅ Transferencias entre sucursales
- ✅ Validación de stock disponible
- ✅ Historial completo de movimientos
- ✅ Alertas de stock bajo por sucursal

#### Entregables:
- Sistema de inventario multi-sucursal
- Trazabilidad completa de movimientos
- Transferencias entre sucursales
- Alertas por sucursal

#### Endpoints Completados:
- `GET /inventory/stock`
- `GET /inventory/stock/:branchId`
- `GET /inventory/movements`
- `POST /inventory/replenish`
- `POST /inventory/adjust`
- `POST /inventory/transfer`
- `GET /inventory/alerts`
- `GET /inventory/replenishments`

---

### **FASE 7: Sistema de Ventas** (Semana 5-6)
**Duración estimada: 6-8 días**

#### Tareas:
- ✅ Crear entidades Sale y SaleItem
- ✅ Implementar registro de ventas con items
- ✅ Numeración automática de ventas
- ✅ Actualización automática de stock por sucursal
- ✅ Validación de stock disponible antes de venta
- ✅ Registro de movimiento de inventario por venta
- ✅ Cálculo de impuestos y descuentos
- ✅ Múltiples métodos de pago
- ✅ Cancelación de ventas
- ✅ Sistema de devoluciones/reembolsos
- ✅ Historial de ventas con filtros
- ✅ Generación de recibos
- ✅ Transacciones atómicas (venta + stock + movimientos)

#### Entregables:
- Módulo de ventas completo
- Ventas con items múltiples
- Actualización automática de inventario
- Sistema de cancelaciones y devoluciones
- Generación de recibos

#### Endpoints Completados:
- `POST /sales`
- `GET /sales`
- `GET /sales/:id`
- `PATCH /sales/:id/cancel`
- `POST /sales/:id/refund`
- `GET /sales/user/:userId`
- `GET /sales/today`
- `GET /sales/date-range`
- `GET /sales/:id/receipt`

---

### **FASE 8: Reportes y Estadísticas** (Semana 6-7)
**Duración estimada: 6-8 días**

#### Tareas:
- ✅ Crear módulo de reportes
- ✅ Reportes de ventas (diario, semanal, mensual)
- ✅ Reportes por producto/categoría
- ✅ Reportes por usuario
- ✅ Reportes por sucursal
- ✅ Estadísticas de ingresos
- ✅ Productos más vendidos
- ✅ Valorización de inventario
- ✅ Reporte de movimientos de inventario
- ✅ Consultas optimizadas con agregaciones SQL
- ✅ Exportación a JSON (base para PDF/Excel)
- ✅ Caché de reportes frecuentes
- ✅ Comparativas entre períodos

#### Entregables:
- Sistema de reportes funcional
- Reportes por múltiples dimensiones
- Estadísticas en tiempo real
- Datos listos para exportación

#### Endpoints Completados:
- `GET /reports/sales/daily`
- `GET /reports/sales/weekly`
- `GET /reports/sales/monthly`
- `GET /reports/sales/by-product`
- `GET /reports/sales/by-user`
- `GET /reports/sales/by-branch`
- `GET /reports/sales/by-category`
- `GET /reports/inventory/valuation`
- `GET /reports/inventory/movements`

---

### **FASE 9: Dashboard Multi-Negocio** (Semana 7)
**Duración estimada: 4-5 días**

#### Tareas:
- ✅ Crear módulo de dashboard
- ✅ Endpoint de resumen general por negocio
- ✅ Estadísticas por sucursal
- ✅ Top productos más vendidos
- ✅ Tendencias de ventas
- ✅ Indicadores visuales de rendimiento
- ✅ Métricas en tiempo real
- ✅ Gráficas de ingresos por período
- ✅ Comparativas entre sucursales
- ✅ Alertas de stock bajo

#### Entregables:
- API de dashboard con datos agregados
- Métricas de rendimiento del negocio
- Comparativas entre sucursales

#### Endpoints Completados:
- `GET /dashboard/overview`
- `GET /dashboard/top-products`
- `GET /dashboard/sales-trends`
- `GET /dashboard/revenue`
- `GET /dashboard/low-stock`
- `GET /dashboard/by-branch`

---

### **FASE 10: Turnos y Promociones** (Semana 8)
**Duración estimada: 5-6 días**

#### Tareas:
- ✅ Crear módulo de turnos (shifts)
- ✅ Apertura y cierre de turno
- ✅ Control de efectivo por turno
- ✅ Conciliación de ventas
- ✅ Crear módulo de promociones
- ✅ Gestión de descuentos y promociones
- ✅ Aplicación automática de promociones
- ✅ Validación de fechas de vigencia

#### Entregables:
- Sistema de turnos funcional
- Control de efectivo
- Sistema de promociones activo

#### Endpoints Completados:
- `POST /shifts/open`
- `PATCH /shifts/:id/close`
- `GET /shifts/active`
- `GET /shifts/:id/sales`
- `GET /promotions`
- `POST /promotions`
- `GET /promotions/active`

---

### **FASE 11: Auditoría y Seguridad** (Semana 8-9)
**Duración estimada: 5-6 días**

#### Tareas:
- ✅ Implementar módulo de auditoría completo
- ✅ Interceptor para logging automático
- ✅ Registro de todas las acciones críticas
- ✅ Almacenamiento de cambios (old/new values en JSONB)
- ✅ Registro de IP y user agent
- ✅ Consulta de logs por usuario/fecha/entidad
- ✅ Implementar rate limiting
- ✅ Validación de CORS
- ✅ Helmet para headers de seguridad
- ✅ Sanitización de inputs

#### Entregables:
- Sistema de auditoría completo
- Logs de todas las acciones críticas
- Seguridad mejorada

#### Endpoints Completados:
- `GET /audit/logs`
- `GET /audit/user/:userId`
- `GET /audit/entity/:type/:id`

---

### **FASE 12: Testing y Documentación** (Semana 9-10)
**Duración estimada: 6-8 días**

#### Tareas:
- ✅ Tests unitarios de servicios críticos
- ✅ Tests de integración de endpoints principales
- ✅ Tests de autenticación y autorización
- ✅ Tests de permisos
- ✅ Tests de transacciones de inventario
- ✅ Documentación completa de Swagger
- ✅ README con instrucciones de instalación
- ✅ Documentación de base de datos
- ✅ Guía de despliegue
- ✅ Documentación de API

#### Entregables:
- Cobertura de tests >70%
- Documentación completa
- Guía de deployment

---

### **FASE 13: Funcionalidades Adicionales** (Semana 10-12) - Opcional
**Duración estimada: 10-15 días**

#### Tareas Opcionales (Prioridad Media-Baja):
- ⬜ Exportación de reportes a PDF (usando pdfkit o puppeteer)
- ⬜ Exportación a Excel (usando exceljs)
- ⬜ Sistema de notificaciones (email para stock bajo)
- ⬜ Notificaciones en tiempo real (WebSockets)
- ⬜ Sistema de backup automático
- ⬜ Dashboard en tiempo real con gráficas
- ⬜ Sistema de multi-moneda
- ⬜ Integración con impresoras fiscales
- ⬜ App móvil (opcional, requiere desarrollo adicional)

---

## ⚡ Comandos Iniciales de Setup

### 1. Instalar pnpm (si no lo tienes)
```bash
# Opción 1: Con npm
npm install -g pnpm

# Opción 2: Con corepack (recomendado - viene con Node 16.13+)
corepack enable
corepack prepare pnpm@latest --activate
```

### 2. Crear Proyecto
```bash
cd c:\Users\STEVE\Desktop\WizeProyect\wizepick-back
pnpm add -g @nestjs/cli
nest new . --package-manager pnpm
```

### 3. Instalar Dependencias
```bash
# TypeORM y PostgreSQL
pnpm add @nestjs/typeorm typeorm pg

# Autenticación y Seguridad
pnpm add @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt
pnpm add -D @types/passport-jwt @types/bcrypt

# Configuración y Validación
pnpm add @nestjs/config class-validator class-transformer

# Documentación API
pnpm add @nestjs/swagger

# Seguridad adicional
pnpm add helmet @nestjs/throttler

# Utilidades
pnpm add @nestjs/schedule
```

### 3. Configurar PostgreSQL
```bash
# Crear base de datos
psql -U postgres
CREATE DATABASE wizepick_db;
\q
```

### 4. Archivo .env
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=wizepick_db
DATABASE_SYNCHRONIZE=false  # Usar migraciones en producción

# JWT
JWT_SECRET=your-super-secret-jwt-key-min-32-characters-long
JWT_EXPIRATION=24h
JWT_REFRESH_SECRET=your-refresh-secret-key-min-32-characters  
JWT_REFRESH_EXPIRATION=7d

# App
PORT=3000
NODE_ENV=development
API_PREFIX=api
CORS_ORIGINS=http://localhost:4200,http://localhost:3001

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

### 5. Crear Script de Migraciones
Agregar a `package.json`:
```json
{
  "scripts": {
    "typeorm": "ts-node -r tsconfig-paths/register ./node_modules/typeorm/cli.js",
    "migration:generate": "pnpm typeorm -- migration:generate -d src/config/ormconfig.ts -n",
    "migration:create": "pnpm typeorm -- migration:create -n",
    "migration:run": "pnpm typeorm -- migration:run -d src/config/ormconfig.ts",
    "migration:revert": "pnpm typeorm -- migration:revert -d src/config/ormconfig.ts",
    "seed:permissions": "ts-node src/database/seeds/001-permissions.seed.ts",
    "seed:roles": "ts-node src/database/seeds/002-roles.seed.ts",
    "seed:superadmin": "ts-node src/database/seeds/003-superadmin.seed.ts"
  }
}
```

### 6. Ejecutar Migraciones
```bash
# Generar migración inicial con todas las tablas
pnpm migration:generate InitialSchema

# Ejecutar migraciones
pnpm migration:run
```

### 7. Ejecutar Seeds
```bash
# Seeds en orden
pnpm seed:permissions  # Crear permisos del sistema
pnpm seed:roles        # Crear roles predefinidos
pnpm seed:superadmin   # Crear usuario superadmin inicial
```

### 8. Iniciar Servidor
```bash
pnpm start:dev
```

### 9. Verificar Instalación
- API Base: `http://localhost:3000/api`
- Swagger Docs: `http://localhost:3000/api/docs`
- Health Check: `http://localhost:3000/api/health`

---

## 📊 Estimación de Tiempos

| Fase | Descripción | Duración Estimada |
|------|-------------|-------------------|
| 1 | Setup Inicial | 5-7 días |
| 2 | Sistema de Permisos y Roles | 6-8 días |
| 3 | Negocios y Sucursales | 4-5 días |
| 4 | Autenticación y Usuarios | 5-7 días |
| 5 | Categorías y Productos | 6-7 días |
| 6 | Inventario Multi-Sucursal | 7-9 días |
| 7 | Sistema de Ventas | 6-8 días |
| 8 | Reportes y Estadísticas | 6-8 días |
| 9 | Dashboard Multi-Negocio | 4-5 días |
| 10 | Turnos y Promociones | 5-6 días |
| 11 | Auditoría y Seguridad | 5-6 días |
| 12 | Testing y Documentación | 6-8 días |
| 13 | Funcionalidades Adicionales | 10-15 días (opcional) |

**TOTAL ESTIMADO (MVP Completo)**: 65-84 días (13-17 semanas / 3-4 meses)
**TOTAL CON ADICIONALES**: 75-99 días (15-20 semanas / 4-5 meses)

---

## 🎯 Criterios de ÉxitoJWT y permisos granulares
- ✅ Gestión de negocios y sucursales (multi-tenant)
- ✅ Sistema de roles y permisos personalizable
- ✅ 6 roles predefinidos del sistema
- ✅ CRUD completo de productos con categorías
- ✅ Control de inventario multi-sucursal
- ✅ Registro de ventas con items y actualización automática de stock
- ✅ Transferencias de stock entre sucursales
- ✅ Alertas de stock bajo por sucursal
- ✅ Reportes básicos de ventas e inventario
- ✅ API documentada con Swagger
- ✅ Sistema de auditoría completo

### Versión Completa
- ✅ Todo lo anterior
- ✅ Dashboard con estadísticas por negocio y sucursal
- ✅ Sistema de turnos con control de efectivo
- ✅ Promociones y descuentos
- ✅ Exportación de reportes (PDF/Excel)
- ✅ Valorización de inventario
- ✅ Historial de precios
- ✅ Importación masiva de productos
- ✅ Sistema de devoluciones
- ✅ Tests con >70% cobertura
- ✅ Notificaciones automáticas

---

## 🚀 Próximos Pasos Inmediatos

### Paso 1: Setup del Proyecto
```bash
cd c:\Users\STEVE\Desktop\WizeProyect\wizepick-back
npm i -g @nestjs/cli
nest new . --package-manager npm (ya definidos en esquema)
- Usar paginación en todos los endpoints de listado
- Considerar caché (Redis) para:
  - Reportes pesados
  - Permisos de usuarios (reducir consultas a BD)
  - Stock en tiempo real (actualizar cada N segundos)
- Transacciones de base de datos para operaciones críticas (ventas, transferencias)
- Usar vistas materializadas para reportes complejos
- Consultas optimizadas con JOINs selectivos

### Escalabilidad
- **Arquitectura multi-tenant**: Cada negocio es independiente
- **Separación por sucursales**: Stock y ventas por ubicación
- **Estructura modular**: Agregar funcionalidades sin afectar el core
- **Base de datos relacional**: Soporta millones de registros con índices apropiados
- **API RESTful**: Permite integración con múltiples frontends (web, móvil, POS)
- **Preparado para microservicios**: Módulos pueden separarse en el futuro

### Seguridad
- **Contraseñas**: Hasheadas con bcrypt (10 salt rounds)
- **JWT**: 
  - Tokens de acceso cortos (24h)
  - Refresh tokens para renovación (7 días)
  - Firmados con secretos únicos
- **Validación de Inputs**: class-validator en todos los DTOs
- **CORS**: Configurado por dominios permitidos
- **Helmet**: Headers HTTP seguros
- **Rate Limiting**: Prevenir abuso de API
- **SQL Injection**: Protegido por TypeORM (prepared statements)
- **XSS**: Sanitización de inputs
- **Auditoría**: Todas las acciones críticas registradas
- **Permisos granulares**: Control fino de acceso

### Multi-Negocio (Multi-Tenant)
- **Aislamiento de datos**: Cada negocio solo ve sus datos
- **BusinessAccessGuard**: Valida acceso a recursos del negocio correcto
- **Configuraciones personalizables**: JSON en tabla businesses
- **Tipos de negocio soportados**: 
  - Nightclub (discoteca)
  - Restaurant (restaurante)
  - Warehouse (bodega)
  - Retail (tienda minorista)
  - Bar
  - Cafe

### Ventajas del Sistema de IDs Numéricos

#### Performance
- **Menor tamaño**: INTEGER (4 bytes) vs UUID (16 bytes)
- **Índices más rápidos**: Árboles B-Tree más eficientes
- **Joins más rápidos**: Comparaciones numéricas
- **Menor uso de memoria**: Cache más eficiente

#### Usabilidad
- **URLs amigables**: `/products/123` vs `/products/f47ac10b-58cc-4372-a567-0e02b2c3d479`
- **Debugging más fácil**: IDs legibles en logs
- **Compatibilidad**: Mejor integración con sistemas legacy

#### IDs Secuenciales con SERIAL/BIGSERIAL
- `SERIAL`: Hasta 2.1 mil millones (2^31 - 1)
- `BIGSERIAL`: Hasta 9.2 trillones (2^63 - 1)
- Auto-incremento nativo de PostgreSQL
- Transacciones seguras

### Tipos de Negocio y Adaptaciones

#### Discoteca/Bar
- Productos: Bebidas alcohólicas, refrescos, cigarrillos, hielo
- Turnos: Control de efectivo por turno
- Ventas rápidas: Sin detalles de cliente

#### Restaurante
- Productos: Alimentos, bebidas, insumos de cocina
- Categorías: Entradas, platos principales, postres, bebidas
- Mesas: Opcional, se puede agregar módulo de mesas

#### Bodega/Almacén
- Productos: Variados por categoría
- Stock: Enfoque en control estricto de inventario
- Reposiciones: Múltiples proveedores

#### Retail/Tienda
- Productos: Diversos con códigos de barras
- SKU: Identificación única
- Promociones: Sistema de descuentos activo

### Próximas Mejoras Técnicas (Post-MVP)

#### Backend
- [ ] GraphQL API (alternativa a REST)
- [ ] Eventos y colas (Bull/RabbitMQ) para procesos asíncronos
- [ ] WebSockets para actualizaciones en tiempo real
- [ ] Elasticsearch para búsquedas avanzadas
- [ ] Redis para caché distribuido
- [ ] Microservicios (separar módulos críticos)

#### Integraciones
- [ ] Pasarelas de pago (Stripe, PayPal)
- [ ] Impresoras fiscales
- [ ] Lectores de código de barras
- [ ] Balanzas electrónicas
- [ ] Sistemas contables externos
- [ ] APIs de proveedores

#### DevOps
- [ ] Docker containerization
- [ ] CI/CD con GitHub Actions
- [ ] Monitoreo con Prometheus + Grafana
- [ ] Logs centralizados (ELK Stack)
- [ ] Backups automáticos
- [ ] Alta disponibilidad (replicación BD)

---

**Documento creado**: Marzo 2026  
**Última actualización**: Marzo 11, 2026  
**Versión**: 2.0  
**Autor**: GitHub Copilot  
**Cambios v2.0**:
- ✅ IDs numéricos (SERIAL/BIGSERIAL) en lugar de UUID
- ✅ Sistema multi-negocio (multi-tenant)
- ✅ Estructura escalable para diferentes tipos de comercio
- ✅ Sistema de roles y permisos granulares
- ✅ 18 tablas vs 8 tablas originales
- ✅ Sucursales múltiples por negocio
- ✅ Stock separado por sucursal
- ✅ Categorías jerárquicas de productos
- ✅ Sistema de promociones
- ✅ Control de turnos mejorado
- ✅ Auditoría extendida
-- Conectar a PostgreSQL
psql -U postgres

-- Crear base de datos
CREATE DATABASE wizepick_db;

-- Crear usuario (opcional)
CREATE USER wizepick_user WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE wizepick_db TO wizepick_user;

\q
```

### Paso 4: Configurar Variables de Entorno
Crear archivo `.env`:
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_NAME=wizepick_db
DATABASE_SYNCHRONIZE=false  # En producción siempre false, usar migraciones

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=24h
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRATION=7d

# App
PORT=3000
NODE_ENV=development
API_PREFIX=api
CORS_ORIGINS=http://localhost:4200,http://localhost:3001

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

### Paso 5: Configurar TypeORM
Crear `src/config/database.config.ts`:
```typescript
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export const getDatabaseConfig = (
  configService: ConfigService,
): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: configService.get('DATABASE_HOST'),
  port: configService.get('DATABASE_PORT'),
  username: configService.get('DATABASE_USER'),
  password: configService.get('DATABASE_PASSWORD'),
  database: configService.get('DATABASE_NAME'),
  entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/../database/migrations/*{.ts,.js}'],
  synchronize: configService.get('DATABASE_SYNCHRONIZE') === 'true',
  logging: configService.get('NODE_ENV') === 'development',
});
```

### Paso 6: Ejecutar Primera Migración
```bash
# Generar migración inicial
npm run typeorm migration:generate -- -n InitialSchema

# Ejecutar migraciones
npm run typeorm migration:run
```

### Paso 7: Crear Seeds Iniciales
```bash
# Crear script de seed para permisos
npm run seed:permissions

# Crear roles predefinidos
npm run seed:roles

# Crear superadmin inicial
npm run seed:superadmin
```

### Paso 8: Iniciar Servidor de Desarrollo
```bash
npm run start:dev
```

El servidor estará disponible en:
- API: `http://localhost:3000/api`
- Swagger: `http://localhost:3000/api/docs`
4. **Crear primera migración**: Tablas de users y auth
5. **Implementar autenticación JWT**: Login y registro básico
6. **Crear usuario superadmin**: Seed inicial para acceso al sistema

---

## 📝 Notas Adicionales

### Consideraciones de Rendimiento
- Implementar índices en columnas que se consultan frecuentemente
- Usar paginación en todos los endpoints de listado
- Considerar caché (Redis) para reportes pesados en versión futura
- Transacciones de base de datos para operaciones críticas (ventas)

### Escalabilidad
- Arquitectura modular permite agregar funcionalidades fácilmente
- Base de datos relacional soporta crecimiento de datos
- API RESTful permite integración con múltiples frontends

### Seguridad
- Contraseñas hasheadas con bcrypt (salt rounds: 10)
- JWT con expiración corta (24h) y refresh tokens
- Validación de inputs con class-validator
- CORS configurado correctamente
- Helmet para headers HTTP seguros
- Rate limiting para prevenir abuso

---

**Documento creado**: Marzo 2026  
**Última actualización**: Marzo 11, 2026  
**Versión**: 1.0  
**Autor**: GitHub Copilot
