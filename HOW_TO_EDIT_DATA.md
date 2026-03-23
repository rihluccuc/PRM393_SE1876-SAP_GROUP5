# 🔧 Hướng dẫn Chỉnh sửa Dữ liệu & Mở rộng

## 📝 Thêm Booking Mới

### Cách 1: Thêm vào dữ liệu mẫu ban đầu
Mở file: `lib/services/booking_history_provider.dart`

Tìm phần `BookingHistoryNotifier` constructor và thêm Booking mới:

```dart
class BookingHistoryNotifier extends StateNotifier<List<Booking>> {
  BookingHistoryNotifier()
      : super([
          // Booking hiện có...
          
          // Thêm booking mới:
          Booking(
            id: 'BK006',
            movieTitle: 'Avatar 3',
            movieImage: 'https://via.placeholder.com/200x300?text=Avatar3',
            cinema: 'CGV Aeon Tân Phú',
            cinemaHall: 'Hall 4',
            format: 'IMAX',
            bookingDate: DateTime(2026, 4, 1),
            time: '20:30',
            seats: ['C5', 'C6', 'C7'],
            totalPrice: 900000,
            status: BookingStatus.confirmed,
            createdAt: DateTime.now(),
          ),
        ]);
}
```

### Cách 2: Thêm dynamically trong widget
```dart
Consumer(
  builder: (context, ref, child) {
    return ElevatedButton(
      onPressed: () {
        final newBooking = Booking(
          id: 'BK007',
          movieTitle: 'Phim mới',
          movieImage: 'https://...',
          cinema: 'CGV Mới',
          cinemaHall: 'Hall 1',
          format: '3D',
          bookingDate: DateTime(2026, 5, 1),
          time: '19:00',
          seats: ['A1'],
          totalPrice: 300000,
          status: BookingStatus.confirmed,
          createdAt: DateTime.now(),
        );
        
        ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
      },
      child: const Text('Thêm vé mới'),
    );
  },
)
```

## ✏️ Sửa Booking Hiện có

### Cách 1: Cập nhật trạng thái
```dart
ref.read(bookingHistoryProvider.notifier).updateBookingStatus(
  'BK001',
  BookingStatus.confirmed,
);
```

### Cách 2: Sửa dữ liệu trong mẫu
Mở: `lib/services/booking_history_provider.dart`

```dart
Booking(
  id: 'BK001',
  movieTitle: 'Deadpool & Wolverine', // ← Sửa tên phim
  movieImage: 'https://new-url.jpg', // ← Sửa URL
  cinema: 'CGV Mới', // ← Sửa tên rạp
  // ... các trường khác
),
```

### Cách 3: Sử dụng copyWith()
```dart
final oldBooking = ref.watch(bookingDetailProvider('BK001'));
oldBooking.when(
  data: (booking) {
    if (booking != null) {
      final updatedBooking = booking.copyWith(
        movieTitle: 'Tên phim mới',
        cinema: 'Rạp mới',
        totalPrice: 500000,
      );
      // Cập nhật vào state...
    }
  },
  loading: () {},
  error: (_, __) {},
);
```

## 🗑️ Xóa Booking

### Cách duy nhất: Hủy booking
```dart
ref.read(bookingHistoryProvider.notifier).cancelBooking('BK001');
```

Note: Sẽ cập nhật status sang `BookingStatus.cancelled`, không xóa hẳn.

Nếu muốn xóa hẳn, thêm method mới vào `BookingHistoryNotifier`:

```dart
void deleteBooking(String bookingId) {
  state = state.where((booking) => booking.id != bookingId).toList();
}
```

## 🔍 Tìm kiếm Booking

### Tìm theo ID
```dart
final booking = ref.watch(bookingDetailProvider('BK001'));
```

### Tìm theo trạng thái
```dart
final confirmed = ref.watch(bookingsByStatusProvider(BookingStatus.confirmed));
final pending = ref.watch(bookingsByStatusProvider(BookingStatus.pending));
```

### Tìm sắp diễn ra
```dart
final upcoming = ref.watch(upcomingBookingsProvider);
```

### Tìm hoàn thành
```dart
final completed = ref.watch(completedBookingsProvider);
```

### Tìm custom
```dart
final bookings = ref.watch(bookingHistoryProvider);
final result = bookings.where((b) => b.cinema == 'CGV Mega Mall').toList();
```

## 📊 Chỉnh sửa Dữ liệu Model

### Thêm field mới vào Booking
File: `lib/models/booking_model.dart`

```dart
class Booking {
  final String id;
  // ... fields hiện có
  
  // Thêm field mới:
  final String? notes;          // Ghi chú
  final double discountPrice;   // Giá sau chiết khấu
  final bool hasPopcorn;        // Có bỏng ngô
  
  Booking({
    required this.id,
    // ... parameters hiện có
    this.notes,
    this.discountPrice = 0,
    this.hasPopcorn = false,
  });
  
  // Cập nhật copyWith()
  Booking copyWith({
    // ... parameters hiện có
    String? notes,
    double? discountPrice,
    bool? hasPopcorn,
  }) {
    return Booking(
      // ... fields hiện có
      notes: notes ?? this.notes,
      discountPrice: discountPrice ?? this.discountPrice,
      hasPopcorn: hasPopcorn ?? this.hasPopcorn,
    );
  }
}
```

### Thêm trạng thái mới
File: `lib/models/booking_model.dart`

```dart
enum BookingStatus {
  confirmed,
  completed,
  cancelled,
  pending,
  refunded,    // ← Thêm trạng thái mới
  expired,     // ← Thêm trạng thái mới
}

extension BookingStatusExt on BookingStatus {
  String get label {
    switch (this) {
      // ... cases hiện có
      case BookingStatus.refunded:
        return 'Đã hoàn tiền';
      case BookingStatus.expired:
        return 'Hết hạn';
    }
  }
  
  Color get color {
    switch (this) {
      // ... cases hiện có
      case BookingStatus.refunded:
        return const Color(0xFF9C27B0); // Purple
      case BookingStatus.expired:
        return const Color(0xFF757575); // Grey
    }
  }
}
```

## 🎬 Lọc & Sắp xếp Nâng cao

### Lọc booking theo rạp
```dart
final bookings = ref.watch(bookingHistoryProvider);
final cinemaBookings = bookings
    .where((b) => b.cinema == 'CGV Vincom Mega Mall')
    .toList();
```

### Lọc booking theo giá
```dart
final expensive = bookings.where((b) => b.totalPrice > 500000).toList();
final cheap = bookings.where((b) => b.totalPrice < 400000).toList();
```

### Lọc booking theo định dạng
```dart
final imax = bookings.where((b) => b.format == 'IMAX').toList();
final threeD = bookings.where((b) => b.format == '3D').toList();
```

### Sắp xếp theo giá (cao nhất trước)
```dart
bookings.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
```

### Sắp xếp theo ngày (mới nhất trước)
```dart
bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
```

### Sắp xếp theo ngày chiếu (sớm nhất trước)
```dart
bookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
```

## 🔐 Thêm Validation

### Validate booking trước khi thêm
```dart
bool isValidBooking(Booking booking) {
  return booking.id.isNotEmpty &&
      booking.movieTitle.isNotEmpty &&
      booking.seats.isNotEmpty &&
      booking.totalPrice > 0 &&
      booking.bookingDate.isAfter(DateTime(2020));
}

if (isValidBooking(newBooking)) {
  ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Dữ liệu không hợp lệ')),
  );
}
```

## 🌐 Tích hợp API (Hướng dẫn)

### Bước 1: Tạo API service
```dart
class BookingApiService {
  static const String baseUrl = 'https://api.example.com';
  
  Future<List<Booking>> getBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/bookings'));
    if (response.statusCode == 200) {
      // Parse JSON and convert to Booking objects
      // ...
    }
    throw Exception('Failed to load bookings');
  }
  
  Future<void> cancelBooking(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking');
    }
  }
}
```

### Bước 2: Cập nhật BookingHistoryNotifier
```dart
class BookingHistoryNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingApiService _apiService;
  
  BookingHistoryNotifier(this._apiService)
      : super(const AsyncValue.loading()) {
    _loadBookings();
  }
  
  Future<void> _loadBookings() async {
    try {
      final bookings = await _apiService.getBookings();
      state = AsyncValue.data(bookings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

## 📋 Danh sách thay đổi thường xuyên

Các thứ bạn có thể muốn chỉnh sửa:

- [ ] Thêm booking mới
- [ ] Sửa tên phim
- [ ] Sửa rạp chiếu
- [ ] Sửa giá vé
- [ ] Thay đổi ngày chiếu
- [ ] Thêm ghế
- [ ] Cập nhật status
- [ ] Thêm field mới
- [ ] Thêm trạng thái mới
- [ ] Tích hợp API

---

**Hỗ trợ:** Xem file `PROVIDERS_USAGE_EXAMPLE.dart` để thêm ví dụ
**Status:** ✅ Sẵn sàng sử dụng

