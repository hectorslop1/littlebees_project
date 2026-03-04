export 'user_role.dart';

// --- Child enrollment status ---
enum ChildStatus {
  active('active'),
  inactive('inactive'),
  graduated('graduated');

  const ChildStatus(this.value);
  final String value;

  static ChildStatus fromString(String value) {
    return ChildStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChildStatus.active,
    );
  }
}

enum Gender {
  male('male'),
  female('female');

  const Gender(this.value);
  final String value;

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gender.male,
    );
  }
}

// --- Attendance ---
enum AttendanceStatus {
  present('present'),
  absent('absent'),
  late_('late'),
  excused('excused');

  const AttendanceStatus(this.value);
  final String value;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

enum CheckInMethod {
  qr('qr'),
  manual('manual'),
  biometric('biometric');

  const CheckInMethod(this.value);
  final String value;

  static CheckInMethod fromString(String value) {
    return CheckInMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckInMethod.manual,
    );
  }
}

// --- Daily logs ---
enum LogType {
  meal('meal'),
  nap('nap'),
  activity('activity'),
  diaper('diaper'),
  medication('medication'),
  observation('observation'),
  incident('incident');

  const LogType(this.value);
  final String value;

  static LogType fromString(String value) {
    return LogType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LogType.observation,
    );
  }
}

// --- Development ---
enum DevelopmentCategory {
  motorFine('motor_fine'),
  motorGross('motor_gross'),
  cognitive('cognitive'),
  language('language'),
  social('social'),
  emotional('emotional');

  const DevelopmentCategory(this.value);
  final String value;

  static DevelopmentCategory fromString(String value) {
    return DevelopmentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DevelopmentCategory.cognitive,
    );
  }
}

enum MilestoneStatus {
  achieved('achieved'),
  inProgress('in_progress'),
  notAchieved('not_achieved');

  const MilestoneStatus(this.value);
  final String value;

  static MilestoneStatus fromString(String value) {
    return MilestoneStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MilestoneStatus.notAchieved,
    );
  }
}

// --- Payments ---
enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  overdue('overdue'),
  cancelled('cancelled');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethodType {
  card('card'),
  oxxo('oxxo'),
  spei('spei');

  const PaymentMethodType(this.value);
  final String value;

  static PaymentMethodType fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethodType.spei,
    );
  }
}

// --- Chat ---
enum MessageType {
  text('text'),
  image('image'),
  file('file'),
  system('system');

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageType.text,
    );
  }
}

// --- Notifications ---
enum NotificationChannel {
  push('push'),
  email('email'),
  sms('sms'),
  inApp('in_app');

  const NotificationChannel(this.value);
  final String value;

  static NotificationChannel fromString(String value) {
    return NotificationChannel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationChannel.inApp,
    );
  }
}

// --- Files ---
enum FilePurpose {
  avatar('avatar'),
  evidence('evidence'),
  document('document'),
  attachment('attachment');

  const FilePurpose(this.value);
  final String value;

  static FilePurpose fromString(String value) {
    return FilePurpose.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FilePurpose.document,
    );
  }
}
