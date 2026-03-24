import '../database/databaseHelper.dart';
import '../model/review.dart';

class ReviewRepository {
  final DatabaseHelper _db;

  ReviewRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  Future<List<ReviewModel>> getByMovieId(int movieId) =>
      _db.getReviewsByMovieId(movieId);

  Future<ReviewModel> addReview({
    required int    movieId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final review = ReviewModel(
      id:        0, // AUTOINCREMENT
      movieId:   movieId,
      userName:  userName,
      rating:    rating,
      comment:   comment,
      date:      DateTime.now().toIso8601String().substring(0, 10),
      likeCount: 0,
    );
    final id = await _db.insertReview(review);
    return ReviewModel(
      id:        id,
      movieId:   movieId,
      userName:  userName,
      rating:    rating,
      comment:   comment,
      date:      review.date,
      likeCount: 0,
    );
  }

  Future<void> toggleLike(int reviewId, bool isLiked, int likeCount) =>
      _db.updateReviewLike(reviewId, isLiked, likeCount);
}
