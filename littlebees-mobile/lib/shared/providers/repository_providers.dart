import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/children_repository.dart';
import '../repositories/daily_logs_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/conversations_repository.dart';
import '../repositories/payments_repository.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository();
});

final dailyLogsRepositoryProvider = Provider<DailyLogsRepository>((ref) {
  return DailyLogsRepository();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  return ConversationsRepository();
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository();
});
