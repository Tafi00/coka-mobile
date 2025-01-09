class Organization {
  final String id;
  final String name;
  final String? description;

  Organization({
    required this.id,
    required this.name,
    this.description,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
