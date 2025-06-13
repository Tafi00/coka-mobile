import 'package:dio/dio.dart';
import '../models/automation/reminder_config.dart';
import '../models/automation/eviction_rule.dart';

class AutomationService {
  final Dio _dio;
  
  // ⚠️ LƯU Ý: Domain API có thể thay đổi
  static const String _baseUrl = 'https://api.coka.ai'; // Production
  static const String _calendarUrl = 'https://calendar.coka.ai'; // Calendar API
  
  AutomationService(this._dio);
  
  // ==================== REMINDER CONFIG APIs ====================
  
  /// Lấy danh sách cấu hình nhắc hẹn theo organizationId
  Future<List<ReminderConfig>> getReminderConfigsByOrgId(String orgId) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.get(
      //   '$_calendarUrl/api/ReminderConfig/organization/$orgId',
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        ReminderConfig(
          id: '1',
          time: 30,
          stages: ['new', 'contacted'],
          hourFrame: [9, 18],
          sourceIds: [],
          utmSources: [],
          workspaceIds: [],
          notificationMessage: 'Nhắc nhở cập nhật trạng thái khách hàng',
          organizationId: orgId,
          isActive: true,
          repeat: 1,
          repeatTime: 30,
          createdAt: DateTime.now().toIso8601String(),
          report: [],
        ),
      ];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách reminder config: $e');
    }
  }
  
  /// Tạo cấu hình nhắc hẹn mới
  Future<ReminderConfig> createReminderConfig(
    String orgId,
    Map<String, dynamic> configData,
  ) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.post(
      //   '$_calendarUrl/api/ReminderConfig',
      //   data: configData,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock response for now
      await Future.delayed(const Duration(milliseconds: 500));
      return ReminderConfig(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: configData['time'] ?? 30,
        stages: List<String>.from(configData['stages'] ?? []),
        hourFrame: List<int>.from(configData['hourFrame'] ?? []),
        sourceIds: List<String>.from(configData['sourceIds'] ?? []),
        utmSources: List<String>.from(configData['utmSources'] ?? []),
        workspaceIds: List<String>.from(configData['workspaceIds'] ?? []),
        notificationMessage: configData['notificationMessage'] ?? '',
        organizationId: orgId,
        isActive: configData['isActive'] ?? true,
        repeat: configData['repeat'] ?? 1,
        repeatTime: configData['repeatTime'] ?? 30,
        createdAt: DateTime.now().toIso8601String(),
        report: [],
      );
    } catch (e) {
      throw Exception('Lỗi khi tạo reminder config: $e');
    }
  }
  
  /// Cập nhật cấu hình nhắc hẹn
  Future<ReminderConfig> updateReminderConfig(
    String orgId,
    String configId,
    Map<String, dynamic> configData,
  ) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.put(
      //   '$_calendarUrl/api/ReminderConfig/$configId',
      //   data: configData,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock response for now
      await Future.delayed(const Duration(milliseconds: 500));
      return ReminderConfig.fromJson(configData);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật reminder config: $e');
    }
  }
  
  /// Xóa cấu hình nhắc hẹn
  Future<void> deleteReminderConfig(String orgId, String configId) async {
    try {
      // TODO: Implement actual API call
      // await _dio.delete(
      //   '$_calendarUrl/api/ReminderConfig/$configId',
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock delay for now
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Lỗi khi xóa reminder config: $e');
    }
  }
  
  /// Toggle trạng thái cấu hình nhắc hẹn
  Future<void> toggleReminderConfigStatus(String orgId, String configId) async {
    try {
      // TODO: Implement actual API call
      // await _dio.patch(
      //   '$_calendarUrl/api/ReminderConfig/$configId/toggle',
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock delay for now
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Lỗi khi toggle reminder config status: $e');
    }
  }
  
  // ==================== EVICTION RULE APIs ====================
  
  /// Lấy danh sách quy tắc thu hồi
  Future<List<EvictionRule>> getEvictionRules(
    String orgId, {
    Map<String, dynamic>? params,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.get(
      //   '$_baseUrl/api/v1/automation/eviction/rule/getlistpaging',
      //   queryParameters: params,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        EvictionRule(
          id: '1',
          name: 'Thu hồi sau 24 giờ',
          description: 'Tự động thu hồi khách hàng sau 24 giờ không có phản hồi',
          status: 1,
          createDate: DateTime.now().toIso8601String(),
          condition: {
            'timeInHours': 24,
            'stages': ['new', 'contacted'],
          },
          action: {
            'type': 'recall',
            'assignTo': 'pool',
          },
        ),
      ];
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách eviction rule: $e');
    }
  }
  
  /// Tạo quy tắc thu hồi mới
  Future<EvictionRule> createEvictionRule(
    String orgId,
    Map<String, dynamic> ruleData,
  ) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.post(
      //   '$_baseUrl/api/v1/automation/eviction/rule/create',
      //   data: ruleData,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock response for now
      await Future.delayed(const Duration(milliseconds: 500));
      return EvictionRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: ruleData['name'] ?? '',
        description: ruleData['description'] ?? '',
        status: ruleData['status'] ?? 1,
        createDate: DateTime.now().toIso8601String(),
        condition: Map<String, dynamic>.from(ruleData['condition'] ?? {}),
        action: Map<String, dynamic>.from(ruleData['action'] ?? {}),
      );
    } catch (e) {
      throw Exception('Lỗi khi tạo eviction rule: $e');
    }
  }
  
  /// Cập nhật quy tắc thu hồi
  Future<EvictionRule> updateEvictionRule(
    String orgId,
    String ruleId,
    Map<String, dynamic> ruleData,
  ) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.patch(
      //   '$_baseUrl/api/v1/automation/eviction/rule/$ruleId/update',
      //   data: ruleData,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock response for now
      await Future.delayed(const Duration(milliseconds: 500));
      return EvictionRule.fromJson(ruleData);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật eviction rule: $e');
    }
  }
  
  /// Xóa quy tắc thu hồi
  Future<void> deleteEvictionRule(String orgId, String ruleId) async {
    try {
      // TODO: Implement actual API call
      // await _dio.delete(
      //   '$_baseUrl/api/v1/automation/eviction/rule/$ruleId/delete',
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock delay for now
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Lỗi khi xóa eviction rule: $e');
    }
  }
  
  /// Cập nhật trạng thái quy tắc thu hồi
  Future<void> updateEvictionRuleStatus(
    String orgId,
    String ruleId,
    int status,
  ) async {
    try {
      // TODO: Implement actual API call
      // await _dio.patch(
      //   '$_baseUrl/api/v1/automation/eviction/rule/$ruleId/updatestatus',
      //   data: {'status': status},
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock delay for now
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Lỗi khi cập nhật eviction rule status: $e');
    }
  }
  
  /// Lấy logs của quy tắc thu hồi
  Future<List<Map<String, dynamic>>> getEvictionLogs(
    String orgId,
    String ruleId, {
    Map<String, dynamic>? params,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await _dio.get(
      //   '$_baseUrl/api/v1/automation/eviction/rule/$ruleId/logs',
      //   queryParameters: params,
      //   options: Options(
      //     headers: {'organizationId': orgId},
      //   ),
      // );
      
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': '1',
          'customerId': 'cust_123',
          'action': 'recalled',
          'timestamp': DateTime.now().toIso8601String(),
          'details': 'Khách hàng đã được thu hồi sau 24 giờ không phản hồi',
        },
      ];
    } catch (e) {
      throw Exception('Lỗi khi lấy eviction logs: $e');
    }
  }
} 