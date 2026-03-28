# 🎫 Views - Booking (Duc)

## Mô Tả
Module Booking gồm 4 màn hình do **Duc** phụ trách:
1. **Select Cinema** - Chọn rạp chiếu
2. **Select Time** - Chọn ngày giờ chiếu
3. **Select Seat** - Chọn ghế ngồi
4. **Payment** - Thanh toán

---

## File: `lib/views/booking/select_cinema_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/booking_viewmodel.dart';

/// SelectCinemaScreen - Chọn rạp chiếu phim
/// Người phụ trách: Duc
class SelectCinemaScreen extends ConsumerStatefulWidget {
  const SelectCinemaScreen({super.key});
  @override
  ConsumerState<SelectCinemaScreen> createState() => _SelectCinemaScreenState();
}

class _SelectCinemaScreenState extends ConsumerState<SelectCinemaScreen> {
  @override
  void initState() {
    super.initState();
    // Load danh sách rạp
    Future.microtask(() => ref.read(bookingProvider.notifier).loadCinemas());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Rạp Chiếu')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cinemas.length,
              itemBuilder: (_, i) {
                final cinema = state.cinemas[i];
                // Rạp đang chọn có viền đỏ
                final isSelected = state.selectedCinema?.id == cinema.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSelected ? Colors.red : Colors.transparent, width: 2),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.theaters, color: Colors.red, size: 36),
                    title: Text(cinema.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cinema.address),
                      Text('${cinema.totalHalls} phòng chiếu', style: TextStyle(color: Colors.grey[600])),
                    ]),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.red) : null,
                    onTap: () {
                      // Chọn rạp → chuyển sang chọn giờ
                      ref.read(bookingProvider.notifier).selectCinema(cinema);
                      Navigator.pushNamed(context, '/select-time');
                    },
                  ),
                );
              },
            ),
    );
  }
}
```

---

## File: `lib/views/booking/select_time_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/booking_viewmodel.dart';

/// SelectTimeScreen - Chọn ngày giờ chiếu
/// Người phụ trách: Duc
class SelectTimeScreen extends ConsumerWidget {
  const SelectTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);

    // Danh sách ngày (7 ngày tiếp theo)
    final dates = List.generate(7, (i) {
      final d = DateTime.now().add(Duration(days: i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });

    // Giờ chiếu mẫu
    const times = ['09:00', '11:30', '14:00', '16:30', '19:00', '21:30'];
    // Định dạng
    const formats = ['2D', '3D', 'IMAX'];

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Suất Chiếu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Chọn ngày ──
          const Text('📅 Chọn ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final isSelected = state.selectedDate == dates[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(dates[i].substring(5)), // Hiện MM-DD
                    selected: isSelected,
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (_) => ref.read(bookingProvider.notifier).selectDate(dates[i]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // ── Chọn format ──
          const Text('🎞️ Định dạng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: formats.map((f) {
            final isSelected = state.selectedFormat == f;
            return ChoiceChip(
              label: Text(f),
              selected: isSelected,
              selectedColor: Colors.red,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (_) => ref.read(bookingProvider.notifier).selectFormat(f),
            );
          }).toList()),
          const SizedBox(height: 24),

          // ── Chọn giờ ──
          const Text('🕐 Chọn giờ chiếu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: times.map((t) {
            final isSelected = state.selectedTime == t;
            return ElevatedButton(
              onPressed: () {
                ref.read(bookingProvider.notifier).selectTime(t);
                Navigator.pushNamed(context, '/select-seat');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.red : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black,
              ),
              child: Text(t),
            );
          }).toList()),
        ]),
      ),
    );
  }
}
```

---

## File: `lib/views/booking/select_seat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../models/seat.dart';
import 'package:intl/intl.dart';

/// SelectSeatScreen - Chọn ghế ngồi
/// Người phụ trách: Duc
class SelectSeatScreen extends ConsumerWidget {
  const SelectSeatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);
    final formatter = NumberFormat('#,###', 'vi_VN');

    // Tạo sơ đồ ghế mẫu (8 hàng x 10 cột)
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final seatData = <Seat>[];
    for (var row in rows) {
      for (var col = 1; col <= 10; col++) {
        // Hàng A-B: VIP (100k), còn lại: thường (75k)
        final price = (row == 'A' || row == 'B') ? 100000 : 75000;
        seatData.add(Seat(label: '$row$col', price: price));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Ghế')),
      body: Column(children: [
        // ── Màn hình chiếu ──
        Container(
          margin: const EdgeInsets.all(16),
          height: 30,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
          child: const Center(child: Text('MÀN HÌNH', style: TextStyle(color: Colors.grey))),
        ),
        // ── Chú thích ──
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(Colors.grey[300]!, 'Trống'),
          const SizedBox(width: 12),
          _legend(Colors.red, 'Đã chọn'),
          const SizedBox(width: 12),
          _legend(Colors.amber, 'VIP'),
        ])),
        const SizedBox(height: 8),
        // ── Sơ đồ ghế ──
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10, mainAxisSpacing: 4, crossAxisSpacing: 4,
            ),
            itemCount: seatData.length,
            itemBuilder: (_, i) {
              final seat = seatData[i];
              final isSelected = state.selectedSeats.contains(seat.label);
              final isVip = seat.label.startsWith('A') || seat.label.startsWith('B');
              return GestureDetector(
                onTap: () => ref.read(bookingProvider.notifier).toggleSeat(seat.label, seat.price),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : (isVip ? Colors.amber[100] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text(seat.label, style: TextStyle(fontSize: 8,
                      color: isSelected ? Colors.white : Colors.black))),
                ),
              );
            },
          ),
        ),
        // ── Tổng tiền + Nút tiếp tục ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)]),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ghế: ${state.selectedSeats.join(", ")}', style: const TextStyle(fontSize: 14)),
              Text('Tổng: ${formatter.format(state.totalPrice)}đ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            ]),
            const Spacer(),
            ElevatedButton(
              onPressed: state.selectedSeats.isEmpty ? null : () => Navigator.pushNamed(context, '/payment'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Tiếp tục'),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12))]);
  }
}
```

---

## File: `lib/views/booking/payment_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../models/movie.dart';
import 'package:intl/intl.dart';

/// PaymentScreen - Thanh toán
/// Người phụ trách: Duc
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh Toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Thông tin đặt vé ──
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Thông tin vé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _infoRow('Rạp', state.selectedCinema?.name ?? ''),
            _infoRow('Ngày', state.selectedDate ?? ''),
            _infoRow('Giờ', state.selectedTime ?? ''),
            _infoRow('Định dạng', state.selectedFormat ?? '2D'),
            _infoRow('Ghế', state.selectedSeats.join(', ')),
            const Divider(),
            _infoRow('Tổng tiền', '${formatter.format(state.totalPrice)}đ', isBold: true),
          ]))),
          const SizedBox(height: 16),

          // ── Phương thức thanh toán ──
          const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _paymentOption(Icons.account_balance_wallet, 'Ví MoMo'),
          _paymentOption(Icons.credit_card, 'Thẻ ngân hàng'),
          _paymentOption(Icons.money, 'Tiền mặt tại quầy'),
          const SizedBox(height: 24),

          // ── Nút xác nhận ──
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: () async {
              final booking = await ref.read(bookingProvider.notifier).confirmBooking(
                movieTitle: 'Phim đã chọn', movieImage: '',
              );
              if (booking != null && context.mounted) {
                // Reset booking state
                ref.read(bookingProvider.notifier).resetBooking();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt vé thành công! 🎉')));
                Navigator.pushNamedAndRemoveUntil(context, '/movie-list', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('XÁC NHẬN THANH TOÁN', style: TextStyle(fontSize: 16)),
          )),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.grey[600])),
      Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold ? Colors.red : Colors.black, fontSize: isBold ? 18 : 14)),
    ]));
  }

  Widget _paymentOption(IconData icon, String label) {
    return Card(child: ListTile(leading: Icon(icon, color: Colors.red), title: Text(label),
        trailing: const Icon(Icons.chevron_right)));
  }
}
```
