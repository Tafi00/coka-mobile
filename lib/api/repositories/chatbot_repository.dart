import '../api_client.dart';
import 'package:dio/dio.dart';

class ChatbotRepository {
  final ApiClient _apiClient;

  ChatbotRepository(this._apiClient);

  /// Lấy danh sách chatbot
  Future<Map<String, dynamic>> getChatbotList(String organizationId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/omni/chatbot/getlistpaging',
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi lấy danh sách chatbot: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết chatbot
  Future<Map<String, dynamic>> getChatbotDetail(String organizationId, String chatbotId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/omni/chatbot/get/$chatbotId',
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi lấy chi tiết chatbot: $e');
      rethrow;
    }
  }

  /// Tạo chatbot mới
  Future<Map<String, dynamic>> createChatbot(String organizationId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/omni/chatbot/create',
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi tạo chatbot: $e');
      rethrow;
    }
  }

  /// Cập nhật chatbot
  Future<Map<String, dynamic>> updateChatbot(String organizationId, String chatbotId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/v1/omni/chatbot/update/$chatbotId',
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi cập nhật chatbot: $e');
      rethrow;
    }
  }

  /// Cập nhật trạng thái chatbot
  Future<Map<String, dynamic>> updateChatbotStatus(String organizationId, String chatbotId, int status) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/v1/omni/chatbot/updatestatus/$chatbotId',
        data: {'status': status},
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái chatbot: $e');
      rethrow;
    }
  }

  /// Cập nhật trạng thái hội thoại chatbot
  Future<Map<String, dynamic>> updateChatbotConversationStatus(
    String organizationId, 
    String conversationId, 
    int status
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/v1/omni/conversation/updatechatbotstatus/$conversationId?Status=$status',
        options: Options(
          headers: {
            'accept': '*/*',
            'organizationId': organizationId,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái hội thoại chatbot: $e');
      rethrow;
    }
  }
} 