import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../domain/child_profile_model.dart';

class ChildProfileRepository {
  final ApiClient _api = ApiClient.instance;

  Future<ChildProfileModel> getChildProfile(String childId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        Endpoints.childProfile(childId),
      );
      return ChildProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Error loading child profile: $e');
    }
  }

  Future<ChildProfileModel> updateProfile(
    String childId, {
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? gender,
    String? photoUrl,
  }) async {
    try {
      final response = await _api.patch<Map<String, dynamic>>(
        Endpoints.childProfile(childId),
        data: {
          'firstName':? firstName,
          'lastName':? lastName,
          'dateOfBirth':? dateOfBirth?.toIso8601String().split('T').first,
          'gender':? gender,
          'photoUrl':? photoUrl,
        },
      );

      return ChildProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating child profile: $e');
    }
  }

  Future<void> upsertMedicalInfo(
    String childId,
    ChildProfileMedicalInfo medicalInfo,
  ) async {
    try {
      await _api.post<dynamic>(
        Endpoints.childMedical(childId),
        data: medicalInfo.toJson(),
      );
    } catch (e) {
      throw Exception('Error updating medical info: $e');
    }
  }

  Future<ChildPickupContact> addPickupContact(
    String childId,
    ChildPickupContact contact,
  ) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        Endpoints.childContacts(childId),
        data: contact.toJson(),
      );
      return ChildPickupContact.fromJson(response);
    } catch (e) {
      throw Exception('Error adding pickup contact: $e');
    }
  }

  Future<ChildPickupContact> updatePickupContact(
    String childId,
    ChildPickupContact contact,
  ) async {
    final contactId = contact.id;
    if (contactId == null) {
      throw Exception('Contact id is required to update pickup contact');
    }

    try {
      final response = await _api.patch<Map<String, dynamic>>(
        Endpoints.childContact(childId, contactId),
        data: contact.toJson(),
      );
      return ChildPickupContact.fromJson(response);
    } catch (e) {
      throw Exception('Error updating pickup contact: $e');
    }
  }

  Future<void> deletePickupContact(String childId, String contactId) async {
    try {
      await _api.delete<dynamic>(Endpoints.childContact(childId, contactId));
    } catch (e) {
      throw Exception('Error deleting pickup contact: $e');
    }
  }
}
