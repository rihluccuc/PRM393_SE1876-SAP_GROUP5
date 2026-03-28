import 'package:flutter/material.dart';

/// CancelTicketScreen - Màn hình hủy vé
class CancelTicketScreen extends StatelessWidget {
  final String? bookingId;

  const CancelTicketScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hủy vé'),
      ),
      body: Center(
        child: Text('Cancel Ticket Screen - Booking ID: $bookingId'),
      ),
    );
  }
}
