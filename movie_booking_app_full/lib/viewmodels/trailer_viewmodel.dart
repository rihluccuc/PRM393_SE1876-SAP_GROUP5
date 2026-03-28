import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trailer_model.dart';
import '../repositories/trailer_repository.dart';

// ─── State ────────────────────────────────────────────────────────
class TrailerState {
  final List<TrailerModel> trailers;
  final bool isLoading;
  final String? error;

  const TrailerState({
    this.trailers = const [],
    this.isLoading = false,
    this.error,
  });

  TrailerState copyWith({
    List<TrailerModel>? trailers,
    bool? isLoading,
    String? error,
  }) {
    return TrailerState(
      trailers: trailers ?? this.trailers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class TrailerViewModel extends StateNotifier<TrailerState> {
  final TrailerRepository _trailerRepo = TrailerRepository();

  TrailerViewModel() : super(const TrailerState());

  // ─── Load trailers theo phim ───────────────────────────────────
  Future<void> loadTrailers(int movieId) async {
    state = state.copyWith(isLoading: true);
    try {
      final trailers = await _trailerRepo.getTrailersByMovieId(movieId);
      state = state.copyWith(trailers: trailers, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final trailerProvider = StateNotifierProvider<TrailerViewModel, TrailerState>(
  (ref) => TrailerViewModel(),
);
