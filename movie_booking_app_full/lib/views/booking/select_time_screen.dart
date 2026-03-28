import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/booking_viewmodel.dart';

/// SelectTimeScreen - Màn hình chọn thời gian chiếu
class SelectTimeScreen extends ConsumerStatefulWidget {
  final int? movieId;
  final int? cinemaId;

  const SelectTimeScreen({
    super.key,
    this.movieId,
    this.cinemaId,
  });

  @override
  ConsumerState<SelectTimeScreen> createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends ConsumerState<SelectTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _availableTimes = [
    '09:00', '11:30', '14:00', '16:30', '19:00', '21:30'
  ];
  final List<String> _formats = ['2D', '3D', 'IMAX'];

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn thời gian'),
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
                _buildStepIndicator('Chọn ghế', false),
                _buildStepConnector(),
                _buildStepIndicator('Thanh toán', false),
              ],
            ),
          ),

          // Date selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn ngày',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(date);

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black,
                            elevation: isSelected ? 4 : 1,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEE', 'vi').format(date).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd').format(date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Format selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn định dạng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _formats.map((format) {
                    final isSelected = bookingState.selectedFormat == format;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(bookingProvider.notifier).selectFormat(format);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black,
                            elevation: isSelected ? 4 : 1,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(format),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Time selector
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn giờ chiếu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _availableTimes.length,
                      itemBuilder: (context, index) {
                        final time = _availableTimes[index];
                        final isSelected = bookingState.selectedTime == time;

                        return ElevatedButton(
                          onPressed: () {
                            ref.read(bookingProvider.notifier).selectTime(time);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black,
                            elevation: isSelected ? 4 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next button
          if (bookingState.selectedTime != null && bookingState.selectedFormat != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookingState.selectedCinema?.name ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${DateFormat('dd/MM/yyyy').format(_selectedDate)} • ${bookingState.selectedTime} • ${bookingState.selectedFormat}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Update selected date
                        ref.read(bookingProvider.notifier).selectDate(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        );

                        Navigator.pushNamed(
                          context,
                          AppRoutes.selectSeat,
                          arguments: {
                            'movieId': widget.movieId,
                            'cinemaId': widget.cinemaId,
                            'showtime': bookingState.selectedTime,
                            'format': bookingState.selectedFormat,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tiếp tục'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
