class ReviewModel {
  final int    id;
  final int    movieId;
  final String userName;
  final double rating;
  final String comment;
  final String date;
  final int    likeCount;
  final bool   isLiked;        // trạng thái local (SharedPreferences)

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

  // ── SQLite ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id':         id,
    'movie_id':   movieId,
    'user_name':  userName,
    'rating':     rating,
    'comment':    comment,
    'date':       date,
    'like_count': likeCount,
    'is_liked':   isLiked ? 1 : 0,
  };

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id:        map['id'] as int,
    movieId:   map['movie_id'] as int,
    userName:  map['user_name'] as String,
    rating:    (map['rating'] as num).toDouble(),
    comment:   map['comment'] as String,
    date:      map['date'] as String,
    likeCount: map['like_count'] as int,
    isLiked:   (map['is_liked'] as int? ?? 0) == 1,
  );

  // ── JSON (API) ─────────────────────────────────────────────────────────────
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id:        json['id'] as int,
    movieId:   json['movie_id'] as int,
    userName:  json['user_name'] as String,
    rating:    (json['rating'] as num).toDouble(),
    comment:   json['comment'] as String,
    date:      json['date'] as String? ?? '',
    likeCount: json['like_count'] as int? ?? 0,
  );

  ReviewModel copyWith({bool? isLiked, int? likeCount}) => ReviewModel(
    id:        id,
    movieId:   movieId,
    userName:  userName,
    rating:    rating,
    comment:   comment,
    date:      date,
    likeCount: likeCount ?? this.likeCount,
    isLiked:   isLiked ?? this.isLiked,
  );
}
