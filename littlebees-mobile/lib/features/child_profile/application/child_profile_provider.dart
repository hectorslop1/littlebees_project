import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/child_profile_repository.dart';
import '../domain/child_profile_model.dart';

final childProfileRepositoryProvider = Provider<ChildProfileRepository>((ref) {
  return ChildProfileRepository();
});

final childProfileProvider = FutureProvider.family<ChildProfileModel, String>((
  ref,
  childId,
) async {
  final repository = ref.watch(childProfileRepositoryProvider);
  return repository.getChildProfile(childId);
});

final childProfileSuggestionsProvider =
    FutureProvider.family<ChildProfileSuggestions, String>((ref, childId) async {
      final repository = ref.watch(childProfileRepositoryProvider);
      return repository.getProfileSuggestions(childId);
    });
