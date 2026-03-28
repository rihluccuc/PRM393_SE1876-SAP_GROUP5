import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/loading_widget.dart';

/// SelectCinemaScreen - Màn hình chọn rạp chiếu phim
class SelectCinemaScreen extends ConsumerStatefulWidget {
  final int? movieId;

  const SelectCinemaScreen({super.key, this.movieId});

  @override
  ConsumerState<SelectCinemaScreen> createState() => _SelectCinemaScreenState();
}

class _SelectCinemaScreenState extends ConsumerState<SelectCinemaScreen> {
  @override
  void initState() {
    super.initState();
    // Load cinemas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).loadCinemas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn rạp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(bookingProvider.notifier).resetBooking();
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
                _buildStepIndicator('Chọn giờ', false),
                _buildStepConnector(),
                _buildStepIndicator('Chọn ghế', false),
                _buildStepConnector(),
                _buildStepIndicator('Thanh toán', false),
              ],
            ),
          ),

          // Cinema list
          Expanded(
            child: bookingState.isLoading
                ? const LoadingWidget(message: 'Đang tải danh sách rạp...')
                : bookingState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Lỗi: ${bookingState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(bookingProvider.notifier).loadCinemas();
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : bookingState.cinemas.isEmpty
                        ? const Center(child: Text('Không có rạp nào'))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(bookingProvider.notifier).loadCinemas();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: bookingState.cinemas.length,
                              itemBuilder: (context, index) {
                                final cinema = bookingState.cinemas[index];
                                final isSelected = bookingState.selectedCinema?.id == cinema.id;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: isSelected ? 8 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      ref.read(bookingProvider.notifier).selectCinema(cinema);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  cinema.name,
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 28,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  cinema.address,
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                cinema.phone ?? 'Không có số điện thoại',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${cinema.totalHalls} phòng',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade800,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),

          // Next button
          if (bookingState.selectedCinema != null)
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
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.selectTime,
                      arguments: {
                        'movieId': widget.movieId,
                        'cinemaId': bookingState.selectedCinema!.id,
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
