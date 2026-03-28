# 📁 Cấu Trúc Dự Án - Movie Booking App (CGV Clone)

## Tổng Quan
- **Kiến trúc**: MVVM (Model - View - ViewModel)
- **Database**: SQLite (sqflite)
- **State Management**: Riverpod + Provider
- **Local Storage**: SharedPreferences
- **Ngôn ngữ**: Dart / Flutter

---

## Cấu Trúc Thư Mục

```
lib/
├── main.dart                          // Khởi tạo app, ProviderScope
├── app.dart                           // MaterialApp, theme, routes
│
├── config/
│   ├── app_routes.dart                // Định nghĩa tất cả routes
│   ├── app_theme.dart                 // Theme (màu sắc, font chữ)
│   └── app_constants.dart             // Hằng số dùng chung
│
├── database/
│   ├── database_helper.dart           // Khởi tạo SQLite, tạo bảng
│   └── seed_data.dart                 // Dữ liệu mẫu ban đầu
│
├── models/
│   ├── user.dart                      // Model User
│   ├── movie.dart                     // Model Movie
│   ├── cinema.dart                    // Model Cinema
│   ├── booking.dart                   // Model Booking + BookingStatus
│   ├── seat.dart                      // Model Seat
│   ├── review_model.dart              // Model ReviewModel
│   └── trailer_model.dart             // Model TrailerModel
│
├── repositories/
│   ├── user_repository.dart           // CRUD User (SQLite)
│   ├── movie_repository.dart          // CRUD Movie (SQLite)
│   ├── cinema_repository.dart         // CRUD Cinema (SQLite)
│   ├── booking_repository.dart        // CRUD Booking (SQLite)
│   ├── review_repository.dart         // CRUD Review (SQLite)
│   └── trailer_repository.dart        // CRUD Trailer (SQLite)
│
├── services/
│   ├── auth_service.dart              // Xử lý đăng nhập/đăng ký
│   ├── movie_service.dart             // Logic nghiệp vụ Movie
│   ├── booking_service.dart           // Logic nghiệp vụ Booking
│   ├── cinema_service.dart            // Logic nghiệp vụ Cinema
│   └── shared_pref_service.dart       // SharedPreferences helper
│
├── viewmodels/
│   ├── auth_viewmodel.dart            // State: login, register, profile
│   ├── movie_viewmodel.dart           // State: movie list, detail
│   ├── booking_viewmodel.dart         // State: chọn rạp, giờ, ghế, thanh toán
│   ├── history_viewmodel.dart         // State: lịch sử, vé, QR, hủy vé
│   ├── admin_viewmodel.dart           // State: quản lý phim, rạp, thống kê
│   ├── review_viewmodel.dart          // State: đánh giá phim
│   └── trailer_viewmodel.dart         // State: trailer phim
│
├── views/
│   ├── auth/                          // 👤 Dat - Authentication
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   │
│   ├── movie/                         // 🎬 Khanh - Movie
│   │   ├── movie_list_screen.dart
│   │   ├── movie_detail_screen.dart
│   │   ├── trailer_screen.dart
│   │   └── review_screen.dart
│   │
│   ├── booking/                       // 🎫 Duc - Booking
│   │   ├── select_cinema_screen.dart
│   │   ├── select_time_screen.dart
│   │   ├── select_seat_screen.dart
│   │   └── payment_screen.dart
│   │
│   ├── history/                       // 📋 Quan - History
│   │   ├── booking_history_screen.dart
│   │   ├── ticket_detail_screen.dart
│   │   ├── qr_code_screen.dart
│   │   └── cancel_ticket_screen.dart
│   │
│   └── admin/                         // ⚙️ Long - Admin
│       ├── add_movie_screen.dart
│       ├── add_showtime_screen.dart
│       ├── manage_cinema_screen.dart
│       └── statistics_screen.dart
│
└── widgets/                           // Widget dùng chung
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── loading_widget.dart
    └── movie_card.dart
```

---

## Phân Công Thành Viên

| Module         | Screen           | Member  |
|----------------|------------------|---------|
| Authentication | Login            | **Dat** |
| Authentication | Register         | **Dat** |
| Authentication | Profile          | **Dat** |
| Authentication | Edit Profile     | **Dat** |
| Movie          | Movie List       | **Khanh** |
| Movie          | Movie Detail     | **Khanh** |
| Movie          | Trailer Screen   | **Khanh** |
| Movie          | Review Screen    | **Khanh** |
| Booking        | Select Cinema    | **Duc** |
| Booking        | Select Time      | **Duc** |
| Booking        | Select Seat      | **Duc** |
| Booking        | Payment          | **Duc** |
| History        | Booking History  | **Quan** |
| History        | Ticket Detail    | **Quan** |
| History        | QR Code Screen   | **Quan** |
| History        | Cancel Ticket    | **Quan** |
| Admin          | Add Movie        | **Long** |
| Admin          | Add Showtime     | **Long** |
| Admin          | Manage Cinema    | **Long** |
| Admin          | Statistics       | **Long** |

---

## pubspec.yaml (Dependencies)

```yaml
name: movie_booking_app
description: "Movie Booking App - CGV Clone"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.6.1         # Riverpod cho state management
  provider: ^6.1.2                 # Provider (dùng kết hợp)

  # Database
  sqflite: ^2.4.1                  # SQLite database
  path: ^1.9.1                     # Hỗ trợ đường dẫn DB

  # Local Storage
  shared_preferences: ^2.3.4       # Lưu trữ cục bộ (token, settings)

  # UI Components
  google_fonts: ^6.2.1             # Font chữ đẹp
  cached_network_image: ^3.4.1     # Cache ảnh từ mạng
  flutter_rating_bar: ^4.0.1       # Widget đánh giá sao

  # Utilities
  intl: ^0.19.0                    # Format ngày tháng, tiền tệ
  uuid: ^4.5.1                     # Tạo ID duy nhất
  qr_flutter: ^4.1.0              # Tạo QR code
  url_launcher: ^6.3.1             # Mở link ngoài (trailer YouTube)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```
