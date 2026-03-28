import 'package:shared_preferences/shared_preferences.dart';

/// SharedPrefService - Quản lý dữ liệu lưu trữ cục bộ
/// Dùng để lưu: trạng thái đăng nhập, theme, cài đặt nhỏ...
class SharedPrefService {
  // ─── Các key hằng số ────────────────────────────────────────────
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';

  // ─── Lưu User ID ───────────────────────────────────────────────
  /// Lưu ID của user đang đăng nhập
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // ─── Lấy User ID ───────────────────────────────────────────────
  /// Lấy ID user đang đăng nhập (null nếu chưa đăng nhập)
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // ─── Lưu vai trò user ──────────────────────────────────────────
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  // ─── Lấy vai trò user ──────────────────────────────────────────
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // ─── Kiểm tra đã đăng nhập chưa ────────────────────────────────
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ─── Dark Mode ──────────────────────────────────────────────────
  /// Lưu cài đặt dark mode
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  /// Kiểm tra có đang dark mode không
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // ─── Ngôn ngữ ──────────────────────────────────────────────────
  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'vi';
  }

  // ─── Xóa tất cả (đăng xuất) ────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
