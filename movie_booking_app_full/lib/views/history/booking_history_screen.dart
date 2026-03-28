import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../widgets/loading_widget.dart';
import '../../models/booking.dart';

/// BookingHistoryScreen - Màn hình lịch sử đặt vé
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedStatus = 'all'; // all, confirmed, completed, cancelled

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load booking history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đặt vé'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã xem'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(historyState.bookings, 'Tất cả'),
          _buildBookingList(_getUpcomingBookings(historyState.bookings), 'Sắp tới'),
          _buildBookingList(_getPastBookings(historyState.bookings), 'Đã xem'),
        ],
      ),
    );
  }

  List<Booking> _getUpcomingBookings(List<Booking> bookings) {
    final now = DateTime.now();
    return bookings.where((booking) {
      final bookingDateTime = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        int.parse(booking.time.split(':')[0]),
        int.parse(booking.time.split(':')[1]),
      );
      return bookingDateTime.isAfter(now) &&
             (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending);
    }).toList();
  }

  List<Booking> _getPastBookings(List<Booking> bookings) {
    final now = DateTime.now();
    return bookings.where((booking) {
      final bookingDateTime = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        int.parse(booking.time.split(':')[0]),
        int.parse(booking.time.split(':')[1]),
      );
      return bookingDateTime.isBefore(now) ||
             booking.status == BookingStatus.completed ||
             booking.status == BookingStatus.cancelled;
    }).toList();
  }

  Widget _buildBookingList(List<Booking> bookings, String emptyMessage) {
    final historyState = ref.watch(historyProvider);

    // Apply search and filter
    final filteredBookings = _filterBookings(bookings);

    if (historyState.isLoading) {
      return const LoadingWidget(message: 'Đang tải lịch sử...');
    }

    if (historyState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: ${historyState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(historyProvider.notifier).loadHistory();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên phim...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // Filter dropdown
              Row(
                children: [
                  const Text('Trạng thái:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                        DropdownMenuItem(value: 'confirmed', child: Text('Đã xác nhận')),
                        DropdownMenuItem(value: 'completed', child: Text('Đã hoàn thành')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Booking list
        Expanded(
          child: filteredBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.movie, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Không có vé nào $emptyMessage'),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy đặt vé xem phim ngay!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(historyProvider.notifier).loadHistory();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    return bookings.where((booking) {
      // Search filter
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          booking.movieTitle.toLowerCase().contains(searchQuery) ||
          booking.cinema.toLowerCase().contains(searchQuery);

      // Status filter
      final matchesStatus = _selectedStatus == 'all' ||
          booking.status.nameString == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildBookingCard(Booking booking) {
    final isUpcoming = booking.bookingDate.isAfter(DateTime.now()) ||
                      (booking.bookingDate.isAtSameMomentAs(DateTime.now()) &&
                       booking.status == BookingStatus.confirmed);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.ticketDetail,
            arguments: booking.id,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.movieTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: booking.status.color),
                    ),
                    child: Text(
                      booking.status.label,
                      style: TextStyle(
                        color: booking.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Cinema and time
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.cinema,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(booking.bookingDate)} • ${booking.time} • ${booking.format}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Ghế: ${booking.seats.join(', ')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Price and actions
              Row(
                children: [
                  Text(
                    '${NumberFormat('#,###').format(booking.totalPrice)} VND',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (isUpcoming && booking.status != BookingStatus.cancelled)
                    TextButton.icon(
                      onPressed: () {
                        _showCancelDialog(booking);
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Hủy vé'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.qrCode,
                        arguments: booking.id,
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    tooltip: 'Mã QR',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(Booking booking) {
    // Check if cancellation is allowed (not within 2 hours of showtime)
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.bookingDate.year,
      booking.bookingDate.month,
      booking.bookingDate.day,
      int.parse(booking.time.split(':')[0]),
      int.parse(booking.time.split(':')[1]),
    );

    final timeUntilShow = bookingDateTime.difference(now);
    final canCancel = timeUntilShow.inHours >= 2 && booking.status != BookingStatus.cancelled;

    if (!canCancel) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Không thể hủy vé'),
          content: const Text('Không thể hủy vé trong vòng 2 giờ trước giờ chiếu hoặc vé đã bị hủy.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy vé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn hủy vé này?'),
            const SizedBox(height: 8),
            Text(
              'Phim: ${booking.movieTitle}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('Rạp: ${booking.cinema}'),
            Text('Thời gian: ${DateFormat('dd/MM/yyyy').format(booking.bookingDate)} ${booking.time}'),
            Text('Ghế: ${booking.seats.join(', ')}'),
            const SizedBox(height: 8),
            const Text(
              'Lưu ý: Vé đã hủy sẽ không được hoàn tiền.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await ref.read(historyProvider.notifier).cancelBooking(booking.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy vé thành công')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );
  }
}
