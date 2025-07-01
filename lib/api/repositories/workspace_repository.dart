import '../api_client.dart';
import 'package:dio/dio.dart';

class WorkspaceRepository {
  final ApiClient _apiClient;

  WorkspaceRepository(this._apiClient);

  Future<Map<String, dynamic>> getWorkspaces(
    String organizationId, {
    int limit = 1000,
    int offset = 0,
  }) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
      'sort': '[{ "Column": "CreatedDate", "Dir": "DESC" }]'
    };

    final response = await _apiClient.dio.get(
      '/api/v1/organization/workspace/getlistpaging',
      queryParameters: queryParams,
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getWorkspaceDetail(
    String organizationId,
    String workspaceId,
  ) async {
    final response = await _apiClient.dio.get(
      '/api/v1/organization/workspace/getdetail/$workspaceId',
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createWorkspace({
    required String organizationId,
    required String name,
    required String scope, // '0' cho riêng tư, '1' cho công khai
  }) async {
    final formData = FormData.fromMap({
      'Name': name,
      'Scope': scope,
    });

    final response = await _apiClient.dio.post(
      '/api/v1/organization/workspace/create',
      data: formData,
      options: Options(headers: {
        'organizationId': organizationId,
        'accept': '*/*',
      }),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateWorkspace({
    required String organizationId,
    required String workspaceId,
    required String name,
    required String scope, // '0' cho riêng tư, '1' cho công khai
  }) async {
    final formData = FormData.fromMap({
      'Name': name,
      'Scope': scope,
    });

    final response = await _apiClient.dio.put(
      '/api/v1/organization/workspace/update/$workspaceId',
      data: formData,
      options: Options(headers: {
        'organizationId': organizationId,
        'accept': '*/*',
      }),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSourceList(
    String organizationId,
    String workspaceId, {
    int limit = 1000,
    int offset = 0,
  }) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
    };

    final response = await _apiClient.dio.get(
      '/api/v1/crm/category/source/getlistpaging',
      queryParameters: queryParams,
      options: Options(headers: {
        'organizationId': organizationId,
        'workspaceId': workspaceId,
      }),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getTagList(
    String organizationId,
    String workspaceId, {
    int limit = 1000,
    int offset = 0,
  }) async {
    final queryParams = {
      'limit': limit,
      'offset': offset,
    };

    final response = await _apiClient.dio.get(
      '/api/v1/crm/category/tags/getlistpaging',
      queryParameters: queryParams,
      options: Options(headers: {
        'organizationId': organizationId,
        'workspaceId': workspaceId,
      }),
    );
    return response.data;
  }
}
