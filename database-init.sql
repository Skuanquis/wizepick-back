-- ============================================
-- WizePick Database Schema
-- Sistema de Control de Inventarios Multi-Negocio
-- PostgreSQL 15+
-- Versión: 2.0
-- Fecha: Marzo 11, 2026
-- ============================================

-- Eliminar tablas si existen (útil para desarrollo)
-- ⚠️ CUIDADO: Esto eliminará todos los datos
-- DROP TABLE IF EXISTS audit_logs CASCADE;
-- DROP TABLE IF EXISTS price_history CASCADE;
-- DROP TABLE IF EXISTS replenishment_items CASCADE;
-- DROP TABLE IF EXISTS stock_replenishments CASCADE;
-- DROP TABLE IF EXISTS inventory_movements CASCADE;
-- DROP TABLE IF EXISTS sale_items CASCADE;
-- DROP TABLE IF EXISTS sales CASCADE;
-- DROP TABLE IF EXISTS branch_stock CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS product_categories CASCADE;
-- DROP TABLE IF EXISTS shifts CASCADE;
-- DROP TABLE IF EXISTS promotions CASCADE;
-- DROP TABLE IF EXISTS role_permissions CASCADE;
-- DROP TABLE IF EXISTS permissions CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;
-- DROP TABLE IF EXISTS roles CASCADE;
-- DROP TABLE IF EXISTS branches CASCADE;
-- DROP TABLE IF EXISTS businesses CASCADE;

-- ============================================
-- TABLA: businesses
-- Negocios/Empresas del sistema
-- ============================================
CREATE TABLE businesses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  business_type VARCHAR(50) NOT NULL CHECK (business_type IN ('nightclub', 'restaurant', 'warehouse', 'retail', 'bar', 'cafe')),
  tax_id VARCHAR(50) UNIQUE,
  address TEXT,
  phone VARCHAR(20),
  email VARCHAR(100),
  settings JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_businesses_type ON businesses(business_type);
CREATE INDEX idx_businesses_active ON businesses(is_active);

COMMENT ON TABLE businesses IS 'Negocios/empresas registrados en el sistema';
COMMENT ON COLUMN businesses.settings IS 'Configuraciones personalizadas en formato JSON';

-- ============================================
-- TABLA: branches
-- Sucursales/Ubicaciones de cada negocio
-- ============================================
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
CREATE INDEX idx_branches_code ON branches(code);

COMMENT ON TABLE branches IS 'Sucursales o ubicaciones físicas de cada negocio';

-- ============================================
-- TABLA: roles
-- Roles del sistema
-- ============================================
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  code VARCHAR(50) NOT NULL,
  description TEXT,
  is_system_role BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(business_id, code)
);

CREATE INDEX idx_roles_business ON roles(business_id);
CREATE INDEX idx_roles_code ON roles(code);
CREATE INDEX idx_roles_system ON roles(is_system_role);

COMMENT ON TABLE roles IS 'Roles personalizables por negocio';
COMMENT ON COLUMN roles.is_system_role IS 'true para roles predefinidos del sistema que no se pueden eliminar';

-- ============================================
-- TABLA: permissions
-- Permisos granulares del sistema
-- ============================================
CREATE TABLE permissions (
  id SERIAL PRIMARY KEY,
  module VARCHAR(50) NOT NULL,
  action VARCHAR(50) NOT NULL,
  code VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_permissions_module ON permissions(module);
CREATE INDEX idx_permissions_code ON permissions(code);

COMMENT ON TABLE permissions IS 'Permisos granulares en formato module.action';
COMMENT ON COLUMN permissions.code IS 'Código único del permiso (ej: products.create)';

-- ============================================
-- TABLA: role_permissions
-- Relación muchos a muchos entre roles y permisos
-- ============================================
CREATE TABLE role_permissions (
  id SERIAL PRIMARY KEY,
  role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

COMMENT ON TABLE role_permissions IS 'Asignación de permisos a roles';

-- ============================================
-- TABLA: users
-- Usuarios del sistema
-- ============================================
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
CREATE INDEX idx_users_email ON users(email);

COMMENT ON TABLE users IS 'Usuarios del sistema vinculados a negocios y roles';

-- ============================================
-- TABLA: product_categories
-- Categorías de productos (jerárquicas)
-- ============================================
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

COMMENT ON TABLE product_categories IS 'Categorías jerárquicas de productos';
COMMENT ON COLUMN product_categories.parent_id IS 'Permite crear subcategorías';

-- ============================================
-- TABLA: products
-- Productos del inventario
-- ============================================
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
  sku VARCHAR(50),
  barcode VARCHAR(100),
  name VARCHAR(150) NOT NULL,
  description TEXT,
  unit_type VARCHAR(30) NOT NULL,
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
CREATE INDEX idx_products_name ON products(name);

COMMENT ON TABLE products IS 'Catálogo de productos del inventario';
COMMENT ON COLUMN products.unit_type IS 'unit, kg, liter, box, pack, dozen';

-- ============================================
-- TABLA: branch_stock
-- Stock por sucursal
-- ============================================
CREATE TABLE branch_stock (
  id SERIAL PRIMARY KEY,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  current_stock DECIMAL(12,3) DEFAULT 0,
  reserved_stock DECIMAL(12,3) DEFAULT 0,
  available_stock DECIMAL(12,3) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
  last_updated TIMESTAMP DEFAULT NOW(),
  UNIQUE(branch_id, product_id)
);

CREATE INDEX idx_branch_stock_branch ON branch_stock(branch_id);
CREATE INDEX idx_branch_stock_product ON branch_stock(product_id);
CREATE INDEX idx_branch_stock_available ON branch_stock(available_stock);

COMMENT ON TABLE branch_stock IS 'Stock de productos separado por sucursal';
COMMENT ON COLUMN branch_stock.available_stock IS 'Calculado automáticamente: current_stock - reserved_stock';

-- ============================================
-- TABLA: sales
-- Registro de ventas (cabecera)
-- ============================================
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
  payment_method VARCHAR(30),
  status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
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

COMMENT ON TABLE sales IS 'Cabecera de ventas realizadas';
COMMENT ON COLUMN sales.payment_method IS 'cash, card, transfer, mixed';

-- ============================================
-- TABLA: sale_items
-- Detalle de items de cada venta
-- ============================================
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

COMMENT ON TABLE sale_items IS 'Detalle de productos vendidos en cada venta';

-- ============================================
-- TABLA: inventory_movements
-- Todos los movimientos de inventario
-- ============================================
CREATE TABLE inventory_movements (
  id BIGSERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  branch_id INTEGER NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  movement_type VARCHAR(30) NOT NULL CHECK (movement_type IN ('entry', 'exit', 'adjustment', 'transfer', 'sale', 'return', 'loss')),
  quantity DECIMAL(12,3) NOT NULL,
  previous_stock DECIMAL(12,3) NOT NULL,
  new_stock DECIMAL(12,3) NOT NULL,
  unit_cost DECIMAL(12,2),
  reference_type VARCHAR(50),
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

COMMENT ON TABLE inventory_movements IS 'Registro de todos los movimientos de inventario';
COMMENT ON COLUMN inventory_movements.reference_type IS 'sale, purchase, adjustment, transfer';

-- ============================================
-- TABLA: stock_replenishments
-- Reposiciones de stock (cabecera)
-- ============================================
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
  status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled')),
  replenishment_date TIMESTAMP DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_replenishments_business ON stock_replenishments(business_id);
CREATE INDEX idx_replenishments_branch ON stock_replenishments(branch_id);
CREATE INDEX idx_replenishments_date ON stock_replenishments(replenishment_date);
CREATE INDEX idx_replenishments_number ON stock_replenishments(replenishment_number);

COMMENT ON TABLE stock_replenishments IS 'Cabecera de reposiciones de inventario';

-- ============================================
-- TABLA: replenishment_items
-- Detalle de items en cada reposición
-- ============================================
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

COMMENT ON TABLE replenishment_items IS 'Detalle de productos en cada reposición';

-- ============================================
-- TABLA: audit_logs
-- Auditoría completa del sistema
-- ============================================
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  business_id INTEGER REFERENCES businesses(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
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
CREATE INDEX idx_audit_action ON audit_logs(action);

COMMENT ON TABLE audit_logs IS 'Registro de auditoría de todas las acciones críticas';

-- ============================================
-- TABLA: price_history
-- Historial de cambios de precios
-- ============================================
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

COMMENT ON TABLE price_history IS 'Historial de cambios en precios de productos';

-- ============================================
-- TABLA: shifts
-- Turnos de trabajo
-- ============================================
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
  status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'closed', 'reviewed')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_shifts_business ON shifts(business_id);
CREATE INDEX idx_shifts_branch ON shifts(branch_id);
CREATE INDEX idx_shifts_user ON shifts(user_id);
CREATE INDEX idx_shifts_status ON shifts(status);
CREATE INDEX idx_shifts_start ON shifts(start_time);

COMMENT ON TABLE shifts IS 'Control de turnos de trabajo con conciliación de efectivo';

-- ============================================
-- TABLA: promotions
-- Promociones y descuentos
-- ============================================
CREATE TABLE promotions (
  id SERIAL PRIMARY KEY,
  business_id INTEGER NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount')),
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase_amount DECIMAL(12,2),
  applies_to VARCHAR(20) DEFAULT 'all' CHECK (applies_to IN ('all', 'category', 'product')),
  target_id INTEGER,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_promotions_business ON promotions(business_id);
CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date);
CREATE INDEX idx_promotions_active ON promotions(is_active);
CREATE INDEX idx_promotions_code ON promotions(code);

COMMENT ON TABLE promotions IS 'Promociones y descuentos configurables';

-- ============================================
-- TRIGGERS para updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a todas las tablas con updated_at
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_product_categories_updated_at BEFORE UPDATE ON product_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stock_replenishments_updated_at BEFORE UPDATE ON stock_replenishments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shifts_updated_at BEFORE UPDATE ON shifts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_promotions_updated_at BEFORE UPDATE ON promotions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista de stock disponible por sucursal
CREATE OR REPLACE VIEW v_available_stock AS
SELECT 
  bs.id,
  bs.branch_id,
  b.name AS branch_name,
  bs.product_id,
  p.name AS product_name,
  p.sku,
  bs.current_stock,
  bs.reserved_stock,
  bs.available_stock,
  p.min_stock_alert,
  CASE 
    WHEN bs.available_stock <= p.min_stock_alert THEN true 
    ELSE false 
  END AS is_low_stock,
  bs.last_updated
FROM branch_stock bs
JOIN branches b ON b.id = bs.branch_id
JOIN products p ON p.id = bs.product_id
WHERE p.is_active = true AND b.is_active = true;

COMMENT ON VIEW v_available_stock IS 'Vista de stock disponible con alertas de stock bajo';

-- ============================================
-- DATOS INICIALES (OPCIONAL)
-- ============================================

-- Insertar permisos base del sistema
INSERT INTO permissions (module, action, code, description) VALUES
-- Businesses
('businesses', 'create', 'businesses.create', 'Crear negocios'),
('businesses', 'read', 'businesses.read', 'Ver negocios'),
('businesses', 'update', 'businesses.update', 'Actualizar negocios'),
('businesses', 'delete', 'businesses.delete', 'Eliminar negocios'),

-- Branches
('branches', 'create', 'branches.create', 'Crear sucursales'),
('branches', 'read', 'branches.read', 'Ver sucursales'),
('branches', 'update', 'branches.update', 'Actualizar sucursales'),
('branches', 'delete', 'branches.delete', 'Eliminar sucursales'),

-- Users
('users', 'create', 'users.create', 'Crear usuarios'),
('users', 'read', 'users.read', 'Ver usuarios'),
('users', 'update', 'users.update', 'Actualizar usuarios'),
('users', 'delete', 'users.delete', 'Eliminar usuarios'),

-- Roles
('roles', 'create', 'roles.create', 'Crear roles'),
('roles', 'read', 'roles.read', 'Ver roles'),
('roles', 'update', 'roles.update', 'Actualizar roles'),
('roles', 'delete', 'roles.delete', 'Eliminar roles'),
('roles', 'assign_permissions', 'roles.assign_permissions', 'Asignar permisos a roles'),

-- Products
('products', 'create', 'products.create', 'Crear productos'),
('products', 'read', 'products.read', 'Ver productos'),
('products', 'update', 'products.update', 'Actualizar productos'),
('products', 'delete', 'products.delete', 'Eliminar productos'),
('products', 'adjust_price', 'products.adjust_price', 'Ajustar precios'),

-- Categories
('categories', 'create', 'categories.create', 'Crear categorías'),
('categories', 'read', 'categories.read', 'Ver categorías'),
('categories', 'update', 'categories.update', 'Actualizar categorías'),
('categories', 'delete', 'categories.delete', 'Eliminar categorías'),

-- Inventory
('inventory', 'view_stock', 'inventory.view_stock', 'Ver stock'),
('inventory', 'replenish', 'inventory.replenish', 'Reabastecer stock'),
('inventory', 'adjust', 'inventory.adjust', 'Ajustar stock'),
('inventory', 'transfer', 'inventory.transfer', 'Transferir entre sucursales'),

-- Sales
('sales', 'create', 'sales.create', 'Crear ventas'),
('sales', 'read', 'sales.read', 'Ver ventas'),
('sales', 'cancel', 'sales.cancel', 'Cancelar ventas'),
('sales', 'refund', 'sales.refund', 'Devolver ventas'),
('sales', 'view_all', 'sales.view_all', 'Ver todas las ventas'),
('sales', 'view_own', 'sales.view_own', 'Ver ventas propias'),

-- Reports
('reports', 'view_sales', 'reports.view_sales', 'Ver reportes de ventas'),
('reports', 'view_inventory', 'reports.view_inventory', 'Ver reportes de inventario'),
('reports', 'export', 'reports.export', 'Exportar reportes'),

-- Dashboard
('dashboard', 'view_general', 'dashboard.view_general', 'Ver dashboard general'),
('dashboard', 'view_detailed', 'dashboard.view_detailed', 'Ver dashboard detallado'),

-- Shifts
('shifts', 'open', 'shifts.open', 'Abrir turno'),
('shifts', 'close', 'shifts.close', 'Cerrar turno'),
('shifts', 'view_own', 'shifts.view_own', 'Ver turnos propios'),
('shifts', 'view_all', 'shifts.view_all', 'Ver todos los turnos'),

-- Promotions
('promotions', 'create', 'promotions.create', 'Crear promociones'),
('promotions', 'read', 'promotions.read', 'Ver promociones'),
('promotions', 'update', 'promotions.update', 'Actualizar promociones'),
('promotions', 'delete', 'promotions.delete', 'Eliminar promociones'),

-- Audit
('audit', 'view_logs', 'audit.view_logs', 'Ver logs de auditoría');

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Verificar tablas creadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Contar registros en permissions
SELECT COUNT(*) as total_permissions FROM permissions;

COMMENT ON DATABASE wizepick_db IS 'Base de datos del sistema WizePick - Control de Inventarios Multi-Negocio';
