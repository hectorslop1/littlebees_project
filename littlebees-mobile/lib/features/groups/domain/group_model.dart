class GroupModel {
  final String id;
  final String name;
  final String? friendlyName;
  final String? description;
  final int ageRangeStart;
  final int ageRangeEnd;
  final int maxCapacity;
  final int currentCapacity;
  final List<String>? teacherNames;
  final String? color;
  final List<Map<String, dynamic>>? children;

  GroupModel({
    required this.id,
    required this.name,
    this.friendlyName,
    this.description,
    required this.ageRangeStart,
    required this.ageRangeEnd,
    required this.maxCapacity,
    required this.currentCapacity,
    this.teacherNames,
    this.color,
    this.children,
  });

  String get displayName => friendlyName ?? name;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // Children count: from _count (list endpoint) or children array (detail endpoint)
    int childrenCount = 0;
    if (json['_count'] != null && json['_count']['children'] != null) {
      childrenCount = json['_count']['children'] as int;
    } else if (json['children'] != null && json['children'] is List) {
      childrenCount = (json['children'] as List).length;
    } else if (json['childrenCount'] != null) {
      childrenCount = json['childrenCount'] as int;
    } else if (json['currentCapacity'] != null) {
      childrenCount = json['currentCapacity'] as int;
    }

    // Parse children array if present (from detail endpoint)
    List<Map<String, dynamic>>? childrenList;
    if (json['children'] != null && json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
    }

    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      friendlyName: json['friendlyName'] as String?,
      description: json['description'] as String?,
      ageRangeStart:
          json['ageRangeMin'] as int? ?? json['ageRangeStart'] as int? ?? 0,
      ageRangeEnd:
          json['ageRangeMax'] as int? ?? json['ageRangeEnd'] as int? ?? 5,
      maxCapacity: json['capacity'] as int? ?? json['maxCapacity'] as int? ?? 0,
      currentCapacity: childrenCount,
      teacherNames: json['teacherNames'] != null
          ? List<String>.from(json['teacherNames'] as List)
          : null,
      color: json['color'] as String?,
      children: childrenList,
    );
  }
}
