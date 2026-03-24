import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/localPrefs.dart';
import '../model/review.dart';
import '../repository/reviewRepository.dart';

// ── State ──────────────────────────────────────────────────────────────────────
class ReviewState {
  final List<ReviewModel> reviews;
  final String            sortBy;        // 'newest' | 'highest' | 'lowest' | 'mostLiked'
  final bool              isLoading;
  final bool              isSubmitting;
  final String?           errorMessage;

  const ReviewState({
    this.reviews      = const [],
    this.sortBy       = 'newest',
    this.isLoading    = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Tổng đánh giá trung bình
  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  /// Danh sách đã sắp xếp
  List<ReviewModel> get sorted {
    final list = [...reviews];
    switch (sortBy) {
      case 'highest':  list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'lowest':   list.sort((a, b) => a.rating.compareTo(b.rating));
      case 'mostLiked':list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      default:         list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  /// Phân phối rating: {10: count, 9: count, ...}
  Map<int, int> get distribution {
    final map = <int, int>{};
    for (final r in reviews) {
      final star = r.rating.round();
      map[star] = (map[star] ?? 0) + 1;
    }
    return map;
  }

  ReviewState copyWith({
    List<ReviewModel>? reviews,
    String?            sortBy,
    bool?              isLoading,
    bool?              isSubmitting,
    String?            errorMessage,
  }) =>
      ReviewState(
        reviews:      reviews      ?? this.reviews,
        sortBy:       sortBy       ?? this.sortBy,
        isLoading:    isLoading    ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );
}

// ── ViewModel ──────────────────────────────────────────────────────────────────
class ReviewViewModel extends StateNotifier<ReviewState> {
  final ReviewRepository _repo;
  final LocalPrefs       _prefs;
  final int              _movieId;

  ReviewViewModel({
    required ReviewRepository repo,
    required LocalPrefs       prefs,
    required int              movieId,
  })  : _repo    = repo,
        _prefs   = prefs,
        _movieId = movieId,
        super(const ReviewState()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getByMovieId(_movieId);
      state = state.copyWith(reviews: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  void setSortBy(String sortBy) => state = state.copyWith(sortBy: sortBy);

  void toggleLike(int reviewId) {
    final updated = state.reviews.map((r) {
      if (r.id != reviewId) return r;
      final newLiked = !r.isLiked;
      final newCount = newLiked ? r.likeCount + 1 : r.likeCount - 1;
      // Persist vào DB
      _repo.toggleLike(reviewId, newLiked, newCount);
      return r.copyWith(isLiked: newLiked, likeCount: newCount);
    }).toList();
    state = state.copyWith(reviews: updated);
  }

  Future<bool> submitReview({
    required double rating,
    required String comment,
  }) async {
    if (comment.trim().length < 10) return false;
    state = state.copyWith(isSubmitting: true);
    try {
      final newReview = await _repo.addReview(
        movieId:  _movieId,
        userName: _prefs.userName,
        rating:   rating,
        comment:  comment.trim(),
      );
      state = state.copyWith(
        reviews:      [newReview, ...state.reviews],
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: '$e');
      return false;
    }
  }
}

// ── Providers ──────────────────────────────────────────────────────────────────
final reviewRepositoryProvider = Provider<ReviewRepository>(
      (_) => ReviewRepository(),
);

final reviewViewModelProvider = StateNotifierProvider.family<
    ReviewViewModel, ReviewState, int>((ref, movieId) {
  return ReviewViewModel(
    repo:    ref.read(reviewRepositoryProvider),
    prefs:   LocalPrefs.instance,
    movieId: movieId,
  );
});
