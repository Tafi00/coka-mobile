import '../api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _apiClient.dio.post('/auth/logout');
    await ApiClient.storage.deleteAll();
  }
}
