import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/models/daily_log_model.dart';
import '../../../shared/enums/enums.dart';

class RegisterActivityRepository {
  final ApiClient _api = ApiClient.instance;

  /// Registro rápido de actividad
  Future<DailyLogEntry> quickRegister({
    required String childId,
    required String type,
    required String title,
    String? description,
    String? date,
    String? time,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.dailyLogsQuickRegister,
        data: {
          'childId': childId,
          'type': type,
          ...?date != null ? {'date': date} : null,
          ...?time != null ? {'time': time} : null,
          'metadata': {
            'title': title,
            'description': description,
            ...?metadata,
          },
        },
      );

      return _parseDailyLog(
        Map<String, dynamic>.from(
          response['dailyLogEntry'] as Map<String, dynamic>? ?? response,
        ),
      );
    } catch (e) {
      throw Exception('Error al registrar actividad: $e');
    }
  }

  /// Registrar entrada con foto
  Future<Map<String, dynamic>> registerCheckIn({
    required String childId,
    String? photoUrl,
    String? mood,
    String? notes,
  }) async {
    try {
      final metadata = <String, dynamic>{};
      if (photoUrl != null) metadata['photoUrl'] = photoUrl;
      if (mood != null) metadata['mood'] = mood;
      if (notes != null) metadata['notes'] = notes;

      final logEntry = await quickRegister(
        childId: childId,
        type: 'check_in',
        title: 'Entrada registrada',
        description: notes,
        date: _todayIso(),
        time: _currentTime(),
        metadata: metadata,
      );
      return {'logEntry': logEntry};
    } catch (e) {
      throw Exception('Error al registrar entrada: $e');
    }
  }

  /// Registrar salida con foto
  Future<Map<String, dynamic>> registerCheckOut({
    required String childId,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      final metadata = <String, dynamic>{};
      if (photoUrl != null) metadata['photoUrl'] = photoUrl;
      if (notes != null) metadata['notes'] = notes;

      final logEntry = await quickRegister(
        childId: childId,
        type: 'check_out',
        title: 'Salida registrada',
        description: notes,
        date: _todayIso(),
        time: _currentTime(),
        metadata: metadata,
      );
      return {'logEntry': logEntry};
    } catch (e) {
      throw Exception('Error al registrar salida: $e');
    }
  }

  /// Registrar comida
  Future<DailyLogEntry> registerMeal({
    required String childId,
    required String foodEaten,
    String? notes,
  }) async {
    return quickRegister(
      childId: childId,
      type: 'meal',
      title: 'Comida registrada',
      description: notes,
      date: _todayIso(),
      time: _currentTime(),
      metadata: {'foodEaten': foodEaten},
    );
  }

  /// Registrar siesta
  Future<DailyLogEntry> registerNap({
    required String childId,
    required int durationMinutes,
    String? notes,
  }) async {
    return quickRegister(
      childId: childId,
      type: 'nap',
      title: 'Siesta registrada',
      description: notes,
      date: _todayIso(),
      time: _currentTime(),
      metadata: {'napDuration': durationMinutes},
    );
  }

  /// Registrar actividad general
  Future<DailyLogEntry> registerActivity({
    required String childId,
    required String activityDescription,
    String? notes,
  }) async {
    return quickRegister(
      childId: childId,
      type: 'activity',
      title: activityDescription,
      description: notes,
      date: _todayIso(),
      time: _currentTime(),
      metadata: {'activityDescription': activityDescription},
    );
  }

  String _todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  DailyLogEntry _parseDailyLog(Map<String, dynamic> json) {
    return DailyLogEntry(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: _parseLogType(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      time: json['time'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      recordedBy: json['recordedBy'] as String?,
      recordedByName: json['recordedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  LogType _parseLogType(String type) {
    switch (type) {
      case 'meal':
        return LogType.meal;
      case 'nap':
        return LogType.nap;
      case 'activity':
        return LogType.activity;
      case 'diaper':
        return LogType.diaper;
      case 'medication':
        return LogType.medication;
      case 'observation':
        return LogType.observation;
      case 'incident':
        return LogType.incident;
      default:
        return LogType.observation;
    }
  }
}
