import 'package:flutter/material.dart';

/// Enum trạng thái đặt vé
enum BookingStatus {
  confirmed,  // Đã xác nhận
  completed,  // Đã hoàn thành
  cancelled,  // Đã hủy
  pending,    // Chờ xác nhận
}

/// Extension thêm chức năng cho BookingStatus
extension BookingStatusExt on BookingStatus {
  /// Trả về nhãn tiếng Việt
  String get label {
    switch (this) {
      case BookingStatus.confirmed: return 'Đã xác nhận';
      case BookingStatus.completed: return 'Đã hoàn thành';
      case BookingStatus.cancelled: return 'Đã hủy';
      case BookingStatus.pending:   return 'Chờ xác nhận';
    }
  }

  /// Trả về màu tương ứng
  Color get color {
    switch (this) {
      case BookingStatus.confirmed: return const Color(0xFF4CAF50); // Xanh lá
      case BookingStatus.completed: return const Color(0xFF2196F3); // Xanh dương
      case BookingStatus.cancelled: return const Color(0xFFF44336); // Đỏ
      case BookingStatus.pending:   return const Color(0xFFFFC107); // Vàng
    }
  }

  /// Chuyển từ String sang BookingStatus
  static BookingStatus fromString(String value) {
    switch (value) {
      case 'confirmed': return BookingStatus.confirmed;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      default:          return BookingStatus.pending;
    }
  }

  /// Trả về tên dạng string
  String get nameString => toString().split('.').last;
}

/// Model Booking - Đại diện cho một lần đặt vé
class Booking {
  final String id;              // ID đặt vé (UUID)
  final String userId;          // ID người dùng
  final String movieTitle;      // Tên phim
  final String movieImage;      // Ảnh poster phim
  final String cinema;          // Tên rạp
  final String cinemaHall;      // Tên phòng chiếu
  final String format;          // Định dạng: 2D, 3D, IMAX
  final DateTime bookingDate;   // Ngày xem phim
  final String time;            // Giờ chiếu
  final List<String> seats;     // Danh sách ghế đã chọn
  final double totalPrice;      // Tổng tiền
  final BookingStatus status;   // Trạng thái đặt vé
  final DateTime createdAt;     // Ngày tạo booking

  Booking({
    required this.id,
    required this.userId,
    required this.movieTitle,
    required this.movieImage,
    required this.cinema,
    required this.cinemaHall,
    required this.format,
    required this.bookingDate,
    required this.time,
    required this.seats,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  /// Chuyển từ Map (SQLite) sang Booking
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      movieTitle: map['movieTitle'],
      movieImage: map['movieImage'],
      cinema: map['cinema'],
      cinemaHall: map['cinemaHall'],
      format: map['format'],
      bookingDate: DateTime.parse(map['bookingDate']),
      time: map['time'],
      seats: (map['seats'] as String).split(','), // "A1,A2" -> ["A1","A2"]
      totalPrice: map['totalPrice'] is int
          ? (map['totalPrice'] as int).toDouble()
          : map['totalPrice'],
      status: BookingStatusExt.fromString(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Chuyển từ Booking sang Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'movieTitle': movieTitle,
      'movieImage': movieImage,
      'cinema': cinema,
      'cinemaHall': cinemaHall,
      'format': format,
      'bookingDate': bookingDate.toIso8601String(),
      'time': time,
      'seats': seats.join(','), // ["A1","A2"] -> "A1,A2"
      'totalPrice': totalPrice,
      'status': status.nameString,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Tạo bản sao Booking
  Booking copyWith({
    String? id,
    String? userId,
    String? movieTitle,
    String? movieImage,
    String? cinema,
    String? cinemaHall,
    String? format,
    DateTime? bookingDate,
    String? time,
    List<String>? seats,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieTitle: movieTitle ?? this.movieTitle,
      movieImage: movieImage ?? this.movieImage,
      cinema: cinema ?? this.cinema,
      cinemaHall: cinemaHall ?? this.cinemaHall,
      format: format ?? this.format,
      bookingDate: bookingDate ?? this.bookingDate,
      time: time ?? this.time,
      seats: seats ?? this.seats,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
