import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/daily_log_model.dart';
import '../enums/enums.dart';

class DailyLogsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<DailyLogEntry>> getDailyLogs({
    required String childId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.dailyLogs,
        queryParameters: {'childId': childId, 'date': dateStr},
      );

      final items = (response['data'] as List? ?? []);
      return items.map((json) => _parseDailyLog(json)).toList();
    } catch (e) {
      throw Exception('Error loading daily logs: $e');
    }
  }

  Future<List<DailyLogEntry>> getDailyLogsForChildren({
    required List<String> childIds,
    required DateTime date,
  }) async {
    try {
      final allLogs = <DailyLogEntry>[];

      for (final childId in childIds) {
        final logs = await getDailyLogs(childId: childId, date: date);
        allLogs.addAll(logs);
      }

      return allLogs;
    } catch (e) {
      throw Exception('Error loading daily logs: $e');
    }
  }

  Future<List<DailyLogEntry>> getDailyLogsByDate({
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.dailyLogs,
        queryParameters: {'date': dateStr},
      );

      final items = (response['data'] as List? ?? []);
      return items
          .map((json) => _parseDailyLog(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw Exception('Error loading daily logs by date: $e');
    }
  }

  Future<DailyLogEntry> createDailyLog({
    required String childId,
    required LogType type,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.dailyLogs,
        data: {
          'childId': childId,
          'type': type.value,
          'title': title,
          'description': description,
          'metadata': metadata,
          'date': DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return _parseDailyLog(response);
    } catch (e) {
      throw Exception('Error creating daily log: $e');
    }
  }

  DailyLogEntry _parseDailyLog(Map<String, dynamic> json) {
    return DailyLogEntry(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: LogType.fromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      time: json['time'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      recordedBy: json['recordedBy'] as String?,
      recordedByName: json['recordedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}
