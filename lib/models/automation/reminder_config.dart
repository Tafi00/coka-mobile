class ReminderConfig {
  final String id;
  final int time;
  final List<String> stages;
  final List<int> hourFrame;
  final List<String> sourceIds;
  final List<String> utmSources;
  final List<String> workspaceIds;
  final String notificationMessage;
  final String organizationId;
  final bool isActive;
  final int repeat;
  final int repeatTime;
  final String createdAt;
  final List<Map<String, dynamic>> report;

  const ReminderConfig({
    required this.id,
    required this.time,
    required this.stages,
    required this.hourFrame,
    required this.sourceIds,
    required this.utmSources,
    required this.workspaceIds,
    required this.notificationMessage,
    required this.organizationId,
    required this.isActive,
    required this.repeat,
    required this.repeatTime,
    required this.createdAt,
    required this.report,
  });

  factory ReminderConfig.fromJson(Map<String, dynamic> json) {
    return ReminderConfig(
      id: json['id'] ?? '',
      time: json['Time'] ?? 0,
      stages: List<String>.from(json['Stages'] ?? []),
      hourFrame: List<int>.from(json['HourFrame'] ?? []),
      sourceIds: List<String>.from(json['SourceIds'] ?? []),
      utmSources: List<String>.from(json['UtmSources'] ?? []),
      workspaceIds: List<String>.from(json['WorkspaceIds'] ?? []),
      notificationMessage: json['NotificationMessage'] ?? '',
      organizationId: json['OrganizationId'] ?? '',
      isActive: json['IsActive'] ?? false,
      repeat: json['Repeat'] ?? 0,
      repeatTime: json['RepeatTime'] ?? 0,
      createdAt: json['CreatedAt'] ?? '',
      report: List<Map<String, dynamic>>.from(json['Report'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Time': time,
      'Stages': stages,
      'HourFrame': hourFrame,
      'SourceIds': sourceIds,
      'UtmSources': utmSources,
      'WorkspaceIds': workspaceIds,
      'NotificationMessage': notificationMessage,
      'OrganizationId': organizationId,
      'IsActive': isActive,
      'Repeat': repeat,
      'RepeatTime': repeatTime,
      'CreatedAt': createdAt,
      'Report': report,
    };
  }

  ReminderConfig copyWith({
    String? id,
    int? time,
    List<String>? stages,
    List<int>? hourFrame,
    List<String>? sourceIds,
    List<String>? utmSources,
    List<String>? workspaceIds,
    String? notificationMessage,
    String? organizationId,
    bool? isActive,
    int? repeat,
    int? repeatTime,
    String? createdAt,
    List<Map<String, dynamic>>? report,
  }) {
    return ReminderConfig(
      id: id ?? this.id,
      time: time ?? this.time,
      stages: stages ?? this.stages,
      hourFrame: hourFrame ?? this.hourFrame,
      sourceIds: sourceIds ?? this.sourceIds,
      utmSources: utmSources ?? this.utmSources,
      workspaceIds: workspaceIds ?? this.workspaceIds,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      organizationId: organizationId ?? this.organizationId,
      isActive: isActive ?? this.isActive,
      repeat: repeat ?? this.repeat,
      repeatTime: repeatTime ?? this.repeatTime,
      createdAt: createdAt ?? this.createdAt,
      report: report ?? this.report,
    );
  }
} 