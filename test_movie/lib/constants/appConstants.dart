/// Tập trung tất cả hằng số của app tại một nơi
class AppConstants {
  AppConstants._();

  // ── API (Mock base URL — thay bằng URL thật sau) ──────────────────────────
  static const String baseUrl = 'https://api.example.com/v1';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const String prefKeyUserId       = 'user_id';
  static const String prefKeyUserName     = 'user_name';
  static const String prefKeyIsLoggedIn   = 'is_logged_in';
  static const String prefKeyThemeMode    = 'theme_mode';
  static const String prefKeyOnboarded    = 'onboarded';
  static const String prefKeyFavorites    = 'favorite_movie_ids'; // JSON list

  // ── SQLite ─────────────────────────────────────────────────────────────────
  static const String dbName    = 'movie_booking.db';
  static const int    dbVersion = 1;

  // Table names
  static const String tableMovies    = 'movies';
  static const String tableReviews   = 'reviews';
  static const String tableTrailers  = 'trailers';
  static const String tableFavorites = 'favorites';
  static const String tableCache     = 'cache_meta';
}

/// Màu sắc dùng chung
class AppColors {
  AppColors._();

  static const int primary    = 0xFFE50914; // CGV red
  static const int background = 0xFF0D0D1A;
  static const int surface    = 0xFF141428;
  static const int card       = 0xFF1E1E35;
  static const int divider    = 0xFF2A2A3E;
  static const int textPrimary   = 0xFFFFFFFF;
  static const int textSecondary = 0xFF9E9E9E;
  static const int gold       = 0xFFFFD700;
  static const int green      = 0xFF2E7D32;
  static const int orange     = 0xFFE65100;
}
