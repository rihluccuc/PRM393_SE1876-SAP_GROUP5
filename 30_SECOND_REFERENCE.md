# ⚡ 30-Second Quick Reference

## 🎯 Trong 30 giây

### 1. Chạy ứng dụng (10 giây)
```bash
flutter pub get && flutter run
```

### 2. Xem lịch sử vé (5 giây)
Bấm nút "Lịch sử đặt vé" → Xem 5 booking ở 4 tabs

### 3. Chi tiết vé (5 giây)
Bấm "Chi tiết" → Xem thông tin vé đầy đủ

### 4. Hủy vé (5 giây)
Bấm "Hủy đặt vé" → Xác nhận → Done!

---

## 📱 Cấu trúc màn hình

```
Home → [Lịch sử đặt vé] → [4 Tabs]
              ↓
          Card Item → [Chi tiết]
```

---

## 💻 Code sử dụng nhanh

### Xem tất cả booking
```dart
final bookings = ref.watch(bookingHistoryProvider);
```

### Hủy booking
```dart
ref.read(bookingHistoryProvider.notifier).cancelBooking('BK001');
```

### Thêm booking
```dart
ref.read(bookingHistoryProvider.notifier).addBooking(newBooking);
```

---

## 🎨 Giao diện

- **Color:** Red `#E71D36`
- **Layout:** Cards + Tabs
- **Data:** 5 bookings (BK001-BK005)

---

## 📚 Tài liệu

| Bạn muốn... | Đọc file này |
|-----------|--------------|
| Bắt đầu | QUICK_START.md |
| Hiểu code | PROVIDERS_USAGE_EXAMPLE.dart |
| Chi tiết | IMPLEMENTATION_GUIDE.md |
| Chỉnh sửa | HOW_TO_EDIT_DATA.md |

---

✅ **Ready to use!** Enjoy! 🎬

