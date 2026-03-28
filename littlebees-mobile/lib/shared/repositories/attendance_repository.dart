import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/attendance_model.dart';
import '../enums/enums.dart';

class AttendanceRepository {
  final ApiClient _api = ApiClient.instance;

  Future<void> checkIn({
    required String childId,
    String method = 'parent_app',
    DateTime? date,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        Endpoints.checkIn,
        data: {
          'childId': childId,
          'method': method,
          'date': _logicalDate(date ?? DateTime.now()),
        },
      );
    } catch (e) {
      throw Exception('Error confirming attendance: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendance({
    required String childId,
    required DateTime date,
  }) async {
    return getAttendanceByDate(date: date, childId: childId);
  }

  Future<List<AttendanceRecord>> getAttendanceByDate({
    required DateTime date,
    String? childId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.attendance,
        queryParameters: {
          'date': dateStr,
          ...?childId == null ? null : {'childId': childId},
        },
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
      final records = await Future.wait(
        childIds.map((childId) => getAttendance(childId: childId, date: date)),
      );
      return records.expand((entry) => entry).toList();
    } catch (e) {
      throw Exception('Error loading attendance: $e');
    }
  }

  Future<void> markAttendance({
    required String childId,
    required AttendanceStatus status,
    String? method,
    String? observations,
    DateTime? date,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        Endpoints.attendanceMark,
        data: {
          'childId': childId,
          'status': status.value,
          'date': _logicalDate(date ?? DateTime.now()),
          ...?method == null ? null : {'method': method},
          ...?observations == null ? null : {'observations': observations},
        },
      );
    } catch (e) {
      throw Exception('Error updating attendance: $e');
    }
  }

  String _logicalDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  AttendanceRecord _parseAttendance(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInAt: json['checkInAt'] != null
          ? DateTime.parse(json['checkInAt'] as String).toLocal()
          : null,
      checkOutAt: json['checkOutAt'] != null
          ? DateTime.parse(json['checkOutAt'] as String).toLocal()
          : null,
      checkInBy:
          json['checkInByName'] as String? ?? json['checkInBy'] as String?,
      checkOutBy:
          json['checkOutByName'] as String? ?? json['checkOutBy'] as String?,
      checkInMethod: json['checkInMethod'] as String?,
      status: AttendanceStatus.fromString(json['status'] as String),
      observations: json['observations'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}
