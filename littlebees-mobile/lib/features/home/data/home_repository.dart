import '../domain/daily_story.dart';
import '../../../core/mocks/mock_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class HomeRepository {
  Future<DailyStory> getDailyStory(String childId, DateTime date);
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<DailyStory> getDailyStory(String childId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (childId == 'c2') return MockData.dailyStory2;
    return MockData.dailyStory;
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository();
});
