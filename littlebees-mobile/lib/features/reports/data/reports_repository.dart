import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class ReportsRepository {
  ReportsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getReportsSummary() async {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final monthStart = _dateOnly(DateTime(now.year, now.month, 1));

    final attendance = await _apiClient.get<Map<String, dynamic>>(
      '${Endpoints.reports}/attendance',
      queryParameters: {
        'from': today,
        'to': today,
      },
    );
    final activities = await _apiClient.get<Map<String, dynamic>>(
      '${Endpoints.reports}/activities',
      queryParameters: {
        'from': today,
        'to': today,
      },
    );
    final payments = await _apiClient.get<Map<String, dynamic>>(
      '${Endpoints.reports}/payments',
      queryParameters: {
        'from': monthStart,
        'to': today,
      },
    );

    return {
      'attendance': attendance,
      'activities': activities,
      'payments': payments,
    };
  }

  String _dateOnly(DateTime date) => date.toIso8601String().split('T')[0];
}
