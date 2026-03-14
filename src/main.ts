import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Obtener ConfigService
  const configService = app.get(ConfigService);

  // Seguridad - Helmet
  app.use(helmet());

  // CORS
  const corsOrigins = configService
    .get<string>('CORS_ORIGINS', 'http://localhost:4200')
    .split(',');
  app.enableCors({
    origin: corsOrigins,
    credentials: true,
  });

  // Prefijo global para todas las rutas
  const apiPrefix = configService.get<string>('API_PREFIX', 'api');
  app.setGlobalPrefix(apiPrefix);

  // Versionado de API
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // Validación global
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Configuración de Swagger
  if (configService.get<string>('SWAGGER_ENABLED', 'true') === 'true') {
    const config = new DocumentBuilder()
      .setTitle('WizePick API')
      .setDescription(
        'Sistema de control de inventarios multi-negocio - API Documentation',
      )
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Ingrese su token JWT',
          in: 'header',
        },
        'access-token',
      )
      .addTag('Auth', 'Autenticación y autorización')
      .addTag('Users', 'Gestión de usuarios')
      .addTag('Businesses', 'Gestión de negocios')
      .addTag('Branches', 'Gestión de sucursales')
      .addTag('Roles', 'Gestión de roles')
      .addTag('Permissions', 'Gestión de permisos')
      .addTag('Products', 'Gestión de productos')
      .addTag('Inventory', 'Gestión de inventario')
      .addTag('Sales', 'Gestión de ventas')
      .addTag('Reports', 'Reportes y estadísticas')
      .addTag('Dashboard', 'Dashboard y métricas')
      .addTag('Shifts', 'Gestión de turnos')
      .addTag('Promotions', 'Gestión de promociones')
      .addTag('Audit', 'Auditoría del sistema')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup(`${apiPrefix}/docs`, app, document, {
      swaggerOptions: {
        persistAuthorization: true,
      },
    });
  }

  // Puerto
  const port = configService.get<number>('PORT', 3000);
  await app.listen(port);

  console.log(`
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║   🚀  WizePick API - Sistema de Inventarios Multi-Negocio   ║
  ║                                                               ║
  ║   📍  Application: http://localhost:${port}/${apiPrefix}                      ║
  ║   📚  API Docs: http://localhost:${port}/${apiPrefix}/docs                ║
  ║   🔧  Environment: ${configService.get('NODE_ENV', 'development')}                        ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
  `);
}
bootstrap();

