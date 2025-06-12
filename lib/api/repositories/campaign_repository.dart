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
} 