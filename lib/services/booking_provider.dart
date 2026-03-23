import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';

// Mock data provider - trong thực tế sẽ được thay bằng API calls
final mockBookingsProvider = Provider<List<Booking>>((ref) {
  return [
    Booking(
      id: 'BK001',
      movieTitle: 'Avatar: The Way of Water',
      movieImage: 'https://via.placeholder.com/200x300?text=Avatar',
      cinema: 'CGV Landmark 81',
      cinemaHall: 'Rạp 5',
      format: 'IMAX 3D',
      bookingDate: DateTime.now().add(const Duration(days: 2)),
      time: '19:30',
      seats: ['A5', 'A6', 'A7'],
      totalPrice: 450000,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Booking(
      id: 'BK002',
      movieTitle: 'Dune: Part Two',
      movieImage: 'https://via.placeholder.com/200x300?text=Dune',
      cinema: 'CGV Crescent Mall',
      cinemaHall: 'Rạp 3',
      format: '2D',
      bookingDate: DateTime.now().subtract(const Duration(days: 5)),
      time: '14:15',
      seats: ['B2', 'B3'],
      totalPrice: 300000,
      status: BookingStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Booking(
      id: 'BK003',
      movieTitle: 'Oppenheimer',
      movieImage: 'https://via.placeholder.com/200x300?text=Oppenheimer',
      cinema: 'CGV Tao Đàn',
      cinemaHall: 'Rạp 7',
      format: '2D',
      bookingDate: DateTime.now().subtract(const Duration(days: 20)),
      time: '18:45',
      seats: ['C1', 'C2', 'C3', 'C4'],
      totalPrice: 400000,
      status: BookingStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Booking(
      id: 'BK004',
      movieTitle: 'Killers of the Flower Moon',
      movieImage: 'https://via.placeholder.com/200x300?text=Killers',
      cinema: 'CGV Vincom Center',
      cinemaHall: 'Rạp 2',
      format: '3D',
      bookingDate: DateTime.now().add(const Duration(days: 10)),
      time: '20:00',
      seats: ['D5', 'D6'],
      totalPrice: 320000,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    ),
  ];
});

// Provider để lấy danh sách booking của user
final userBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(mockBookingsProvider);
  return bookings;
});

// Provider để lấy chi tiết một booking
final bookingDetailProvider = Provider.family<Booking?, String>((ref, bookingId) {
  final bookings = ref.watch(mockBookingsProvider);
  try {
    return bookings.firstWhere((booking) => booking.id == bookingId);
  } catch (e) {
    return null;
  }
});

// Provider để lọc booking theo trạng thái
final bookingsByStatusProvider = Provider.family<List<Booking>, BookingStatus>((ref, status) {
  final bookings = ref.watch(mockBookingsProvider);
  return bookings.where((booking) => booking.status == status).toList();
});

// Provider để lấy booking sắp tới
final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(mockBookingsProvider);
  final now = DateTime.now();
  return bookings
      .where((booking) => booking.bookingDate.isAfter(now) && booking.status != BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
});

// Provider để lấy booking đã qua
final pastBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(mockBookingsProvider);
  final now = DateTime.now();
  return bookings
      .where((booking) => booking.bookingDate.isBefore(now) || booking.status == BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
});

