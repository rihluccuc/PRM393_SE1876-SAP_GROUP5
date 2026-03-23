import 'package:flutter/material.dart';

enum BookingStatus {
  confirmed,
  completed,
  cancelled,
  pending,
}

extension BookingStatusExt on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.completed:
        return 'Đã hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.pending:
        return 'Chờ xác nhận';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
        return const Color(0xFF4CAF50);
      case BookingStatus.completed:
        return const Color(0xFF2196F3);
      case BookingStatus.cancelled:
        return const Color(0xFFF44336);
      case BookingStatus.pending:
        return const Color(0xFFFFC107);
    }
  }

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending':
        return BookingStatus.pending;
      default:
        return BookingStatus.pending;
    }
  }

  String get nameString => toString().split('.').last;
}

class Booking {
  final String id;
  final String movieTitle;
  final String movieImage;
  final String cinema;
  final String cinemaHall;
  final String format;
  final DateTime bookingDate;
  final String time;
  final List<String> seats;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
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

  Booking copyWith({
    String? id,
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

  // Chuyển từ Map (SQLite) sang Booking
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      movieTitle: map['movieTitle'],
      movieImage: map['movieImage'],
      cinema: map['cinema'],
      cinemaHall: map['cinemaHall'],
      format: map['format'],
      bookingDate: DateTime.parse(map['bookingDate']),
      time: map['time'],
      seats: (map['seats'] as String).split(','),
      totalPrice: map['totalPrice'] is int ? (map['totalPrice'] as int).toDouble() : map['totalPrice'],
      status: BookingStatusExt.fromString(map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Chuyển từ Booking sang Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'movieImage': movieImage,
      'cinema': cinema,
      'cinemaHall': cinemaHall,
      'format': format,
      'bookingDate': bookingDate.toIso8601String(),
      'time': time,
      'seats': seats.join(','),
      'totalPrice': totalPrice,
      'status': status.nameString,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
