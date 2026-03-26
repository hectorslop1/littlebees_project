import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/excuses_repository.dart';
import '../../../shared/models/excuse_model.dart';
import '../../../shared/enums/enums.dart';

final excusesRepositoryProvider = Provider<ExcusesRepository>((ref) {
  return ExcusesRepository();
});

/// Provider para listar justificantes
final excusesListProvider = FutureProvider.autoDispose.family<List<Excuse>, ExcusesFilters?>((ref, filters) async {
  final repository = ref.watch(excusesRepositoryProvider);
  
  return repository.getExcuses(
    childId: filters?.childId,
    status: filters?.status,
    startDate: filters?.startDate,
    endDate: filters?.endDate,
  );
});

/// Provider para justificantes de un niño específico
final excusesByChildProvider = FutureProvider.autoDispose.family<List<Excuse>, String>((ref, childId) async {
  final repository = ref.watch(excusesRepositoryProvider);
  return repository.getExcusesByChild(childId);
});

/// Provider para detalle de un justificante
final excuseDetailProvider = FutureProvider.autoDispose.family<Excuse, String>((ref, id) async {
  final repository = ref.watch(excusesRepositoryProvider);
  return repository.getExcuseById(id);
});

/// Notifier para acciones de justificantes
class ExcusesNotifier extends StateNotifier<AsyncValue<Excuse?>> {
  final ExcusesRepository _repository;

  ExcusesNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createExcuse({
    required String childId,
    required ExcuseType type,
    required String title,
    String? description,
    required DateTime date,
    List<String>? attachments,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.createExcuse(
        childId: childId,
        type: type,
        title: title,
        description: description,
        date: date,
        attachments: attachments,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateStatus({
    required String id,
    required ExcuseStatus status,
    String? reviewNotes,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _repository.updateExcuseStatus(
        id: id,
        status: status,
        reviewNotes: reviewNotes,
      );
      
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteExcuse(String id) async {
    state = const AsyncValue.loading();
    
    try {
      await _repository.deleteExcuse(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final excusesNotifierProvider = StateNotifierProvider<ExcusesNotifier, AsyncValue<Excuse?>>((ref) {
  final repository = ref.watch(excusesRepositoryProvider);
  return ExcusesNotifier(repository);
});

/// Clase para filtros de justificantes
class ExcusesFilters {
  final String? childId;
  final ExcuseStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  ExcusesFilters({
    this.childId,
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcusesFilters &&
          runtimeType == other.runtimeType &&
          childId == other.childId &&
          status == other.status &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(childId, status, startDate, endDate);
}
