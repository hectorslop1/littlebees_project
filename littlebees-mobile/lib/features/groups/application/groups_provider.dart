import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/group_model.dart';
import '../data/groups_repository.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository();
});

final groupsProvider = FutureProvider<List<GroupModel>>((ref) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return await repository.getGroups();
});

final groupByIdProvider = FutureProvider.family<GroupModel, String>((ref, groupId) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return await repository.getGroupById(groupId);
});
