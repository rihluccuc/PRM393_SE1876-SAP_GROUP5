/// Model User - Đại diện cho người dùng (khách hàng / admin)
class User {
  final int? id;          // ID tự tăng (null khi tạo mới)
  final String name;      // Tên người dùng
  final String email;     // Email (duy nhất)
  final String password;  // Mật khẩu
  final String role;      // Vai trò: 'user' hoặc 'admin'
  final String? city;     // Thành phố (tùy chọn)
  final String? district; // Quận/huyện (tùy chọn)
  final String? phone;    // Số điện thoại (tùy chọn)

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

  /// Chuyển từ Map (SQLite) sang User object
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

  /// Chuyển từ User object sang Map (SQLite)
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
