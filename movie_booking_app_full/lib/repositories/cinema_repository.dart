import '../database/database_helper.dart';
import '../models/cinema.dart';

/// CinemaRepository - Thao tác CRUD với bảng cinemas
class CinemaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy tất cả rạp ────────────────────────────────────────────
  Future<List<Cinema>> getAllCinemas() async {
    final db = await _dbHelper.database;
    final result = await db.query('cinemas', orderBy: 'name ASC');
    return result.map((map) => Cinema.fromMap(map)).toList();
  }

  // ─── Lấy rạp theo ID ───────────────────────────────────────────
  Future<Cinema?> getCinemaById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cinemas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return Cinema.fromMap(result.first);
    return null;
  }

  // ─── Thêm rạp mới ──────────────────────────────────────────────
  Future<int> insertCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.insert('cinemas', cinema.toMap());
  }

  // ─── Cập nhật rạp ──────────────────────────────────────────────
  Future<int> updateCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cinemas',
      cinema.toMap(),
      where: 'id = ?',
      whereArgs: [cinema.id],
    );
  }

  // ─── Xóa rạp ───────────────────────────────────────────────────
  Future<int> deleteCinema(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cinemas', where: 'id = ?', whereArgs: [id]);
  }
}
