import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QrCodeScreen - Màn hình mã QR
class QrCodeScreen extends StatelessWidget {
  final String? bookingId;

  const QrCodeScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    if (bookingId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mã QR'),
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin đặt vé'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mã QR vé xem phim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy đưa mã này cho nhân viên soát vé',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: bookingId!,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mã đặt vé: $bookingId',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Lưu ý: Mã QR này chỉ sử dụng được một lần',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
