// lib/repositories/movie_repository.dart
// =====================================================
// Repository: MovieRepository
// Lớp trung gian xử lý toàn bộ CRUD cho bảng movies
// ViewModel gọi Repository, không gọi trực tiếp DB
// =====================================================

import '../database/database_helper.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final DatabaseHelper _dbHelper;

  MovieRepository(this._dbHelper);

  /// Lấy tất cả phim, sắp xếp mới nhất trước
  Future<List<Movie>> getAllMovies() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'movies',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  /// Lấy phim đang active (đang chiếu)
  Future<List<Movie>> getActiveMovies() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'movies',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'title ASC',
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  /// Lấy phim theo ID
  Future<Movie?> getMovieById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Movie.fromMap(maps.first);
  }

  /// Tìm kiếm phim theo tên
  Future<List<Movie>> searchMovies(String keyword) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'title ASC',
    );
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  /// Thêm phim mới, trả về ID vừa tạo
  Future<int> insertMovie(Movie movie) async {
    final db = await _dbHelper.database;
    return await db.insert('movies', movie.toMap());
  }

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

  /// Xóa phim (và cascade xóa showtimes liên quan)
  Future<int> deleteMovie(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Thay đổi trạng thái phim (active/inactive)
  Future<void> toggleMovieStatus(int id, String newStatus) async {
    final db = await _dbHelper.database;
    await db.update(
      'movies',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}