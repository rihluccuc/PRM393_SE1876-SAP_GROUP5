// lib/viewmodels/providers.dart
// =====================================================
// RIVERPOD PROVIDERS - Trung tâm quản lý trạng thái
// Tất cả các widget đều truy cập state qua các provider này
// =====================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/movie_model.dart';
import '../models/cinema_model.dart';
import '../repositories/movie_repository.dart';
import '../repositories/cinema_repository.dart';

// =====================================================
// INFRASTRUCTURE PROVIDERS (Singleton)
// Khởi tạo 1 lần, dùng xuyên suốt app
// =====================================================

/// Provider cho DatabaseHelper - Singleton, không thay đổi
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider cho MovieRepository
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return MovieRepository(db);
});

/// Provider cho CinemaRepository
final cinemaRepositoryProvider = Provider<CinemaRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return CinemaRepository(db);
});

/// Provider cho ShowtimeRepository
final showtimeRepositoryProvider = Provider<ShowtimeRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return ShowtimeRepository(db);
});

/// Provider cho StatisticsRepository
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return StatisticsRepository(db);
});

// =====================================================
// MOVIE PROVIDERS
// =====================================================

/// FutureProvider: Tải danh sách tất cả phim
/// Widget dùng: ref.watch(moviesProvider)
final moviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getAllMovies();
});

/// FutureProvider: Chỉ lấy phim đang active
final activeMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getActiveMovies();
});

// =====================================================
// CINEMA PROVIDERS
// =====================================================

/// FutureProvider: Tải danh sách tất cả rạp chiếu
final cinemasProvider = FutureProvider<List<Cinema>>((ref) async {
  final repo = ref.watch(cinemaRepositoryProvider);
  return repo.getAllCinemas();
});

/// FutureProvider: Tải tất cả phòng chiếu
final hallsProvider = FutureProvider<List<Hall>>((ref) async {
  final repo = ref.watch(cinemaRepositoryProvider);
  return repo.getAllHalls();
});

// =====================================================
// SHOWTIME PROVIDERS
// =====================================================

/// FutureProvider: Tải tất cả lịch chiếu
final showtimesProvider = FutureProvider<List<Showtime>>((ref) async {
  final repo = ref.watch(showtimeRepositoryProvider);
  return repo.getAllShowtimes();
});

// =====================================================
// STATISTICS PROVIDERS
// =====================================================

/// FutureProvider: Thống kê tổng quan
final overallStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final statsRepo = ref.watch(statisticsRepositoryProvider);
  // Thêm vé mẫu nếu chưa có để demo thống kê
  await statsRepo.insertSampleTickets();
  return statsRepo.getOverallStats();
});

/// FutureProvider: Top phim bán chạy
final topMoviesProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getTopMovies();
});

/// FutureProvider: Doanh thu theo ngày
final revenueByDateProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getRevenueByDate();
});

/// FutureProvider: Thống kê theo thể loại
final statsByGenreProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(statisticsRepositoryProvider);
  return repo.getStatsByGenre();
});

// =====================================================
// MOVIE VIEWMODEL - Xử lý logic thêm/sửa/xóa phim
// Dùng StateNotifier để thông báo cập nhật UI
// =====================================================

/// Trạng thái của màn hình quản lý phim
class MovieState {
  final bool isLoading;        // Đang xử lý?
  final String? errorMessage;  // Thông báo lỗi (null = không lỗi)
  final String? successMessage; // Thông báo thành công

  const MovieState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  MovieState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return MovieState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,        // Reset về null nếu không truyền
      successMessage: successMessage,
    );
  }
}

/// StateNotifier quản lý thao tác CRUD phim
class MovieViewModel extends StateNotifier<MovieState> {
  final MovieRepository _repo;
  final Ref _ref; // Dùng để invalidate provider khi có thay đổi

  MovieViewModel(this._repo, this._ref) : super(const MovieState());

  /// Thêm phim mới
  Future<bool> addMovie(Movie movie) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.insertMovie(movie);
      // Invalidate provider để refresh danh sách phim
      _ref.invalidate(moviesProvider);
      _ref.invalidate(activeMoviesProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Thêm phim "${movie.title}" thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi: ${e.toString()}',
      );
      return false;
    }
  }

  /// Cập nhật thông tin phim
  Future<bool> updateMovie(Movie movie) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.updateMovie(movie);
      _ref.invalidate(moviesProvider);
      _ref.invalidate(activeMoviesProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cập nhật phim thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi cập nhật: ${e.toString()}',
      );
      return false;
    }
  }

  /// Xóa phim
  Future<bool> deleteMovie(int id, String title) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.deleteMovie(id);
      _ref.invalidate(moviesProvider);
      _ref.invalidate(showtimesProvider); // Xóa phim → xóa cả lịch chiếu
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã xóa phim "$title"',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi xóa phim: ${e.toString()}',
      );
      return false;
    }
  }

  /// Reset thông báo
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Provider cho MovieViewModel
final movieViewModelProvider =
StateNotifierProvider<MovieViewModel, MovieState>((ref) {
  final repo = ref.watch(movieRepositoryProvider);
  return MovieViewModel(repo, ref);
});

// =====================================================
// CINEMA VIEWMODEL - Xử lý logic thêm/sửa/xóa rạp và phòng
// =====================================================

class CinemaState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const CinemaState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  CinemaState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return CinemaState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class CinemaViewModel extends StateNotifier<CinemaState> {
  final CinemaRepository _repo;
  final Ref _ref;

  CinemaViewModel(this._repo, this._ref) : super(const CinemaState());

  Future<bool> addCinema(Cinema cinema) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.insertCinema(cinema);
      _ref.invalidate(cinemasProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Thêm rạp "${cinema.name}" thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateCinema(Cinema cinema) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.updateCinema(cinema);
      _ref.invalidate(cinemasProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cập nhật rạp thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCinema(int id, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.deleteCinema(id);
      _ref.invalidate(cinemasProvider);
      _ref.invalidate(hallsProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã xóa rạp "$name"',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addHall(Hall hall) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.insertHall(hall);
      _ref.invalidate(hallsProvider);
      _ref.invalidate(cinemasProvider); // Cập nhật total_halls
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Thêm phòng "${hall.name}" thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteHall(int hallId, int cinemaId, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.deleteHall(hallId, cinemaId);
      _ref.invalidate(hallsProvider);
      _ref.invalidate(cinemasProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã xóa phòng "$name"',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final cinemaViewModelProvider =
StateNotifierProvider<CinemaViewModel, CinemaState>((ref) {
  final repo = ref.watch(cinemaRepositoryProvider);
  return CinemaViewModel(repo, ref);
});

// =====================================================
// SHOWTIME VIEWMODEL
// =====================================================

class ShowtimeState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ShowtimeState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ShowtimeState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ShowtimeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ShowtimeViewModel extends StateNotifier<ShowtimeState> {
  final ShowtimeRepository _repo;
  final Ref _ref;

  ShowtimeViewModel(this._repo, this._ref) : super(const ShowtimeState());

  Future<bool> addShowtime(Showtime showtime) async {
    state = state.copyWith(isLoading: true);
    try {
      // Kiểm tra xung đột lịch chiếu
      final hasConflict = await _repo.hasConflict(
        hallId: showtime.hallId,
        showDate: showtime.showDate,
        startTime: showtime.startTime,
        endTime: showtime.endTime,
      );

      if (hasConflict) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
          'Phòng chiếu đã có lịch trong khung giờ này! Vui lòng chọn giờ khác.',
        );
        return false;
      }

      await _repo.insertShowtime(showtime);
      _ref.invalidate(showtimesProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Thêm lịch chiếu thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteShowtime(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.deleteShowtime(id);
      _ref.invalidate(showtimesProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã xóa lịch chiếu',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final showtimeViewModelProvider =
StateNotifierProvider<ShowtimeViewModel, ShowtimeState>((ref) {
  final repo = ref.watch(showtimeRepositoryProvider);
  return ShowtimeViewModel(repo, ref);
});