import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://api.coka.ai'; // Thay đổi URL API của bạn
  static const storage = FlutterSecureStorage();
  
  // Cấu hình retry
  static const int maxRetries = 3; // Số lần thử lại tối đa
  static const int retryDelayMs = 1000; // Thời gian chờ giữa các lần thử (ms)
  
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
          handler.next(response);
        },
      ),
    );
    
    // Thêm retry interceptor
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: _retryInterceptor,
      ),
    );
  }

  Future<void> _requestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Thêm metadata cho việc retry
    options.extra['retryCount'] = 0;

    // Lấy token từ secure storage
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('No token found');
    }
    return handler.next(options);
  }

  // Interceptor xử lý retry khi gặp lỗi
  Future<void> _retryInterceptor(
    DioException err, 
    ErrorInterceptorHandler handler
  ) async {
    final options = err.requestOptions;
    
    // Lấy số lần đã thử lại
    final int retryCount = options.extra['retryCount'] ?? 0;
    
    // Các lỗi cần retry: timeout, không kết nối được, lỗi server 5xx
    final bool shouldRetry = _shouldRetry(err) && retryCount < maxRetries;
    
    if (shouldRetry) {
      print('Retrying request (${retryCount + 1}/$maxRetries): ${options.path}');
      
      // Tăng biến đếm retry
      options.extra['retryCount'] = retryCount + 1;
      
      // Delay trước khi thử lại, tăng thời gian chờ sau mỗi lần thử (exponential backoff)
      final delay = retryDelayMs * (retryCount + 1);
      await Future.delayed(Duration(milliseconds: delay));
      
      try {
        // Thực hiện lại request
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // Nếu vẫn lỗi, chuyển cho interceptor tiếp theo xử lý
        if (e is DioException) {
          return handler.next(e);
        } else {
          return handler.next(DioException(
            requestOptions: options,
            error: e,
          ));
        }
      }
    }
    
    // Không thử lại, chuyển lỗi cho interceptor tiếp theo
    return handler.next(err);
  }
  
  // Xác định các loại lỗi nên thử lại
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            err.response!.statusCode! >= 500 && 
            err.response!.statusCode! < 600);
  }

  Future<void> _errorInterceptor(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print(
        'API Error - ${err.requestOptions.path}: ${err.response?.statusCode}');
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
