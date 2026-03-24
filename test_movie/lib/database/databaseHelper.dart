import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/appConstants.dart';
import '../model/movie.dart';
import '../model/review.dart';
import '../model/trailer.dart';

/// DatabaseHelper — Singleton quản lý toàn bộ SQLite
/// Chỉ một instance duy nhất chạy trong suốt vòng đời app
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  // ── Khởi tạo DB & tạo bảng ────────────────────────────────────────────────
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bảng movies — cache dữ liệu từ API
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMovies} (
        id               INTEGER PRIMARY KEY,
        title            TEXT    NOT NULL,
        poster_url       TEXT    NOT NULL,
        backdrop_url     TEXT    NOT NULL,
        synopsis         TEXT    NOT NULL,
        rating           REAL    DEFAULT 0,
        rating_count     INTEGER DEFAULT 0,
        age_rating       TEXT    NOT NULL,
        genres           TEXT    NOT NULL,
        duration_minutes INTEGER NOT NULL,
        director         TEXT    NOT NULL,
        release_date     TEXT    NOT NULL,
        is_now_showing   INTEGER DEFAULT 0,
        language         TEXT    NOT NULL
      )
    ''');

    // Bảng reviews — lưu review local & từ API
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReviews} (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id   INTEGER NOT NULL,
        user_name  TEXT    NOT NULL,
        rating     REAL    NOT NULL,
        comment    TEXT    NOT NULL,
        date       TEXT    NOT NULL,
        like_count INTEGER DEFAULT 0,
        is_liked   INTEGER DEFAULT 0,
        FOREIGN KEY (movie_id) REFERENCES ${AppConstants.tableMovies}(id)
      )
    ''');

    // Bảng trailers — cache trailer list
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTrailers} (
        id         INTEGER PRIMARY KEY,
        movie_id   INTEGER NOT NULL,
        title      TEXT    NOT NULL,
        video_id   TEXT    NOT NULL,
        type       TEXT    NOT NULL,
        duration   TEXT    NOT NULL,
        view_count INTEGER DEFAULT 0,
        FOREIGN KEY (movie_id) REFERENCES ${AppConstants.tableMovies}(id)
      )
    ''');

    // Bảng favorites — ID phim đã yêu thích
    await db.execute('''
      CREATE TABLE ${AppConstants.tableFavorites} (
        movie_id   INTEGER PRIMARY KEY,
        created_at TEXT    NOT NULL
      )
    ''');

    // Seed mock data ngay sau khi tạo DB
    await _seedMockData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Xử lý migration khi tăng version
    // Ví dụ: if (oldVersion < 2) await db.execute('ALTER TABLE ...');
  }

  // ── SEED MOCK DATA ─────────────────────────────────────────────────────────
  Future<void> _seedMockData(Database db) async {
    final batch = db.batch();

    // Movies
    final movies = _mockMovies();
    for (final m in movies) {
      batch.insert(AppConstants.tableMovies, m.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Trailers
    final trailers = _mockTrailers();
    for (final t in trailers) {
      batch.insert(AppConstants.tableTrailers, t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Reviews
    final reviews = _mockReviews();
    for (final r in reviews) {
      final map = r.toMap();
      map.remove('id'); // AUTOINCREMENT
      batch.insert(AppConstants.tableReviews, map,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // ── MOVIES CRUD ────────────────────────────────────────────────────────────
  Future<List<MovieModel>> getAllMovies() async {
    final db   = await database;
    final rows = await db.query(AppConstants.tableMovies);
    return rows.map(MovieModel.fromMap).toList();
  }

  Future<List<MovieModel>> getNowShowingMovies() async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableMovies,
      where: 'is_now_showing = ?',
      whereArgs: [1],
    );
    return rows.map(MovieModel.fromMap).toList();
  }

  Future<List<MovieModel>> getComingSoonMovies() async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableMovies,
      where: 'is_now_showing = ?',
      whereArgs: [0],
    );
    return rows.map(MovieModel.fromMap).toList();
  }

  Future<MovieModel?> getMovieById(int id) async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableMovies,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MovieModel.fromMap(rows.first);
  }

  Future<void> upsertMovies(List<MovieModel> movies) async {
    final db    = await database;
    final batch = db.batch();
    for (final m in movies) {
      batch.insert(AppConstants.tableMovies, m.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ── REVIEWS CRUD ───────────────────────────────────────────────────────────
  Future<List<ReviewModel>> getReviewsByMovieId(int movieId) async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableReviews,
      where:     'movie_id = ?',
      whereArgs: [movieId],
      orderBy:   'date DESC',
    );
    return rows.map(ReviewModel.fromMap).toList();
  }

  Future<int> insertReview(ReviewModel review) async {
    final db  = await database;
    final map = review.toMap()..remove('id');
    return db.insert(AppConstants.tableReviews, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateReviewLike(int reviewId, bool isLiked, int likeCount) async {
    final db = await database;
    await db.update(
      AppConstants.tableReviews,
      {'is_liked': isLiked ? 1 : 0, 'like_count': likeCount},
      where:     'id = ?',
      whereArgs: [reviewId],
    );
  }

  // ── TRAILERS CRUD ──────────────────────────────────────────────────────────
  Future<List<TrailerModel>> getTrailersByMovieId(int movieId) async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableTrailers,
      where:     'movie_id = ?',
      whereArgs: [movieId],
    );
    return rows.map(TrailerModel.fromMap).toList();
  }

  Future<void> upsertTrailers(List<TrailerModel> trailers) async {
    final db    = await database;
    final batch = db.batch();
    for (final t in trailers) {
      batch.insert(AppConstants.tableTrailers, t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ── FAVORITES ──────────────────────────────────────────────────────────────
  Future<List<int>> getFavoriteMovieIds() async {
    final db   = await database;
    final rows = await db.query(AppConstants.tableFavorites);
    return rows.map((r) => r['movie_id'] as int).toList();
  }

  Future<void> toggleFavorite(int movieId) async {
    final db    = await database;
    final exist = await db.query(
      AppConstants.tableFavorites,
      where: 'movie_id = ?', whereArgs: [movieId], limit: 1,
    );
    if (exist.isEmpty) {
      await db.insert(AppConstants.tableFavorites, {
        'movie_id':   movieId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete(AppConstants.tableFavorites,
          where: 'movie_id = ?', whereArgs: [movieId]);
    }
  }

  Future<bool> isFavorite(int movieId) async {
    final db   = await database;
    final rows = await db.query(
      AppConstants.tableFavorites,
      where: 'movie_id = ?', whereArgs: [movieId], limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ── Close ──────────────────────────────────────────────────────────────────
  Future<void> close() async => (await database).close();

  // ═══════════════════════════════════════════════════════════════════════════
  // MOCK DATA — thay bằng API call thật sau
  // ═══════════════════════════════════════════════════════════════════════════
  List<MovieModel> _mockMovies() => [
    const MovieModel(
      id: 1,
      title: 'Avengers: Secret Wars',
      posterUrl:   'https://image.tmdb.org/t/p/w500/tMefBSflR6PGQLv7WvFPpY1HIoJ.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
      synopsis: 'Sau những sự kiện tàn khốc trong Avengers: Endgame, các siêu anh hùng phải đối mặt với mối đe dọa mới từ đa vũ trụ. Thanos mới xuất hiện cùng một đội quân hùng mạnh chưa từng có, buộc tất cả các anh hùng phải hợp sức.',
      rating: 8.7, ratingCount: 24580,
      ageRating: 'T13',
      genres: 'Hành động,Phiêu lưu,Khoa học viễn tưởng',
      durationMinutes: 155, director: 'Anthony Russo',
      releaseDate: '2025-05-01', isNowShowing: true, language: 'Tiếng Anh',
    ),
    const MovieModel(
      id: 2,
      title: 'Lật Mặt 7: Một Điều Ước',
      posterUrl:   'https://image.tmdb.org/t/p/w500/9l1eZiJHmhr5jIlthMdJN5WYoff.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/1X7vow16X7CnCoexXh4H4F2yDJv.jpg',
      synopsis: 'Tiếp nối thành công của loạt phim Lật Mặt, phần 7 kể câu chuyện về một gia đình với những bí mật được chôn vùi sâu trong quá khứ. Khi sự thật dần hé lộ, mọi mối quan hệ đều bị thử thách.',
      rating: 7.9, ratingCount: 18320,
      ageRating: 'T16',
      genres: 'Tâm lý,Hành động,Tội phạm',
      durationMinutes: 127, director: 'Lý Hải',
      releaseDate: '2025-04-30', isNowShowing: true, language: 'Tiếng Việt',
    ),
    const MovieModel(
      id: 3,
      title: 'Mission: Impossible 8',
      posterUrl:   'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/iQFcwSGbZXMkeyKrxbPnwnRo5fl.jpg',
      synopsis: 'Ethan Hunt trở lại với sứ mệnh bất khả thi nguy hiểm nhất từ trước đến nay. Lần này không chỉ thế giới mà toàn bộ thực tại đang bị đe dọa bởi một AI vượt tầm kiểm soát.',
      rating: 8.2, ratingCount: 15780,
      ageRating: 'T13',
      genres: 'Hành động,Gián điệp,Phiêu lưu',
      durationMinutes: 163, director: 'Christopher McQuarrie',
      releaseDate: '2025-05-23', isNowShowing: true, language: 'Tiếng Anh',
    ),
    const MovieModel(
      id: 4,
      title: 'Inside Out 3',
      posterUrl:   'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/wqnLdwVXoBjKibFRR5U3y0aDUhs.jpg',
      synopsis: 'Riley đã trưởng thành và đang đối mặt với những thách thức tuổi trưởng thành. Những cảm xúc trong đầu phải làm việc cùng nhau vượt qua hành trình mới đầy bất ngờ.',
      rating: 8.5, ratingCount: 12340,
      ageRating: 'G',
      genres: 'Hoạt hình,Gia đình,Phiêu lưu',
      durationMinutes: 100, director: 'Kelsey Mann',
      releaseDate: '2025-06-13', isNowShowing: true, language: 'Tiếng Anh',
    ),
    const MovieModel(
      id: 5,
      title: 'Superman: Legacy',
      posterUrl:   'https://image.tmdb.org/t/p/w500/74oTpv3hqs5IiEMWADQfvFJJnmN.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/gH9oXlyba1cBcV7l0Ltj5yCfb7f.jpg',
      synopsis: 'Một câu chuyện hoàn toàn mới về Siêu nhân — Clark Kent đang cố gắng cân bằng giữa di sản Kryptonian và danh tính con người, trong khi mối đe dọa mới đang hình thành.',
      rating: 0, ratingCount: 0,
      ageRating: 'T13',
      genres: 'Hành động,Khoa học viễn tưởng',
      durationMinutes: 140, director: 'James Gunn',
      releaseDate: '2025-07-11', isNowShowing: false, language: 'Tiếng Anh',
    ),
    const MovieModel(
      id: 6,
      title: 'Jurassic World 4',
      posterUrl:   'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/gmBCygLZMqoJPJbA1V63bT5GKSk.jpg',
      synopsis: 'Thế giới khủng long rơi vào hỗn loạn khi một loài chưa từng biết đến xuất hiện, đe dọa sự tồn tại của loài người. Một nhóm chuyên gia phải đối mặt với thử thách sinh tử.',
      rating: 0, ratingCount: 0,
      ageRating: 'T13',
      genres: 'Hành động,Phiêu lưu,Khoa học viễn tưởng',
      durationMinutes: 145, director: 'Gareth Edwards',
      releaseDate: '2025-07-02', isNowShowing: false, language: 'Tiếng Anh',
    ),
  ];

  List<TrailerModel> _mockTrailers() => [
    const TrailerModel(id: 1, movieId: 1, title: 'Avengers: Secret Wars — Official Trailer',    videoId: 'hA6hldpSTF8', type: 'Trailer', duration: '2:34', viewCount: 48200000),
    const TrailerModel(id: 2, movieId: 1, title: 'Avengers: Secret Wars — Teaser',              videoId: 'eOrNdBpGMv8', type: 'Teaser',  duration: '1:15', viewCount: 22100000),
    const TrailerModel(id: 3, movieId: 2, title: 'Lật Mặt 7 — Trailer chính thức',              videoId: 'TnGl01FkMMo', type: 'Trailer', duration: '3:02', viewCount: 12500000),
    const TrailerModel(id: 4, movieId: 3, title: 'Mission: Impossible 8 — Final Trailer',       videoId: 'avz06PDqDbM', type: 'Trailer', duration: '2:55', viewCount: 35600000),
    const TrailerModel(id: 5, movieId: 3, title: 'Mission: Impossible 8 — Teaser',              videoId: 'TnGl01FkMMo', type: 'Teaser',  duration: '1:30', viewCount: 18900000),
    const TrailerModel(id: 6, movieId: 4, title: 'Inside Out 3 — Official Trailer',             videoId: 'eOrNdBpGMv8', type: 'Trailer', duration: '2:10', viewCount: 27800000),
  ];

  List<ReviewModel> _mockReviews() => [
    const ReviewModel(id: 0, movieId: 1, userName: 'Minh Tuấn',  rating: 9.0, comment: 'Phim cực kỳ mãn nhãn! Hiệu ứng hình ảnh đỉnh cao, cốt truyện hấp dẫn từ đầu đến cuối.', date: '2025-03-20', likeCount: 142),
    const ReviewModel(id: 0, movieId: 1, userName: 'Thu Hương',  rating: 8.5, comment: 'Rất hay! Dàn diễn viên diễn xuất tốt. Phim hơi dài ở đoạn giữa nhưng nhìn chung tuyệt vời khi xem IMAX.', date: '2025-03-19', likeCount: 87),
    const ReviewModel(id: 0, movieId: 1, userName: 'Quốc Bảo',   rating: 10,  comment: 'Masterpiece! Không có gì để chê. Nhạc phim, hình ảnh, diễn xuất đều hoàn hảo.', date: '2025-03-18', likeCount: 215),
    const ReviewModel(id: 0, movieId: 2, userName: 'Việt Dũng',  rating: 8.0, comment: 'Lý Hải làm phim ngày càng chuyên nghiệp. Kịch bản chặt chẽ, hành động đẹp mắt. Tự hào phim Việt!', date: '2025-03-21', likeCount: 324),
    const ReviewModel(id: 0, movieId: 3, userName: 'Thanh Nam',  rating: 9.0, comment: 'Tom Cruise lại chứng minh đẳng cấp. Cảnh hành động thật 100% không CGI. Đỉnh của đỉnh!', date: '2025-03-22', likeCount: 267),
  ];
}
