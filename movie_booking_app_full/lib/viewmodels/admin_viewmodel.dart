import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../models/cinema.dart';
import '../services/movie_service.dart';
import '../services/cinema_service.dart';
import '../services/booking_service.dart';

// ─── State ────────────────────────────────────────────────────────
class AdminState {
  final List<Movie> movies;
  final List<Cinema> cinemas;
  final int totalMovies;
  final int totalBookings;
  final double totalRevenue;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.movies = const [],
    this.cinemas = const [],
    this.totalMovies = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0.0,
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<Movie>? movies,
    List<Cinema>? cinemas,
    int? totalMovies,
    int? totalBookings,
    double? totalRevenue,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      movies: movies ?? this.movies,
      cinemas: cinemas ?? this.cinemas,
      totalMovies: totalMovies ?? this.totalMovies,
      totalBookings: totalBookings ?? this.totalBookings,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class AdminViewModel extends StateNotifier<AdminState> {
  final MovieService _movieService = MovieService();
  final CinemaService _cinemaService = CinemaService();
  final BookingService _bookingService = BookingService();

  AdminViewModel() : super(const AdminState());

  // ─── Load thống kê ─────────────────────────────────────────────
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);
    try {
      final totalMovies = await _movieService.getTotalMovies();
      final totalBookings = await _bookingService.getTotalBookings();
      final totalRevenue = await _bookingService.getTotalRevenue();

      state = state.copyWith(
        totalMovies: totalMovies,
        totalBookings: totalBookings,
        totalRevenue: totalRevenue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Thêm phim mới ────────────────────────────────────────────
  Future<bool> addMovie(Movie movie) async {
    state = state.copyWith(isLoading: true);
    try {
      await _movieService.addMovie(movie);
      // Reload danh sách phim
      final movies = await _movieService.getActiveMovies();
      state = state.copyWith(movies: movies, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

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

  // ─── Load danh sách rạp ───────────────────────────────────────
  Future<void> loadCinemas() async {
    state = state.copyWith(isLoading: true);
    try {
      final cinemas = await _cinemaService.getAllCinemas();
      state = state.copyWith(cinemas: cinemas, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Xóa phim ─────────────────────────────────────────────────
  Future<void> deleteMovie(int id) async {
    await _movieService.deleteMovie(id);
    await loadMovies(); // Reload
  }

  // ─── Thêm rạp mới ─────────────────────────────────────────────
  Future<bool> addCinema(Cinema cinema) async {
    state = state.copyWith(isLoading: true);
    try {
      await _cinemaService.addCinema(cinema);
      await loadCinemas();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final adminProvider = StateNotifierProvider<AdminViewModel, AdminState>(
  (ref) => AdminViewModel(),
);
