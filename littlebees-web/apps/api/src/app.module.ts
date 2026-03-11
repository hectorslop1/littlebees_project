import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { ClsModule } from 'nestjs-cls';
import { PrismaModule } from './modules/prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { TenantsModule } from './modules/tenants/tenants.module';
import { ChildrenModule } from './modules/children/children.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { DailyLogsModule } from './modules/daily-logs/daily-logs.module';
import { HealthModule } from './modules/health/health.module';
import { AuditModule } from './modules/audit/audit.module';
import { DevelopmentModule } from './modules/development/development.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { FilesModule } from './modules/files/files.module';
import { ServicesModule } from './modules/services/services.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { InvoicingModule } from './modules/invoicing/invoicing.module';
import { ChatModule } from './modules/chat/chat.module';
import { ReportsModule } from './modules/reports/reports.module';
import { GroupsModule } from './modules/groups/groups.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),

    // Continuation Local Storage for tenant context
    ClsModule.forRoot({
      global: true,
      middleware: {
        mount: true,
      },
    }),

    // Core modules
    PrismaModule,
    HealthModule,

    // Feature modules
    AuthModule,
    UsersModule,
    TenantsModule,
    GroupsModule,
    ChildrenModule,
    AttendanceModule,
    DailyLogsModule,

    // New modules - Phase 1
    AuditModule,
    DevelopmentModule,
    NotificationsModule,
    FilesModule,
    ServicesModule,
    PaymentsModule,
    InvoicingModule,
    ChatModule,
    ReportsModule,
  ],
})
export class AppModule {}
