# 🧠 ViewModels - Quản Lý State (Riverpod)

## Mô Tả
ViewModel là lớp quản lý state, kết nối giữa Service và View.
Sử dụng **Riverpod** (StateNotifier + StateNotifierProvider) để quản lý state.

### Luồng Dữ Liệu MVVM:
```
View (UI) → ViewModel (State) → Service (Logic) → Repository (CRUD) → Database (SQLite)
```

---

## File: `lib/viewmodels/auth_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── State class ──────────────────────────────────────────────────
/// AuthState - Trạng thái của authentication
class AuthState {
  final User? user;         // User hiện tại (null = chưa đăng nhập)
  final bool isLoading;     // Đang xử lý
  final String? error;      // Lỗi (nếu có)

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Tạo bản sao state với một số field thay đổi
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel (StateNotifier) ────────────────────────────────────
/// AuthViewModel - Quản lý state cho đăng nhập/đăng ký
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  // Khởi tạo với state rỗng
  AuthViewModel() : super(const AuthState());

  // ─── Đăng nhập ─────────────────────────────────────────────────
  /// Gọi AuthService.login() và cập nhật state
  Future<bool> login(String email, String password) async {
    // Bắt đầu loading
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Gọi service đăng nhập
      final user = await _authService.login(
        email: email,
        password: password,
      );
      // Thành công → cập nhật user vào state
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      // Thất bại → hiển thị lỗi
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ─── Đăng ký ───────────────────────────────────────────────────
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ─── Đăng xuất ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(); // Reset state về mặc định
  }

  // ─── Kiểm tra đăng nhập ────────────────────────────────────────
  Future<void> checkLoginStatus() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  // ─── Cập nhật profile ──────────────────────────────────────────
  Future<bool> updateProfile(User updatedUser) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.updateProfile(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
/// Provider toàn cục cho AuthViewModel
/// Dùng: ref.watch(authProvider) hoặc ref.read(authProvider.notifier)
final authProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);
```

---

## File: `lib/viewmodels/movie_viewmodel.dart`

```dart
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
```

---

## File: `lib/viewmodels/booking_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/cinema.dart';
import '../services/booking_service.dart';
import '../services/cinema_service.dart';

// ─── State ────────────────────────────────────────────────────────
/// BookingState - Trạng thái flow đặt vé
class BookingState {
  final List<Cinema> cinemas;          // Danh sách rạp
  final Cinema? selectedCinema;        // Rạp đã chọn
  final String? selectedDate;          // Ngày đã chọn
  final String? selectedTime;          // Giờ đã chọn
  final String? selectedFormat;        // Format: 2D/3D/IMAX
  final List<String> selectedSeats;    // Ghế đã chọn
  final double totalPrice;             // Tổng tiền
  final bool isLoading;
  final String? error;

  const BookingState({
    this.cinemas = const [],
    this.selectedCinema,
    this.selectedDate,
    this.selectedTime,
    this.selectedFormat,
    this.selectedSeats = const [],
    this.totalPrice = 0.0,
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    List<Cinema>? cinemas,
    Cinema? selectedCinema,
    String? selectedDate,
    String? selectedTime,
    String? selectedFormat,
    List<String>? selectedSeats,
    double? totalPrice,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      cinemas: cinemas ?? this.cinemas,
      selectedCinema: selectedCinema ?? this.selectedCinema,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class BookingViewModel extends StateNotifier<BookingState> {
  final BookingService _bookingService = BookingService();
  final CinemaService _cinemaService = CinemaService();

  BookingViewModel() : super(const BookingState());

  // ─── Load danh sách rạp ────────────────────────────────────────
  Future<void> loadCinemas() async {
    state = state.copyWith(isLoading: true);
    try {
      final cinemas = await _cinemaService.getAllCinemas();
      state = state.copyWith(cinemas: cinemas, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Chọn rạp ──────────────────────────────────────────────────
  void selectCinema(Cinema cinema) {
    state = state.copyWith(selectedCinema: cinema);
  }

  // ─── Chọn ngày ─────────────────────────────────────────────────
  void selectDate(String date) {
    state = state.copyWith(selectedDate: date);
  }

  // ─── Chọn giờ ──────────────────────────────────────────────────
  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  // ─── Chọn format ───────────────────────────────────────────────
  void selectFormat(String format) {
    state = state.copyWith(selectedFormat: format);
  }

  // ─── Toggle ghế ────────────────────────────────────────────────
  /// Chọn/bỏ chọn ghế
  void toggleSeat(String seatLabel, int seatPrice) {
    final currentSeats = List<String>.from(state.selectedSeats);
    if (currentSeats.contains(seatLabel)) {
      // Bỏ chọn ghế
      currentSeats.remove(seatLabel);
      state = state.copyWith(
        selectedSeats: currentSeats,
        totalPrice: state.totalPrice - seatPrice,
      );
    } else {
      // Chọn ghế
      currentSeats.add(seatLabel);
      state = state.copyWith(
        selectedSeats: currentSeats,
        totalPrice: state.totalPrice + seatPrice,
      );
    }
  }

  // ─── Xác nhận đặt vé ──────────────────────────────────────────
  Future<Booking?> confirmBooking({
    required String movieTitle,
    required String movieImage,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final booking = await _bookingService.createBooking(
        movieTitle: movieTitle,
        movieImage: movieImage,
        cinema: state.selectedCinema!.name,
        cinemaHall: 'Phòng 1',
        format: state.selectedFormat ?? '2D',
        bookingDate: DateTime.parse(state.selectedDate!),
        time: state.selectedTime!,
        seats: state.selectedSeats,
        totalPrice: state.totalPrice,
      );
      state = state.copyWith(isLoading: false);
      return booking;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }

  // ─── Reset state ───────────────────────────────────────────────
  /// Reset về trạng thái ban đầu (khi quay lại flow đặt vé)
  void resetBooking() {
    state = const BookingState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final bookingProvider = StateNotifierProvider<BookingViewModel, BookingState>(
  (ref) => BookingViewModel(),
);
```

---

## File: `lib/viewmodels/history_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

// ─── State ────────────────────────────────────────────────────────
class HistoryState {
  final List<Booking> bookings;        // Danh sách lịch sử
  final Booking? selectedBooking;      // Booking đang xem chi tiết
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.bookings = const [],
    this.selectedBooking,
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<Booking>? bookings,
    Booking? selectedBooking,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel ────────────────────────────────────────────────────
class HistoryViewModel extends StateNotifier<HistoryState> {
  final BookingService _bookingService = BookingService();

  HistoryViewModel() : super(const HistoryState());

  // ─── Load lịch sử đặt vé ──────────────────────────────────────
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final bookings = await _bookingService.getBookingHistory();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Xem chi tiết vé ──────────────────────────────────────────
  Future<void> loadBookingDetail(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final booking = await _bookingService.getBookingDetail(id);
      state = state.copyWith(selectedBooking: booking, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ─── Hủy vé ────────────────────────────────────────────────────
  Future<bool> cancelBooking(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _bookingService.cancelBooking(id);
      // Reload lại danh sách
      await loadHistory();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
final historyProvider = StateNotifierProvider<HistoryViewModel, HistoryState>(
  (ref) => HistoryViewModel(),
);
```

---

## File: `lib/viewmodels/admin_viewmodel.dart`

```dart
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
```

---

## File: `lib/viewmodels/review_viewmodel.dart`

```dart
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
```

---

## File: `lib/viewmodels/trailer_viewmodel.dart`

```dart
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
```
