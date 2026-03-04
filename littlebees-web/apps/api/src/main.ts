import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // CORS
  app.enableCors({
    origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3001'],
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Swagger / OpenAPI
  const config = new DocumentBuilder()
    .setTitle('KinderSpace MX API')
    .setDescription('API para el sistema de gestión de guarderías KinderSpace MX')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Autenticación y autorización')
    .addTag('children', 'Gestión de niños')
    .addTag('attendance', 'Control de asistencia')
    .addTag('daily-logs', 'Bitácora diaria')
    .addTag('development', 'Seguimiento de desarrollo')
    .addTag('chat', 'Mensajería')
    .addTag('payments', 'Pagos')
    .addTag('invoices', 'Facturación CFDI 4.0')
    .addTag('services', 'Servicios y marketplace')
    .addTag('notifications', 'Notificaciones')
    .addTag('files', 'Gestión de archivos')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`KinderSpace API running on http://localhost:${port}`);
  console.log(`Swagger docs at http://localhost:${port}/api/docs`);
}

bootstrap();
