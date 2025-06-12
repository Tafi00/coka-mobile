class Campaign {
  final String id;
  final String name;
  final String description;
  final String organizationId;
  final String status;
  final String? createdBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.organizationId,
    required this.status,
    this.createdBy,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      organizationId: json['organizationId'] ?? '',
      status: json['status'] ?? 'DRAFT',
      createdBy: json['createdBy'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organizationId': organizationId,
      'status': status,
      'createdBy': createdBy,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 