// lib/models/cinema_model.dart
// =====================================================
// Model: Cinema - Thông tin rạp chiếu phim
// =====================================================

class Cinema {
  final int? id;
  final String name;        // Tên rạp
  final String address;     // Địa chỉ
  final String? phone;      // Số điện thoại
  final int totalHalls;     // Tổng số phòng
  final String? createdAt;

  const Cinema({
    this.id,
    required this.name,
    required this.address,
    this.phone,
    this.totalHalls = 1,
    this.createdAt,
  });

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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'total_halls': totalHalls,
    };
  }

  Cinema copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    int? totalHalls,
  }) {
    return Cinema(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      totalHalls: totalHalls ?? this.totalHalls,
      createdAt: createdAt,
    );
  }
}

// =====================================================
// Model: Hall - Phòng chiếu phim
// =====================================================

class Hall {
  final int? id;
  final int cinemaId;       // Thuộc rạp nào
  final String name;        // Tên phòng
  final int capacity;       // Sức chứa
  final String hallType;    // standard / vip / imax

  const Hall({
    this.id,
    required this.cinemaId,
    required this.name,
    this.capacity = 100,
    this.hallType = 'standard',
  });

  factory Hall.fromMap(Map<String, dynamic> map) {
    return Hall(
      id: map['id'] as int?,
      cinemaId: map['cinema_id'] as int,
      name: map['name'] as String,
      capacity: map['capacity'] as int? ?? 100,
      hallType: map['hall_type'] as String? ?? 'standard',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cinema_id': cinemaId,
      'name': name,
      'capacity': capacity,
      'hall_type': hallType,
    };
  }

  Hall copyWith({
    int? id,
    int? cinemaId,
    String? name,
    int? capacity,
    String? hallType,
  }) {
    return Hall(
      id: id ?? this.id,
      cinemaId: cinemaId ?? this.cinemaId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      hallType: hallType ?? this.hallType,
    );
  }
}

// =====================================================
// Model: Showtime - Lịch chiếu phim
// =====================================================

class Showtime {
  final int? id;
  final int movieId;          // Phim nào
  final int hallId;           // Phòng chiếu nào
  final String showDate;      // Ngày chiếu
  final String startTime;     // Giờ bắt đầu
  final String endTime;       // Giờ kết thúc
  final double ticketPrice;   // Giá vé
  final int? availableSeats;  // Ghế còn trống
  final String status;        // active / cancelled / full

  final String? createdAt;

  // Dữ liệu JOIN từ các bảng khác (không lưu vào DB)
  final String? movieTitle;   // Tên phim (JOIN từ movies)
  final String? movieImage;
  final String? hallName;     // Tên phòng (JOIN từ halls)

  const Showtime({
    this.id,
    required this.movieId,
    required this.hallId,
    required this.showDate,
    required this.startTime,
    required this.endTime,
    this.ticketPrice = 75000,
    this.availableSeats,
    this.status = 'active',
    this.createdAt,
    this.movieTitle,
    this.movieImage,
    this.hallName,
  });

  factory Showtime.fromMap(Map<String, dynamic> map) {
    return Showtime(
      id: map['id'] as int?,
      movieId: map['movie_id'] as int,
      hallId: map['hall_id'] as int,
      showDate: map['show_date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      ticketPrice: (map['ticket_price'] as num?)?.toDouble() ?? 75000,
      availableSeats: map['available_seats'] as int?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as String?,
      movieTitle: map['movie_title'] as String?,  // Từ JOIN query
      movieImage: map['movie_image'] as String?,
      hallName: map['hall_name'] as String?,      // Từ JOIN query
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'movie_id': movieId,
      'hall_id': hallId,
      'show_date': showDate,
      'start_time': startTime,
      'end_time': endTime,
      'ticket_price': ticketPrice,
      'available_seats': availableSeats,
      'status': status,
    };
  }

  Showtime copyWith({
    int? id,
    int? movieId,
    int? hallId,
    String? showDate,
    String? startTime,
    String? endTime,
    double? ticketPrice,
    int? availableSeats,
    String? status,
    String? movieTitle,
    String? movieImage,
    String? hallName,
  }) {
    return Showtime(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      hallId: hallId ?? this.hallId,
      showDate: showDate ?? this.showDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      createdAt: createdAt,
      movieTitle: movieTitle ?? this.movieTitle,
      movieImage: movieImage ?? this.movieImage,
      hallName: hallName ?? this.hallName,
    );
  }
}

// =====================================================
// Model: Statistics Summary - Thống kê tổng quan
// =====================================================

class StatsSummary {
  final int totalMovies;         // Tổng số phim
  final int totalShowtimes;      // Tổng số suất chiếu
  final int totalTicketsSold;    // Tổng vé đã bán
  final double totalRevenue;     // Tổng doanh thu
  final List<Map<String, dynamic>> topMovies;    // Top phim bán nhiều vé
  final List<Map<String, dynamic>> revenueByDate; // Doanh thu theo ngày

  const StatsSummary({
    this.totalMovies = 0,
    this.totalShowtimes = 0,
    this.totalTicketsSold = 0,
    this.totalRevenue = 0.0,
    this.topMovies = const [],
    this.revenueByDate = const [],
  });
}