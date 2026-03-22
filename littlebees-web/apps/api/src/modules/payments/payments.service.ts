import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { PaymentStatus, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    options?: {
      childId?: string;
      status?: string;
      startDate?: string;
      endDate?: string;
      page?: number;
      limit?: number;
    },
  ) {
    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    await this.ensureMonthlyChargesForTenant(tenantId);

    const where: Record<string, unknown> = { tenantId };

    if (options?.childId) where.childId = options.childId;
    if (options?.status) where.status = options.status as PaymentStatus;
    if (options?.startDate || options?.endDate) {
      where.dueDate = {
        ...(options?.startDate && { gte: new Date(options.startDate) }),
        ...(options?.endDate && { lte: new Date(options.endDate) }),
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.payment.findMany({
        where,
        skip,
        take: limit,
        include: {
          child: { select: { id: true, firstName: true, lastName: true } },
        },
        orderBy: { dueDate: 'desc' },
      }),
      this.prisma.payment.count({ where }),
    ]);

    return {
      data: data.map((payment) => ({
        ...payment,
        amount: Number(payment.amount),
      })),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    };
  }

  async findAllForParent(
    tenantId: string,
    userId: string,
    options?: { status?: string; page?: number; limit?: number },
  ) {
    await this.ensureMonthlyChargesForTenant(tenantId);

    const childLinks = await this.prisma.childParent.findMany({
      where: { userId },
      select: { childId: true },
    });

    const childIds = childLinks.map((l) => l.childId);

    const page = options?.page || 1;
    const limit = options?.limit || 20;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = {
      tenantId,
      childId: { in: childIds },
    };
    if (options?.status) where.status = options.status as PaymentStatus;

    const [data, total] = await Promise.all([
      this.prisma.payment.findMany({
        where,
        skip,
        take: limit,
        include: {
          child: { select: { id: true, firstName: true, lastName: true } },
        },
        orderBy: { dueDate: 'desc' },
      }),
      this.prisma.payment.count({ where }),
    ]);

    return {
      data: data.map((payment) => ({
        ...payment,
        amount: Number(payment.amount),
      })),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasNextPage: page * limit < total,
        hasPreviousPage: page > 1,
      },
    };
  }

  async findById(tenantId: string, id: string) {
    const payment = await this.prisma.payment.findFirst({
      where: { id, tenantId },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
        invoices: true,
      },
    });

    if (!payment) {
      throw new NotFoundException('Pago no encontrado');
    }

    return payment;
  }

  async create(
    tenantId: string,
    data: { childId: string; concept: string; amount: number; dueDate: string },
  ) {
    return this.prisma.payment.create({
      data: {
        tenantId,
        childId: data.childId,
        concept: data.concept,
        amount: data.amount,
        currency: 'MXN',
        status: PaymentStatus.pending,
        dueDate: new Date(data.dueDate),
      },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
      },
    });
  }

  async update(
    tenantId: string,
    id: string,
    data: { concept?: string; amount?: number; dueDate?: string },
  ) {
    const payment = await this.findById(tenantId, id);

    if (payment.status !== PaymentStatus.pending) {
      throw new BadRequestException('Solo se pueden editar pagos pendientes');
    }

    return this.prisma.payment.update({
      where: { id },
      data: {
        ...(data.concept && { concept: data.concept }),
        ...(data.amount && { amount: data.amount }),
        ...(data.dueDate && { dueDate: new Date(data.dueDate) }),
      },
    });
  }

  async markAsPaid(tenantId: string, id: string, paymentMethod: string) {
    const payment = await this.findById(tenantId, id);

    if (payment.status === PaymentStatus.paid) {
      throw new BadRequestException('El pago ya está marcado como pagado');
    }

    if (payment.status === PaymentStatus.cancelled) {
      throw new BadRequestException('No se puede pagar un cargo cancelado');
    }

    return this.prisma.payment.update({
      where: { id },
      data: {
        status: PaymentStatus.paid,
        paidAt: new Date(),
        paymentMethod,
      },
    });
  }

  async simulatePay(
    tenantId: string,
    id: string,
    user: { id: string; role: string },
    data: {
      cardholderName: string;
      cardNumber: string;
      expiryMonth: string;
      expiryYear: string;
      cvv: string;
    },
  ) {
    const payment = await this.prisma.payment.findFirst({
      where: { id, tenantId },
      include: {
        child: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            parents: {
              select: {
                userId: true,
              },
            },
          },
        },
      },
    });

    if (!payment) {
      throw new NotFoundException('Pago no encontrado');
    }

    if (user.role === UserRole.parent) {
      const isParent = payment.child.parents.some((parent) => parent.userId === user.id);
      if (!isParent) {
        throw new ForbiddenException('No puedes pagar cargos que no correspondan a tus hijos');
      }
    }

    if (payment.status === PaymentStatus.paid) {
      throw new BadRequestException('El pago ya fue procesado');
    }

    if (payment.status === PaymentStatus.cancelled) {
      throw new BadRequestException('No se puede pagar un cargo cancelado');
    }

    const digits = data.cardNumber.replace(/\D/g, '');
    if (digits.length < 12) {
      throw new BadRequestException('La tarjeta dummy debe contener al menos 12 digitos');
    }

    const last4 = digits.slice(-4);
    const brand = this.detectCardBrand(digits);
    const gatewayTransactionId = `DUMMY-${Date.now()}-${Math.floor(Math.random() * 100000)}`;

    const updatedPayment = await this.prisma.payment.update({
      where: { id },
      data: {
        status: PaymentStatus.paid,
        paidAt: new Date(),
        paymentMethod: 'card',
        gatewayTransactionId,
        gatewayResponse: {
          mode: 'dummy_card',
          approved: true,
          cardholderName: data.cardholderName.trim(),
          brand,
          last4,
          expiryMonth: data.expiryMonth,
          expiryYear: data.expiryYear,
          processedAt: new Date().toISOString(),
        },
      },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
      },
    });

    await this.prisma.notification.create({
      data: {
        tenantId,
        userId: user.id,
        type: 'payment_paid',
        title: 'Pago registrado',
        body: `Se registro el pago de ${updatedPayment.concept} para ${updatedPayment.child.firstName}.`,
        data: {
          paymentId: updatedPayment.id,
          childId: updatedPayment.child.id,
          gatewayTransactionId,
          simulation: true,
        },
        channel: 'in_app',
        sentAt: new Date(),
      },
    });

    return {
      ...updatedPayment,
      amount: Number(updatedPayment.amount),
    };
  }

  async cancel(tenantId: string, id: string) {
    const payment = await this.findById(tenantId, id);

    if (payment.status === PaymentStatus.paid) {
      throw new BadRequestException('No se puede cancelar un pago ya realizado');
    }

    return this.prisma.payment.update({
      where: { id },
      data: { status: PaymentStatus.cancelled },
    });
  }

  async findByChild(tenantId: string, childId: string) {
    return this.prisma.payment.findMany({
      where: { tenantId, childId },
      orderBy: { dueDate: 'desc' },
    });
  }

  async getOverdueSummary(tenantId: string) {
    const overdue = await this.prisma.payment.findMany({
      where: { tenantId, status: PaymentStatus.overdue },
      include: {
        child: { select: { id: true, firstName: true, lastName: true } },
      },
      orderBy: { dueDate: 'asc' },
    });

    const totalAmount = overdue.reduce(
      (sum, p) => sum + Number(p.amount),
      0,
    );

    return {
      count: overdue.length,
      totalAmount,
      payments: overdue,
    };
  }

  private async ensureMonthlyChargesForTenant(tenantId: string) {
    const today = new Date();
    const dueDate = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 5));
    const monthStart = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 1));
    const monthEnd = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth() + 1, 0));
    const concept = `Colegiatura ${this.getMonthLabel(today.getUTCMonth())} ${today.getUTCFullYear()}`;

    const children = await this.prisma.child.findMany({
      where: {
        tenantId,
        deletedAt: null,
        status: 'active',
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        parents: {
          select: {
            userId: true,
          },
        },
      },
    });

    for (const child of children) {
      const existingPayment = await this.prisma.payment.findFirst({
        where: {
          tenantId,
          childId: child.id,
          dueDate: {
            gte: monthStart,
            lte: monthEnd,
          },
        },
      });

      if (existingPayment) {
        continue;
      }

      const latestPayment = await this.prisma.payment.findFirst({
        where: {
          tenantId,
          childId: child.id,
        },
        orderBy: { dueDate: 'desc' },
      });

      const amount = latestPayment ? Number(latestPayment.amount) : 5500;
      const isOverdue = dueDate.getTime() < new Date(
        today.getUTCFullYear(),
        today.getUTCMonth(),
        today.getUTCDate(),
      ).getTime();

      const createdPayment = await this.prisma.payment.create({
        data: {
          tenantId,
          childId: child.id,
          concept,
          amount,
          currency: latestPayment?.currency || 'MXN',
          status: isOverdue ? PaymentStatus.overdue : PaymentStatus.pending,
          dueDate,
        },
      });

      if (child.parents.length > 0) {
        await this.prisma.notification.createMany({
          data: child.parents.map((parent) => ({
            tenantId,
            userId: parent.userId,
            type: 'payment_due',
            title: 'Nuevo cargo mensual',
            body: `Ya esta disponible ${concept} para ${child.firstName} ${child.lastName}.`,
            data: {
              paymentId: createdPayment.id,
              childId: child.id,
              amount,
            },
            channel: 'in_app',
            sentAt: new Date(),
          })),
        });
      }
    }
  }

  private getMonthLabel(monthIndex: number) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return months[monthIndex] || 'Mes';
  }

  private detectCardBrand(cardNumber: string) {
    if (cardNumber.startsWith('4')) {
      return 'visa';
    }

    if (/^5[1-5]/.test(cardNumber)) {
      return 'mastercard';
    }

    if (/^3[47]/.test(cardNumber)) {
      return 'amex';
    }

    return 'dummy_card';
  }
}
