import '../../../core/api/api_client.dart';
import '../domain/group_model.dart';

class GroupsRepository {
  final ApiClient _api = ApiClient.instance;

  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _api.get<dynamic>('/groups');

      List items;
      if (response is List) {
        items = response;
      } else if (response is Map<String, dynamic>) {
        items = response['data'] as List? ?? [];
      } else {
        items = [];
      }

      return items.map((json) => GroupModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading groups: $e');
    }
  }

  Future<GroupModel> getGroupById(String groupId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/groups/$groupId');
      return GroupModel.fromJson(response);
    } catch (e) {
      throw Exception('Error loading group: $e');
    }
  }
}
