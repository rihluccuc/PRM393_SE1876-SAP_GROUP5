import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../repositories/booking_repository.dart';
import '../../services/notification_service.dart';

/// PaymentScreen - Màn hình thanh toán
class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? bookingData;

  const PaymentScreen({super.key, this.bookingData});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _paymentMethod = 'momo'; // momo, zalopay, bank, cash
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user info if available
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      _nameController.text = authState.user!.name;
      _emailController.text = authState.user!.email;
      _phoneController.text = authState.user!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final movieState = ref.watch(movieProvider);

    final bookingData = widget.bookingData ?? {};
    final seats = bookingData['seats'] as List<String>? ?? [];
    final totalPrice = bookingData['totalPrice'] as double? ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
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
                _buildStepIndicator('Thanh toán', true),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking summary
                    _buildBookingSummary(bookingState, movieState, seats, totalPrice),

                    const SizedBox(height: 24),

                    // Customer info
                    const Text(
                      'Thông tin khách hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ tên *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Payment method
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildPaymentMethod('momo', 'Ví MoMo', Icons.account_balance_wallet),
                    _buildPaymentMethod('zalopay', 'ZaloPay', Icons.payment),
                    _buildPaymentMethod('bank', 'Chuyển khoản ngân hàng', Icons.account_balance),
                    _buildPaymentMethod('cash', 'Thanh toán tại quầy', Icons.money),

                    const SizedBox(height: 24),

                    // Terms and conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              text: 'Tôi đồng ý với ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Điều khoản sử dụng',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' và '),
                                TextSpan(
                                  text: 'Chính sách bảo mật',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (bookingState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          bookingState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Bottom payment button
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
                  // Total price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(totalPrice)} VND',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Thanh toán',
                    isLoading: bookingState.isLoading,
                    onPressed: _agreeToTerms ? _processPayment : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(bookingState, movieState, List<String> seats, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movieState.selectedMovie?.title ?? 'Phim không xác định',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                bookingState.selectedCinema?.name ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${bookingState.selectedDate ?? ''} • ${bookingState.selectedTime ?? ''} • ${bookingState.selectedFormat ?? ''}',
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
                'Ghế: ${seats.join(', ')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(totalPrice)} VND',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            _paymentMethod = value;
          });
        },
        title: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : null,
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final bookingData = widget.bookingData ?? {};
    final movieId = bookingData['movieId'] as int?;
    final cinemaId = bookingData['cinemaId'] as int?;

    if (movieId == null || cinemaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Thiếu thông tin đặt vé')),
      );
      return;
    }

    // Get movie details for booking
    final movieState = ref.read(movieProvider);
    final movie = movieState.selectedMovie;

    if (movie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin phim')),
      );
      return;
    }

    final booking = await ref.read(bookingProvider.notifier).confirmBooking(
      userId: ref.read(authProvider).user!.id.toString(), // Get user ID from auth
      movieTitle: movie.title,
      movieImage: movie.imagePath ?? '',
    );

    if (booking != null && mounted) {
      // Update booking status to confirmed after payment
      final bookingRepo = BookingRepository();
      await bookingRepo.updateBookingStatus(booking.id, 'confirmed');
      
      // Show booking success notification
      final notificationService = NotificationService();
      await notificationService.showBookingSuccessNotification(
        movie.title,
        '${DateFormat('dd/MM/yyyy').format(booking.bookingDate)} ${booking.time}',
      );

      // Schedule show reminder notification (1 hour before)
      final showDateTime = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
        int.parse(booking.time.split(':')[0]),
        int.parse(booking.time.split(':')[1]),
      );
      await notificationService.scheduleShowReminder(
        movie.title,
        showDateTime,
        int.parse(booking.id),
      );
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Thanh toán thành công!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đặt vé: ${booking.id}'),
              const SizedBox(height: 8),
              Text('Phim: ${booking.movieTitle}'),
              Text('Rạp: ${booking.cinema}'),
              Text('Thời gian: ${DateFormat('dd/MM/yyyy').format(booking.bookingDate)} ${booking.time}'),
              Text('Ghế: ${booking.seats.join(', ')}'),
              const SizedBox(height: 8),
              Text(
                'Tổng tiền: ${NumberFormat('#,###').format(booking.totalPrice)} VND',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Reset booking state
                ref.read(bookingProvider.notifier).resetBooking();
                // Navigate to home
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: const Text('Về trang chủ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to ticket detail
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.ticketDetail,
                  (route) => false,
                  arguments: booking.id,
                );
              },
              child: const Text('Xem vé'),
            ),
          ],
        ),
      );
    }
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
