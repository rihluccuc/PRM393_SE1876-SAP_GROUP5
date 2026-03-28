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

  // ─── Lấy bookings theo user ID ──────────────────────────────────
  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Booking.fromMap(map)).toList();
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
