import '../api_client.dart';

class OrganizationRepository {
  final ApiClient _apiClient;

  OrganizationRepository(this._apiClient);

  Future<List<dynamic>> getOrganizations() async {
    final response = await _apiClient.dio.get('/organizations');
    return response.data;
  }

  Future<Map<String, dynamic>> getOrganizationDetail(String id) async {
    final response = await _apiClient.dio.get('/organizations/$id');
    return response.data;
  }
}
