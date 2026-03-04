import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Sets the tenant context for Row-Level Security.
   * Uses set_config with parameterized query to prevent SQL injection.
   */
  async setTenantContext(tenantId: string): Promise<void> {
    await this.$executeRaw`SELECT set_config('app.tenant_id', ${tenantId}, true)`;
  }

  /**
   * Executes a callback within a transaction with tenant context set.
   */
  async withTenant<T>(tenantId: string, callback: (prisma: PrismaClient) => Promise<T>): Promise<T> {
    return this.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT set_config('app.tenant_id', ${tenantId}, true)`;
      return callback(tx as PrismaClient);
    });
  }
}
