// ignore_for_file: unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/models/booking_model.dart';
import 'lib/services/booking_history_provider.dart';

///
/// HƯỚNG DẪN SỬ DỤNG PROVIDERS
///
/// File này chỉ để tham khảo - không cần compile
///

void exampleUsage(WidgetRef ref) {
  /// ============================================
  /// 1. WATCH TOÀN BỘ BOOKING HISTORY
  /// ============================================
  /// Theo dõi tất cả các booking
  final allBookings = ref.watch(bookingHistoryProvider);
  print('Tất cả bookings: ${allBookings.length}');

  /// ============================================
  /// 2. WATCH BOOKING CHI TIẾT THEO ID
  /// ============================================
  /// Theo dõi chi tiết một booking cụ thể
  final bookingDetail = ref.watch(bookingDetailProvider('BK001'));
  // Sử dụng .when() để handle AsyncValue
  bookingDetail.when(
    data: (booking) {
      if (booking != null) {
        print('Phim: ${booking.movieTitle}');
      }
    },
    loading: () => print('Đang tải...'),
    error: (error, _) => print('Lỗi: $error'),
  );

  /// ============================================
  /// 3. WATCH BOOKING THEO TRẠNG THÁI
  /// ============================================
  /// Lấy tất cả booking đã xác nhận
  final confirmedBookings =
      ref.watch(bookingsByStatusProvider(BookingStatus.confirmed));
  print('Booking đã xác nhận: ${confirmedBookings.length}');

  /// Lấy tất cả booking đã hoàn thành
  final completedBookings =
      ref.watch(bookingsByStatusProvider(BookingStatus.completed));
  print('Booking hoàn thành: ${completedBookings.length}');

  /// Lấy tất cả booking chờ xác nhận
  final pendingBookings =
      ref.watch(bookingsByStatusProvider(BookingStatus.pending));
  print('Booking chờ xác nhận: ${pendingBookings.length}');

  /// Lấy tất cả booking đã hủy
  final cancelledBookings =
      ref.watch(bookingsByStatusProvider(BookingStatus.cancelled));
  print('Booking đã hủy: ${cancelledBookings.length}');

  /// ============================================
  /// 4. WATCH BOOKING SẮP DIỄN RA
  /// ============================================
  /// Lấy các booking xác nhận và ngày chiếu sau ngày hiện tại
  /// Sắp xếp theo ngày sớm nhất trước
  final upcomingBookings = ref.watch(upcomingBookingsProvider);
  for (var booking in upcomingBookings) {
    print(
        'Sắp diễn ra: ${booking.movieTitle} - ${booking.bookingDate.toString()}');
  }

  /// ============================================
  /// 5. WATCH BOOKING ĐÃ HOÀN THÀNH
  /// ============================================
  /// Lấy các booking hoàn thành
  /// Sắp xếp theo ngày tạo mới nhất trước
  final completed = ref.watch(completedBookingsProvider);
  for (var booking in completed) {
    print('Hoàn thành: ${booking.movieTitle}');
  }

  /// ============================================
  /// 6. THÊM BOOKING MỚI
  /// ============================================
  /// Tạo một booking mới và thêm vào danh sách
  final newBooking = Booking(
    id: 'BK006',
    movieTitle: 'Avatar 3',
    movieImage: 'https://via.placeholder.com/200x300?text=Avatar3',
    cinema: 'CGV Aeon Tân Phú',
    cinemaHall: 'Hall 4',
    format: 'IMAX',
    bookingDate: DateTime(2026, 4, 1),
    time: '20:30',
    seats: ['C5', 'C6', 'C7'],
    totalPrice: 900000,
    status: BookingStatus.confirmed,
    createdAt: DateTime.now(),
  );

  ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);

  /// ============================================
  /// 7. CẬP NHẬT TRẠNG THÁI BOOKING
  /// ============================================
  /// Cập nhật trạng thái booking từ pending sang confirmed
  ref
      .read(bookingHistoryProvider.notifier)
      .updateBookingStatus('BK003', BookingStatus.confirmed);

  /// ============================================
  /// 8. HỦY BOOKING
  /// ============================================
  /// Hủy một booking (chuyển sang status cancelled)
  ref.read(bookingHistoryProvider.notifier).cancelBooking('BK002');

  /// ============================================
  /// 9. LỌCDỮ LIỆU PHỨC TẠP
  /// ============================================
  /// Lấy các booking ở một rạp cụ thể
  final cinemaBookings = allBookings
      .where((booking) => booking.cinema == 'CGV Vincom Mega Mall')
      .toList();
  print('Booking ở CGV Mega Mall: ${cinemaBookings.length}');

  /// Lấy các booking ở một ngày cụ thể
  final dateToFilter = DateTime(2026, 2, 28);
  final dateBookings = allBookings
      .where((booking) => booking.bookingDate.day == dateToFilter.day &&
          booking.bookingDate.month == dateToFilter.month &&
          booking.bookingDate.year == dateToFilter.year)
      .toList();
  print('Booking ngày 28/02/2026: ${dateBookings.length}');

  /// Lấy các booking có giá > 400000
  final expensiveBookings =
      allBookings.where((booking) => booking.totalPrice > 400000).toList();
  print('Booking > 400000: ${expensiveBookings.length}');

  /// ============================================
  /// 10. SỬ DỤNG TRONG WIDGET
  /// ============================================
  /// Ví dụ: Consumer widget
  ///
  /// Consumer(
  ///   builder: (context, ref, child) {
  ///     final bookings = ref.watch(bookingHistoryProvider);
  ///     return ListView.builder(
  ///       itemCount: bookings.length,
  ///       itemBuilder: (context, index) {
  ///         final booking = bookings[index];
  ///         return ListTile(
  ///           title: Text(booking.movieTitle),
  ///           subtitle: Text(booking.status.label),
  ///         );
  ///       },
  ///     );
  ///   },
  /// )
}

/// ============================================
/// DỮ LIỆU MẪU ĐƯỢC CUNG CẤP
/// ============================================
///
/// BK001: Deadpool & Wolverine
///   - Status: COMPLETED (Hoàn thành)
///   - Cinema: CGV Vincom Mega Mall, Hall 7
///   - Format: 3D
///   - Date: 28/02/2026 19:30
///   - Seats: [E1, E2, E3]
///   - Price: 450000₫
///
/// BK002: Dune: Part Two
///   - Status: CONFIRMED (Đã xác nhận)
///   - Cinema: CGV Vincom Tây Hồ, Hall 3
///   - Format: IMAX
///   - Date: 15/03/2026 20:00
///   - Seats: [A5, A6]
///   - Price: 600000₫
///
/// BK003: The Brutalist
///   - Status: PENDING (Chờ xác nhận)
///   - Cinema: CGV Hà Đông, Hall 2
///   - Format: 2D
///   - Date: 10/03/2026 16:45
///   - Seats: [D10, D11]
///   - Price: 300000₫
///
/// BK004: Oppenheimer
///   - Status: CANCELLED (Đã hủy)
///   - Cinema: CGV Aeon Tân Phú, Hall 1
///   - Format: 2D
///   - Date: 20/02/2026 18:00
///   - Seats: [B3, B4, B5, B6]
///   - Price: 400000₫
///
/// BK005: Inception
///   - Status: COMPLETED (Hoàn thành)
///   - Cinema: CGV Vincom Mega Mall, Hall 5
///   - Format: 3D
///   - Date: 25/01/2026 21:00
///   - Seats: [F7, F8]
///   - Price: 500000₫

