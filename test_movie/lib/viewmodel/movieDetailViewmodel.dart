import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/movie.dart';
import '../repository/movieRepository.dart';
import '../database/databaseHelper.dart';
import 'movieListViewmodel.dart';

// ── State ──────────────────────────────────────────────────────────────────────
class MovieDetailState {
  final MovieModel? movie;
  final bool        isFavorite;
  final bool        isLoading;
  final String?     errorMessage;

  const MovieDetailState({
    this.movie,
    this.isFavorite  = false,
    this.isLoading   = true,
    this.errorMessage,
  });

  MovieDetailState copyWith({
    MovieModel? movie,
    bool?       isFavorite,
    bool?       isLoading,
    String?     errorMessage,
  }) =>
      MovieDetailState(
        movie:        movie        ?? this.movie,
        isFavorite:   isFavorite   ?? this.isFavorite,
        isLoading:    isLoading    ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

// ── ViewModel ──────────────────────────────────────────────────────────────────
class MovieDetailViewModel extends StateNotifier<MovieDetailState> {
  final MovieRepository    _movieRepo;
  final DatabaseHelper     _favRepo;
  final int                _movieId;

  MovieDetailViewModel({
    required MovieRepository    movieRepo,
    required DatabaseHelper     favRepo,
    required int                movieId,
  })  : _movieRepo = movieRepo,
        _favRepo   = favRepo,
        _movieId   = movieId,
        super(const MovieDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _movieRepo.getById(_movieId),
        _favRepo.isFavorite(_movieId),
      ]);
      state = state.copyWith(
        movie:      results[0] as MovieModel?,
        isFavorite: results[1] as bool,
        isLoading:  false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: 'Không thể tải chi tiết phim: $e',
      );
    }
  }

  Future<void> toggleFavorite() async {
    if (state.movie == null) return;
    await _favRepo.toggleFavorite(_movieId);
    final isFav = await _favRepo.isFavorite(_movieId);
    state = state.copyWith(isFavorite: isFav);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────
final movieDetailViewModelProvider = StateNotifierProvider.family<
    MovieDetailViewModel, MovieDetailState, int>((ref, movieId) {
  return MovieDetailViewModel(
    movieRepo: ref.read(movieRepositoryProvider),
    favRepo:   ref.read(favoriteRepositoryProvider),
    movieId:   movieId,
  );
});
