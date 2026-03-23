# 🚀 Quick Start Guide - Hướng dẫn Bắt đầu Nhanh

## 📝 Tóm tắt nhanh

Bạn đã có một ứng dụng đặt vé xem phim hoàn chỉnh với:
- ✅ Màn hình lịch sử đặt vé (4 tabs)
- ✅ Màn hình chi tiết vé
- ✅ Quản lý state với RiverPod
- ✅ Dữ liệu mẫu không dùng JSON

## 🎯 Bắt đầu ngay

### Bước 1: Chạy ứng dụng
```bash
cd C:\Users\meoca\StudioProjects\movie_booking_app
flutter pub get
flutter run
```

### Bước 2: Vào màn hình lịch sử đặt vé
Từ màn hình chính, bấm nút "Lịch sử đặt vé" để xem:
- 📋 **Tất cả:** 5 vé (mới nhất trước)
- 📅 **Sắp diễn ra:** 1 vé (BK002 - 15/03/2026)
- ✅ **Hoàn thành:** 2 vé (BK001, BK005)
- ❌ **Đã hủy:** 1 vé (BK004)

### Bước 3: Xem chi tiết vé
Bấm "Chi tiết" trên bất kỳ vé nào để xem:
- Thông tin phim
- Rạp chiếu và phòng
- Ngày giờ chiếu
- Danh sách ghế
- Tổng giá tiền
- Nút "Tải vé" hoặc "Hủy đặt vé"

## 📂 Cấu trúc thư mục chính

```
lib/
├── models/
│   └── booking_model.dart          ← Định nghĩa Booking & BookingStatus
├── services/
│   └── booking_history_provider.dart ← RiverPod providers & dữ liệu mẫu
└── screens/history/
    ├── booking_history_screen.dart  ← Màn hình lịch sử (4 tabs)
    └── ticket_detail_screen.dart    ← Màn hình chi tiết vé
```

## 🔌 Sử dụng Providers trong Widget

### Cách 1: Xem tất cả booking
```dart
Consumer(
  builder: (context, ref, child) {
    final bookings = ref.watch(bookingHistoryProvider);
    return ListView(
      children: bookings.map((b) => Text(b.movieTitle)).toList(),
    );
  },
)
```

### Cách 2: Xem booking theo trạng thái
```dart
final confirmed = ref.watch(bookingsByStatusProvider(BookingStatus.confirmed));
final completed = ref.watch(bookingsByStatusProvider(BookingStatus.completed));
final pending = ref.watch(bookingsByStatusProvider(BookingStatus.pending));
final cancelled = ref.watch(bookingsByStatusProvider(BookingStatus.cancelled));
```

### Cách 3: Xem booking sắp diễn ra
```dart
final upcoming = ref.watch(upcomingBookingsProvider);
// Chỉ confirmed & ngày chiếu >= hôm nay
```

## 🎬 Dữ liệu mẫu

| Mã | Phim | Status | Ngày | Giá |
|----|------|--------|------|-----|
| BK001 | Deadpool & Wolverine | ✅ Completed | 28/02 | 450k |
| BK002 | Dune: Part Two | ✔️ Confirmed | 15/03 | 600k |
| BK003 | The Brutalist | ⏳ Pending | 10/03 | 300k |
| BK004 | Oppenheimer | ❌ Cancelled | 20/02 | 400k |
| BK005 | Inception | ✅ Completed | 25/01 | 500k |

## 🔧 Hành động thường dùng

### Hủy booking
```dart
ref.read(bookingHistoryProvider.notifier).cancelBooking('BK002');
```

### Thêm booking mới
```dart
final newBooking = Booking(
  id: 'BK006',
  movieTitle: 'Avatar 3',
  movieImage: 'https://...',
  cinema: 'CGV Tân Phú',
  cinemaHall: 'Hall 1',
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

### Cập nhật trạng thái
```dart
ref.read(bookingHistoryProvider.notifier).updateBookingStatus(
  'BK003',
  BookingStatus.confirmed,
);
```

## 🎨 Màu sắc

- **AppBar:** Red `#E71D36` (Giống CGV)
- **Confirmed:** Green `#4CAF50`
- **Completed:** Blue `#2196F3`
- **Cancelled:** Red `#F44336`
- **Pending:** Yellow `#FFC107`

## 📚 Tài liệu đầy đủ

Xem các file hướng dẫn chi tiết:
- `IMPLEMENTATION_GUIDE.md` - Hướng dẫn chi tiết từng phần
- `DETAILED_GUIDE.md` - Giải thích giao diện và flow
- `PROVIDERS_USAGE_EXAMPLE.dart` - Ví dụ code sử dụng
- `SUMMARY.md` - Tóm tắt tất cả thay đổi

## ❓ Câu hỏi thường gặp

**Q: Dữ liệu có lưu trữ đâu?**
A: Dữ liệu mẫu nằm trong `BookingHistoryNotifier` - khi app restart sẽ reset. Để lưu lâu dài, cần kết nối database.

**Q: Có thể thêm phim mới không?**
A: Có! Thêm Booking mới vào danh sách bằng `addBooking()`.

**Q: Tại sao không dùng JSON?**
A: Như yêu cầu, dữ liệu được định nghĩa trực tiếp trong code.

**Q: Làm sao kết nối API?**
A: Thay đổi `BookingHistoryNotifier` để gọi API thay vì dữ liệu static.

## ✨ Các tính năng sẵn sàng

- ✅ Lọc booking theo 4 tab
- ✅ Xem chi tiết vé
- ✅ Hủy booking (dialog xác nhận)
- ✅ Tải vé (UI - sẵn sàng API)
- ✅ Sắp xếp theo ngày
- ✅ Hiển thị poster (từ URL)
- ✅ Responsive design

## 🎁 Bonus

### Dialog xác nhận hủy vé
- Bấm "Hủy đặt vé" trong TicketDetailScreen
- Xác nhận yêu cầu
- State tự động cập nhật
- Quay lại màn hình trước

### Quay lại navigation
- Bấm nút "<" trong AppBar quay lại
- Tất cả state được giữ lại

### Empty states
- Mỗi tab hiển thị icon + message khi trống

## 🚀 Phát triển thêm

Để thêm tính năng:

1. **API Integration:** Tạo method trong `BookingHistoryNotifier` gọi API
2. **Database:** Sử dụng Hive, SQLite hoặc Firebase
3. **QR Code:** Thêm `qr_flutter` package
4. **Notifications:** Firebase Cloud Messaging
5. **Payment:** Stripe hoặc Payment gateway khác

## 📞 Cần trợ giúp?

- Kiểm tra file: `PROVIDERS_USAGE_EXAMPLE.dart` để thấy ví dụ
- Xem `booking_history_provider.dart` để hiểu cách dữ liệu hoạt động
- Đọc `booking_history_screen.dart` để hiểu giao diện

---

**Status:** ✅ Sẵn sàng sử dụng
**Phiên bản:** 1.0
**Ngày:** 03/03/2026

