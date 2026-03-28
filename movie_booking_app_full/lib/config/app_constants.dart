/// App Constants - Hằng số dùng chung trong app
class AppConstants {
  // ─── API Keys & URLs ────────────────────────────────────────────
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = 'your_tmdb_api_key_here'; // Thay bằng API key thật

  // ─── Colors ─────────────────────────────────────────────────────
  static const int primaryColor = 0xFFE53E3E;    // Đỏ CGV
  static const int secondaryColor = 0xFF1A1A1A;  // Đen
  static const int accentColor = 0xFFFFD700;     // Vàng

  // ─── Font Sizes ─────────────────────────────────────────────────
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 20.0;

  // ─── Spacing ────────────────────────────────────────────────────
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // ─── Seat Prices ────────────────────────────────────────────────
  static const int seatPriceNormal = 75000;    // Ghế thường
  static const int seatPriceVIP = 100000;      // Ghế VIP
  static const int seatPriceCouple = 150000;   // Ghế đôi

  // ─── Booking Limits ─────────────────────────────────────────────
  static const int maxSeatsPerBooking = 8;     // Tối đa 8 ghế/booking

  // ─── Timeouts ───────────────────────────────────────────────────
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // ─── Image URLs ─────────────────────────────────────────────────
  static const String placeholderImage = 'https://via.placeholder.com/300x450?text=No+Image';
  static const String logoUrl = 'assets/images/logo.png';

  // ─── Strings ────────────────────────────────────────────────────
  static const String appName = 'CGV Cinema';
  static const String currency = 'VND';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
}
