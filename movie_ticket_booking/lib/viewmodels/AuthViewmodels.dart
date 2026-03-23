import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/User.dart';
import '../repositories/AuthRepository.dart';
import '../services/LocalStorageService.dart';

part 'AuthViewmodels.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late LocalStorageService _localStorageService;

  @override
  FutureOr<void> build() {
    _localStorageService = LocalStorageService();
  }

  /// REGISTER
  Future<(bool success, String? error)> register(
      String name, 
      String email, 
      String password,
      String city,
      String district,
      String phone) async {
    final repo = ref.watch(authRepositoryProvider);

    try {
      // Check if email already exists
      final existingUser = await repo.getUserByEmail(email);
      if (existingUser != null) {
        return (false, "Email đã được sử dụng");
      }

      await repo.register(
        User(
          name: name,
          email: email,
          password: password,
          role: "user", // Default role
          city: city,
          district: district,
          phone: phone,
        ),
      );
      return (true, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// LOGIN - Returns User if successful, null otherwise
  Future<User?> login(String email, String password) async {
    final repo = ref.watch(authRepositoryProvider);

    final user = await repo.login(email, password);

    // Nếu đăng nhập thành công, lưu user vào local storage
    if (user != null) {
      await _localStorageService.saveUser(user);
    }

    return user;
  }

  /// LOGOUT
  Future<void> logout() async {
    await _localStorageService.clearUser();
  }

  /// Get current user from local storage
  Future<User?> getCurrentUser() async {
    return await _localStorageService.getUser();
  }

  /// Update user address
  Future<bool> updateUserAddress(int userId, String city, String district) async {
    final repo = ref.watch(authRepositoryProvider);
    return await repo.updateUserAddress(userId, city, district);
  }

  /// Change user password
  Future<(bool success, String? error)> changeUserPassword(int userId, String currentPassword, String newPassword) async {
    final repo = ref.watch(authRepositoryProvider);
    return await repo.changeUserPassword(userId, currentPassword, newPassword);
  }
}