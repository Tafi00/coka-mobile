import '../api_client.dart';
import 'package:dio/dio.dart';

class MessageRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/v1';

  MessageRepository(this._apiClient);

  Future<Map<String, dynamic>> connectFacebook(
      String organizationId, dynamic data) async {
    final response = await _apiClient.dio.post(
      '$_baseUrl/auth/facebook/message',
      data: data,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getConversationList(
    String organizationId, {
    required int page,
    String? provider,
  }) async {
    final queryParams = {
      'offset': page * 20,
      'limit': 20,
      'provider': provider,
      'sort': '[{ "Column": "CreatedDate", "Dir": "DESC" }]',
    };

    final response = await _apiClient.dio.get(
      '$_baseUrl/omni/conversation/getlistpaging',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getChatList(
    String organizationId,
    String conversationId,
    int page,
  ) async {
    final queryParams = {
      'ConversationId': conversationId,
      'offset': page * 20,
      'limit': 20,
    };

    final response = await _apiClient.dio.get(
      '$_baseUrl/social/message/getlistpaging',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSubscriptions(
    String organizationId, {
    required bool subscribed,
    String? provider,
  }) async {
    final queryParams = {
      'offset': 0,
      'limit': 1000,
      'subscribed': subscribed,
      'provider': provider,
    };

    final response = await _apiClient.dio.get(
      '$_baseUrl/integration/omnichannel/getlistpaging',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateSubscription(
    String organizationId,
    String subscribedId,
    dynamic body,
  ) async {
    final response = await _apiClient.dio.patch(
      '$_baseUrl/integration/omnichannel/updatestatus/$subscribedId',
      data: body,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> sendFacebookMessage(
    String organizationId,
    dynamic body,
  ) async {
    final response = await _apiClient.dio.post(
      '$_baseUrl/social/message/sendmessage',
      data: body,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> assignConversation(
    String organizationId,
    String conversationId,
    String userId,
  ) async {
    final response = await _apiClient.dio.patch(
      '$_baseUrl/omni/conversation/$conversationId/assignto',
      data: {
        'assignTo': userId,
      },
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> convertToLead(
    String organizationId,
    String conversationId,
    dynamic body,
  ) async {
    final response = await _apiClient.dio.post(
      '$_baseUrl/omni/conversation/$conversationId/converttolead',
      data: body,
      options: Options(
        headers: {
          'organizationId': organizationId,
        },
      ),
    );
    return response.data;
  }
}
