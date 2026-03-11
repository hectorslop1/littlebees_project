class Endpoints {
  Endpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String mfaSetup = '/auth/mfa/setup';
  static const String mfaVerify = '/auth/mfa/verify';

  // Children
  static const String children = '/children';
  static String child(String id) => '/children/$id';
  static String childMedical(String id) => '/children/$id/medical';
  static String childContacts(String id) => '/children/$id/contacts';

  // Attendance
  static const String attendance = '/attendance';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';

  // Daily Logs
  static const String dailyLogs = '/daily-logs';

  // Development
  static const String development = '/development';
  static const String milestones = '/development/milestones';
  static String developmentSummary(String childId) =>
      '/development/$childId/summary';

  // Chat
  static const String conversations = '/chat/conversations';
  static String messages(String convId) =>
      '/chat/conversations/$convId/messages';

  // Payments
  static const String payments = '/payments';
  static String pay(String id) => '/payments/$id/pay';

  // Notifications
  static const String notifications = '/notifications';

  // Files
  static const String fileUpload = '/files/upload';

  // Reports
  static const String reports = '/reports';

  // Health
  static const String health = '/health';
}
