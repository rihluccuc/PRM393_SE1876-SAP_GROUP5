import '../models/seat.dart';

/// SeatAvailabilityService - Quản lý tình trạng ghế
class SeatAvailabilityService {

  /// Lấy danh sách ghế đã được đặt cho một suất chiếu cụ thể
  Future<List<String>> getBookedSeats({
    required int movieId,
    required int cinemaId,
    required String showtime,
    required String format,
    required DateTime date,
  }) async {
    // Trong thực tế, cần query database để lấy ghế đã đặt
    // Hiện tại trả về danh sách giả lập
    return [
      'A1', 'A2', 'B5', 'C3', 'D7', 'E2', 'F4', 'G1', 'H3', 'I5',
      'J2', 'K4', 'L6', 'M1', 'N3', 'O5', 'P2', 'Q4', 'R6', 'S1',
    ];
  }

  /// Kiểm tra ghế có khả dụng không
  Future<bool> isSeatAvailable({
    required String seatLabel,
    required int movieId,
    required int cinemaId,
    required String showtime,
    required String format,
    required DateTime date,
  }) async {
    final bookedSeats = await getBookedSeats(
      movieId: movieId,
      cinemaId: cinemaId,
      showtime: showtime,
      format: format,
      date: date,
    );
    return !bookedSeats.contains(seatLabel);
  }

  /// Đặt giữ ghế tạm thời (reservation)
  Future<bool> reserveSeat({
    required String seatLabel,
    required int movieId,
    required int cinemaId,
    required String showtime,
    required String format,
    required DateTime date,
    required String userId,
  }) async {
    // Trong thực tế, cần implement logic đặt giữ ghế với timeout
    // Hiện tại luôn trả về true
    return true;
  }

  /// Hủy đặt giữ ghế
  Future<void> releaseSeat({
    required String seatLabel,
    required int movieId,
    required int cinemaId,
    required String showtime,
    required String format,
    required DateTime date,
  }) async {
    // Implement logic hủy đặt giữ
  }

  /// Tạo layout ghế cho rạp
  List<Seat> generateSeatLayout() {
    List<Seat> seats = [];

    // Ghế VIP (hàng A-D)
    for (int row = 0; row < 4; row++) {
      String rowLabel = String.fromCharCode(65 + row); // A, B, C, D
      for (int col = 1; col <= 10; col++) {
        seats.add(Seat(
          label: '$rowLabel$col',
          price: 120000, // 120k VND
        ));
      }
    }

    // Ghế thường (hàng E-J)
    for (int row = 4; row < 10; row++) {
      String rowLabel = String.fromCharCode(65 + row); // E, F, G, H, I, J
      for (int col = 1; col <= 12; col++) {
        seats.add(Seat(
          label: '$rowLabel$col',
          price: 80000, // 80k VND
        ));
      }
    }

    // Ghế couple (hàng K)
    String coupleRow = 'K';
    for (int col = 1; col <= 6; col += 2) {
      seats.add(Seat(
        label: '${coupleRow}${col}-${col + 1}',
        price: 180000, // 180k VND cho 2 ghế
      ));
    }

    return seats;
  }
}
