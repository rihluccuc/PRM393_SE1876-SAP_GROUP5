/// Model thuần — không phụ thuộc Flutter hay bất kỳ package nào
class MovieModel {
  final int    id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String synopsis;
  final double rating;
  final int    ratingCount;
  final String ageRating;       // 'G' | 'PG' | 'T13' | 'T16' | 'T18'
  final String genres;          // Lưu dạng "Hành động,Tâm lý" để dễ SQLite
  final int    durationMinutes;
  final String director;
  final String releaseDate;
  final bool   isNowShowing;
  final String language;

  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.synopsis,
    required this.rating,
    required this.ratingCount,
    required this.ageRating,
    required this.genres,
    required this.durationMinutes,
    required this.director,
    required this.releaseDate,
    required this.isNowShowing,
    required this.language,
  });

  // Lấy danh sách thể loại từ chuỗi
  List<String> get genreList =>
      genres.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  // ── SQLite ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id':               id,
    'title':            title,
    'poster_url':       posterUrl,
    'backdrop_url':     backdropUrl,
    'synopsis':         synopsis,
    'rating':           rating,
    'rating_count':     ratingCount,
    'age_rating':       ageRating,
    'genres':           genres,
    'duration_minutes': durationMinutes,
    'director':         director,
    'release_date':     releaseDate,
    'is_now_showing':   isNowShowing ? 1 : 0,
    'language':         language,
  };

  factory MovieModel.fromMap(Map<String, dynamic> map) => MovieModel(
    id:              map['id'] as int,
    title:           map['title'] as String,
    posterUrl:       map['poster_url'] as String,
    backdropUrl:     map['backdrop_url'] as String,
    synopsis:        map['synopsis'] as String,
    rating:          (map['rating'] as num).toDouble(),
    ratingCount:     map['rating_count'] as int,
    ageRating:       map['age_rating'] as String,
    genres:          map['genres'] as String,
    durationMinutes: map['duration_minutes'] as int,
    director:        map['director'] as String,
    releaseDate:     map['release_date'] as String,
    isNowShowing:    (map['is_now_showing'] as int) == 1,
    language:        map['language'] as String,
  );

  // ── JSON (API) ─────────────────────────────────────────────────────────────
  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id:              json['id'] as int,
    title:           json['title'] as String,
    posterUrl:       json['poster_url'] as String,
    backdropUrl:     json['backdrop_url'] as String,
    synopsis:        json['synopsis'] as String,
    rating:          (json['rating'] as num? ?? 0).toDouble(),
    ratingCount:     json['rating_count'] as int? ?? 0,
    ageRating:       json['age_rating'] as String? ?? 'G',
    genres:          (json['genres'] is List)
        ? (json['genres'] as List).join(',')
        : json['genres'] as String? ?? '',
    durationMinutes: json['duration_minutes'] as int? ?? 0,
    director:        json['director'] as String? ?? '',
    releaseDate:     json['release_date'] as String? ?? '',
    isNowShowing:    json['is_now_showing'] as bool? ?? false,
    language:        json['language'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':               id,
    'title':            title,
    'poster_url':       posterUrl,
    'backdrop_url':     backdropUrl,
    'synopsis':         synopsis,
    'rating':           rating,
    'rating_count':     ratingCount,
    'age_rating':       ageRating,
    'genres':           genreList,
    'duration_minutes': durationMinutes,
    'director':         director,
    'release_date':     releaseDate,
    'is_now_showing':   isNowShowing,
    'language':         language,
  };

  MovieModel copyWith({
    double? rating,
    int?    ratingCount,
    bool?   isNowShowing,
  }) =>
      MovieModel(
        id:              id,
        title:           title,
        posterUrl:       posterUrl,
        backdropUrl:     backdropUrl,
        synopsis:        synopsis,
        rating:          rating ?? this.rating,
        ratingCount:     ratingCount ?? this.ratingCount,
        ageRating:       ageRating,
        genres:          genres,
        durationMinutes: durationMinutes,
        director:        director,
        releaseDate:     releaseDate,
        isNowShowing:    isNowShowing ?? this.isNowShowing,
        language:        language,
      );

  @override
  bool operator ==(Object other) =>
      other is MovieModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
