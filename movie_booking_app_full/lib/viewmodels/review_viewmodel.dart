import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

// ─── State ────────────────────────────────────────────────────────
class ReviewState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final String? error;

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  ReviewState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class ReviewViewModel extends StateNotifier<ReviewState> {
  final ReviewRepository _reviewRepo = ReviewRepository();

  ReviewViewModel() : super(const ReviewState());

  // ─── Load reviews theo phim ────────────────────────────────────
  Future<void> loadReviews(int movieId) async {
    state = state.copyWith(isLoading: true);
    try {
      final reviews = await _reviewRepo.getReviewsByMovieId(movieId);
      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Thêm review ──────────────────────────────────────────────
  Future<void> addReview(ReviewModel review) async {
    await _reviewRepo.insertReview(review);
    await loadReviews(review.movieId); // Reload
  }

  // ─── Toggle like ───────────────────────────────────────────────
  Future<void> toggleLike(int reviewId) async {
    final reviews = state.reviews.map((r) {
      if (r.id == reviewId) {
        final newLikeCount = r.isLiked ? r.likeCount - 1 : r.likeCount + 1;
        return r.copyWith(isLiked: !r.isLiked, likeCount: newLikeCount);
      }
      return r;
    }).toList();
    state = state.copyWith(reviews: reviews);
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final reviewProvider = StateNotifierProvider<ReviewViewModel, ReviewState>(
  (ref) => ReviewViewModel(),
);
