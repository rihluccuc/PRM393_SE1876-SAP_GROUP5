import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/trailer.dart';
import '../repository/trailerRepository.dart';

// ── State ──────────────────────────────────────────────────────────────────────
class TrailerState {
  final List<TrailerModel> trailers;
  final int                selectedIndex;
  final bool               isLoading;
  final String?            errorMessage;

  const TrailerState({
    this.trailers      = const [],
    this.selectedIndex = 0,
    this.isLoading     = true,
    this.errorMessage,
  });

  TrailerModel? get selectedTrailer =>
      trailers.isEmpty ? null : trailers[selectedIndex];

  TrailerState copyWith({
    List<TrailerModel>? trailers,
    int?                selectedIndex,
    bool?               isLoading,
    String?             errorMessage,
  }) =>
      TrailerState(
        trailers:      trailers      ?? this.trailers,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isLoading:     isLoading     ?? this.isLoading,
        errorMessage:  errorMessage,
      );
}

// ── ViewModel ──────────────────────────────────────────────────────────────────
class TrailerViewModel extends StateNotifier<TrailerState> {
  final TrailerRepository _repo;
  final int               _movieId;

  TrailerViewModel({required TrailerRepository repo, required int movieId})
      : _repo    = repo,
        _movieId = movieId,
        super(const TrailerState()) {
    loadTrailers();
  }

  Future<void> loadTrailers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repo.getByMovieId(_movieId);
      state = state.copyWith(trailers: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '$e');
    }
  }

  void selectTrailer(int index) {
    if (index < 0 || index >= state.trailers.length) return;
    state = state.copyWith(selectedIndex: index);
  }
}

// ── Providers ──────────────────────────────────────────────────────────────────
final trailerRepositoryProvider = Provider<TrailerRepository>(
      (_) => TrailerRepository(),
);

final trailerViewModelProvider = StateNotifierProvider.family<
    TrailerViewModel, TrailerState, int>((ref, movieId) {
  return TrailerViewModel(
    repo:    ref.read(trailerRepositoryProvider),
    movieId: movieId,
  );
});
