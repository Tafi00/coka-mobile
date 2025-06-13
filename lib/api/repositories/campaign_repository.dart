import '../api_client.dart';
import 'package:dio/dio.dart';

class CampaignRepository {
  final ApiClient _apiClient;
  final String _baseUrl = '/api/v1/campaigns';

  CampaignRepository(this._apiClient);

  Future<Map<String, dynamic>> getCampaigns(
    String organizationId, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _apiClient.dio.get(
      _baseUrl,
      options: Options(headers: {'organizationId': organizationId}),
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCampaignDetail(
    String organizationId,
    String campaignId,
  ) async {
    final response = await _apiClient.dio.get(
      '$_baseUrl/$campaignId',
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createCampaign(
    String organizationId,
    Map<String, dynamic> campaignData,
  ) async {
    final response = await _apiClient.dio.post(
      _baseUrl,
      data: campaignData,
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateCampaign(
    String organizationId,
    String campaignId,
    Map<String, dynamic> campaignData,
  ) async {
    final response = await _apiClient.dio.put(
      '$_baseUrl/$campaignId',
      data: campaignData,
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteCampaign(
    String organizationId,
    String campaignId,
  ) async {
    final response = await _apiClient.dio.delete(
      '$_baseUrl/$campaignId',
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> assignUsersToCampaign(
    String organizationId,
    String campaignId,
    List<String> userIds,
  ) async {
    final response = await _apiClient.dio.post(
      '$_baseUrl/$campaignId/users',
      data: {'userIds': userIds},
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCampaignUsers(
    String organizationId,
    String campaignId,
  ) async {
    final response = await _apiClient.dio.get(
      '$_baseUrl/$campaignId/users',
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> removeUserFromCampaign(
    String organizationId,
    String campaignId,
    String userId,
  ) async {
    final response = await _apiClient.dio.delete(
      '$_baseUrl/$campaignId/users/$userId',
      options: Options(headers: {'organizationId': organizationId}),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCampaignsPaging(
    String organizationId, {
    int? page,
    int? size,
    String? search,
    Map<String, String>? additionalParams,
  }) async {
    Map<String, dynamic> queryParams = {};
    
    if (page != null) queryParams['page'] = page;
    if (size != null) queryParams['size'] = size;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (additionalParams != null) queryParams.addAll(additionalParams);

    final response = await _apiClient.dio.get(
      '/api/v1/campaign/getlistpaging',
      options: Options(
        headers: {
          'Accept-Language': 'vi-VN,vi;q=0.9,en-VN;q=0.8,en;q=0.7,fr-FR;q=0.6,fr;q=0.5,en-US;q=0.4',
          'Connection': 'keep-alive',
          'Content-Type': 'application/json',
          'accept': '*/*',
          'organizationId': organizationId,
        },
      ),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data;
  }
} 