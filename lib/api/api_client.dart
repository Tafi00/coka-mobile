import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://api.coka.ai'; // Thay đổi URL API của bạn
  static const storage = FlutterSecureStorage();

  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _requestInterceptor,
        onError: _errorInterceptor,
        onResponse: (response, handler) {
          print(
              'API Response - ${response.requestOptions.path}: ${response.statusCode}');
          print('Response data: ${response.data}');
          handler.next(response);
        },
      ),
    );
  }

  Future<void> _requestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('API Request - ${options.path}');
    print('Query params: ${options.queryParameters}');
    print('Headers: ${options.headers}');

    // Lấy token từ secure storage
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      print('Using token: ${token.substring(0, 10)}...');
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('No token found');
    }
    return handler.next(options);
  }

  Future<void> _errorInterceptor(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print(
        'API Error - ${err.requestOptions.path}: ${err.response?.statusCode}');
    print('Error message: ${err.message}');
    print('Error response: ${err.response?.data}');

    if (err.response?.statusCode == 401) {
      print('Attempting to refresh token...');
      // Token hết hạn, thực hiện refresh token
      try {
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          print('Found refresh token, attempting to refresh...');
          final response = await dio.post(
            '/api/v1/account/refreshtoken',
            data: {'refreshToken': refreshToken},
          );

          if (response.data != null &&
              response.data['content']['accessToken'] != null) {
            final newToken = response.data['content']['accessToken'];
            final newRefreshToken = response.data['content']['refreshToken'];
            await storage.write(key: 'access_token', value: newToken);
            await storage.write(key: 'refresh_token', value: newRefreshToken);
            print('Token refresh successful');

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final cloneReq = await dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );

            return handler.resolve(cloneReq);
          }
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // Xử lý lỗi refresh token
        await storage.deleteAll();
        // TODO: Chuyển về trang login
      }
    }
    return handler.next(err);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: headers != null ? Options(headers: headers) : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }
}
