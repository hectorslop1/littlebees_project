import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/attendance_model.dart';
import '../enums/enums.dart';

class AttendanceRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<AttendanceRecord>> getAttendance({
    required String childId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.attendance,
        queryParameters: {'childId': childId, 'date': dateStr},
      );

      final items = (response['data'] as List? ?? []);
      return items.map((json) => _parseAttendance(json)).toList();
    } catch (e) {
      throw Exception('Error loading attendance: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceForChildren({
    required List<String> childIds,
    required DateTime date,
  }) async {
    try {
      final allRecords = <AttendanceRecord>[];

      for (final childId in childIds) {
        final records = await getAttendance(childId: childId, date: date);
        allRecords.addAll(records);
      }

      return allRecords;
    } catch (e) {
      throw Exception('Error loading attendance: $e');
    }
  }

  AttendanceRecord _parseAttendance(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInAt: json['checkInAt'] != null
          ? DateTime.parse(json['checkInAt'] as String)
          : null,
      checkOutAt: json['checkOutAt'] != null
          ? DateTime.parse(json['checkOutAt'] as String)
          : null,
      checkInBy: json['checkInBy'] as String?,
      checkOutBy: json['checkOutBy'] as String?,
      checkInMethod: json['checkInMethod'] as String?,
      status: AttendanceStatus.fromString(json['status'] as String),
      observations: json['observations'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
