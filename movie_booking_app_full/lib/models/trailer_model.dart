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
