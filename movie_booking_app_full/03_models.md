# 📦 Models - Các Lớp Dữ Liệu

## Mô Tả
Models là các class đại diện cho dữ liệu trong app.
Mỗi model có:
- **Fields**: các thuộc tính dữ liệu
- **fromMap()**: chuyển từ Map (SQLite) sang Object
- **toMap()**: chuyển từ Object sang Map (SQLite)
- **copyWith()**: tạo bản sao với một số field thay đổi

---

## File: `lib/models/user.dart`

```dart
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
```

---

## File: `lib/models/movie.dart`

```dart
/// Model Movie - Đại diện cho một bộ phim
class Movie {
  // ================= Các field lưu trong Database =================
  final int? id;            // ID phim
  final String title;       // Tên phim
  final String? description;// Mô tả
  final int duration;       // Thời lượng (phút)
  final String? genre;      // Thể loại
  final double rating;      // Điểm đánh giá (0.0 - 5.0)
  final String? imagePath;  // Đường dẫn ảnh poster
  final String? releaseDate;// Ngày phát hành
  final String status;      // Trạng thái: 'active' hoặc 'inactive'
  final String? createdAt;  // Ngày tạo

  // ================= Các field dùng cho UI (không lưu DB) =================
  final List<String>? showtimes;    // Danh sách giờ chiếu
  final String? cinemaName;         // Tên rạp (lấy từ JOIN)
  final String? hallName;           // Tên phòng chiếu
  final double? ticketPrice;        // Giá vé
  final bool? isFavorite;           // Đã yêu thích chưa
  final int? availableSeats;        // Số ghế trống

  const Movie({
    this.id,
    required this.title,
    this.description,
    required this.duration,
    this.genre,
    this.rating = 0.0,
    this.imagePath,
    this.releaseDate,
    this.status = 'active',
    this.createdAt,
    this.showtimes,
    this.cinemaName,
    this.hallName,
    this.ticketPrice,
    this.isFavorite,
    this.availableSeats,
  });

  /// Chuyển từ Map (SQLite / JSON) sang Movie object
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      duration: map['duration'] as int,
      genre: map['genre'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['image_path'] as String?,
      releaseDate: map['release_date'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] as String?,
      // JOIN data (nếu có)
      cinemaName: map['cinema_name'] as String?,
      hallName: map['hall_name'] as String?,
      ticketPrice: (map['ticket_price'] as num?)?.toDouble(),
      availableSeats: map['available_seats'] as int?,
    );
  }

  /// Chuyển từ Movie object sang Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'genre': genre,
      'rating': rating,
      'image_path': imagePath,
      'release_date': releaseDate,
      'status': status,
    };
  }

  /// Tạo bản sao Movie với một số field thay đổi
  Movie copyWith({
    int? id,
    String? title,
    String? description,
    int? duration,
    String? genre,
    double? rating,
    String? imagePath,
    String? releaseDate,
    String? status,
    List<String>? showtimes,
    String? cinemaName,
    String? hallName,
    double? ticketPrice,
    bool? isFavorite,
    int? availableSeats,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      releaseDate: releaseDate ?? this.releaseDate,
      status: status ?? this.status,
      createdAt: createdAt,
      showtimes: showtimes ?? this.showtimes,
      cinemaName: cinemaName ?? this.cinemaName,
      hallName: hallName ?? this.hallName,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      isFavorite: isFavorite ?? this.isFavorite,
      availableSeats: availableSeats ?? this.availableSeats,
    );
  }
}
```

---

## File: `lib/models/cinema.dart`

```dart
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
```

---

## File: `lib/models/booking.dart`

```dart
import 'package:flutter/material.dart';

/// Enum trạng thái đặt vé
enum BookingStatus {
  confirmed,  // Đã xác nhận
  completed,  // Đã hoàn thành
  cancelled,  // Đã hủy
  pending,    // Chờ xác nhận
}

/// Extension thêm chức năng cho BookingStatus
extension BookingStatusExt on BookingStatus {
  /// Trả về nhãn tiếng Việt
  String get label {
    switch (this) {
      case BookingStatus.confirmed: return 'Đã xác nhận';
      case BookingStatus.completed: return 'Đã hoàn thành';
      case BookingStatus.cancelled: return 'Đã hủy';
      case BookingStatus.pending:   return 'Chờ xác nhận';
    }
  }

  /// Trả về màu tương ứng
  Color get color {
    switch (this) {
      case BookingStatus.confirmed: return const Color(0xFF4CAF50); // Xanh lá
      case BookingStatus.completed: return const Color(0xFF2196F3); // Xanh dương
      case BookingStatus.cancelled: return const Color(0xFFF44336); // Đỏ
      case BookingStatus.pending:   return const Color(0xFFFFC107); // Vàng
    }
  }

  /// Chuyển từ String sang BookingStatus
  static BookingStatus fromString(String value) {
    switch (value) {
      case 'confirmed': return BookingStatus.confirmed;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      default:          return BookingStatus.pending;
    }
  }

  /// Trả về tên dạng string
  String get nameString => toString().split('.').last;
}

/// Model Booking - Đại diện cho một lần đặt vé
class Booking {
  final String id;              // ID đặt vé (UUID)
  final String movieTitle;      // Tên phim
  final String movieImage;      // Ảnh poster phim
  final String cinema;          // Tên rạp
  final String cinemaHall;      // Tên phòng chiếu
  final String format;          // Định dạng: 2D, 3D, IMAX
  final DateTime bookingDate;   // Ngày xem phim
  final String time;            // Giờ chiếu
  final List<String> seats;     // Danh sách ghế đã chọn
  final double totalPrice;      // Tổng tiền
  final BookingStatus status;   // Trạng thái đặt vé
  final DateTime createdAt;     // Ngày tạo booking

  Booking({
    required this.id,
    required this.movieTitle,
    required this.movieImage,
    required this.cinema,
    required this.cinemaHall,
    required this.format,
    required this.bookingDate,
    required this.time,
    required this.seats,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  /// Chuyển từ Map (SQLite) sang Booking
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      movieTitle: map['movieTitle'],
      movieImage: map['movieImage'],
      cinema: map['cinema'],
      cinemaHall: map['cinemaHall'],
      format: map['format'],
      bookingDate: DateTime.parse(map['bookingDate']),
      time: map['time'],
      seats: (map['seats'] as String).split(','), // "A1,A2" -> ["A1","A2"]
      totalPrice: map['totalPrice'] is int
          ? (map['totalPrice'] as int).toDouble()
          : map['totalPrice'],
      status: BookingStatusExt.fromString(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Chuyển từ Booking sang Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'movieImage': movieImage,
      'cinema': cinema,
      'cinemaHall': cinemaHall,
      'format': format,
      'bookingDate': bookingDate.toIso8601String(),
      'time': time,
      'seats': seats.join(','), // ["A1","A2"] -> "A1,A2"
      'totalPrice': totalPrice,
      'status': status.nameString,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Tạo bản sao Booking
  Booking copyWith({
    String? id,
    String? movieTitle,
    String? movieImage,
    String? cinema,
    String? cinemaHall,
    String? format,
    DateTime? bookingDate,
    String? time,
    List<String>? seats,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      movieImage: movieImage ?? this.movieImage,
      cinema: cinema ?? this.cinema,
      cinemaHall: cinemaHall ?? this.cinemaHall,
      format: format ?? this.format,
      bookingDate: bookingDate ?? this.bookingDate,
      time: time ?? this.time,
      seats: seats ?? this.seats,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

---

## File: `lib/models/seat.dart`

```dart
/// Model Seat - Đại diện cho 1 ghế ngồi trong phòng chiếu
class Seat {
  final String label; // Nhãn ghế: "A1", "B3", "C5"...
  final int price;    // Giá ghế (VND)

  Seat({
    required this.label,
    required this.price,
  });
}
```

---

## File: `lib/models/review_model.dart`

```dart
/// Model ReviewModel - Đại diện cho 1 đánh giá phim
class ReviewModel {
  final int id;           // ID đánh giá
  final int movieId;      // ID phim được đánh giá
  final String userName;  // Tên người đánh giá
  final double rating;    // Điểm rating (1.0 - 5.0)
  final String comment;   // Nội dung đánh giá
  final String date;      // Ngày đánh giá
  final int likeCount;    // Số lượt thích
  final bool isLiked;     // Trạng thái local (SharedPreferences)

  const ReviewModel({
    required this.id,
    required this.movieId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.likeCount,
    this.isLiked = false,
  });

  /// Chuyển từ ReviewModel sang Map (SQLite)
  Map<String, dynamic> toMap() => {
    'id': id,
    'movie_id': movieId,
    'user_name': userName,
    'rating': rating,
    'comment': comment,
    'date': date,
    'like_count': likeCount,
    'is_liked': isLiked ? 1 : 0, // SQLite lưu bool dưới dạng int
  };

  /// Chuyển từ Map (SQLite) sang ReviewModel
  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id: map['id'] as int,
    movieId: map['movie_id'] as int,
    userName: map['user_name'] as String,
    rating: (map['rating'] as num).toDouble(),
    comment: map['comment'] as String,
    date: map['date'] as String,
    likeCount: map['like_count'] as int,
    isLiked: (map['is_liked'] as int? ?? 0) == 1,
  );

  /// Chuyển từ JSON (API) sang ReviewModel
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as int,
    movieId: json['movie_id'] as int,
    userName: json['user_name'] as String,
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String,
    date: json['date'] as String? ?? '',
    likeCount: json['like_count'] as int? ?? 0,
  );

  /// Tạo bản sao ReviewModel
  ReviewModel copyWith({bool? isLiked, int? likeCount}) => ReviewModel(
    id: id,
    movieId: movieId,
    userName: userName,
    rating: rating,
    comment: comment,
    date: date,
    likeCount: likeCount ?? this.likeCount,
    isLiked: isLiked ?? this.isLiked,
  );
}
```

---

## File: `lib/models/trailer_model.dart`

```dart
/// Model TrailerModel - Đại diện cho 1 trailer phim
class TrailerModel {
  final int id;           // ID trailer
  final int movieId;      // ID phim
  final String title;     // Tên trailer
  final String videoId;   // YouTube video ID
  final String type;      // Loại: 'Trailer', 'Teaser', 'Clip', 'Behind the scenes'
  final String duration;  // Thời lượng: "2:30"
  final int viewCount;    // Lượt xem

  const TrailerModel({
    required this.id,
    required this.movieId,
    required this.title,
    required this.videoId,
    required this.type,
    required this.duration,
    required this.viewCount,
  });

  /// Lấy URL thumbnail từ YouTube video ID
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  /// Chuyển sang Map (SQLite)
  Map<String, dynamic> toMap() => {
    'id': id,
    'movie_id': movieId,
    'title': title,
    'video_id': videoId,
    'type': type,
    'duration': duration,
    'view_count': viewCount,
  };

  /// Chuyển từ Map (SQLite)
  factory TrailerModel.fromMap(Map<String, dynamic> map) => TrailerModel(
    id: map['id'] as int,
    movieId: map['movie_id'] as int,
    title: map['title'] as String,
    videoId: map['video_id'] as String,
    type: map['type'] as String,
    duration: map['duration'] as String,
    viewCount: map['view_count'] as int,
  );

  /// Chuyển từ JSON (API)
  factory TrailerModel.fromJson(Map<String, dynamic> json) => TrailerModel(
    id: json['id'] as int,
    movieId: json['movie_id'] as int,
    title: json['title'] as String,
    videoId: json['video_id'] as String,
    type: json['type'] as String? ?? 'Trailer',
    duration: json['duration'] as String? ?? '0:00',
    viewCount: json['view_count'] as int? ?? 0,
  );
}
```
