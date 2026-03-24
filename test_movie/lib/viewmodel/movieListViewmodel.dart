import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/movie.dart';
import '../repository/movieRepository.dart';
import '../database/databaseHelper.dart';

// ── State ──────────────────────────────────────────────────────────────────────
/// Trạng thái của màn hình Movie List
class MovieListState {
  final List<MovieModel> nowShowing;
  final List<MovieModel> comingSoon;
  final List<int>        favoriteIds;
  final String           selectedTab;     // 'nowShowing' | 'comingSoon'
  final String           selectedGenre;   // 'Tất cả' | genre name
  final bool             isLoading;
  final String?          errorMessage;

  const MovieListState({
    this.nowShowing    = const [],
    this.comingSoon    = const [],
    this.favoriteIds   = const [],
    this.selectedTab   = 'nowShowing',
    this.selectedGenre = 'Tất cả',
    this.isLoading     = false,
    this.errorMessage,
  });

  MovieListState copyWith({
    List<MovieModel>? nowShowing,
    List<MovieModel>? comingSoon,
    List<int>?        favoriteIds,
    String?           selectedTab,
    String?           selectedGenre,
    bool?             isLoading,
    String?           errorMessage,
  }) =>
      MovieListState(
        nowShowing:    nowShowing    ?? this.nowShowing,
        comingSoon:    comingSoon    ?? this.comingSoon,
        favoriteIds:   favoriteIds   ?? this.favoriteIds,
        selectedTab:   selectedTab   ?? this.selectedTab,
        selectedGenre: selectedGenre ?? this.selectedGenre,
        isLoading:     isLoading     ?? this.isLoading,
        errorMessage:  errorMessage,
      );

  /// Phim hiển thị theo tab & genre đang chọn
  List<MovieModel> get displayedMovies {
    final source = selectedTab == 'nowShowing' ? nowShowing : comingSoon;
    if (selectedGenre == 'Tất cả') return source;
    return source
        .where((m) => m.genreList.contains(selectedGenre))
        .toList();
  }

  /// Banner: 3 phim đầu của nowShowing
  List<MovieModel> get bannerMovies => nowShowing.take(3).toList();
}

// ── ViewModel ──────────────────────────────────────────────────────────────────
class MovieListViewModel extends StateNotifier<MovieListState> {
  final MovieRepository    _movieRepo;
  final DatabaseHelper _favRepo;

  MovieListViewModel({
    required MovieRepository    movieRepo,
    required DatabaseHelper favRepo,
  })  : _movieRepo = movieRepo,
        _favRepo   = favRepo,
        super(const MovieListState()) {
    loadMovies();
  }

  /// Tải toàn bộ dữ liệu ban đầu
  Future<void> loadMovies() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _movieRepo.getNowShowing(),
        _movieRepo.getComingSoon(),
        _favRepo.getFavoriteMovieIds(),
      ]);
      state = state.copyWith(
        nowShowing:  results[0] as List<MovieModel>,
        comingSoon:  results[1] as List<MovieModel>,
        favoriteIds: results[2] as List<int>,
        isLoading:   false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: 'Không thể tải dữ liệu: $e',
      );
    }
  }

  void selectTab(String tab)     => state = state.copyWith(selectedTab: tab);
  void selectGenre(String genre) => state = state.copyWith(selectedGenre: genre);

  Future<void> toggleFavorite(int movieId) async {
    await _favRepo.toggleFavorite(movieId);
    final ids = await _favRepo.getFavoriteMovieIds();
    state = state.copyWith(favoriteIds: ids);
  }

  bool isFavorite(int movieId) => state.favoriteIds.contains(movieId);
}

// ── Providers ──────────────────────────────────────────────────────────────────
final movieRepositoryProvider = Provider<MovieRepository>(
      (_) => MovieRepository(),
);

final favoriteRepositoryProvider = Provider<DatabaseHelper>(
      (_) => DatabaseHelper.instance,
);

final movieListViewModelProvider =
StateNotifierProvider<MovieListViewModel, MovieListState>((ref) {
  return MovieListViewModel(
    movieRepo: ref.read(movieRepositoryProvider),
    favRepo:   ref.read(favoriteRepositoryProvider),
  );
});
