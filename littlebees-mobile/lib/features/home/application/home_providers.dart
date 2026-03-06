import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/child_model.dart';
import '../domain/daily_story.dart';
import '../data/remote_home_repository.dart';
import '../../../core/mocks/mock_data.dart';

// Provider for the RemoteHomeRepository
final remoteHomeRepositoryProvider = Provider<RemoteHomeRepository>((ref) {
  return RemoteHomeRepository();
});

// Provider to get all children for the current user
final myChildrenProvider = FutureProvider<List<Child>>((ref) async {
  // Temporarily return mock data to avoid API issues
  await Future.delayed(
    const Duration(milliseconds: 800),
  ); // Simulate network delay
  return [MockData.child1, MockData.child2];
});

// StateProvider to keep track of the currently selected child ID
// Will be set to the first child's ID once children are loaded
final currentChildIdProvider = StateProvider<String?>((ref) => null);

// Provider for the daily story of the selected child
final dailyStoryProvider = FutureProvider.family<DailyStory, String>((
  ref,
  childId,
) async {
  // Temporarily use mock data to avoid API issues
  await Future.delayed(
    const Duration(milliseconds: 1500),
  ); // Simulate network delay

  // Return appropriate mock data based on child ID
  if (childId == 'demo-child-1' || childId == 'c1') {
    return MockData.dailyStory;
  } else if (childId == 'c2') {
    return MockData.dailyStory2;
  } else {
    return MockData.dailyStory; // Default to first child's story
  }
});
