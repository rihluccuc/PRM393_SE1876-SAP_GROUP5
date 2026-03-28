# 🚀 App Configuration - main.dart, Routes, Theme

## Mô Tả
Các file cấu hình chính của ứng dụng:
- **main.dart** - Điểm vào ứng dụng
- **app_routes.dart** - Định nghĩa tất cả routes
- **app_theme.dart** - Theme (giao diện CGV đỏ đen)
- **app.dart** - MaterialApp wrapper

---

## File: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Điểm vào chính của ứng dụng
/// ProviderScope: bọc toàn bộ app để Riverpod hoạt động
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter khởi tạo
  runApp(
    const ProviderScope( // Bọc app trong ProviderScope cho Riverpod
      child: MovieBookingApp(),
    ),
  );
}
```

---

## File: `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';

/// MovieBookingApp - Widget gốc của ứng dụng
class MovieBookingApp extends StatelessWidget {
  const MovieBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGV Movie Booking',
      debugShowCheckedModeBanner: false,  // Ẩn banner debug
      theme: AppTheme.lightTheme,         // Theme sáng
      darkTheme: AppTheme.darkTheme,      // Theme tối
      themeMode: ThemeMode.light,         // Mặc định: sáng
      initialRoute: '/login',             // Màn hình khởi đầu
      routes: AppRoutes.routes,           // Tất cả routes
    );
  }
}
```

---

## File: `lib/config/app_routes.dart`

```dart
import 'package:flutter/material.dart';

// Import tất cả các screens
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/profile_screen.dart';
import '../views/auth/edit_profile_screen.dart';

import '../views/movie/movie_list_screen.dart';
import '../views/movie/movie_detail_screen.dart';
import '../views/movie/trailer_screen.dart';
import '../views/movie/review_screen.dart';

import '../views/booking/select_cinema_screen.dart';
import '../views/booking/select_time_screen.dart';
import '../views/booking/select_seat_screen.dart';
import '../views/booking/payment_screen.dart';

import '../views/history/booking_history_screen.dart';
import '../views/history/ticket_detail_screen.dart';
import '../views/history/qr_code_screen.dart';
import '../views/history/cancel_ticket_screen.dart';

import '../views/admin/add_movie_screen.dart';
import '../views/admin/add_showtime_screen.dart';
import '../views/admin/manage_cinema_screen.dart';
import '../views/admin/statistics_screen.dart';

/// AppRoutes - Định nghĩa tất cả routes trong app
class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // ── Authentication (Dat) ──
    '/login':          (_) => const LoginScreen(),
    '/register':       (_) => const RegisterScreen(),
    '/profile':        (_) => const ProfileScreen(),
    '/edit-profile':   (_) => const EditProfileScreen(),

    // ── Movie (Khanh) ──
    '/movie-list':     (_) => const MovieListScreen(),
    '/movie-detail':   (_) => const MovieDetailScreen(),
    '/trailer':        (_) => const TrailerScreen(),
    '/reviews':        (_) => const ReviewScreen(),

    // ── Booking (Duc) ──
    '/select-cinema':  (_) => const SelectCinemaScreen(),
    '/select-time':    (_) => const SelectTimeScreen(),
    '/select-seat':    (_) => const SelectSeatScreen(),
    '/payment':        (_) => const PaymentScreen(),

    // ── History (Quan) ──
    '/booking-history': (_) => const BookingHistoryScreen(),
    '/ticket-detail':   (_) => const TicketDetailScreen(),
    '/qr-code':         (_) => const QRCodeScreen(),
    '/cancel-ticket':   (_) => const CancelTicketScreen(),

    // ── Admin (Long) ──
    '/add-movie':       (_) => const AddMovieScreen(),
    '/add-showtime':    (_) => const AddShowtimeScreen(),
    '/manage-cinema':   (_) => const ManageCinemaScreen(),
    '/statistics':      (_) => const StatisticsScreen(),
  };
}
```

---

## File: `lib/config/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme - Định nghĩa theme CGV (đỏ đen)
class AppTheme {
  // Màu chính của CGV
  static const Color primaryRed = Color(0xFFE71D36);    // Đỏ CGV
  static const Color darkBackground = Color(0xFF1A1A2E); // Nền tối
  static const Color cardDark = Color(0xFF16213E);        // Card tối

  // ── Theme sáng ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
      ),
      // Font chữ
      textTheme: GoogleFonts.interTextTheme(),
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
        ),
      ),
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      // Card
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Input
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
    );
  }

  // ── Theme tối ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
        ),
      ),
    );
  }
}
```

---

## File: `lib/config/app_constants.dart`

```dart
/// AppConstants - Hằng số dùng chung trong app
class AppConstants {
  // ── Tên app ─────────────────────────────────────────────────────
  static const String appName = 'CGV Movie Booking';
  static const String appVersion = '1.0.0';

  // ── Giá vé ──────────────────────────────────────────────────────
  static const int normalSeatPrice = 75000;  // Ghế thường: 75,000 VNĐ
  static const int vipSeatPrice = 100000;    // Ghế VIP: 100,000 VNĐ

  // ── Định dạng phim ──────────────────────────────────────────────
  static const List<String> formats = ['2D', '3D', 'IMAX'];

  // ── SharedPreferences keys ──────────────────────────────────────
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyDarkMode = 'dark_mode';
}
```
