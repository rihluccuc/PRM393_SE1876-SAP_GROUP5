import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class LocalStorageService {
  static const String _userKey = 'current_user';

  /// Lưu user info vào local storage
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toMap());
    await prefs.setString(_userKey, userJson);
  }

  /// Lấy user info từ local storage
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(userJson);
        return User.fromMap(map);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Xóa user info khỏi local storage (logout)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Kiểm tra user đã đăng nhập chưa
  Future<bool> isUserLoggedIn() async {
    final user = await getUser();
    return user != null;
  }
}

