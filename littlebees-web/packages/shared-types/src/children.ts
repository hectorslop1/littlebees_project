import { ChildStatus, Gender } from './enums';

export interface ChildResponse {
  id: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: Gender;
  photoUrl: string | null;
  groupId: string;
  groupName: string;
  status: ChildStatus;
  enrollmentDate: string;
  age: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateChildRequest {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: Gender;
  groupId: string;
  parentIds: string[];
}

export interface UpdateChildRequest {
  firstName?: string;
  lastName?: string;
  groupId?: string;
  status?: ChildStatus;
}

export interface MedicalInfoResponse {
  id: string;
  childId: string;
  allergies: string[];
  conditions: string[];
  medications: string[];
  bloodType: string | null;
  observations: string | null;
  doctorName: string | null;
  doctorPhone: string | null;
}

export interface UpdateMedicalInfoRequest {
  allergies?: string[];
  conditions?: string[];
  medications?: string[];
  bloodType?: string;
  observations?: string;
  doctorName?: string;
  doctorPhone?: string;
}

export interface EmergencyContactResponse {
  id: string;
  childId: string;
  name: string;
  relationship: string;
  phone: string;
  email: string | null;
  priority: number;
}

export interface CreateEmergencyContactRequest {
  name: string;
  relationship: string;
  phone: string;
  email?: string;
}

export interface GroupResponse {
  id: string;
  name: string; // Legacy field, kept for compatibility
  level: string; // Educational stage: 'lactantes', 'maternal', 'preescolar_1', etc.
  friendlyName: string; // UI display name: "Abejitas 🐝", "Mariposas 🦋", etc.
  subgroup: string | null; // Optional subgroup: "A", "B", "C"
  ageRangeMin: number;
  ageRangeMax: number;
  capacity: number;
  color: string;
  academicYear: string;
  teacherId: string | null;
  teacherName: string | null;
  childrenCount: number;
}
