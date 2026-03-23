class Booking {
  final String id;
  final String userId;
  final String showtimeId;
  final List<String> seats;
  final double totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.seats,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      showtimeId: json['showtimeId'],
      seats: List<String>.from(json['seats']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'showtimeId': showtimeId,
      'seats': seats,
      'totalPrice': totalPrice,
    };
  }
}