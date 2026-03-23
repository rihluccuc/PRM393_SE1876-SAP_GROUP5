import 'package:flutter/material.dart';
import 'cinema_list_screen.dart';
import '../viewmodels/seat_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRPaymentScreen extends ConsumerWidget {
  final int amount;
  final String cinemaName;
  final String showTime;
  final List<String> selectedSeats;

  const QRPaymentScreen({
    super.key,
    required this.amount,
    required this.cinemaName,
    required this.showTime,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ================= 🔥 THÔNG TIN NGÂN HÀNG (SỬA Ở ĐÂY) =================
    const String bankCode = "970422"; // 👉 MÃ NGÂN HÀNG (VD: MB = 970422, VCB = 970436)
    const String accountNumber = "0000538527191"; // 👉 SỐ TÀI KHOẢN CỦA BẠN
    const String accountName = "HOANG KHAC MINH DUC"; // 👉 TÊN CHỦ TÀI KHOẢN (VIẾT KHÔNG DẤU)
    // ======================================================================

    final String qrUrl =
        "https://img.vietqr.io/image/$bankCode-$accountNumber-compact2.png"
        "?amount=$amount"
        "&addInfo=DatVe_${cinemaName}_${showTime}"
        "&accountName=$accountName";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Quét mã QR để thanh toán"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildQRCard(qrUrl),
                  const SizedBox(height: 30),
                  _buildAmountCard(),
                ],
              ),
            ),
          ),
          _buildPaymentButton(context, ref),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.qr_code_2,
            size: 48,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Mở app ngân hàng để quét",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        const Text(
          "Quét mã QR để thanh toán",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ================= QR =================
  Widget _buildQRCard(String qrUrl) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Image.network(
          qrUrl,
          width: 220,
          height: 220,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 220,
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 220,
              height: 220,
              child: Center(
                child: Text(
                  "Không thể tải mã QR\nVui lòng thử lại",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= AMOUNT =================
  Widget _buildAmountCard() {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Số tiền cần thanh toán"),
            const SizedBox(height: 8),
            Text(
              "${_formatMoney(amount)} VND",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _buildPaymentButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () => _handlePayment(context, ref),
          child: const Text(
            "Tôi đã thanh toán",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC =================
  Future<void> _handlePayment(
      BuildContext context,
      WidgetRef ref,
      ) async {
    try {
      final repo = ref.read(seatRepositoryProvider);

      final cleanCinema = cinemaName.trim();
      final cleanShowTime = showTime.trim();

      await repo.bookSeats(
        cleanCinema,
        cleanShowTime,
        selectedSeats,
      );

      ref.invalidate(
        bookedSeatsProvider((cleanCinema, cleanShowTime)),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 ICON SUCCESS
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 16),

                // 🔥 TITLE
                const Text(
                  "Thanh toán thành công!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // 🔥 SUBTEXT
                Text(
                  "Bạn đã đặt ${selectedSeats.length} ghế\nChúc bạn xem phim vui vẻ 🎬",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // 🔥 BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const CinemaListScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text("Không thể đặt ghế: $e"),
        ),
      );
    }
  }

  String _formatMoney(int money) {
    return money.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }
}