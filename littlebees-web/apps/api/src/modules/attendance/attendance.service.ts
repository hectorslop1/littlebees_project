import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AttendanceService {
  constructor(private readonly prisma: PrismaService) {}

  async getByDate(tenantId: string, date: string) {
    return this.prisma.attendanceRecord.findMany({
      where: { tenantId, date: new Date(date) },
      include: {
        child: { select: { id: true, firstName: true, lastName: true, photoUrl: true } },
      },
      orderBy: { checkInAt: 'desc' },
    });
  }

  async checkIn(tenantId: string, childId: string, userId: string, method: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.attendanceRecord.upsert({
      where: { childId_date: { childId, date: today } },
      create: {
        tenantId,
        childId,
        date: today,
        checkInAt: new Date(),
        checkInBy: userId,
        checkInMethod: method,
        status: 'present',
      },
      update: {
        checkInAt: new Date(),
        checkInBy: userId,
        checkInMethod: method,
        status: 'present',
      },
    });
  }

  async checkOut(tenantId: string, childId: string, userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.prisma.attendanceRecord.updateMany({
      where: {
        tenantId,
        childId,
        date: today,
        checkOutAt: null,
      },
      data: {
        checkOutAt: new Date(),
        checkOutBy: userId,
      },
    });
  }
}
