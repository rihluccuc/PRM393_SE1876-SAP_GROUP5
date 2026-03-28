import '../database/database_helper.dart';
import '../models/movie.dart';

/// MovieRepository - Thao tác CRUD với bảng movies
class MovieRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy tất cả phim ───────────────────────────────────────────
  /// Lấy danh sách tất cả phim đang active
  Future<List<Movie>> getAllMovies() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'created_at DESC', // Sắp xếp mới nhất trước
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // ─── Lấy phim theo ID ──────────────────────────────────────────
  /// Lấy chi tiết 1 phim
  Future<Movie?> getMovieById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Movie.fromMap(result.first);
    }
    return null;
  }

  // ─── Thêm phim mới ─────────────────────────────────────────────
  /// Thêm phim mới (admin), trả về ID
  Future<int> insertMovie(Movie movie) async {
    final db = await _dbHelper.database;
    return await db.insert('movies', movie.toMap());
  }

  // ─── Cập nhật phim ─────────────────────────────────────────────
  /// Cập nhật thông tin phim
  Future<int> updateMovie(Movie movie) async {
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  // ─── Xóa phim ──────────────────────────────────────────────────
  /// Xóa phim (soft delete - chuyển status sang inactive)
  Future<int> deleteMovie(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      {'status': 'inactive'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Tìm kiếm phim ─────────────────────────────────────────────
  /// Tìm phim theo tên (LIKE %keyword%)
  Future<List<Movie>> searchMovies(String keyword) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'title LIKE ? AND status = ?',
      whereArgs: ['%$keyword%', 'active'],
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // ─── Đếm tổng phim ─────────────────────────────────────────────
  /// Đếm số lượng phim (dùng cho thống kê admin)
  Future<int> getMovieCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM movies');
    return result.first['count'] as int;
  }
}
