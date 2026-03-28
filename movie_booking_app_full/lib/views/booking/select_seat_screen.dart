import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_routes.dart';
import '../../config/app_constants.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../models/seat.dart';
import '../../services/seat_availability_service.dart';

/// SelectSeatScreen - Màn hình chọn ghế ngồi
class SelectSeatScreen extends ConsumerStatefulWidget {
  final int? movieId;
  final int? cinemaId;
  final String? showtime;
  final String? format;

  const SelectSeatScreen({
    super.key,
    this.movieId,
    this.cinemaId,
    this.showtime,
    this.format,
  });

  @override
  ConsumerState<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends ConsumerState<SelectSeatScreen> {
  // Mock seat layout (10 rows x 12 seats per row)
  late List<List<Seat>> _seats;
  List<String> _bookedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeats();
    _loadBookedSeats();
  }

  void _initializeSeats() {
    _seats = [];
    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

    for (int i = 0; i < rows.length; i++) {
      final rowSeats = <Seat>[];
      for (int j = 1; j <= 12; j++) {
        final seatLabel = '${rows[i]}$j';
        int price;

        // Different pricing based on row
        if (i < 3) { // Front rows (A, B, C)
          price = AppConstants.seatPriceNormal;
        } else if (i < 7) { // Middle rows (D, E, F, G)
          price = AppConstants.seatPriceVIP;
        } else { // Back rows (H, I, J)
          price = AppConstants.seatPriceCouple;
        }

        rowSeats.add(Seat(label: seatLabel, price: price));
      }
      _seats.add(rowSeats);
    }
  }

  Future<void> _loadBookedSeats() async {
    if (widget.movieId == null || widget.cinemaId == null || widget.showtime == null) return;

    final service = SeatAvailabilityService();
    try {
      final bookedSeats = await service.getBookedSeats(
        movieId: widget.movieId!,
        cinemaId: widget.cinemaId!,
        showtime: widget.showtime!,
        format: widget.format ?? '2D',
        date: DateTime.now(), // Use current date for demo
      );
      setState(() {
        _bookedSeats = bookedSeats;
      });
    } catch (e) {
      // Handle error
      print('Error loading booked seats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ghế'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                _buildStepIndicator('Chọn rạp', true),
                _buildStepConnector(),
                _buildStepIndicator('Chọn giờ', true),
                _buildStepConnector(),
                _buildStepIndicator('Chọn ghế', true),
                _buildStepConnector(),
                _buildStepIndicator('Thanh toán', false),
              ],
            ),
          ),

          // Screen indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'MÀN HÌNH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Seat grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Seat grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Row labels and seats
                        for (int rowIndex = 0; rowIndex < _seats.length; rowIndex++) ...[
                          Row(
                            children: [
                              // Row label
                              SizedBox(
                                width: 24,
                                child: Text(
                                  String.fromCharCode(65 + rowIndex), // A, B, C...
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Seats in row
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: _seats[rowIndex].map((seat) {
                                    final isSelected = bookingState.selectedSeats.contains(seat.label);
                                    final isBooked = _bookedSeats.contains(seat.label);
                                    return _buildSeatButton(seat, isSelected, isBooked);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          if (rowIndex < _seats.length - 1) const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chú thích',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem(Colors.white, 'Còn trống'),
                            _buildLegendItem(Theme.of(context).primaryColor, 'Đã chọn'),
                            _buildLegendItem(Colors.grey, 'Đã đặt'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Giá vé:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Ghế thường: ${AppConstants.seatPriceNormal.toStringAsFixed(0)} VND\n'
                          '• Ghế VIP: ${AppConstants.seatPriceVIP.toStringAsFixed(0)} VND\n'
                          '• Ghế đôi: ${AppConstants.seatPriceCouple.toStringAsFixed(0)} VND',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom summary and next button
          if (bookingState.selectedSeats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Summary
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bookingState.selectedSeats.length} ghế đã chọn',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                bookingState.selectedSeats.join(', '),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${bookingState.totalPrice.toStringAsFixed(0)} VND',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.payment,
                          arguments: {
                            'bookingData': {
                              'movieId': widget.movieId,
                              'cinemaId': widget.cinemaId,
                              'showtime': widget.showtime,
                              'format': widget.format,
                              'seats': bookingState.selectedSeats,
                              'totalPrice': bookingState.totalPrice,
                            },
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tiếp tục thanh toán'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeatButton(Seat seat, bool isSelected, bool isBooked) {
    Color seatColor;
    if (isSelected) {
      seatColor = Theme.of(context).primaryColor;
    } else if (isBooked) {
      seatColor = Colors.grey;
    } else {
      seatColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        if (!isBooked) {
          ref.read(bookingProvider.notifier).toggleSeat(seat.label, seat.price);
        }
      },
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            seat.label.substring(1), // Remove row letter, show only number
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
            ),
            child: Icon(
              isActive ? Icons.check : Icons.circle,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[500],
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
