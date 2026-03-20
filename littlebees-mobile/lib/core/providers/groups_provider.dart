import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo de grupo
class Group {
  final String id;
  final String name;
  final String? description;
  final int? capacity;
  final int childrenCount;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.capacity,
    this.childrenCount = 0,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      childrenCount: json['childrenCount'] as int? ?? 0,
    );
  }
}

// Modelo de niño
class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? groupId;
  final String? groupName;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.groupId,
    this.groupName,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
    );
  }
}

// Estado de grupos
class GroupsState {
  final List<Group> groups;
  final bool isLoading;
  final String? error;

  GroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
  });

  GroupsState copyWith({
    List<Group>? groups,
    bool? isLoading,
    String? error,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para grupos
class GroupsNotifier extends StateNotifier<GroupsState> {
  GroupsNotifier() : super(GroupsState());

  void setGroups(List<Group> groups) {
    state = state.copyWith(groups: groups, isLoading: false, error: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Aquí se implementaría la lógica para cargar grupos desde la API
  Future<void> loadGroups() async {
    setLoading(true);
    try {
      // TODO: Implementar llamada a la API
      // final groups = await apiService.getGroups();
      // setGroups(groups);
      setLoading(false);
    } catch (e) {
      setError(e.toString());
    }
  }
}

// Provider de grupos
final groupsProvider = StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
  return GroupsNotifier();
});

// Provider para obtener un grupo específico
final groupByIdProvider = Provider.family<Group?, String>((ref, groupId) {
  final groups = ref.watch(groupsProvider).groups;
  try {
    return groups.firstWhere((g) => g.id == groupId);
  } catch (e) {
    return null;
  }
});

// Estado de niños
class ChildrenState {
  final List<Child> children;
  final bool isLoading;
  final String? error;

  ChildrenState({
    this.children = const [],
    this.isLoading = false,
    this.error,
  });

  ChildrenState copyWith({
    List<Child>? children,
    bool? isLoading,
    String? error,
  }) {
    return ChildrenState(
      children: children ?? this.children,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para niños
class ChildrenNotifier extends StateNotifier<ChildrenState> {
  ChildrenNotifier() : super(ChildrenState());

  void setChildren(List<Child> children) {
    state = state.copyWith(children: children, isLoading: false, error: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<void> loadChildren({String? groupId}) async {
    setLoading(true);
    try {
      // TODO: Implementar llamada a la API
      // final children = await apiService.getChildren(groupId: groupId);
      // setChildren(children);
      setLoading(false);
    } catch (e) {
      setError(e.toString());
    }
  }
}

// Provider de niños
final childrenProvider = StateNotifierProvider<ChildrenNotifier, ChildrenState>((ref) {
  return ChildrenNotifier();
});

// Provider para obtener niños de un grupo específico
final childrenByGroupProvider = Provider.family<List<Child>, String>((ref, groupId) {
  final children = ref.watch(childrenProvider).children;
  return children.where((c) => c.groupId == groupId).toList();
});
