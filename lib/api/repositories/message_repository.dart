import '../api_client.dart';

class MessageRepository {
  final ApiClient _apiClient;

  MessageRepository(this._apiClient);

  Future<List<dynamic>> getMessages(String organizationId) async {
    final response =
        await _apiClient.dio.get('/organizations/$organizationId/messages');
    return response.data;
  }

  Future<Map<String, dynamic>> getMessageDetail(
      String organizationId, String messageId) async {
    final response = await _apiClient.dio
        .get('/organizations/$organizationId/messages/$messageId');
    return response.data;
  }
}
