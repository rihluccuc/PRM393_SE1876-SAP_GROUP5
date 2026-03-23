import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/seat_repository.dart';

final seatRepositoryProvider = Provider((ref) {
  return SeatRepository();
});

// 🔥 lấy ghế đã đặt
final bookedSeatsProvider =
FutureProvider.family<List<String>, (String, String)>((ref, params) async {
  final repo = ref.read(seatRepositoryProvider);
  return repo.getBookedSeats(params.$1, params.$2);
});