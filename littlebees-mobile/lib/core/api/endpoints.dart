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
  static String childProfile(String id) => '/children/$id/profile';
  static String childProfileSuggestions(String id) =>
      '/children/$id/profile-suggestions';
  static String childMedical(String id) => '/children/$id/medical-info';
  static String childContacts(String id) => '/children/$id/emergency-contacts';
  static String childContact(String childId, String contactId) =>
      '/children/$childId/emergency-contacts/$contactId';
  static String childParents(String id) => '/children/$id/parents';
  static String childParent(String childId, String userId) =>
      '/children/$childId/parents/$userId';

  // Attendance
  static const String attendance = '/attendance';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceMark = '/attendance/mark';

  // Daily Logs
  static const String dailyLogs = '/daily-logs';
  static const String dailyLogsQuickRegister = '/daily-logs/quick-register';
  static String daySchedule(String groupId) =>
      '/daily-logs/day-schedule/$groupId';

  // Groups
  static const String groups = '/groups';
  static String group(String id) => '/groups/$id';

  // Development
  static const String development = '/development';
  static const String milestones = '/development/milestones';
  static String developmentSummary(String childId) =>
      '/development/$childId/summary';

  // Chat
  static const String chatContacts = '/chat/contacts';
  static const String conversations = '/chat/conversations';
  static String messages(String convId) =>
      '/chat/conversations/$convId/messages';

  // Payments
  static const String payments = '/payments';
  static String pay(String id) => '/payments/$id/mark-paid';
  static String simulatePay(String id) => '/payments/$id/simulate-pay';

  // Notifications
  static const String notifications = '/notifications';

  // Files
  static const String fileUpload = '/files/upload';
  static String file(String id) => '/files/$id';

  // Reports
  static const String reports = '/reports';

  // AI Assistant
  static const String aiSessions = '/ai/sessions';
  static String aiSession(String id) => '/ai/sessions/$id';
  static String aiChat(String id) => '/ai/sessions/$id/chat';

  // Users
  static const String users = '/users';
  static const String usersMe = '/users/me';

  // Excuses/Justificantes
  static const String excuses = '/excuses';
  static String excuse(String id) => '/excuses/$id';
  static String excusesByChild(String childId) => '/excuses/child/$childId';
  static String updateExcuseStatus(String id) => '/excuses/$id/status';

  // Health
  static const String health = '/health';
}
