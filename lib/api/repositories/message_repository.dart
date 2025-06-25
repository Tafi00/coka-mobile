import '../api_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
          'organizationid': organizationId,
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
          'organizationid': organizationId,
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
          'organizationid': organizationId,
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
          'organizationid': organizationId,
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
          'organizationid': organizationId,
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> sendFacebookMessage(
    String organizationId,
    String conversationId,
    String message, {
    String? messageId,
    List<Map<String, dynamic>>? attachments,
    File? attachment,
    String? attachmentName,
  }) async {
    final formData = FormData.fromMap({
      'conversationId': conversationId,
      'messageId': messageId ?? 'undefined',
      'message': message,
    });

    // Xử lý attachment theo format web
    if (attachment != null) {
      formData.files.add(MapEntry(
        'Attachment', // Viết hoa chữ A như web
        await MultipartFile.fromFile(
          attachment.path,
          filename: attachmentName ?? attachment.path.split('/').last,
        ),
      ));
    }

    final response = await _apiClient.dio.post(
      '$_baseUrl/social/message/sendmessage',
      data: formData,
      options: Options(
        headers: {
          'organizationid': organizationId,
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
          'organizationid': organizationId,
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
          'organizationid': organizationId,
        },
      ),
    );
    return response.data;
  }

  /// Gửi ảnh với text message - sử dụng endpoint sendmessage
  Future<Map<String, dynamic>> sendImageMessage(
    String organizationId,
    String conversationId,
    XFile imageFile, {
    String? textMessage,
  }) async {
    print('=== SENDING IMAGE ===');
    print('Image name: ${imageFile.name}');
    print('Image path: ${imageFile.path}');
    print('Text message: $textMessage');

    // Tạo FormData đúng format cho ảnh (như curl)
    final formData = FormData();
    formData.fields.add(MapEntry('conversationId', conversationId));
    formData.fields.add(MapEntry('messageId', 'undefined'));
    formData.fields.add(MapEntry('message', textMessage ?? ''));

    // Thêm file ảnh với field name "Attachment" như curl
    formData.files.add(MapEntry(
      'Attachment', // Đúng như curl request
      await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.name,
        contentType: DioMediaType('image', imageFile.path.split('.').last),
      ),
    ));

    print('FormData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
    print('FormData files: ${formData.files.map((e) => '${e.key}=${e.value.filename}').join(', ')}');

    try {
      // Sử dụng endpoint sendmessage như curl
      final response = await _apiClient.dio.post(
        '$_baseUrl/social/message/sendmessage',
        data: formData,
        options: Options(
          headers: {
            'organizationid': organizationId, // lowercase như curl
          },
        ),
      );
      
      print('=== IMAGE RESPONSE SUCCESS ===');
      print('Response: ${response.data}');
      
      // Check if response contains error even with 200 status
      if (response.data != null && response.data['code'] != null && response.data['code'] != 200) {
        final errorMessage = response.data['message'] ?? 'Có lỗi xảy ra';
        throw Exception(errorMessage);
      }
      
      return response.data;
      
    } catch (e) {
      print('=== IMAGE RESPONSE ERROR ===');
      print('Error: $e');
      
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        
        // Handle server error responses
        if (e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData is Map && responseData['message'] != null) {
            final serverMessage = responseData['message'];
            throw Exception(serverMessage);
          }
        }
        
        // Handle HTTP status codes
        switch (e.response?.statusCode) {
          case 400:
            throw Exception('Yêu cầu không hợp lệ');
          case 401:
            throw Exception('Phiên đăng nhập đã hết hạn');
          case 403:
            throw Exception('Không có quyền thực hiện');
          case 500:
            throw Exception('Lỗi server, vui lòng thử lại sau');
          default:
            throw Exception('Không thể gửi ảnh, vui lòng thử lại');
        }
      }
      
      // Re-throw other exceptions
      rethrow;
    }
  }

  /// Gửi file với text message  
  Future<Map<String, dynamic>> sendFileMessage(
    String organizationId,
    String conversationId,
    File file, {
    String? textMessage,
  }) async {
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    // Debug logging
    print('=== SENDING FILE ===');
    print('File name: $fileName');
    print('File extension: $fileExtension');
    print('File path: ${file.path}');
    print('File size: ${await file.length()} bytes');
    print('Text message: $textMessage');
    
    // Map file extensions to server-supported types
    String mimeType;
    String serverSupportedType;
    
    switch (fileExtension) {
      case 'pdf':
        mimeType = 'application/pdf';
        serverSupportedType = 'pdf';
        break;
      case 'doc':
        mimeType = 'application/msword';
        serverSupportedType = 'doc';
        break;
      case 'docx':
        // Map docx to doc for server compatibility
        mimeType = 'application/msword'; 
        serverSupportedType = 'doc';
        print('Converting docx to doc for server compatibility');
        break;
      case 'xls':
        // Map xls to csv for server compatibility
        mimeType = 'text/csv';
        serverSupportedType = 'csv';
        print('Converting xls to csv for server compatibility');
        break;
      case 'xlsx':
        // Map xlsx to csv for server compatibility
        mimeType = 'text/csv';
        serverSupportedType = 'csv';
        print('Converting xlsx to csv for server compatibility');
        break;
      default:
        throw Exception('File extension .$fileExtension not supported. Only support: pdf, doc, docx, xls, xlsx');
    }
    
    print('Original MIME type: ${_getOriginalMimeType(fileExtension)}');
    print('Server MIME type: $mimeType');
    print('Server supported type: $serverSupportedType');

    // Tạo FormData đúng format web
    final formData = FormData();
    formData.fields.add(MapEntry('conversationId', conversationId));
    formData.fields.add(MapEntry('messageId', 'undefined'));
    formData.fields.add(MapEntry('message', textMessage ?? ''));
    
    formData.files.add(MapEntry(
      'Attachment',
      await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: DioMediaType.parse(mimeType), // Use mapped MIME type
      ),
    ));

    print('FormData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
    print('FormData files: ${formData.files.map((e) => '${e.key}=${e.value.filename}').join(', ')}');

    try {
      final response = await _apiClient.dio.post(
        '$_baseUrl/social/message/sendmessage',
        data: formData,
        options: Options(
          headers: {
            'organizationid': organizationId,
          },
        ),
      );
      
      print('=== RESPONSE SUCCESS ===');
      print('Response: ${response.data}');
      
      // Check if response contains error even with 200 status
      if (response.data != null && response.data['code'] != null && response.data['code'] != 200) {
        final errorMessage = response.data['message'] ?? 'Có lỗi xảy ra';
        throw Exception(errorMessage);
      }
      
      return response.data;
      
    } catch (e) {
      print('=== RESPONSE ERROR ===');
      print('Error: $e');
      
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        
        // Handle server error responses
        if (e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData is Map && responseData['message'] != null) {
            final serverMessage = responseData['message'];
            throw Exception(serverMessage);
          }
        }
        
        // Handle HTTP status codes
        switch (e.response?.statusCode) {
          case 400:
            throw Exception('Yêu cầu không hợp lệ');
          case 401:
            throw Exception('Phiên đăng nhập đã hết hạn');
          case 403:
            throw Exception('Không có quyền thực hiện');
          case 500:
            throw Exception('Lỗi server, vui lòng thử lại sau');
          default:
            throw Exception('Không thể gửi file, vui lòng thử lại');
        }
      }
      
      // Re-throw other exceptions
      rethrow;
    }
  }
  
  // Helper method để get original MIME type
  String _getOriginalMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  /// Lấy danh sách nhân viên có thể assign
  Future<Map<String, dynamic>> getAssignableUsers(
    String organizationId,
    String workspaceId,
  ) async {
    final response = await _apiClient.dio.get(
      '$_baseUrl/organization/workspace/user/getlistpaging',
      queryParameters: {
        'workspaceId': workspaceId,
      },
      options: Options(
        headers: {
          'organizationid': organizationId,
        },
      ),
    );
    return response.data;
  }

  /// Lấy danh sách team
  Future<Map<String, dynamic>> getTeamList(
    String organizationId,
    String workspaceId,
    String searchText, {
    bool isTreeView = false,
  }) async {
    final queryParams = {
      'workspaceId': workspaceId,
      'searchText': searchText,
      'isTreeView': isTreeView,
      'offset': 0,
      'limit': 100,
    };

    final response = await _apiClient.dio.get(
      '$_baseUrl/organization/workspace/team/getlistpaging',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'organizationid': organizationId,
        },
      ),
    );
    return response.data;
  }
}
