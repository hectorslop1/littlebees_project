import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/child_model.dart';
import '../../home/application/home_providers.dart';

final childProfileProvider = FutureProvider.family<Child, String>((
  ref,
  childId,
) async {
  final repository = ref.watch(childrenRepositoryProvider);
  return repository.getChildById(childId);
});
