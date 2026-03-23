# 📱 Movie Booking App - Hướng dẫn chi tiết

## 🎯 Mục đích

Tạo ứng dụng đặt vé xem phim giống CGV với các tính năng:
- ✅ Lịch sử đặt vé với các tab lọc
- ✅ Chi tiết vé hoàn chỉnh
- ✅ Quản lý trạng thái booking
- ✅ Sử dụng RiverPod cho state management
- ✅ **Không dùng JSON** - dữ liệu mẫu được định nghĩa trực tiếp trong code

## 📂 Tệp đã tạo/cập nhật

### 1. **lib/services/booking_history_provider.dart** (MỚI)
   - Định nghĩa `BookingHistoryNotifier` với dữ liệu mẫu 5 booking
   - Các provider con: `bookingDetailProvider`, `bookingsByStatusProvider`, `upcomingBookingsProvider`, `completedBookingsProvider`
   - Methods: `updateBookingStatus()`, `cancelBooking()`, `addBooking()`

### 2. **lib/screens/history/booking_history_screen.dart** (ĐÃ CẬP NHẬT)
   - Thay thế hoàn toàn bằng giao diện mới
   - 4 tab: Tất cả, Sắp diễn ra, Hoàn thành, Đã hủy
   - Hiển thị danh sách booking dưới dạng card đẹp
   - Tương tác với các provider

### 3. **lib/screens/history/ticket_detail_screen.dart** (ĐÃ CẬP NHẬT)
   - Cập nhật để sử dụng `bookingDetailProvider` mới
   - Giao diện chi tiết vé theo kiểu CGV
   - Nút hủy đặt vé (cập nhật state)
   - Nút tải vé

### 4. **lib/services/index.dart** (ĐÃ CẬP NHẬT)
   - Thêm export cho `booking_history_provider.dart`

### 5. **lib/models/booking_model.dart** (ĐÃ CẬP NHẬT)
   - Xóa JSON methods (không dùng JSON)
   - Giữ `copyWith()` method

## 🎨 Giao diện

### Booking History Screen

```
┌─────────────────────────────────────┐
│  < Lịch sử đặt vé                   │  (AppBar - Red Background)
├─────────────────────────────────────┤
│  Tất cả │ Sắp │ Hoàn │ Đã hủy      │  (4 Tabs)
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ Status: Đã hoàn thành │ 3D      │ │ (Header)
│  ├─────────────────────────────────┤ │
│  │ [Poster] Tên phim      Chi tiết │ │ (Movie info + button)
│  │         Rạp chiếu              │ │
│  │         Phòng chiếu             │ │
│  │         Thứ 2, 28/02 - 19:30   │ │
│  ├─────────────────────────────────┤ │
│  │ Tổng tiền: 450000₫             │ │ (Price)
│  └─────────────────────────────────┘ │
│                                     │
│  [Thêm booking khác...]             │
└─────────────────────────────────────┘
```

### Ticket Detail Screen

```
┌─────────────────────────────────────┐
│  < Chi tiết vé                      │  (AppBar - Red)
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ Mã vé: BK001      Đã hoàn thành │ │
│  │ │ 3D                            │ │
│  ├─────────────────────────────────┤ │
│  │ [Poster] Deadpool & Wolverine   │ │
│  ├─────────────────────────────────┤ │
│  │ 📍 CGV Vincom Mega Mall         │ │
│  │ 🎬 Hall 7                       │ │
│  ├─────────────────────────────────┤ │
│  │ 📅 Thứ 2, 28/02/2026  ⏰ 19:30 │ │
│  ├─────────────────────────────────┤ │
│  │ Ghế: [E1] [E2] [E3]             │ │
│  ├─────────────────────────────────┤ │
│  │ Tổng giá tiền: 450000₫         │ │
│  └─────────────────────────────────┘ │
│                                     │
│  [🎫 Tải vé]                        │
│  [❌ Hủy đặt vé]                    │
└─────────────────────────────────────┘
```

## 🔄 Flow dữ liệu

```
BookingHistoryNotifier
  │
  ├─ State: List<Booking> (5 booking mẫu)
  │
  ├─ Methods:
  │  ├─ updateBookingStatus(id, status)
  │  ├─ cancelBooking(id)
  │  └─ addBooking(booking)
  │
  └─ Providers:
     ├─ bookingHistoryProvider (watch all)
     ├─ bookingDetailProvider (get by id)
     ├─ bookingsByStatusProvider (filter by status)
     ├─ upcomingBookingsProvider (confirmed + future date)
     └─ completedBookingsProvider (completed only)
```

## 📊 Dữ liệu mẫu

### Booking 1 - BK001
```
Phim: Deadpool & Wolverine
Rạp: CGV Vincom Mega Mall
Phòng: Hall 7
Định dạng: 3D
Ngày: 28/02/2026
Giờ: 19:30
Ghế: E1, E2, E3
Giá: 450,000₫
Trạng thái: ✅ Hoàn thành
```

### Booking 2 - BK002
```
Phim: Dune: Part Two
Rạp: CGV Vincom Tây Hồ
Phòng: Hall 3
Định dạng: IMAX
Ngày: 15/03/2026
Giờ: 20:00
Ghế: A5, A6
Giá: 600,000₫
Trạng thái: ✔️ Đã xác nhận
```

### Booking 3 - BK003
```
Phim: The Brutalist
Rạp: CGV Hà Đông
Phòng: Hall 2
Định dạng: 2D
Ngày: 10/03/2026
Giờ: 16:45
Ghế: D10, D11
Giá: 300,000₫
Trạng thái: ⏳ Chờ xác nhận
```

### Booking 4 - BK004
```
Phim: Oppenheimer
Rạp: CGV Aeon Tân Phú
Phòng: Hall 1
Định dạng: 2D
Ngày: 20/02/2026
Giờ: 18:00
Ghế: B3, B4, B5, B6
Giá: 400,000₫
Trạng thái: ❌ Đã hủy
```

### Booking 5 - BK005
```
Phim: Inception
Rạp: CGV Vincom Mega Mall
Phòng: Hall 5
Định dạng: 3D
Ngày: 25/01/2026
Giờ: 21:00
Ghế: F7, F8
Giá: 500,000₫
Trạng thái: ✅ Hoàn thành
```

## 🎯 Cách sử dụng trong Widget

### Cách 1: Consumer Widget
```dart
Consumer(
  builder: (context, ref, child) {
    final bookings = ref.watch(bookingHistoryProvider);
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Text(bookings[index].movieTitle);
      },
    );
  },
)
```

### Cách 2: ConsumerStatefulWidget
```dart
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingHistoryProvider);
    return ListView(
      children: bookings.map((b) => Text(b.movieTitle)).toList(),
    );
  }
}
```

### Cách 3: Gọi Methods
```dart
// Hủy booking
ref.read(bookingHistoryProvider.notifier).cancelBooking('BK001');

// Cập nhật status
ref.read(bookingHistoryProvider.notifier).updateBookingStatus(
  'BK001',
  BookingStatus.confirmed,
);

// Thêm booking mới
ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
```

## 🎬 Tab Navigation

### Tab 1: Tất cả
- Hiển thị tất cả booking (reversed - mới nhất trước)
- Sử dụng: `ref.watch(bookingHistoryProvider)`

### Tab 2: Sắp diễn ra
- Chỉ confirmed bookings với ngày chiếu sau hôm nay
- Sắp xếp: ngày sớm nhất trước
- Sử dụng: `ref.watch(upcomingBookingsProvider)`

### Tab 3: Hoàn thành
- Chỉ completed bookings
- Sắp xếp: ngày tạo mới nhất trước
- Sử dụng: `ref.watch(completedBookingsProvider)`

### Tab 4: Đã hủy
- Chỉ cancelled bookings
- Sắp xếp: reversed
- Sử dụng: `ref.watch(bookingsByStatusProvider(BookingStatus.cancelled))`

## 🎨 Màu sắc

| Element | Màu | Hex |
|---------|-----|-----|
| AppBar Background | Đỏ | #E71D36 |
| Confirmed Status | Xanh | #4CAF50 |
| Completed Status | Blue | #2196F3 |
| Cancelled Status | Đỏ | #F44336 |
| Pending Status | Vàng | #FFC107 |
| Card Background | Trắng | #FFFFFF |
| Text Primary | Đen | #000000 |
| Text Secondary | Xám | #999999 |

## 🔧 Mở rộng tính năng

### Thêm booking mới vào danh sách
```dart
final newBooking = Booking(
  id: 'BK006',
  movieTitle: 'Phim mới',
  movieImage: 'URL_IMAGE',
  cinema: 'Tên rạp',
  cinemaHall: 'Hall X',
  format: '3D',
  bookingDate: DateTime(2026, 4, 1),
  time: '19:00',
  seats: ['A1', 'A2'],
  totalPrice: 300000,
  status: BookingStatus.confirmed,
  createdAt: DateTime.now(),
);

ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
```

### Lọc dữ liệu tùy chỉnh
```dart
final bookings = ref.watch(bookingHistoryProvider);
final filtered = bookings
    .where((b) => b.cinema == 'CGV Vincom Mega Mall')
    .where((b) => b.totalPrice > 300000)
    .toList();
```

### Sắp xếp dữ liệu
```dart
final bookings = ref.watch(bookingHistoryProvider);
bookings.sort((a, b) => b.totalPrice.compareTo(a.totalPrice)); // Giá cao nhất trước
```

## ✅ Checklist

- ✅ Tạo `BookingHistoryNotifier` với dữ liệu mẫu
- ✅ Tạo các providers cần thiết
- ✅ Cập nhật `BookingHistoryScreen` - 4 tabs
- ✅ Cập nhật `TicketDetailScreen` - chi tiết vé
- ✅ Thêm hành động hủy booking
- ✅ Thêm hành động tải vé (UI)
- ✅ Không dùng JSON
- ✅ Theo dõi cấu trúc file có sẵn
- ✅ Sử dụng RiverPod + Provider
- ✅ Giao diện giống CGV

## 🚀 Lần tới có thể thêm

- API integration
- Real QR codes
- Email/SMS notifications
- Payment gateway
- Movie reviews and ratings

