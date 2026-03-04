import { AttendanceStatus, CheckInMethod } from './enums';

export interface AttendanceRecordResponse {
  id: string;
  childId: string;
  childName: string;
  date: string;
  checkInAt: string | null;
  checkOutAt: string | null;
  checkInBy: string | null;
  checkOutBy: string | null;
  checkInMethod: CheckInMethod;
  status: AttendanceStatus;
  observations: string | null;
}

export interface CheckInRequest {
  childId: string;
  method: CheckInMethod;
  observations?: string;
}

export interface CheckOutRequest {
  childId: string;
  method: CheckInMethod;
  observations?: string;
}

export interface AttendanceSummaryResponse {
  date: string;
  groupId: string;
  groupName: string;
  totalChildren: number;
  present: number;
  absent: number;
  late: number;
  excused: number;
  attendanceRate: number;
}
