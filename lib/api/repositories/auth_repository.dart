import '../api_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _googleSignIn = GoogleSignIn();

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String userName) async {
    final response = await _apiClient.dio.post(
      '/api/v1/auth/login',
      data: {
        'userName': userName,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> loginWithGoogle(
      {bool forceNewAccount = false}) async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      forceCodeForRefreshToken: true,
    );

    if (forceNewAccount) {
      await googleSignIn.signOut();
    }

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Đăng nhập Google bị hủy');

      try {
        final googleAuth = await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        if (accessToken == null) throw Exception('Không thể lấy token Google');

        return await socialLogin(accessToken, 'google');
      } catch (authError) {
        throw Exception('Lỗi xác thực Google: ${authError.toString()}');
      }
    } catch (e) {
      print('Chi tiết lỗi Google Sign-In: $e');
      throw Exception('Lỗi đăng nhập Google: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> socialLogin(
      String accessToken, String provider) async {
    final response = await _apiClient.dio.post(
      '/api/v1/auth/social/login',
      data: {
        'accessToken': accessToken,
        'provider': provider,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String otpId, String code) async {
    final response = await _apiClient.dio.post(
      '/api/v1/otp/verify',
      data: {
        'otpId': otpId,
        'code': code,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resendOtp(String otpId) async {
    final response = await _apiClient.dio.post(
      '/api/v1/otp/resend',
      data: {
        'otpId': otpId,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await ApiClient.storage.read(key: 'refresh_token');
    final response = await _apiClient.dio.post(
      '/api/v1/account/refreshtoken',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.dio.get('/api/v1/user/profile/getdetail');
    return response.data;
  }

  Future<void> logout() async {
    await ApiClient.storage.deleteAll();
  }

  Future<Map<String, dynamic>> loginWithFacebook() async {
    try {
      final LoginResult result =
          await FacebookAuth.instance.login(permissions: ['pages_show_list']);

      if (result.status == LoginStatus.success) {
        final String? accessToken = result.accessToken?.tokenString;
        if (accessToken == null) {
          throw Exception('Không thể lấy token Facebook');
        }

        return await socialLogin(accessToken, 'facebook');
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Đăng nhập Facebook bị hủy');
      } else {
        throw Exception('Đăng nhập Facebook thất bại');
      }
    } catch (e) {
      print('Chi tiết lỗi Facebook Sign-In: $e');
      throw Exception('Lỗi đăng nhập Facebook: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _apiClient.get('/api/v1/user/profile/getdetail');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data,
      {File? avatar}) async {
    try {
      final formData = FormData();

      // Thêm các thông tin cơ bản vào formData
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Thêm avatar nếu có
      if (avatar != null) {
        String fileName = avatar.path.split('/').last;
        String mimeType = fileName.endsWith('.png')
            ? 'image/png'
            : fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')
                ? 'image/jpeg'
                : 'image/jpg';

        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            avatar.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        ));
      }

      final response = await _apiClient.patch(
        '/api/v1/user/profile/update',
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
