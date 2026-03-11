import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/daily_log_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../home/application/home_providers.dart';
import '../../auth/application/auth_provider.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final attendanceForDateProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final children = await ref.watch(myChildrenProvider.future);
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(attendanceRepositoryProvider);

  if (user == null || children.isEmpty) {
    return [];
  }

  final childIds = children.map((c) => c.id).toList();

  return await repository.getAttendanceForChildren(
    childIds: childIds,
    date: selectedDate,
  );
});

final dailyLogsForDateProvider = FutureProvider<List<DailyLogEntry>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  final children = await ref.watch(myChildrenProvider.future);
  final selectedDate = ref.watch(selectedDateProvider);
  final repository = ref.watch(dailyLogsRepositoryProvider);

  if (user == null || children.isEmpty) {
    return [];
  }

  final childIds = children.map((c) => c.id).toList();

  return await repository.getDailyLogsForChildren(
    childIds: childIds,
    date: selectedDate,
  );
});
