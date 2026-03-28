import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/cinema.dart';
import '../services/booking_service.dart';
import '../services/cinema_service.dart';
import 'auth_viewmodel.dart';

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
    required String userId,
    required String movieTitle,
    required String movieImage,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final booking = await _bookingService.createBooking(
        userId: userId,
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
