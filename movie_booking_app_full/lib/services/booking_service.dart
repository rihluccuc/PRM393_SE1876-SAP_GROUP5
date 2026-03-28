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
    required String userId,
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
      userId: userId,
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

  /// Lấy lịch sử đặt vé theo user
  Future<List<Booking>> getBookingHistoryByUser(String userId) async {
    return await _bookingRepo.getBookingsByUserId(userId);
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
