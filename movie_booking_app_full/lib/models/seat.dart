/// Model Seat - Đại diện cho 1 ghế ngồi trong phòng chiếu
class Seat {
  final String label; // Nhãn ghế: "A1", "B3", "C5"...
  final int price;    // Giá ghế (VND)

  Seat({
    required this.label,
    required this.price,
  });
}
