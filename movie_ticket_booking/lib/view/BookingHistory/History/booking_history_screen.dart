import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/booking_model.dart';
import '../../../viewmodels/BookingHistoryVM/booking_history_provider.dart';
import 'ticket_detail_screen.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE71D36),
        title: const Text(
          'Lịch sử đặt vé',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE71D36),
              labelColor: const Color(0xFFE71D36),
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Sắp diễn ra'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Đã hủy'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllBookingsTab(),
                _buildUpcomingBookingsTab(),
                _buildCompletedBookingsTab(),
                _buildCancelledBookingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBookingsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final bookings = ref.watch(bookingHistoryProvider);
        if (bookings.isEmpty) {
          return _buildEmptyState('Không có vé đặt nào');
        }
        return _buildBookingsList(bookings.reversed.toList());
      },
    );
  }

  Widget _buildUpcomingBookingsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final bookings = ref.watch(upcomingBookingsProvider);
        if (bookings.isEmpty) {
          return _buildEmptyState('Không có vé sắp diễn ra');
        }
        return _buildBookingsList(bookings);
      },
    );
  }

  Widget _buildCompletedBookingsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final bookings = ref.watch(completedBookingsProvider);
        if (bookings.isEmpty) {
          return _buildEmptyState('Không có vé hoàn thành');
        }
        return _buildBookingsList(bookings);
      },
    );
  }

  Widget _buildCancelledBookingsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final bookings = ref.watch(bookingsByStatusProvider(BookingStatus.cancelled));
        if (bookings.isEmpty) {
          return _buildEmptyState('Không có vé đã hủy');
        }
        return _buildBookingsList(bookings.reversed.toList());
      },
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(context, bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(bookingId: booking.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: booking.status.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã vé: ${booking.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.status.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: booking.status.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: booking.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.format,
                      style: TextStyle(
                        fontSize: 12,
                        color: booking.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Movie info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster
                  Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        booking.movieImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.movie,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Movie details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.movieTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: booking.cinema,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          icon: Icons.event_seat_outlined,
                          label: booking.cinemaHall,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          icon: Icons.access_time_outlined,
                          label: _formatDateTime(booking.bookingDate, booking.time),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            // Footer with price and action
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.totalPrice.toStringAsFixed(0)}₫',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE71D36),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE71D36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailScreen(bookingId: booking.id),
                        ),
                      );
                    },
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date, String time) {
    final dayOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    final day = date.day;
    final month = date.month;
    final weekday = dayOfWeek[date.weekday - 1];
    return '$weekday, $day/$month - $time';
  }
}

