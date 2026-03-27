import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/enums/enums.dart';
import '../domain/family_management_models.dart';

class FamiliesRepository {
  FamiliesRepository({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  Future<List<ManagedParentUser>> getParents() async {
    final response = await _api.get<List<dynamic>>(Endpoints.users);

    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .where((json) {
          final tenants = json['userTenants'] as List<dynamic>? ?? const [];
          final role = tenants.isNotEmpty
              ? (tenants.first as Map<String, dynamic>)['role'] as String?
              : null;
          return role == UserRole.parent.value;
        })
        .map(ManagedParentUser.fromJson)
        .toList()
      ..sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
  }

  Future<List<ParentChildOption>> getChildren() async {
    final response = await _api.get<dynamic>(Endpoints.children);
    final items = response is Map<String, dynamic>
        ? (response['data'] as List<dynamic>? ?? const [])
        : (response as List<dynamic>? ?? const []);

    return items
        .map(
          (item) => ParentChildOption.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
  }

  Future<ManagedParentUser> createParent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      Endpoints.users,
      data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone?.trim().isEmpty == true ? null : phone?.trim(),
        'role': UserRole.parent.value,
      },
    );

    return ManagedParentUser.fromJson(response);
  }

  Future<void> assignParentToChild({
    required String childId,
    required String userId,
    required String relationship,
    bool isPrimary = false,
    bool canPickup = true,
  }) async {
    await _api.post<dynamic>(
      Endpoints.childParents(childId),
      data: {
        'userId': userId,
        'relationship': relationship,
        'isPrimary': isPrimary,
        'canPickup': canPickup,
      },
    );
  }
}
