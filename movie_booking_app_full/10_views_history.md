# 📋 Views - History (Quan)

## Mô Tả
Module History gồm 4 màn hình do **Quan** phụ trách:
1. **Booking History** - Lịch sử đặt vé
2. **Ticket Detail** - Chi tiết vé
3. **QR Code Screen** - Mã QR vé
4. **Cancel Ticket** - Hủy vé

---

## File: `lib/views/history/booking_history_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../models/booking.dart';
import 'package:intl/intl.dart';

/// BookingHistoryScreen - Danh sách lịch sử đặt vé
/// Người phụ trách: Quan
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});
  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch Sử Đặt Vé')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.bookings.isEmpty
              ? const Center(child: Text('Chưa có lịch sử đặt vé'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  itemBuilder: (_, i) {
                    final b = state.bookings[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.movie, color: Colors.red, size: 36),
                        title: Text(b.movieTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${b.cinema} • ${b.time}'),
                          Text('${formatter.format(b.totalPrice)}đ'),
                          // Badge trạng thái
                          Chip(
                            label: Text(b.status.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: b.status.color,
                            padding: EdgeInsets.zero,
                          ),
                        ]),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/ticket-detail', arguments: b.id),
                      ),
                    );
                  },
                ),
    );
  }
}
```

---

## File: `lib/views/history/ticket_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/history_viewmodel.dart';
import 'package:intl/intl.dart';

/// TicketDetailScreen - Chi tiết vé đã đặt
/// Người phụ trách: Quan
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key});
  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bookingId = ModalRoute.of(context)!.settings.arguments as String;
    ref.read(historyProvider.notifier).loadBookingDetail(bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(historyProvider).selectedBooking;
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Vé')),
      body: booking == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                  // ── Tên phim ──
                  Text(booking.movieTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // ── Badge trạng thái ──
                  Chip(label: Text(booking.status.label, style: const TextStyle(color: Colors.white)),
                      backgroundColor: booking.status.color),
                  const Divider(height: 32),
                  // ── Thông tin ──
                  _row('🎬 Rạp', booking.cinema),
                  _row('🏠 Phòng', booking.cinemaHall),
                  _row('📅 Ngày', DateFormat('dd/MM/yyyy').format(booking.bookingDate)),
                  _row('🕐 Giờ', booking.time),
                  _row('🎞️ Định dạng', booking.format),
                  _row('💺 Ghế', booking.seats.join(', ')),
                  const Divider(),
                  _row('💰 Tổng tiền', '${formatter.format(booking.totalPrice)}đ'),
                  const SizedBox(height: 24),
                  // ── Nút QR Code ──
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/qr-code', arguments: booking.id),
                    icon: const Icon(Icons.qr_code), label: const Text('Xem Mã QR'),
                  )),
                  const SizedBox(height: 8),
                  // ── Nút Hủy vé ──
                  if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed)
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/cancel-ticket', arguments: booking.id),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text('Hủy Vé', style: TextStyle(color: Colors.red)),
                    )),
                ])),
              ),
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
    ));
  }
}
```

---

## File: `lib/views/history/qr_code_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QRCodeScreen - Hiển thị mã QR cho vé
/// Người phụ trách: Quan
class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy bookingId từ arguments
    final bookingId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Mã QR')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // ── QR Code ──
          QrImageView(
            data: 'BOOKING:$bookingId',  // Dữ liệu trong QR
            version: QrVersions.auto,
            size: 250,
          ),
          const SizedBox(height: 24),
          // ── Mã booking ──
          Text('Mã vé: ${bookingId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Đưa mã QR này cho nhân viên tại quầy',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          // ── Nút đóng ──
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Đóng'),
          ),
        ]),
      ),
    );
  }
}
```

---

## File: `lib/views/history/cancel_ticket_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/history_viewmodel.dart';

/// CancelTicketScreen - Hủy vé
/// Người phụ trách: Quan
class CancelTicketScreen extends ConsumerWidget {
  const CancelTicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Hủy Vé')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // ── Icon cảnh báo ──
          const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text('Xác nhận hủy vé?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Vé đã hủy sẽ không thể khôi phục.\nTiền sẽ được hoàn lại trong 3-5 ngày làm việc.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          // ── Nút Hủy vé ──
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: () async {
              final success = await ref.read(historyProvider.notifier).cancelBooking(bookingId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy vé thành công')));
                Navigator.popUntil(context, (route) => route.settings.name == '/booking-history' || route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('XÁC NHẬN HỦY VÉ'),
          )),
          const SizedBox(height: 12),
          // ── Nút Quay lại ──
          SizedBox(width: double.infinity, height: 48, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('QUAY LẠI'),
          )),
        ]),
      ),
    );
  }
}
```
