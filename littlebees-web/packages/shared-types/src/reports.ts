export interface AttendanceReportResponse {
  period: { from: string; to: string };
  groups: AttendanceGroupSummary[];
  overall: {
    totalDays: number;
    averageAttendanceRate: number;
  };
}

export interface AttendanceGroupSummary {
  groupId: string;
  groupName: string;
  totalChildren: number;
  averageAttendanceRate: number;
  dailyBreakdown: {
    date: string;
    present: number;
    absent: number;
    rate: number;
  }[];
}

export interface DevelopmentReportResponse {
  period: { from: string; to: string };
  children: DevelopmentChildSummary[];
}

export interface DevelopmentChildSummary {
  childId: string;
  childName: string;
  ageMonths: number;
  overallProgress: number;
  categoryBreakdown: {
    category: string;
    achieved: number;
    total: number;
    percent: number;
  }[];
}

export interface PaymentReportResponse {
  period: { from: string; to: string };
  totalRevenue: number;
  totalPending: number;
  totalOverdue: number;
  paymentsByStatus: {
    status: string;
    count: number;
    amount: number;
  }[];
  monthlyBreakdown: {
    month: string;
    collected: number;
    pending: number;
  }[];
}
