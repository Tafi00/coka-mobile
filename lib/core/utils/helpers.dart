import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:coka/core/theme/app_colors.dart';
import '../constants/app_constants.dart';

class Helpers {
  static const String apiBaseUrl = 'https://api.coka.ai';

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  static String formatDate(DateTime date) {
    // Logic format date
    return '';
  }

  /// Chuyển đổi ngày từ định dạng dd/MM/yyyy sang ISO string
  static String convertToISOString(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final date = DateTime(
        int.parse(parts[2]), // năm
        int.parse(parts[1]), // tháng
        int.parse(parts[0]), // ngày
      );
      return date.toIso8601String();
    }
    return dateStr;
  }

  static String getAvatarUrl(String? imgData) {
    if (imgData == null || imgData.isEmpty) return '';
    if (imgData.contains('https')) return imgData;
    return '$apiBaseUrl$imgData';
  }

  /// Clear cache cho một URL cụ thể
  static Future<void> clearImageCache(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    final url = getAvatarUrl(imageUrl);
    await CachedNetworkImage.evictFromCache(url);
  }

  /// Clear toàn bộ image cache
  static Future<void> clearAllImageCache() async {
    await DefaultCacheManager().emptyCache();
  }

  static Color getColorFromText(String text) {
    final List<Color> colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFFE53935), // Red
      const Color(0xFF43A047), // Green
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFFFB300), // Amber
      const Color(0xFF00897B), // Teal
      const Color(0xFF3949AB), // Indigo
      const Color(0xFFD81B60), // Pink
      const Color(0xFF6D4C41), // Brown
      const Color(0xFF546E7A), // Blue Grey
    ];

    // Tính tổng mã ASCII của các ký tự trong text
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      sum += text.codeUnitAt(i);
    }

    // Lấy màu dựa trên phần dư của tổng với số lượng màu
    return colors[sum % colors.length];
  }

  static Color getTabBadgeColor(String tabName) {
    switch (tabName) {
      case "Tất cả":
        return const Color(0xFF5C33F0);
      case "Tiềm năng":
        return const Color(0xFF92F7A8);
      case "Giao dịch":
        return const Color(0xFFA4F3FF);
      case "Không tiềm năng":
        return const Color(0xFFFEC067);
      case "Chưa xác định":
        return const Color(0xFF9F87FF);
      default:
        return const Color(0xFF9F87FF);
    }
  }

  static String? getStageGroupName(String stageId) {
    for (var entry in AppConstants.stageObject.entries) {
      final stages = entry.value['data'] as List;
      if (stages.any((stage) => stage['id'] == stageId)) {
        return entry.value['name'] as String;
      }
    }
    return null;
  }
}

extension DioExceptionExt on DioException {
  String get errorMessage {
    final response = this.response?.data;
    if (response != null && response['message'] != null) {
      return response['message'];
    }
    return 'Có lỗi xảy ra, vui lòng thử lại';
  }
}

extension MapExtension on Map<String, dynamic> {
  Map<String, String> toQueryParameters() {
    final Map<String, String> result = {};

    void convert(String key, dynamic value) {
      if (value == null) return;

      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          result['$key[$i]'] = value[i].toString();
        }
      } else {
        result[key] = value.toString();
      }
    }

    forEach((key, value) => convert(key, value));
    return result;
  }
}
