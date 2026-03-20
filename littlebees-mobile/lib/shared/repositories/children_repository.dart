import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../models/child_model.dart';
import '../models/auth_models.dart';

class ChildrenRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<Child>> getMyChildren({required UserInfo user}) async {
    try {
      final response = await _api.get<dynamic>(Endpoints.children);

      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) => _parseChild(json)).toList();
    } catch (e) {
      throw Exception('Error loading children: $e');
    }
  }

  Future<Child> getChildById(String childId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.child(childId),
      );
      return _parseChild(response);
    } catch (e) {
      throw Exception('Error loading child: $e');
    }
  }

  Child _parseChild(Map<String, dynamic> json) {
    // Extract group name from nested group object if present
    String? groupName;
    if (json['group'] != null && json['group'] is Map) {
      groupName = json['group']['name'] as String?;
    } else {
      groupName = json['groupName'] as String?;
    }

    return Child(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String? ?? '',
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String? ?? 'male',
      photoUrl: json['photoUrl'] as String?,
      groupId: json['groupId'] as String?,
      groupName: groupName,
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      qrCodeHash: json['qrCodeHash'] as String?,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      conditions: json['conditions'] != null
          ? List<String>.from(json['conditions'] as List)
          : null,
      medications: json['medications'] != null
          ? List<String>.from(json['medications'] as List)
          : null,
      bloodType: json['bloodType'] as String?,
      authorizedPickups: null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
