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
