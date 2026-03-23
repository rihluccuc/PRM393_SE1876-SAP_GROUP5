class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? city;
  final String? district;
  final String? phone;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.city,
    this.district,
    this.phone,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      city: map['city'],
      district: map['district'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'city': city,
      'district': district,
      'phone': phone,
    };
  }
}