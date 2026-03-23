// lib/models/movie_model.dart
// =====================================================
// Model: Movie - Đại diện cho 1 bộ phim trong hệ thống
// =====================================================

class Movie {
  final int? id;
  final String title;         // Tên phim
  final String? description;  // Mô tả
  final int duration;         // Thời lượng (phút)
  final String? genre;        // Thể loại
  final double rating;        // Điểm đánh giá
  final String? imagePath;    // Đường dẫn ảnh (assets hoặc file system)
  final String? releaseDate;  // Ngày phát hành
  final String status;        // 'active' hoặc 'inactive'
  final String? createdAt;

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
  });

  /// Chuyển từ Map (SQLite) sang Movie object
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
    );
  }

  /// Chuyển Movie object sang Map để lưu vào SQLite
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

  /// Tạo bản sao có chỉnh sửa một số trường
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
    );
  }
}