import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PaymentStatus } from '@prisma/client';
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
      data,
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
      data,
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
}
