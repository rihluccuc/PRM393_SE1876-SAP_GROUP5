# 📂 Repositories - Truy Vấn Database

## Mô Tả
Repository là lớp trung gian giữa Database và Service.
Nhiệm vụ: thực hiện các thao tác CRUD (Create, Read, Update, Delete) trên SQLite.

---

## File: `lib/repositories/user_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/user.dart';

/// UserRepository - Thao tác CRUD với bảng users
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Tạo user mới ──────────────────────────────────────────────
  /// Thêm user vào database, trả về ID của user mới
  Future<int> insertUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // ─── Lấy user theo email ───────────────────────────────────────
  /// Tìm user theo email (dùng cho đăng nhập)
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',       // Điều kiện tìm kiếm
      whereArgs: [email],       // Giá trị truyền vào
    );
    // Nếu tìm thấy thì chuyển sang User, không thì trả về null
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ─── Lấy user theo ID ──────────────────────────────────────────
  /// Tìm user theo ID
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ─── Cập nhật user ─────────────────────────────────────────────
  /// Cập nhật thông tin user, trả về số dòng bị ảnh hưởng
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ─── Lấy tất cả users ──────────────────────────────────────────
  /// Lấy danh sách tất cả users (dùng cho admin)
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }
}
```

---

## File: `lib/repositories/movie_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/movie.dart';

/// MovieRepository - Thao tác CRUD với bảng movies
class MovieRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy tất cả phim ───────────────────────────────────────────
  /// Lấy danh sách tất cả phim đang active
  Future<List<Movie>> getAllMovies() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'created_at DESC', // Sắp xếp mới nhất trước
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // ─── Lấy phim theo ID ──────────────────────────────────────────
  /// Lấy chi tiết 1 phim
  Future<Movie?> getMovieById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Movie.fromMap(result.first);
    }
    return null;
  }

  // ─── Thêm phim mới ─────────────────────────────────────────────
  /// Thêm phim mới (admin), trả về ID
  Future<int> insertMovie(Movie movie) async {
    final db = await _dbHelper.database;
    return await db.insert('movies', movie.toMap());
  }

  // ─── Cập nhật phim ─────────────────────────────────────────────
  /// Cập nhật thông tin phim
  Future<int> updateMovie(Movie movie) async {
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  // ─── Xóa phim ──────────────────────────────────────────────────
  /// Xóa phim (soft delete - chuyển status sang inactive)
  Future<int> deleteMovie(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'movies',
      {'status': 'inactive'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Tìm kiếm phim ─────────────────────────────────────────────
  /// Tìm phim theo tên (LIKE %keyword%)
  Future<List<Movie>> searchMovies(String keyword) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'movies',
      where: 'title LIKE ? AND status = ?',
      whereArgs: ['%$keyword%', 'active'],
    );
    return result.map((map) => Movie.fromMap(map)).toList();
  }

  // ─── Đếm tổng phim ─────────────────────────────────────────────
  /// Đếm số lượng phim (dùng cho thống kê admin)
  Future<int> getMovieCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM movies');
    return result.first['count'] as int;
  }
}
```

---

## File: `lib/repositories/cinema_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/cinema.dart';

/// CinemaRepository - Thao tác CRUD với bảng cinemas
class CinemaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy tất cả rạp ────────────────────────────────────────────
  Future<List<Cinema>> getAllCinemas() async {
    final db = await _dbHelper.database;
    final result = await db.query('cinemas', orderBy: 'name ASC');
    return result.map((map) => Cinema.fromMap(map)).toList();
  }

  // ─── Lấy rạp theo ID ───────────────────────────────────────────
  Future<Cinema?> getCinemaById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cinemas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return Cinema.fromMap(result.first);
    return null;
  }

  // ─── Thêm rạp mới ──────────────────────────────────────────────
  Future<int> insertCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.insert('cinemas', cinema.toMap());
  }

  // ─── Cập nhật rạp ──────────────────────────────────────────────
  Future<int> updateCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cinemas',
      cinema.toMap(),
      where: 'id = ?',
      whereArgs: [cinema.id],
    );
  }

  // ─── Xóa rạp ───────────────────────────────────────────────────
  Future<int> deleteCinema(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cinemas', where: 'id = ?', whereArgs: [id]);
  }
}
```

---

## File: `lib/repositories/booking_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/booking.dart';

/// BookingRepository - Thao tác CRUD với bảng bookings
class BookingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Tạo booking mới ───────────────────────────────────────────
  Future<void> insertBooking(Booking booking) async {
    final db = await _dbHelper.database;
    await db.insert('bookings', booking.toMap());
  }

  // ─── Lấy tất cả bookings ───────────────────────────────────────
  /// Lấy lịch sử đặt vé, sắp xếp mới nhất trước
  Future<List<Booking>> getAllBookings() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bookings',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  // ─── Lấy booking theo ID ───────────────────────────────────────
  Future<Booking?> getBookingById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return Booking.fromMap(result.first);
    return null;
  }

  // ─── Cập nhật trạng thái booking ────────────────────────────────
  /// Cập nhật status (ví dụ: hủy vé)
  Future<int> updateBookingStatus(String id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Đếm tổng bookings ─────────────────────────────────────────
  Future<int> getBookingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM bookings');
    return result.first['count'] as int;
  }

  // ─── Tính tổng doanh thu ────────────────────────────────────────
  Future<double> getTotalRevenue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(totalPrice) as total FROM bookings WHERE status != 'cancelled'"
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
```

---

## File: `lib/repositories/review_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/review_model.dart';

/// ReviewRepository - Thao tác CRUD với bảng reviews
class ReviewRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy reviews theo phim ─────────────────────────────────────
  Future<List<ReviewModel>> getReviewsByMovieId(int movieId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'reviews',
      where: 'movie_id = ?',
      whereArgs: [movieId],
      orderBy: 'date DESC',
    );
    return result.map((map) => ReviewModel.fromMap(map)).toList();
  }

  // ─── Thêm review mới ───────────────────────────────────────────
  Future<int> insertReview(ReviewModel review) async {
    final db = await _dbHelper.database;
    return await db.insert('reviews', review.toMap());
  }

  // ─── Cập nhật like count ────────────────────────────────────────
  Future<int> updateLikeCount(int id, int likeCount) async {
    final db = await _dbHelper.database;
    return await db.update(
      'reviews',
      {'like_count': likeCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

---

## File: `lib/repositories/trailer_repository.dart`

```dart
import '../database/database_helper.dart';
import '../models/trailer_model.dart';

/// TrailerRepository - Thao tác CRUD với bảng trailers
class TrailerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Lấy trailers theo phim ────────────────────────────────────
  Future<List<TrailerModel>> getTrailersByMovieId(int movieId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'trailers',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return result.map((map) => TrailerModel.fromMap(map)).toList();
  }

  // ─── Thêm trailer mới ──────────────────────────────────────────
  Future<int> insertTrailer(TrailerModel trailer) async {
    final db = await _dbHelper.database;
    return await db.insert('trailers', trailer.toMap());
  }
}
```
