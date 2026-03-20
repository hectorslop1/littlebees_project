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
  });

  String get displayName => friendlyName ?? name;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
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
      currentCapacity:
          json['_count']?['children'] as int? ??
          json['currentCapacity'] as int? ??
          0,
      teacherNames: json['teacherNames'] != null
          ? List<String>.from(json['teacherNames'] as List)
          : null,
    );
  }
}
