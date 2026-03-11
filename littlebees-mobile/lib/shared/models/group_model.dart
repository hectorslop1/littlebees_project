import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String tenantId,
    required String name,
    required int ageRangeMin,
    required int ageRangeMax,
    required int capacity,
    required String color,
    required String academicYear,
    String? teacherId,
    String? teacherName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}
