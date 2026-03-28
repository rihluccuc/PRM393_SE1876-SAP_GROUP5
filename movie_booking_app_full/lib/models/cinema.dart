/// Model Cinema - Đại diện cho một rạp chiếu phim
class Cinema {
  final int? id;            // ID rạp
  final String name;        // Tên rạp
  final String address;     // Địa chỉ
  final String? phone;      // Số điện thoại
  final int totalHalls;     // Tổng số phòng chiếu
  final String? createdAt;  // Ngày tạo

  // 👉 UI fields (không lưu DB, chỉ dùng hiển thị)
  final double? distance;        // Khoảng cách (km)
  final List<String>? showtimes; // Giờ chiếu hiện có

  const Cinema({
    this.id,
    required this.name,
    required this.address,
    this.phone,
    this.totalHalls = 1,
    this.createdAt,
    this.distance,
    this.showtimes,
  });

  /// Chuyển từ Map sang Cinema
  factory Cinema.fromMap(Map<String, dynamic> map) {
    return Cinema(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String?,
      totalHalls: map['total_halls'] as int? ?? 1,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Chuyển từ Cinema sang Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'total_halls': totalHalls,
    };
  }

  /// Tạo bản sao Cinema
  Cinema copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    int? totalHalls,
    double? distance,
    List<String>? showtimes,
  }) {
    return Cinema(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      totalHalls: totalHalls ?? this.totalHalls,
      createdAt: createdAt,
      distance: distance ?? this.distance,
      showtimes: showtimes ?? this.showtimes,
    );
  }
}
