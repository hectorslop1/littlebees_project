import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/models/excuse_model.dart';
import '../../../shared/enums/enums.dart';

class ExcusesRepository {
  final ApiClient _api = ApiClient.instance;

  /// Crear un nuevo justificante (solo padres)
  Future<Excuse> createExcuse({
    required String childId,
    required ExcuseType type,
    required String title,
    String? description,
    required DateTime date,
    List<String>? attachments,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.excuses,
        data: {
          'childId': childId,
          'type': type.value,
          'title': title,
          'description': description,
          'date': date.toIso8601String().split('T')[0],
          'attachments': attachments ?? [],
        },
      );

      return Excuse.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear justificante: $e');
    }
  }

  /// Listar justificantes (filtrado por rol)
  Future<List<Excuse>> getExcuses({
    String? childId,
    ExcuseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (childId != null) queryParams['childId'] = childId;
      if (status != null) queryParams['status'] = status.value;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _api.get<dynamic>(
        Endpoints.excuses,
        queryParameters: queryParams,
      );

      // Handle various response formats gracefully
      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        return [];
      }

      return items
          .map((json) => Excuse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener justificantes: $e');
    }
  }

  /// Obtener justificantes de un niño específico
  Future<List<Excuse>> getExcusesByChild(String childId) async {
    try {
      final response = await _api.get<List<dynamic>>(
        Endpoints.excusesByChild(childId),
      );

      return response
          .map((json) => Excuse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener justificantes del niño: $e');
    }
  }

  /// Obtener detalle de un justificante
  Future<Excuse> getExcuseById(String id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.excuse(id),
      );

      return Excuse.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener justificante: $e');
    }
  }

  /// Actualizar estado de un justificante (aprobar/rechazar) - solo maestras
  Future<Excuse> updateExcuseStatus({
    required String id,
    required ExcuseStatus status,
    String? reviewNotes,
  }) async {
    try {
      final response = await _api.patch<Map<String, dynamic>>(
        Endpoints.updateExcuseStatus(id),
        data: {'status': status.value, 'reviewNotes': reviewNotes},
      );

      return Excuse.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  /// Eliminar un justificante (solo si está pendiente)
  Future<void> deleteExcuse(String id) async {
    try {
      await _api.delete(Endpoints.excuse(id));
    } catch (e) {
      throw Exception('Error al eliminar justificante: $e');
    }
  }
}
