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
