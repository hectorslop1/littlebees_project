import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/child_model.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/models/daily_log_model.dart';
import '../domain/daily_story.dart';
import '../data/remote_home_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/providers/repository_providers.dart'
    show attendanceRepositoryProvider, dailyLogsRepositoryProvider;
import '../../auth/application/auth_provider.dart';
import '../../groups/application/groups_provider.dart';
import '../../excuses/application/excuses_provider.dart';

// Provider for the RemoteHomeRepository
final remoteHomeRepositoryProvider = Provider<RemoteHomeRepository>((ref) {
  return RemoteHomeRepository();
});

// Provider for the ChildrenRepository
final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository();
});

// Provider to get all children for the current user (role-based filtering)
final myChildrenProvider = FutureProvider<List<Child>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(childrenRepositoryProvider);

  // The backend API automatically filters children based on user role:
  // - Parents see only their children (via child_parents table)
  // - Teachers see children in their assigned groups
  // - Admins/Directors see all children in their tenant
  return await repository.getMyChildren(user: user);
});

// StateProvider to keep track of the currently selected child ID
// Will be set to the first child's ID once children are loaded
final currentChildIdProvider = StateProvider<String?>((ref) => null);

// Provider for the daily story of the selected child
final dailyStoryProvider = FutureProvider.family<DailyStory, String>((
  ref,
  childId,
) async {
  final repository = ref.watch(remoteHomeRepositoryProvider);
  final date = DateTime.now();

  // Fetch real data from API
  return await repository.getDailyStory(childId, date);
});

final todayRoleAttendanceProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  final children = await ref.watch(myChildrenProvider.future);
  if (children.isEmpty) {
    return [];
  }

  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getAttendanceForChildren(
    childIds: children.map((child) => child.id).toList(),
    date: DateTime.now(),
  );
});

final todayRoleDailyLogsProvider = FutureProvider<List<DailyLogEntry>>((
  ref,
) async {
  final repository = ref.watch(dailyLogsRepositoryProvider);
  return repository.getDailyLogsByDate(date: DateTime.now());
});

class TeacherDashboardSnapshot {
  const TeacherDashboardSnapshot({
    required this.groupsCount,
    required this.studentsCount,
    required this.presentCount,
    required this.todayActivitiesCount,
    required this.pendingExcusesCount,
  });

  final int groupsCount;
  final int studentsCount;
  final int presentCount;
  final int todayActivitiesCount;
  final int pendingExcusesCount;
}

final teacherDashboardProvider = FutureProvider<TeacherDashboardSnapshot>((
  ref,
) async {
  final groups = await ref.watch(groupsProvider.future);
  final children = await ref.watch(myChildrenProvider.future);
  final attendance = await ref.watch(todayRoleAttendanceProvider.future);
  final logs = await ref.watch(todayRoleDailyLogsProvider.future);
  final excuses = await ref.watch(
    excusesListProvider(ExcusesFilters(status: ExcuseStatus.pending)).future,
  );

  final presentIds = attendance
      .where(
        (record) =>
            record.checkInAt != null ||
            record.status == AttendanceStatus.present ||
            record.status == AttendanceStatus.late_,
      )
      .map((record) => record.childId)
      .toSet();

  return TeacherDashboardSnapshot(
    groupsCount: groups.length,
    studentsCount: children.length,
    presentCount: presentIds.length,
    todayActivitiesCount: logs.length,
    pendingExcusesCount: excuses.length,
  );
});

class DirectorDashboardSnapshot {
  const DirectorDashboardSnapshot({
    required this.groupsCount,
    required this.studentsCount,
    required this.presentCount,
    required this.todayActivitiesCount,
    required this.pendingExcusesCount,
  });

  final int groupsCount;
  final int studentsCount;
  final int presentCount;
  final int todayActivitiesCount;
  final int pendingExcusesCount;
}

final directorDashboardProvider = FutureProvider<DirectorDashboardSnapshot>((
  ref,
) async {
  final groups = await ref.watch(groupsProvider.future);
  final children = await ref.watch(myChildrenProvider.future);
  final attendance = await ref.watch(todayRoleAttendanceProvider.future);
  final logs = await ref.watch(todayRoleDailyLogsProvider.future);
  final excuses = await ref.watch(
    excusesListProvider(ExcusesFilters(status: ExcuseStatus.pending)).future,
  );

  final presentIds = attendance
      .where(
        (record) =>
            record.checkInAt != null ||
            record.status == AttendanceStatus.present ||
            record.status == AttendanceStatus.late_,
      )
      .map((record) => record.childId)
      .toSet();

  return DirectorDashboardSnapshot(
    groupsCount: groups.length,
    studentsCount: children.length,
    presentCount: presentIds.length,
    todayActivitiesCount: logs.length,
    pendingExcusesCount: excuses.length,
  );
});
