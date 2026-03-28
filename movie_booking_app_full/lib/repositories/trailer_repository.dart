import '../database/database_helper.dart';
import '../models/trailer_model.dart';

/// TrailerRepository - Thao tác CRUD với bảng trailers
class TrailerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy trailers theo phim ────────────────────────────────────
  Future<List<TrailerModel>> getTrailersByMovieId(int movieId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'trailers',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return result.map((map) => TrailerModel.fromMap(map)).toList();
  }

  // ─── Thêm trailer mới ──────────────────────────────────────────
  Future<int> insertTrailer(TrailerModel trailer) async {
    final db = await _dbHelper.database;
    return await db.insert('trailers', trailer.toMap());
  }
}
