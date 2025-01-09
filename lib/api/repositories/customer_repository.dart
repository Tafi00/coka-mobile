import '../api_client.dart';

class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository(this._apiClient);

  Future<List<dynamic>> getCustomers(
      String organizationId, String workspaceId) async {
    final response = await _apiClient.dio.get(
        '/organizations/$organizationId/workspaces/$workspaceId/customers');
    return response.data;
  }

  Future<Map<String, dynamic>> getCustomerDetail(
      String organizationId, String workspaceId, String customerId) async {
    final response = await _apiClient.dio.get(
        '/organizations/$organizationId/workspaces/$workspaceId/customers/$customerId');
    return response.data;
  }
}
