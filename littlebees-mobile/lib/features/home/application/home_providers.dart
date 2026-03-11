import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/child_model.dart';
import '../domain/daily_story.dart';
import '../data/remote_home_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../auth/application/auth_provider.dart';

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
