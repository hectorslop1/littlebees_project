import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InvoiceStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class InvoicingService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    options?: {
      status?: string;
      paymentId?: string;
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

    if (options?.status) where.status = options.status as InvoiceStatus;
    if (options?.paymentId) where.paymentId = options.paymentId;
    if (options?.startDate || options?.endDate) {
      where.issuedAt = {
        ...(options?.startDate && { gte: new Date(options.startDate) }),
        ...(options?.endDate && { lte: new Date(options.endDate) }),
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.invoice.findMany({
        where,
        skip,
        take: limit,
        include: {
          payment: { select: { id: true, concept: true, amount: true, childId: true } },
        },
        orderBy: { issuedAt: 'desc' },
      }),
      this.prisma.invoice.count({ where }),
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
    const invoice = await this.prisma.invoice.findFirst({
      where: { id, tenantId },
      include: {
        payment: {
          select: { id: true, concept: true, amount: true, childId: true, status: true },
        },
      },
    });

    if (!invoice) {
      throw new NotFoundException('Factura no encontrada');
    }

    return invoice;
  }

  async create(
    tenantId: string,
    data: {
      paymentId: string;
      rfcReceptor: string;
      razonSocial: string;
      regimenFiscal: string;
      usoCfdi: string;
      codigoPostal: string;
    },
  ) {
    const payment = await this.prisma.payment.findFirst({
      where: { id: data.paymentId, tenantId },
    });

    if (!payment) {
      throw new NotFoundException('Pago no encontrado');
    }

    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
    });

    const folio = `KS-${Date.now()}`;

    return this.prisma.invoice.create({
      data: {
        tenantId,
        paymentId: data.paymentId,
        folio,
        rfcEmisor: tenant?.satRfc || '',
        rfcReceptor: data.rfcReceptor,
        total: payment.amount,
        status: InvoiceStatus.valid,
        issuedAt: new Date(),
      },
      include: {
        payment: { select: { id: true, concept: true, amount: true } },
      },
    });
  }

  async cancel(tenantId: string, id: string, reason: string) {
    const invoice = await this.findById(tenantId, id);

    if (invoice.status === InvoiceStatus.cancelled) {
      throw new BadRequestException('La factura ya está cancelada');
    }

    return this.prisma.invoice.update({
      where: { id },
      data: {
        status: InvoiceStatus.cancelled,
        cancelledAt: new Date(),
        cancellationReason: reason,
      },
    });
  }

  async findByPayment(tenantId: string, paymentId: string) {
    return this.prisma.invoice.findMany({
      where: { tenantId, paymentId },
      orderBy: { issuedAt: 'desc' },
    });
  }
}
