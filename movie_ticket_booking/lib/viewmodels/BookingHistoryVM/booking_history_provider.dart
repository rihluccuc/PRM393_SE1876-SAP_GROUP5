import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_ticket_booking/models/booking_model.dart';
import 'package:movie_ticket_booking/services/database.dart';

// Provider cho database helper
final databaseHelperProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Provider cho tất cả bookings
final bookingHistoryProvider = StateNotifierProvider<BookingHistoryNotifier, List<Booking>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BookingHistoryNotifier(dbHelper);
});

class BookingHistoryNotifier extends StateNotifier<List<Booking>> {
  final DatabaseService _dbHelper;

  BookingHistoryNotifier(this._dbHelper) : super([]) {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookings = await _dbHelper.getAllBookings();
    state = bookings;
  }

  // Hàm để cập nhật status của booking
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    await _dbHelper.updateBookingStatus(bookingId, newStatus);
    state = [
      for (final booking in state)
        if (booking.id == bookingId) booking.copyWith(status: newStatus) else booking,
    ];
  }

  // Hàm để xóa booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Thêm booking mới
  Future<void> addBooking(Booking booking) async {
    await _dbHelper.insertBooking(booking);
    state = [...state, booking];
  }

  // Xóa booking
  Future<void> removeBooking(String bookingId) async {
    await _dbHelper.deleteBooking(bookingId);
    state = state.where((booking) => booking.id != bookingId).toList();
  }
}

// Provider để lấy một booking cụ thể theo ID
final bookingDetailProvider = FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final bookings = ref.watch(bookingHistoryProvider);
  try {
    return bookings.firstWhere((booking) => booking.id == bookingId);
  } catch (e) {
    return null;
  }
});

// Provider để lọc booking theo status
final bookingsByStatusProvider = Provider.family<List<Booking>, BookingStatus>((ref, status) {
  final bookings = ref.watch(bookingHistoryProvider);
  return bookings.where((booking) => booking.status == status).toList();
});

// Provider để lấy các booking sắp diễn ra
final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingHistoryProvider);
  final now = DateTime.now();
  return bookings
      .where((booking) =>
  booking.status == BookingStatus.confirmed && booking.bookingDate.isAfter(now))
      .toList()
    ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
});

// Provider để lấy các booking đã hoàn thành
final completedBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingHistoryProvider);
  return bookings.where((booking) => booking.status == BookingStatus.completed).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});