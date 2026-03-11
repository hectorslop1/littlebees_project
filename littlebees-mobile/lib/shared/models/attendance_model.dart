import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/enums.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required String id,
    required String tenantId,
    required String childId,
    required DateTime date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    String? checkInBy,
    String? checkOutBy,
    String? checkInMethod,
    required AttendanceStatus status,
    String? observations,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}
