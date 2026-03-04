import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { PrismaService } from '../../modules/prisma/prisma.service';

@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  constructor(private readonly prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;

    // Only audit state-changing operations
    if (['GET', 'HEAD', 'OPTIONS'].includes(method)) {
      return next.handle();
    }

    const userId = request.user?.id;
    const tenantId = request.user?.tenantId;

    if (!userId || !tenantId) {
      return next.handle();
    }

    const action = method;
    const resourceType = context.getClass().name.replace('Controller', '').toLowerCase();
    const resourceId = request.params?.id;

    const ipAddress = request.ip || null;
    const userAgent = request.headers['user-agent'] || null;

    return next.handle().pipe(
      tap(async () => {
        try {
          await this.prisma.auditLog.create({
            data: {
              tenantId,
              userId,
              action,
              resourceType,
              resourceId: resourceId || null,
              ipAddress,
              userAgent,
            },
          });
        } catch {
          // Audit log failure should not break the request
        }
      }),
    );
  }
}
