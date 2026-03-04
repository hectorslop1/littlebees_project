import { Injectable } from '@nestjs/common';
import { AttendanceStatus, MilestoneStatus, PaymentStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async getAttendanceReport(
    tenantId: string,
    from: string,
    to: string,
    groupId?: string,
  ) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    const groups = await this.prisma.group.findMany({
      where: { tenantId, ...(groupId && { id: groupId }) },
      include: {
        children: {
          where: { status: 'active' },
          select: { id: true },
        },
      },
    });

    const groupSummaries = await Promise.all(
      groups.map(async (group) => {
        const childIds = group.children.map((c) => c.id);

        const records = await this.prisma.attendanceRecord.findMany({
          where: {
            tenantId,
            childId: { in: childIds },
            date: { gte: fromDate, lte: toDate },
          },
        });

        // Group by date
        const dateMap = new Map<string, { present: number; absent: number }>();
        for (const record of records) {
          const dateKey = record.date.toISOString().split('T')[0];
          const entry = dateMap.get(dateKey) || { present: 0, absent: 0 };

          if (
            record.status === AttendanceStatus.present ||
            record.status === AttendanceStatus.late
          ) {
            entry.present++;
          } else {
            entry.absent++;
          }

          dateMap.set(dateKey, entry);
        }

        const dailyBreakdown = Array.from(dateMap.entries()).map(
          ([date, counts]) => ({
            date,
            present: counts.present,
            absent: counts.absent,
            rate:
              counts.present + counts.absent > 0
                ? Math.round(
                    (counts.present / (counts.present + counts.absent)) * 100,
                  )
                : 0,
          }),
        );

        const totalPresent = records.filter(
          (r) =>
            r.status === AttendanceStatus.present ||
            r.status === AttendanceStatus.late,
        ).length;
        const totalRecords = records.length;

        return {
          groupId: group.id,
          groupName: group.name,
          totalChildren: childIds.length,
          averageAttendanceRate:
            totalRecords > 0
              ? Math.round((totalPresent / totalRecords) * 100)
              : 0,
          dailyBreakdown,
        };
      }),
    );

    const allRates = groupSummaries.map((g) => g.averageAttendanceRate);
    const overallRate =
      allRates.length > 0
        ? Math.round(allRates.reduce((a, b) => a + b, 0) / allRates.length)
        : 0;

    return {
      period: { from, to },
      groups: groupSummaries,
      overall: {
        totalDays: Math.ceil(
          (toDate.getTime() - fromDate.getTime()) / (1000 * 60 * 60 * 24),
        ),
        averageAttendanceRate: overallRate,
      },
    };
  }

  async getDevelopmentReport(
    tenantId: string,
    from: string,
    to: string,
    groupId?: string,
  ) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    const childrenWhere: Record<string, unknown> = {
      tenantId,
      status: 'active',
    };
    if (groupId) childrenWhere.groupId = groupId;

    const children = await this.prisma.child.findMany({
      where: childrenWhere,
      select: { id: true, firstName: true, lastName: true, dateOfBirth: true },
    });

    const childSummaries = await Promise.all(
      children.map(async (child) => {
        const records = await this.prisma.developmentRecord.findMany({
          where: {
            tenantId,
            childId: child.id,
            evaluatedAt: { gte: fromDate, lte: toDate },
          },
          include: { milestone: true },
        });

        const categoryMap = new Map<
          string,
          { achieved: number; total: number }
        >();

        for (const record of records) {
          const cat = record.milestone.category;
          const entry = categoryMap.get(cat) || { achieved: 0, total: 0 };
          entry.total++;
          if (record.status === MilestoneStatus.achieved) entry.achieved++;
          categoryMap.set(cat, entry);
        }

        const categoryBreakdown = Array.from(categoryMap.entries()).map(
          ([category, counts]) => ({
            category,
            achieved: counts.achieved,
            total: counts.total,
            percent:
              counts.total > 0
                ? Math.round((counts.achieved / counts.total) * 100)
                : 0,
          }),
        );

        const totalAchieved = records.filter(
          (r) => r.status === MilestoneStatus.achieved,
        ).length;

        const ageMonths = Math.floor(
          (Date.now() - child.dateOfBirth.getTime()) / (1000 * 60 * 60 * 24 * 30.44),
        );

        return {
          childId: child.id,
          childName: `${child.firstName} ${child.lastName}`,
          ageMonths,
          overallProgress:
            records.length > 0
              ? Math.round((totalAchieved / records.length) * 100)
              : 0,
          categoryBreakdown,
        };
      }),
    );

    return {
      period: { from, to },
      children: childSummaries,
    };
  }

  async getPaymentReport(tenantId: string, from: string, to: string) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    const payments = await this.prisma.payment.findMany({
      where: {
        tenantId,
        createdAt: { gte: fromDate, lte: toDate },
      },
    });

    const statusCounts = new Map<string, { count: number; amount: number }>();
    for (const payment of payments) {
      const entry = statusCounts.get(payment.status) || {
        count: 0,
        amount: 0,
      };
      entry.count++;
      entry.amount += Number(payment.amount);
      statusCounts.set(payment.status, entry);
    }

    const paidPayments = payments.filter(
      (p) => p.status === PaymentStatus.paid,
    );
    const pendingPayments = payments.filter(
      (p) => p.status === PaymentStatus.pending,
    );
    const overduePayments = payments.filter(
      (p) => p.status === PaymentStatus.overdue,
    );

    // Monthly breakdown
    const monthlyMap = new Map<
      string,
      { collected: number; pending: number }
    >();
    for (const payment of payments) {
      const monthKey = payment.createdAt.toISOString().substring(0, 7);
      const entry = monthlyMap.get(monthKey) || { collected: 0, pending: 0 };

      if (payment.status === PaymentStatus.paid) {
        entry.collected += Number(payment.amount);
      } else if (
        payment.status === PaymentStatus.pending ||
        payment.status === PaymentStatus.overdue
      ) {
        entry.pending += Number(payment.amount);
      }

      monthlyMap.set(monthKey, entry);
    }

    return {
      period: { from, to },
      totalRevenue: paidPayments.reduce((s, p) => s + Number(p.amount), 0),
      totalPending: pendingPayments.reduce((s, p) => s + Number(p.amount), 0),
      totalOverdue: overduePayments.reduce((s, p) => s + Number(p.amount), 0),
      paymentsByStatus: Array.from(statusCounts.entries()).map(
        ([status, data]) => ({
          status,
          count: data.count,
          amount: data.amount,
        }),
      ),
      monthlyBreakdown: Array.from(monthlyMap.entries())
        .map(([month, data]) => ({
          month,
          collected: data.collected,
          pending: data.pending,
        }))
        .sort((a, b) => a.month.localeCompare(b.month)),
    };
  }
}
