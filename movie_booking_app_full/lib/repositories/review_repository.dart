import '../database/database_helper.dart';
import '../models/review_model.dart';

/// ReviewRepository - Thao tác CRUD với bảng reviews
class ReviewRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy reviews theo phim ─────────────────────────────────────
  Future<List<ReviewModel>> getReviewsByMovieId(int movieId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reviews',
      where: 'movie_id = ?',
      whereArgs: [movieId],
      orderBy: 'date DESC',
    );
    return result.map((map) => ReviewModel.fromMap(map)).toList();
  }

  // ─── Thêm review mới ───────────────────────────────────────────
  Future<int> insertReview(ReviewModel review) async {
    final db = await _dbHelper.database;
    return await db.insert('reviews', review.toMap());
  }

  // ─── Cập nhật like count ────────────────────────────────────────
  Future<int> updateLikeCount(int id, int likeCount) async {
    final db = await _dbHelper.database;
    return await db.update(
      'reviews',
      {'like_count': likeCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
