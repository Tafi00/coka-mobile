class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
