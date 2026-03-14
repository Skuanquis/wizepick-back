# 📝 Ejemplos de Entidades TypeORM

Este archivo contiene ejemplos de las entidades principales del sistema usando TypeORM con decoradores.

## Business Entity

```typescript
// src/modules/businesses/entities/business.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Branch } from '../../branches/entities/branch.entity';
import { User } from '../../users/entities/user.entity';

@Entity('businesses')
export class Business {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 150 })
  name: string;

  @Column({ 
    length: 50,
    type: 'varchar'
  })
  business_type: 'nightclub' | 'restaurant' | 'warehouse' | 'retail' | 'bar' | 'cafe';

  @Column({ length: 50, nullable: true, unique: true })
  tax_id: string;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ length: 20, nullable: true })
  phone: string;

  @Column({ length: 100, nullable: true })
  email: string;

  @Column({ type: 'jsonb', default: {} })
  settings: Record<string, any>;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relaciones
  @OneToMany(() => Branch, branch => branch.business)
  branches: Branch[];

  @OneToMany(() => User, user => user.business)
  users: User[];
}
```

## User Entity

```typescript
// src/modules/users/entities/user.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Exclude } from 'class-transformer';
import { Business } from '../../businesses/entities/business.entity';
import { Branch } from '../../branches/entities/branch.entity';
import { Role } from '../../roles/entities/role.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  business_id: number;

  @Column({ nullable: true })
  branch_id: number;

  @Column()
  role_id: number;

  @Column({ length: 50, unique: true })
  username: string;

  @Column({ length: 100, unique: true })
  email: string;

  @Column({ length: 255 })
  @Exclude() // No exponer en respuestas JSON
  password_hash: string;

  @Column({ length: 100 })
  full_name: string;

  @Column({ length: 20, nullable: true })
  phone: string;

  @Column({ length: 50, nullable: true })
  employee_code: string;

  @Column({ default: true })
  is_active: boolean;

  @Column({ type: 'timestamp', nullable: true })
  last_login: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relaciones
  @ManyToOne(() => Business, business => business.users)
  @JoinColumn({ name: 'business_id' })
  business: Business;

  @ManyToOne(() => Branch, { nullable: true })
  @JoinColumn({ name: 'branch_id' })
  branch: Branch;

  @ManyToOne(() => Role, { eager: true })
  @JoinColumn({ name: 'role_id' })
  role: Role;
}
```

## Product Entity

```typescript
// src/modules/products/entities/product.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Business } from '../../businesses/entities/business.entity';
import { ProductCategory } from './product-category.entity';
import { BranchStock } from '../../inventory/entities/branch-stock.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  business_id: number;

  @Column({ nullable: true })
  category_id: number;

  @Column({ length: 50, nullable: true })
  sku: string;

  @Column({ length: 100, nullable: true })
  barcode: string;

  @Column({ length: 150 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 30 })
  unit_type: string; // 'unit', 'kg', 'liter', 'box', 'pack', 'dozen'

  @Column({ default: 1 })
  units_per_package: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  cost_price: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  sale_price: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  tax_rate: number;

  @Column({ default: 10 })
  min_stock_alert: number;

  @Column({ nullable: true })
  max_stock_limit: number;

  @Column({ length: 255, nullable: true })
  image_url: string;

  @Column({ length: 150, nullable: true })
  supplier: string;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relaciones
  @ManyToOne(() => Business)
  @JoinColumn({ name: 'business_id' })
  business: Business;

  @ManyToOne(() => ProductCategory, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  category: ProductCategory;

  @OneToMany(() => BranchStock, stock => stock.product)
  branch_stocks: BranchStock[];
}
```

## Sale Entity (con Items)

```typescript
// src/modules/sales/entities/sale.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { Business } from '../../businesses/entities/business.entity';
import { Branch } from '../../branches/entities/branch.entity';
import { User } from '../../users/entities/user.entity';
import { SaleItem } from './sale-item.entity';

@Entity('sales')
export class Sale {
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id: number;

  @Column()
  business_id: number;

  @Column()
  branch_id: number;

  @Column()
  user_id: number;

  @Column({ length: 50, unique: true })
  sale_number: string;

  @Column({ length: 100, nullable: true })
  customer_name: string;

  @Column({ length: 100, nullable: true })
  customer_email: string;

  @Column({ length: 20, nullable: true })
  customer_phone: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  subtotal: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  tax_amount: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  discount_amount: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  total_amount: number;

  @Column({ length: 30, nullable: true })
  payment_method: string; // 'cash', 'card', 'transfer', 'mixed'

  @Column({ length: 20, default: 'completed' })
  status: string; // 'pending', 'completed', 'cancelled', 'refunded'

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  sale_date: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relaciones
  @ManyToOne(() => Business)
  @JoinColumn({ name: 'business_id' })
  business: Business;

  @ManyToOne(() => Branch)
  @JoinColumn({ name: 'branch_id' })
  branch: Branch;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @OneToMany(() => SaleItem, item => item.sale, { cascade: true, eager: true })
  items: SaleItem[];
}

// src/modules/sales/entities/sale-item.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Sale } from './sale.entity';
import { Product } from '../../products/entities/product.entity';

@Entity('sale_items')
export class SaleItem {
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id: number;

  @Column({ type: 'bigint' })
  sale_id: number;

  @Column()
  product_id: number;

  @Column({ type: 'decimal', precision: 12, scale: 3 })
  quantity: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  unit_price: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  tax_rate: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  discount_percent: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  subtotal: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  total: number;

  @CreateDateColumn()
  created_at: Date;

  // Relaciones
  @ManyToOne(() => Sale, sale => sale.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sale_id' })
  sale: Sale;

  @ManyToOne(() => Product, { eager: true })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
```

## BranchStock Entity

```typescript
// src/modules/inventory/entities/branch-stock.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn, ManyToOne, JoinColumn, Unique } from 'typeorm';
import { Branch } from '../../branches/entities/branch.entity';
import { Product } from '../../products/entities/product.entity';

@Entity('branch_stock')
@Unique(['branch_id', 'product_id'])
export class BranchStock {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  branch_id: number;

  @Column()
  product_id: number;

  @Column({ type: 'decimal', precision: 12, scale: 3, default: 0 })
  current_stock: number;

  @Column({ type: 'decimal', precision: 12, scale: 3, default: 0 })
  reserved_stock: number;

  // available_stock es calculado: current_stock - reserved_stock
  // Se puede usar una columna generada en PostgreSQL o calcular en el servicio

  @UpdateDateColumn()
  last_updated: Date;

  // Relaciones
  @ManyToOne(() => Branch)
  @JoinColumn({ name: 'branch_id' })
  branch: Branch;

  @ManyToOne(() => Product, { eager: true })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
```

## Role y Permission Entities

```typescript
// src/modules/roles/entities/role.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, ManyToMany, JoinTable, JoinColumn } from 'typeorm';
import { Business } from '../../businesses/entities/business.entity';
import { Permission } from './permission.entity';

@Entity('roles')
export class Role {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  business_id: number;

  @Column({ length: 50 })
  name: string;

  @Column({ length: 50 })
  code: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ default: false })
  is_system_role: boolean;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relaciones
  @ManyToOne(() => Business, { nullable: true })
  @JoinColumn({ name: 'business_id' })
  business: Business;

  @ManyToMany(() => Permission, { eager: true })
  @JoinTable({
    name: 'role_permissions',
    joinColumn: { name: 'role_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'permission_id', referencedColumnName: 'id' }
  })
  permissions: Permission[];
}

// src/modules/roles/entities/permission.entity.ts
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('permissions')
export class Permission {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 50 })
  module: string;

  @Column({ length: 50 })
  action: string;

  @Column({ length: 100, unique: true })
  code: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @CreateDateColumn()
  created_at: Date;
}
```

## DTOs Ejemplos

```typescript
// src/modules/sales/dto/create-sale.dto.ts
import { IsNotEmpty, IsNumber, IsString, IsOptional, IsArray, ValidateNested, IsEnum, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

class CreateSaleItemDto {
  @ApiProperty({ example: 1 })
  @IsNumber()
  @IsNotEmpty()
  product_id: number;

  @ApiProperty({ example: 2 })
  @IsNumber()
  @Min(0.001)
  quantity: number;

  @ApiProperty({ example: 15.50, required: false })
  @IsNumber()
  @IsOptional()
  unit_price?: number; // Opcional, se toma del precio del producto si no se envía

  @ApiProperty({ example: 0, required: false })
  @IsNumber()
  @IsOptional()
  discount_percent?: number;
}

export class CreateSaleDto {
  @ApiProperty({ example: 1 })
  @IsNumber()
  @IsNotEmpty()
  branch_id: number;

  @ApiProperty({ example: 'Juan Pérez', required: false })
  @IsString()
  @IsOptional()
  customer_name?: string;

  @ApiProperty({ example: 'juan@example.com', required: false })
  @IsString()
  @IsOptional()
  customer_email?: string;

  @ApiProperty({ example: '3001234567', required: false })
  @IsString()
  @IsOptional()
  customer_phone?: string;

  @ApiProperty({ 
    type: [CreateSaleItemDto],
    example: [
      { product_id: 1, quantity: 2, discount_percent: 0 },
      { product_id: 5, quantity: 1 }
    ]
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateSaleItemDto)
  items: CreateSaleItemDto[];

  @ApiProperty({ example: 'cash', enum: ['cash', 'card', 'transfer', 'mixed'] })
  @IsEnum(['cash', 'card', 'transfer', 'mixed'])
  @IsNotEmpty()
  payment_method: string;

  @ApiProperty({ example: 5, required: false })
  @IsNumber()
  @IsOptional()
  discount_amount?: number;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  notes?: string;
}
```

## Repository Pattern Example

```typescript
// src/modules/sales/sales.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Sale } from './entities/sale.entity';
import { SaleItem } from './entities/sale-item.entity';
import { CreateSaleDto } from './dto/create-sale.dto';
import { Product } from '../products/entities/product.entity';
import { BranchStock } from '../inventory/entities/branch-stock.entity';
import { InventoryService } from '../inventory/inventory.service';

@Injectable()
export class SalesService {
  constructor(
    @InjectRepository(Sale)
    private salesRepository: Repository<Sale>,
    @InjectRepository(SaleItem)
    private saleItemsRepository: Repository<SaleItem>,
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @InjectRepository(BranchStock)
    private branchStockRepository: Repository<BranchStock>,
    private inventoryService: InventoryService,
    private dataSource: DataSource,
  ) {}

  async create(createSaleDto: CreateSaleDto, userId: number, businessId: number): Promise<Sale> {
    // Usar transacción para garantizar consistencia
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 1. Validar stock disponible
      for (const item of createSaleDto.items) {
        const stock = await this.branchStockRepository.findOne({
          where: {
            branch_id: createSaleDto.branch_id,
            product_id: item.product_id
          }
        });

        if (!stock || stock.current_stock < item.quantity) {
          throw new BadRequestException(
            `Stock insuficiente para el producto ${item.product_id}`
          );
        }
      }

      // 2. Crear venta
      const sale = this.salesRepository.create({
        business_id: businessId,
        branch_id: createSaleDto.branch_id,
        user_id: userId,
        sale_number: await this.generateSaleNumber(businessId),
        customer_name: createSaleDto.customer_name,
        customer_email: createSaleDto.customer_email,
        customer_phone: createSaleDto.customer_phone,
        payment_method: createSaleDto.payment_method,
        discount_amount: createSaleDto.discount_amount || 0,
        notes: createSaleDto.notes,
        status: 'completed',
      });

      // 3. Crear items y calcular totales
      let subtotal = 0;
      let taxAmount = 0;

      const saleItems: SaleItem[] = [];
      for (const itemDto of createSaleDto.items) {
        const product = await this.productsRepository.findOne({
          where: { id: itemDto.product_id, business_id: businessId }
        });

        if (!product) {
          throw new NotFoundException(`Producto ${itemDto.product_id} no encontrado`);
        }

        const unitPrice = itemDto.unit_price || product.sale_price;
        const itemSubtotal = unitPrice * itemDto.quantity;
        const discount = (itemSubtotal * (itemDto.discount_percent || 0)) / 100;
        const itemTotal = itemSubtotal - discount;
        const itemTax = (itemTotal * product.tax_rate) / 100;

        const saleItem = this.saleItemsRepository.create({
          product_id: product.id,
          quantity: itemDto.quantity,
          unit_price: unitPrice,
          tax_rate: product.tax_rate,
          discount_percent: itemDto.discount_percent || 0,
          subtotal: itemSubtotal,
          total: itemTotal + itemTax,
        });

        saleItems.push(saleItem);
        subtotal += itemSubtotal;
        taxAmount += itemTax;
      }

      sale.subtotal = subtotal;
      sale.tax_amount = taxAmount;
      sale.total_amount = subtotal + taxAmount - sale.discount_amount;
      sale.items = saleItems;

      // 4. Guardar venta con items
      const savedSale = await queryRunner.manager.save(sale);

      // 5. Actualizar stock
      for (const item of createSaleDto.items) {
        await this.inventoryService.decreaseStock(
          createSaleDto.branch_id,
          item.product_id,
          item.quantity,
          userId,
          'sale',
          savedSale.id,
          queryRunner
        );
      }

      await queryRunner.commitTransaction();
      return savedSale;

    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  private async generateSaleNumber(businessId: number): Promise<string> {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    
    const count = await this.salesRepository.count({
      where: { business_id: businessId }
    });
    
    const sequential = String(count + 1).padStart(6, '0');
    return `V-${year}${month}${day}-${sequential}`;
  }

  async findAll(businessId: number, branchId?: number) {
    const query = this.salesRepository
      .createQueryBuilder('sale')
      .where('sale.business_id = :businessId', { businessId })
      .leftJoinAndSelect('sale.items', 'items')
      .leftJoinAndSelect('items.product', 'product')
      .leftJoinAndSelect('sale.user', 'user')
      .orderBy('sale.created_at', 'DESC');

    if (branchId) {
      query.andWhere('sale.branch_id = :branchId', { branchId });
    }

    return query.getMany();
  }
}
```

---

**Notas**:
- Estos son ejemplos completos y funcionales
- Usar transacciones para operaciones críticas
- Validar permisos en los controladores usando Guards
- Documentar con Swagger usando decoradores @ApiProperty
- Excluir campos sensibles (password_hash) con @Exclude
- Usar eager loading con precaución (puede afectar performance)
