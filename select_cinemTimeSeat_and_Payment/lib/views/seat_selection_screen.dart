import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_screen.dart';
import '../viewmodels/seat_viewmodel.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  final String showTime;
  final String cinemaName;

  const SeatSelectionScreen({
    super.key,
    required this.showTime,
    required this.cinemaName,
  });

  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState
    extends ConsumerState<SeatSelectionScreen> {
  final int rows = 8;
  final int cols = 8;

  Set<String> selectedSeats = {};

  // 🔥 giá ghế cố định
  final int seatPrice = 50000;

  // 🔥 tính tổng tiền
  int get totalPrice => selectedSeats.length * seatPrice;

  @override
  Widget build(BuildContext context) {
    final bookedSeatsAsync = ref.watch(
      bookedSeatsProvider((
      widget.cinemaName.trim(),
      widget.showTime.trim(),
      )),
    );

    return bookedSeatsAsync.when(
      data: (bookedSeats) => _buildScaffold(bookedSeats),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
    );
  }

  Widget _buildScaffold(List<String> bookedSeats) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildScreenLabel(),
          const SizedBox(height: 12),
          Expanded(
            child: _buildSeatGrid(bookedSeats),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.cinemaName,
              style: const TextStyle(color: Colors.white)),
          Text(
            "Suất chiếu: ${widget.showTime}",
            style:
            const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenLabel() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "MÀN HÌNH",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSeatGrid(List<String> bookedSeats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          int row = index ~/ cols + 1;
          int col = index % cols;

          String seatLabel =
              "$row${String.fromCharCode(65 + col)}";

          return _buildSeatItem(seatLabel, bookedSeats);
        },
      ),
    );
  }

  Widget _buildSeatItem(
      String seatLabel, List<String> bookedSeats) {
    bool isSelected = selectedSeats.contains(seatLabel);
    bool isBooked = bookedSeats.contains(seatLabel);

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
        setState(() {
          if (isSelected) {
            selectedSeats.remove(seatLabel);
          } else {
            selectedSeats.add(seatLabel);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey[600] // ghế đã đặt
              : isSelected
              ? Colors.red
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            seatLabel,
            style: TextStyle(
              fontSize: 12,
              color: isBooked || isSelected
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đã chọn: ${selectedSeats.length}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${_formatMoney(totalPrice)} VND",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: selectedSeats.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      cinemaName:
                      widget.cinemaName.trim(),
                      showTime:
                      widget.showTime.trim(),
                      selectedSeats:
                      selectedSeats.toList(),
                      seatPrice: seatPrice, // 🔥 thêm dòng này
                    ),
                  ),
                );
              },
              child: const Text(
                "Đặt Vé",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(int money) {
    return money
        .toString()
        .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',');
  }
}