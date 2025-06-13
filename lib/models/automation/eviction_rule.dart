class EvictionRule {
  final String id;
  final String name;
  final String description;
  final int status;
  final String createDate;
  final Map<String, dynamic> condition;
  final Map<String, dynamic> action;

  const EvictionRule({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createDate,
    required this.condition,
    required this.action,
  });

  factory EvictionRule.fromJson(Map<String, dynamic> json) {
    return EvictionRule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      createDate: json['createDate'] ?? '',
      condition: Map<String, dynamic>.from(json['condition'] ?? {}),
      action: Map<String, dynamic>.from(json['action'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createDate': createDate,
      'condition': condition,
      'action': action,
    };
  }

  EvictionRule copyWith({
    String? id,
    String? name,
    String? description,
    int? status,
    String? createDate,
    Map<String, dynamic>? condition,
    Map<String, dynamic>? action,
  }) {
    return EvictionRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createDate: createDate ?? this.createDate,
      condition: condition ?? this.condition,
      action: action ?? this.action,
    );
  }
}

class EvictionRuleResponse {
  final int code;
  final String message;
  final List<EvictionRule> content;

  const EvictionRuleResponse({
    required this.code,
    required this.message,
    required this.content,
  });

  factory EvictionRuleResponse.fromJson(Map<String, dynamic> json) {
    return EvictionRuleResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => EvictionRule.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'content': content.map((rule) => rule.toJson()).toList(),
    };
  }
} 