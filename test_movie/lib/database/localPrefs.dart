import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/appConstants.dart';

/// LocalPrefs — Singleton wrapper cho SharedPreferences
/// Dùng cho: user session, settings, danh sách yêu thích, trạng thái UI
class LocalPrefs {
  LocalPrefs._internal();
  static final LocalPrefs instance = LocalPrefs._internal();

  late SharedPreferences _prefs;

  /// Gọi một lần duy nhất trong main()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── User Session ───────────────────────────────────────────────────────────
  bool   get isLoggedIn => _prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
  String get userName   => _prefs.getString(AppConstants.prefKeyUserName) ?? 'Khách';
  int    get userId     => _prefs.getInt(AppConstants.prefKeyUserId) ?? 0;

  Future<void> saveUserSession({
    required int    userId,
    required String userName,
  }) async {
    await _prefs.setInt(AppConstants.prefKeyUserId, userId);
    await _prefs.setString(AppConstants.prefKeyUserName, userName);
    await _prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.prefKeyUserId);
    await _prefs.remove(AppConstants.prefKeyUserName);
    await _prefs.setBool(AppConstants.prefKeyIsLoggedIn, false);
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────
  bool get onboarded => _prefs.getBool(AppConstants.prefKeyOnboarded) ?? false;
  Future<void> setOnboarded() =>
      _prefs.setBool(AppConstants.prefKeyOnboarded, true);

  // ── Theme ──────────────────────────────────────────────────────────────────
  String get themeMode =>
      _prefs.getString(AppConstants.prefKeyThemeMode) ?? 'dark';
  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.prefKeyThemeMode, mode);

  // ── Favorites (backup trong prefs, chính là SQLite) ────────────────────────
  List<int> getFavoriteIds() {
    final raw = _prefs.getString(AppConstants.prefKeyFavorites);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<int>();
  }

  Future<void> saveFavoriteIds(List<int> ids) async {
    await _prefs.setString(AppConstants.prefKeyFavorites, jsonEncode(ids));
  }

  // ── Generic helpers ────────────────────────────────────────────────────────
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
}
