# ⚙️ Services - Logic Nghiệp Vụ

## Mô Tả
Service là lớp chứa logic nghiệp vụ (business logic).
Nó gọi Repository để lấy/ghi dữ liệu và xử lý các quy tắc nghiệp vụ.

---

## File: `lib/services/auth_service.dart`

```dart
import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'shared_pref_service.dart';

/// AuthService - Xử lý logic đăng nhập, đăng ký, profile
class AuthService {
  final UserRepository _userRepo = UserRepository();
  final SharedPrefService _prefService = SharedPrefService();

  // ─── Đăng ký ────────────────────────────────────────────────────
  /// Đăng ký tài khoản mới
  /// Trả về User nếu thành công, throw Exception nếu email đã tồn tại
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Kiểm tra email đã tồn tại chưa
    final existingUser = await _userRepo.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email đã được sử dụng');
    }

    // Tạo user mới
    final user = User(
      name: name,
      email: email,
      password: password,
      role: 'user', // Mặc định là user thường
    );

    // Lưu vào database
    final id = await _userRepo.insertUser(user);

    // Lưu trạng thái đăng nhập vào SharedPreferences
    await _prefService.saveUserId(id);
    await _prefService.saveUserRole('user');

    // Trả về user với ID từ database
    return User(
      id: id,
      name: name,
      email: email,
      password: password,
      role: 'user',
    );
  }

  // ─── Đăng nhập ─────────────────────────────────────────────────
  /// Đăng nhập bằng email và password
  /// Trả về User nếu thành công, throw Exception nếu sai
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Tìm user theo email
    final user = await _userRepo.getUserByEmail(email);
    if (user == null) {
      throw Exception('Email không tồn tại');
    }

    // Kiểm tra password
    if (user.password != password) {
      throw Exception('Mật khẩu không đúng');
    }

    // Lưu trạng thái đăng nhập
    await _prefService.saveUserId(user.id!);
    await _prefService.saveUserRole(user.role);

    return user;
  }

  // ─── Đăng xuất ──────────────────────────────────────────────────
  /// Xóa trạng thái đăng nhập
  Future<void> logout() async {
    await _prefService.clearAll();
  }

  // ─── Lấy user hiện tại ─────────────────────────────────────────
  /// Lấy thông tin user đang đăng nhập (từ SharedPreferences)
  Future<User?> getCurrentUser() async {
    final userId = await _prefService.getUserId();
    if (userId == null) return null;
    return await _userRepo.getUserById(userId);
  }

  // ─── Cập nhật profile ───────────────────────────────────────────
  /// Cập nhật thông tin cá nhân
  Future<void> updateProfile(User user) async {
    await _userRepo.updateUser(user);
  }
}
```

---

## File: `lib/services/movie_service.dart`

```dart
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

/// MovieService - Xử lý logic nghiệp vụ liên quan đến phim
class MovieService {
  final MovieRepository _movieRepo = MovieRepository();

  // ─── Lấy danh sách phim ────────────────────────────────────────
  /// Lấy tất cả phim đang chiếu
  Future<List<Movie>> getActiveMovies() async {
    return await _movieRepo.getAllMovies();
  }

  // ─── Lấy chi tiết phim ─────────────────────────────────────────
  /// Lấy thông tin chi tiết 1 phim theo ID
  Future<Movie?> getMovieDetail(int id) async {
    return await _movieRepo.getMovieById(id);
  }

  // ─── Tìm kiếm phim ─────────────────────────────────────────────
  /// Tìm phim theo tên
  Future<List<Movie>> searchMovies(String keyword) async {
    if (keyword.isEmpty) return await getActiveMovies();
    return await _movieRepo.searchMovies(keyword);
  }

  // ─── Thêm phim (Admin) ─────────────────────────────────────────
  /// Thêm phim mới vào database
  Future<int> addMovie(Movie movie) async {
    return await _movieRepo.insertMovie(movie);
  }

  // ─── Cập nhật phim (Admin) ──────────────────────────────────────
  Future<void> updateMovie(Movie movie) async {
    await _movieRepo.updateMovie(movie);
  }

  // ─── Xóa phim (Admin) ──────────────────────────────────────────
  Future<void> deleteMovie(int id) async {
    await _movieRepo.deleteMovie(id);
  }

  // ─── Thống kê (Admin) ──────────────────────────────────────────
  Future<int> getTotalMovies() async {
    return await _movieRepo.getMovieCount();
  }
}
```

---

## File: `lib/services/booking_service.dart`

```dart
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';

/// BookingService - Xử lý logic đặt vé
class BookingService {
  final BookingRepository _bookingRepo = BookingRepository();
  final Uuid _uuid = const Uuid();

  // ─── Tạo booking mới ───────────────────────────────────────────
  /// Tạo đặt vé mới với trạng thái pending
  Future<Booking> createBooking({
    required String movieTitle,
    required String movieImage,
    required String cinema,
    required String cinemaHall,
    required String format,
    required DateTime bookingDate,
    required String time,
    required List<String> seats,
    required double totalPrice,
  }) async {
    // Tạo booking với UUID làm ID
    final booking = Booking(
      id: _uuid.v4(),                // Tạo ID duy nhất
      movieTitle: movieTitle,
      movieImage: movieImage,
      cinema: cinema,
      cinemaHall: cinemaHall,
      format: format,
      bookingDate: bookingDate,
      time: time,
      seats: seats,
      totalPrice: totalPrice,
      status: BookingStatus.pending,  // Mặc định: chờ xác nhận
      createdAt: DateTime.now(),
    );

    // Lưu vào database
    await _bookingRepo.insertBooking(booking);
    return booking;
  }

  // ─── Lấy lịch sử đặt vé ───────────────────────────────────────
  Future<List<Booking>> getBookingHistory() async {
    return await _bookingRepo.getAllBookings();
  }

  // ─── Lấy chi tiết booking ──────────────────────────────────────
  Future<Booking?> getBookingDetail(String id) async {
    return await _bookingRepo.getBookingById(id);
  }

  // ─── Hủy vé ────────────────────────────────────────────────────
  /// Hủy vé (chuyển status sang cancelled)
  Future<void> cancelBooking(String id) async {
    await _bookingRepo.updateBookingStatus(id, 'cancelled');
  }

  // ─── Thống kê doanh thu ────────────────────────────────────────
  Future<double> getTotalRevenue() async {
    return await _bookingRepo.getTotalRevenue();
  }

  // ─── Đếm tổng bookings ─────────────────────────────────────────
  Future<int> getTotalBookings() async {
    return await _bookingRepo.getBookingCount();
  }
}
```

---

## File: `lib/services/cinema_service.dart`

```dart
import '../models/cinema.dart';
import '../repositories/cinema_repository.dart';

/// CinemaService - Xử lý logic liên quan đến rạp chiếu phim
class CinemaService {
  final CinemaRepository _cinemaRepo = CinemaRepository();

  // ─── Lấy danh sách rạp ─────────────────────────────────────────
  Future<List<Cinema>> getAllCinemas() async {
    return await _cinemaRepo.getAllCinemas();
  }

  // ─── Lấy chi tiết rạp ──────────────────────────────────────────
  Future<Cinema?> getCinemaDetail(int id) async {
    return await _cinemaRepo.getCinemaById(id);
  }

  // ─── Thêm rạp mới (Admin) ──────────────────────────────────────
  Future<int> addCinema(Cinema cinema) async {
    return await _cinemaRepo.insertCinema(cinema);
  }

  // ─── Cập nhật rạp (Admin) ──────────────────────────────────────
  Future<void> updateCinema(Cinema cinema) async {
    await _cinemaRepo.updateCinema(cinema);
  }

  // ─── Xóa rạp (Admin) ───────────────────────────────────────────
  Future<void> deleteCinema(int id) async {
    await _cinemaRepo.deleteCinema(id);
  }
}
```

---

## File: `lib/services/shared_pref_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPrefService - Quản lý dữ liệu lưu trữ cục bộ
/// Dùng để lưu: trạng thái đăng nhập, theme, cài đặt nhỏ...
class SharedPrefService {
  // ─── Các key hằng số ────────────────────────────────────────────
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';

  // ─── Lưu User ID ───────────────────────────────────────────────
  /// Lưu ID của user đang đăng nhập
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // ─── Lấy User ID ───────────────────────────────────────────────
  /// Lấy ID user đang đăng nhập (null nếu chưa đăng nhập)
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // ─── Lưu vai trò user ──────────────────────────────────────────
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  // ─── Lấy vai trò user ──────────────────────────────────────────
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // ─── Kiểm tra đã đăng nhập chưa ────────────────────────────────
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ─── Dark Mode ──────────────────────────────────────────────────
  /// Lưu cài đặt dark mode
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  /// Kiểm tra có đang dark mode không
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // ─── Ngôn ngữ ──────────────────────────────────────────────────
  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'vi';
  }

  // ─── Xóa tất cả (đăng xuất) ────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```
