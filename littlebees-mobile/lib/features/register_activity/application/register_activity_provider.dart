import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/register_activity_repository.dart';
import '../../../shared/models/daily_log_model.dart';

final registerActivityRepositoryProvider = Provider<RegisterActivityRepository>((ref) {
  return RegisterActivityRepository();
});

class RegisterActivityNotifier extends StateNotifier<AsyncValue<DailyLogEntry?>> {
  final RegisterActivityRepository _repository;

  RegisterActivityNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> quickRegister({
    required String childId,
    required String type,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.quickRegister(
        childId: childId,
        type: type,
        title: title,
        description: description,
        metadata: metadata,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerCheckIn({
    required String childId,
    String? photoUrl,
    String? mood,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.registerCheckIn(
        childId: childId,
        photoUrl: photoUrl,
        mood: mood,
        notes: notes,
      );
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerCheckOut({
    required String childId,
    String? photoUrl,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.registerCheckOut(
        childId: childId,
        photoUrl: photoUrl,
        notes: notes,
      );
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerMeal({
    required String childId,
    required String foodEaten,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.registerMeal(
        childId: childId,
        foodEaten: foodEaten,
        notes: notes,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerNap({
    required String childId,
    required int durationMinutes,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.registerNap(
        childId: childId,
        durationMinutes: durationMinutes,
        notes: notes,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> registerActivity({
    required String childId,
    required String activityDescription,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.registerActivity(
        childId: childId,
        activityDescription: activityDescription,
        notes: notes,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final registerActivityProvider = StateNotifierProvider<RegisterActivityNotifier, AsyncValue<DailyLogEntry?>>((ref) {
  final repository = ref.watch(registerActivityRepositoryProvider);
  return RegisterActivityNotifier(repository);
});
