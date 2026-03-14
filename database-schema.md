# 🗄️ Esquema de Base de Datos - WizePick

## Diagrama de Relaciones (ERD)

```
┌─────────────────┐
│   businesses    │
│─────────────────│
│ id (PK)         │
│ name            │
│ business_type   │◄──────────┐
│ tax_id          │           │
│ settings        │           │
└─────────────────┘           │
         ▲                    │
         │                    │
         │ 1:N                │ 1:N
         │                    │
┌────────┴────────┐   ┌───────┴──────────┐
│    branches     │   │      roles       │
│─────────────────│   │──────────────────│
│ id (PK)         │   │ id (PK)          │
│ business_id(FK) │   │ business_id (FK) │
│ name            │   │ name             │
│ code            │   │ code             │
└─────────────────┘   └──────────────────┘
         ▲                    ▲
         │                    │
         │ 1:N                │ N:M
         │                    │        ┌────────────────────┐
┌────────┴────────┐           │        │   permissions      │
│      users      │           │        │────────────────────│
│─────────────────│           │        │ id (PK)            │
│ id (PK)         │           │        │ module             │
│ business_id(FK) │           │        │ action             │
│ branch_id (FK)  │           │        │ code               │
│ role_id (FK)    ├───────────┘        └──────────┬─────────┘
│ username        │                               │
│ email           │                               │
│ password_hash   │                               │ N:M
└────────┬────────┘                               │
         │                             ┌──────────┴─────────────┐
         │ 1:N                         │   role_permissions     │
         │                             │────────────────────────│
┌────────┴────────────┐                │ id (PK)                │
│  product_categories │                │ role_id (FK)           │
│─────────────────────│                │ permission_id (FK)     │
│ id (PK)             │                └────────────────────────┘
│ business_id (FK)    │
│ parent_id (FK)      │ (Auto-referencia para jerarquía)
│ name                │
└──────────┬──────────┘
           │
           │ 1:N
           │
┌──────────┴──────────┐
│      products       │
│─────────────────────│
│ id (PK)             │
│ business_id (FK)    │◄────────┐
│ category_id (FK)    │         │
│ sku                 │         │
│ barcode             │         │ 1:N
│ name                │         │
│ cost_price          │         │
│ sale_price          │  ┌──────┴──────────────┐
└──────────┬──────────┘  │   branch_stock      │
           │             │─────────────────────│
           │ 1:N         │ id (PK)             │
           │             │ branch_id (FK)      │
┌──────────┴────────────┐│ product_id (FK)     │
│ inventory_movements   ││ current_stock       │
│───────────────────────││ reserved_stock      │
│ id (PK)               ││ available_stock     │
│ business_id (FK)      │└─────────────────────┘
│ branch_id (FK)        │
│ product_id (FK)       │
│ user_id (FK)          │
│ movement_type         │
│ quantity              │
│ previous_stock        │
│ new_stock             │
└───────────────────────┘

┌─────────────────────────┐
│         sales           │
│─────────────────────────│
│ id (PK)                 │
│ business_id (FK)        │
│ branch_id (FK)          │
│ user_id (FK)            │
│ sale_number             │
│ customer_name           │
│ subtotal                │
│ tax_amount              │
│ total_amount            │
│ payment_method          │
│ status                  │
└───────────┬─────────────┘
            │
            │ 1:N
            │
┌───────────┴─────────────┐
│      sale_items         │
│─────────────────────────│
│ id (PK)                 │
│ sale_id (FK)            │
│ product_id (FK)         │
│ quantity                │
│ unit_price              │
│ subtotal                │
│ total                   │
└─────────────────────────┘

┌─────────────────────────────┐
│   stock_replenishments      │
│─────────────────────────────│
│ id (PK)                     │
│ business_id (FK)            │
│ branch_id (FK)              │
│ user_id (FK)                │
│ replenishment_number        │
│ supplier                    │
│ total_cost                  │
└──────────────┬──────────────┘
               │
               │ 1:N
               │
┌──────────────┴──────────────┐
│   replenishment_items       │
│─────────────────────────────│
│ id (PK)                     │
│ replenishment_id (FK)       │
│ product_id (FK)             │
│ quantity                    │
│ unit_cost                   │
│ total_cost                  │
└─────────────────────────────┘

┌─────────────────────┐
│       shifts        │
│─────────────────────│
│ id (PK)             │
│ business_id (FK)    │
│ branch_id (FK)      │
│ user_id (FK)        │
│ shift_number        │
│ start_time          │
│ end_time            │
│ initial_cash        │
│ final_cash          │
│ total_sales         │
│ status              │
└─────────────────────┘

┌─────────────────────┐
│    promotions       │
│─────────────────────│
│ id (PK)             │
│ business_id (FK)    │
│ name                │
│ discount_type       │
│ discount_value      │
│ start_date          │
│ end_date            │
│ is_active           │
└─────────────────────┘

┌─────────────────────┐
│    audit_logs       │
│─────────────────────│
│ id (PK)             │
│ business_id (FK)    │
│ user_id (FK)        │
│ action              │
│ entity_type         │
│ entity_id           │
│ old_values (JSONB)  │
│ new_values (JSONB)  │
│ ip_address          │
└─────────────────────┘

┌─────────────────────┐
│   price_history     │
│─────────────────────│
│ id (PK)             │
│ product_id (FK)     │
│ old_cost_price      │
│ new_cost_price      │
│ old_sale_price      │
│ new_sale_price      │
│ changed_by (FK)     │
│ changed_at          │
└─────────────────────┘
```

## Leyenda

- **PK**: Primary Key (Clave Primaria)
- **FK**: Foreign Key (Clave Foránea)
- **1:N**: Relación uno a muchos
- **N:M**: Relación muchos a muchos
- **◄**: Dirección de la relación

## Características Clave

### Multi-Tenant (Multi-Negocio)
- Todas las tablas principales tienen `business_id`
- Aislamiento de datos por negocio
- Permite SaaS multi-empresa

### Stock Multi-Sucursal
- Tabla `branch_stock` separa el inventario por sucursal
- Cada producto puede tener diferentes cantidades en cada sucursal
- Soporte para transferencias entre sucursales

### Permisos Granulares
- Tabla `permissions` con todas las acciones disponibles
- Tabla `role_permissions` para relación N:M
- Roles personalizables por negocio

### Auditoría Completa
- `audit_logs` con JSONB para flexibilidad
- Registro de cambios antes/después
- Trazabilidad de IP y user agent

### Jerarquía de Categorías
- `product_categories` con `parent_id` auto-referencial
- Permite categorías y subcategorías ilimitadas

### Transacciones Completas
- Ventas con items (`sales` + `sale_items`)
- Reposiciones con items (`stock_replenishments` + `replenishment_items`)
- Integridad referencial garantizada

## Índices Importantes

### Índices de Performance
```sql
-- Búsquedas frecuentes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_movements_date ON inventory_movements(created_at);

-- Filtros por negocio/sucursal
CREATE INDEX idx_users_business ON users(business_id);
CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_sales_branch ON sales(branch_id);

-- Relaciones N:M
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

-- Stock disponible
CREATE INDEX idx_branch_stock_available ON branch_stock(available_stock);
```

## Tipos de Datos Estratégicos

### IDs Numéricos
- `SERIAL`: Para tablas con crecimiento moderado (< 2 mil millones)
- `BIGSERIAL`: Para tablas transaccionales (ventas, movimientos, audit)

### Decimales de Alta Precisión
- `DECIMAL(12,2)`: Precios y montos (hasta 999,999,999.99)
- `DECIMAL(12,3)`: Cantidades fraccionarias (kg, litros)

### JSONB para Flexibilidad
- `settings` en businesses: Configuraciones personalizadas
- `old_values/new_values` en audit_logs: Cambios dinámicos

### Timestamps
- `created_at`: Fecha de creación (DEFAULT NOW())
- `updated_at`: Última actualización (trigger o ORM)

## Integridad Referencial

### Cascade
```sql
ON DELETE CASCADE  -- Eliminar registros dependientes
```
Usado en:
- business → branches
- business → roles
- sale → sale_items
- replenishment → replenishment_items

### Set Null
```sql
ON DELETE SET NULL  -- Mantener registro, nulificar FK
```
Usado en:
- user → audit_logs (mantener logs aunque se elimine usuario)
- branch → users (permitir reasignación)

## Constraints Únicos

```sql
-- Evitar duplicados
UNIQUE(business_id, sku)              -- SKU único por negocio
UNIQUE(business_id, code) ON roles    -- Código de rol único por negocio
UNIQUE(branch_id, product_id)         -- Stock único por sucursal-producto
UNIQUE(role_id, permission_id)        -- Permiso único por rol
```

## Secuencias y Auto-incremento

PostgreSQL maneja automáticamente las secuencias con SERIAL:

```sql
-- Internamente crea:
CREATE SEQUENCE table_name_id_seq;
ALTER TABLE table_name ALTER COLUMN id SET DEFAULT nextval('table_name_id_seq');
```

Ventajas:
- Transacciones seguras
- No hay gaps en producción normal
- Mejor performance que UUID

## Estimación de Tamaño

### Negocio Pequeño (1 año)
- Products: 500 registros (~50 KB)
- Sales: 50,000 registros (~5 MB)
- Sale Items: 150,000 registros (~15 MB)
- Inventory Movements: 200,000 registros (~20 MB)
- **Total estimado**: ~50 MB

### Negocio Mediano (1 año)
- Products: 5,000 registros (~500 KB)
- Sales: 500,000 registros (~50 MB)
- Sale Items: 1,500,000 registros (~150 MB)
- Inventory Movements: 2,000,000 registros (~200 MB)
- **Total estimado**: ~450 MB

### Negocio Grande (1 año, múltiples sucursales)
- Products: 20,000 registros (~2 MB)
- Sales: 5,000,000 registros (~500 MB)
- Sale Items: 15,000,000 registros (~1.5 GB)
- Inventory Movements: 20,000,000 registros (~2 GB)
- **Total estimado**: ~4.5 GB

PostgreSQL maneja estos volúmenes sin problema con índices apropiados.

---

**Versión**: 2.0  
**Fecha**: Marzo 11, 2026
