import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

/// TicketDetailScreen - Màn hình chi tiết vé
class TicketDetailScreen extends StatelessWidget {
  final String? bookingId;

  const TicketDetailScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    // Mock booking data - in real app, fetch from database
    final mockBooking = {
      'id': bookingId ?? '12345',
      'movieTitle': 'Avengers: Endgame',
      'cinema': 'CGV Vincom Center',
      'date': DateTime.now(),
      'time': '20:00',
      'seats': ['A1', 'A2'],
      'format': '2D',
      'totalPrice': 150000,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ticket Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Movie Title
                    Text(
                      mockBooking['movieTitle'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Cinema
                    Text(
                      mockBooking['cinema'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date & Time
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(mockBooking['date'] as DateTime)} • ${mockBooking['time']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Format & Seats
                    Text(
                      '${mockBooking['format']} • Ghế: ${(mockBooking['seats'] as List<String>).join(', ')}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Text(
                      'Tổng tiền: ${NumberFormat('#,###').format(mockBooking['totalPrice'])} VND',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Mã QR vé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: 'booking_${mockBooking['id']}',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${mockBooking['id']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Hãy đến rạp trước giờ chiếu 30 phút\n'
                    '• Mang theo mã QR hoặc ID vé\n'
                    '• Nhân viên sẽ quét mã để xác nhận',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
