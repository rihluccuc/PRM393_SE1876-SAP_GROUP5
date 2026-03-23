# Movie Booking App - Hướng dẫn cấu trúc

## 📋 Tổng quan
Ứng dụng đặt vé xem phim được xây dựng với Flutter, sử dụng **RiverPod** để quản lý state và **không sử dụng JSON** cho dữ liệu mẫu.

## 🏗️ Cấu trúc thư mục

```
lib/
├── models/
│   ├── booking_model.dart      # Định nghĩa model Booking
│   └── index.dart              # Export models
│
├── services/
│   ├── booking_history_provider.dart   # RiverPod providers cho booking history
│   ├── booking_provider.dart           # Provider cũ (có thể dùng sau)
│   └── index.dart                      # Export services
│
├── screens/
│   ├── history/
│   │   ├── booking_history_screen.dart # Màn hình lịch sử đặt vé
│   │   ├── ticket_detail_screen.dart   # Màn hình chi tiết vé
│   │   └── index.dart                  # Export screens
│   ├── auth/
│   ├── booking/
│   ├── movie/
│   └── admin/
│
├── widgets/
│   ├── booking_widgets.dart    # Widget components
│   └── index.dart              # Export widgets
│
└── main.dart                   # Entry point
```

## 🔌 Các Providers RiverPod

### 1. `bookingHistoryProvider`
**Loại:** `StateNotifierProvider`
**Mục đích:** Quản lý danh sách tất cả các booking
**Dữ liệu mẫu:** 5 booking khác nhau với các trạng thái khác nhau

```dart
final bookings = ref.watch(bookingHistoryProvider);
```

### 2. `bookingDetailProvider`
**Loại:** `FutureProvider.family`
**Mục đích:** Lấy chi tiết một booking theo ID
**Cách dùng:**
```dart
final booking = ref.watch(bookingDetailProvider('BK001'));
```

### 3. `bookingsByStatusProvider`
**Loại:** `Provider.family`
**Mục đích:** Lọc booking theo trạng thái
**Cách dùng:**
```dart
final confirmed = ref.watch(bookingsByStatusProvider(BookingStatus.confirmed));
```

### 4. `upcomingBookingsProvider`
**Loại:** `Provider`
**Mục đích:** Lấy các booking sắp diễn ra (confirmed và sau ngày hiện tại)

```dart
final upcoming = ref.watch(upcomingBookingsProvider);
```

### 5. `completedBookingsProvider`
**Loại:** `Provider`
**Mục đích:** Lấy các booking đã hoàn thành

```dart
final completed = ref.watch(completedBookingsProvider);
```

## 📱 Màn hình chính

### 1. BookingHistoryScreen
**Tính năng:**
- Hiển thị 4 tab: Tất cả, Sắp diễn ra, Hoàn thành, Đã hủy
- Danh sách booking dưới dạng card
- Hiển thị thông tin: poster, tên phim, rạp, phòng, giờ, tổng tiền
- Nút "Chi tiết" để xem chi tiết vé

**Dữ liệu mẫu:** 5 booking
- BK001: Deadpool & Wolverine - Hoàn thành
- BK002: Dune: Part Two - Đã xác nhận
- BK003: The Brutalist - Chờ xác nhận
- BK004: Oppenheimer - Đã hủy
- BK005: Inception - Hoàn thành

### 2. TicketDetailScreen
**Tính năng:**
- Hiển thị chi tiết vé hoàn chỉnh
- Hiển thị poster phim, tên, mã vé, trạng thái
- Thông tin: rạp chiếu, phòng, định dạng, ngày/giờ, ghế, tổng tiền
- Nút "Tải vé" - download ticket
- Nút "Hủy đặt vé" - hủy booking (nếu chưa hoàn thành)

## 🎨 Model Booking

```dart
class Booking {
  final String id;                    // Mã vé: BK001
  final String movieTitle;            // Tên phim
  final String movieImage;            // URL poster
  final String cinema;                // Tên rạp
  final String cinemaHall;            // Tên phòng chiếu
  final String format;                // 2D, 3D, IMAX
  final DateTime bookingDate;         // Ngày chiếu
  final String time;                  // Giờ chiếu: 19:30
  final List<String> seats;           // Danh sách ghế: [E1, E2, E3]
  final double totalPrice;            // Tổng giá tiền
  final BookingStatus status;         // Trạng thái
  final DateTime createdAt;           // Thời gian tạo
}
```

## 📊 BookingStatus Enum

```dart
enum BookingStatus {
  confirmed,      // Đã xác nhận (màu xanh)
  completed,      // Đã hoàn thành (màu xanh)
  cancelled,      // Đã hủy (màu đỏ)
  pending,        // Chờ xác nhận (màu vàng)
}
```

Mỗi status có:
- `label`: Chuỗi hiển thị tiếng Việt
- `color`: Màu sắc tương ứng

## 🎯 Hành động chính

### 1. Xem lịch sử đặt vé
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BookingHistoryScreen(),
  ),
);
```

### 2. Xem chi tiết vé
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TicketDetailScreen(bookingId: 'BK001'),
  ),
);
```

### 3. Hủy đặt vé
```dart
ref.read(bookingHistoryProvider.notifier).cancelBooking('BK001');
```

### 4. Thêm booking mới
```dart
final newBooking = Booking(
  id: 'BK006',
  movieTitle: 'Avatar 3',
  // ... các trường khác
);
ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
```

## 🎨 Giao diện

### Màu sắc chính
- **Primary Red:** `#E71D36` - Màu chủ đạo của CGV
- **Status Green:** `#4CAF50` - Trạng thái xác nhận
- **Status Red:** `#F44336` - Trạng thái hủy
- **Status Blue:** `#2196F3` - Trạng thái hoàn thành
- **Status Yellow:** `#FFC107` - Trạng thái chờ xác nhận

### Components
- **AppBar:** Red background với text white
- **Card:** White background với shadow
- **Status Badge:** Màu theo trạng thái
- **Buttons:** Primary red color cho action chính

## 📝 Dữ liệu mẫu

Tất cả dữ liệu mẫu được định nghĩa trực tiếp trong `BookingHistoryNotifier` constructor, **không sử dụng JSON**:

```dart
class BookingHistoryNotifier extends StateNotifier<List<Booking>> {
  BookingHistoryNotifier()
      : super([
          Booking(
            id: 'BK001',
            movieTitle: 'Deadpool & Wolverine',
            // ...
          ),
          // ... thêm các booking khác
        ]);
}
```

## 🔧 Cách thêm dữ liệu mới

Để thêm booking mới, sửa dữ liệu mẫu trong `booking_history_provider.dart`:

```dart
Booking(
  id: 'BK006',
  movieTitle: 'Phim của tôi',
  movieImage: 'https://example.com/image.jpg',
  cinema: 'CGV Thành phố',
  cinemaHall: 'Hall 1',
  format: '3D',
  bookingDate: DateTime(2026, 3, 20),
  time: '19:00',
  seats: ['A1', 'A2'],
  totalPrice: 300000,
  status: BookingStatus.confirmed,
  createdAt: DateTime.now(),
),
```

## 🚀 Cách chạy ứng dụng

```bash
cd C:\Users\meoca\StudioProjects\movie_booking_app

# Get dependencies
flutter pub get

# Run app
flutter run
```

## 📚 Dependencies chính

- **flutter_riverpod:** Quản lý state
- **riverpod_annotation:** Annotations cho RiverPod
- **riverpod_generator:** Code generation (optional)
- **flutter:** Framework chính

## ✅ Tính năng đã hoàn thành

- ✅ Màn hình lịch sử đặt vé với 4 tab
- ✅ Màn hình chi tiết vé
- ✅ RiverPod providers cho state management
- ✅ Dữ liệu mẫu không dùng JSON
- ✅ Hủy đặt vé
- ✅ Tải vé (UI chỉ)
- ✅ Lọc booking theo trạng thái
- ✅ Giao diện giống CGV

## 🔮 Tính năng có thể phát triển tiếp

- [ ] Kết nối API thực
- [ ] Thanh toán trực tuyến
- [ ] QR code cho vé
- [ ] Share vé qua email/SMS
- [ ] Review phim sau khi xem
- [ ] Bình luận phim

