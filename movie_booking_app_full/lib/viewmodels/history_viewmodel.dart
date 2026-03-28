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
