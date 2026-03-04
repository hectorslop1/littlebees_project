import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable, from, switchMap } from 'rxjs';
import { PrismaService } from '../../modules/prisma/prisma.service';

@Injectable()
export class TenantContextInterceptor implements NestInterceptor {
  constructor(private readonly prisma: PrismaService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const tenantId = request.user?.tenantId;

    if (!tenantId) {
      return next.handle();
    }

    return from(this.prisma.setTenantContext(tenantId)).pipe(
      switchMap(() => next.handle()),
    );
  }
}
