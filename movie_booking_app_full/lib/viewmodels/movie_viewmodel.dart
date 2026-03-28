import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

// ─── State ────────────────────────────────────────────────────────
/// MovieState - Trạng thái danh sách phim
class MovieState {
  final List<Movie> movies;      // Danh sách phim
  final Movie? selectedMovie;    // Phim đang xem chi tiết
  final bool isLoading;
  final String? error;

  const MovieState({
    this.movies = const [],
    this.selectedMovie,
    this.isLoading = false,
    this.error,
  });

  MovieState copyWith({
    List<Movie>? movies,
    Movie? selectedMovie,
    bool? isLoading,
    String? error,
  }) {
    return MovieState(
      movies: movies ?? this.movies,
      selectedMovie: selectedMovie ?? this.selectedMovie,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class MovieViewModel extends StateNotifier<MovieState> {
  final MovieService _movieService = MovieService();

  MovieViewModel() : super(const MovieState());

  // ─── Load danh sách phim ───────────────────────────────────────
  Future<void> loadMovies() async {
    state = state.copyWith(isLoading: true);
    try {
      final movies = await _movieService.getActiveMovies();
      state = state.copyWith(movies: movies, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Load chi tiết phim ────────────────────────────────────────
  Future<void> loadMovieDetail(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final movie = await _movieService.getMovieDetail(id);
      state = state.copyWith(selectedMovie: movie, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Tìm kiếm phim ────────────────────────────────────────────
  Future<void> searchMovies(String keyword) async {
    state = state.copyWith(isLoading: true);
    try {
      final movies = await _movieService.searchMovies(keyword);
      state = state.copyWith(movies: movies, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final movieProvider = StateNotifierProvider<MovieViewModel, MovieState>(
  (ref) => MovieViewModel(),
);
