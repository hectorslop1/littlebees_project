// User roles within a tenant
export enum UserRole {
  SUPER_ADMIN = 'super_admin',
  DIRECTOR = 'director',
  ADMIN = 'admin',
  TEACHER = 'teacher',
  PARENT = 'parent',
}

// Child enrollment status
export enum ChildStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  GRADUATED = 'graduated',
}

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
}

// Attendance
export enum AttendanceStatus {
  PRESENT = 'present',
  ABSENT = 'absent',
  LATE = 'late',
  EXCUSED = 'excused',
}

export enum CheckInMethod {
  QR = 'qr',
  MANUAL = 'manual',
  BIOMETRIC = 'biometric',
}

// Daily log types
export enum LogType {
  MEAL = 'meal',
  NAP = 'nap',
  ACTIVITY = 'activity',
  DIAPER = 'diaper',
  MEDICATION = 'medication',
  OBSERVATION = 'observation',
  INCIDENT = 'incident',
}

// Development categories
export enum DevelopmentCategory {
  MOTOR_FINE = 'motor_fine',
  MOTOR_GROSS = 'motor_gross',
  COGNITIVE = 'cognitive',
  LANGUAGE = 'language',
  SOCIAL = 'social',
  EMOTIONAL = 'emotional',
}

export enum MilestoneStatus {
  ACHIEVED = 'achieved',
  IN_PROGRESS = 'in_progress',
  NOT_ACHIEVED = 'not_achieved',
}

// Payments
export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  CANCELLED = 'cancelled',
}

export enum PaymentMethodType {
  CARD = 'card',
  OXXO = 'oxxo',
  SPEI = 'spei',
}

// Invoicing (CFDI)
export enum InvoiceStatus {
  VALID = 'valid',
  CANCELLED = 'cancelled',
}

// Chat
export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  FILE = 'file',
  SYSTEM = 'system',
}

// Notifications
export enum NotificationChannel {
  PUSH = 'push',
  EMAIL = 'email',
  SMS = 'sms',
  IN_APP = 'in_app',
}

// Files
export enum FilePurpose {
  AVATAR = 'avatar',
  EVIDENCE = 'evidence',
  DOCUMENT = 'document',
  ATTACHMENT = 'attachment',
}

// Subscription
export enum SubscriptionStatus {
  TRIAL = 'trial',
  ACTIVE = 'active',
  PAST_DUE = 'past_due',
  CANCELLED = 'cancelled',
}

// Services
export enum ServiceType {
  CLASS = 'class',
  WORKSHOP = 'workshop',
  MARKETPLACE_ITEM = 'marketplace_item',
}
