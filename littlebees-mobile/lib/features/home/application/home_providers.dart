import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/child_model.dart';
import '../domain/daily_story.dart';
import '../data/remote_home_repository.dart';

// Provider for the RemoteHomeRepository
final remoteHomeRepositoryProvider = Provider<RemoteHomeRepository>((ref) {
  return RemoteHomeRepository();
});

// Provider to get all children for the current user
final myChildrenProvider = FutureProvider<List<Child>>((ref) async {
  final repo = ref.watch(remoteHomeRepositoryProvider);
  return repo.getMyChildren();
});

// StateProvider to keep track of the currently selected child ID
// Will be set to the first child's ID once children are loaded
final currentChildIdProvider = StateProvider<String?>((ref) => null);

// Provider for the daily story of the selected child
final dailyStoryProvider = FutureProvider.family<DailyStory, String>((
  ref,
  childId,
) async {
  final repo = ref.watch(remoteHomeRepositoryProvider);
  return repo.getDailyStory(childId, DateTime.now());
});
