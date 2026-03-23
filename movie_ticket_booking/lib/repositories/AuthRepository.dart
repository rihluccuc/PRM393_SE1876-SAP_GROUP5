import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/User.dart';
import '../services/database.dart';

part 'AuthRepository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

class AuthRepository {
  final db = DatabaseService();

  Future<void> register(User user) async {
    await db.insertUser(user);
  }

  Future<User?> getUserByEmail(String email) async {
    return await db.getUserByEmail(email);
  }

  Future<User?> login(String email, String password) async {
    return db.loginUser(email, password);
  }

  Future<bool> updateUserAddress(int userId, String city, String district) async {
    final result = await db.updateUserAddress(userId, city, district);
    return result > 0;
  }

  Future<(bool success, String? error)> changeUserPassword(int userId, String currentPassword, String newPassword) async {
    // First verify current password
    final user = await db.getUserById(userId);
    if (user == null) {
      return (false, "User not found");
    }

    if (user.password != currentPassword) {
      return (false, "Current password is incorrect");
    }

    if (currentPassword == newPassword) {
      return (false, "New password cannot be the same as current password");
    }

    final result = await db.changeUserPassword(userId, newPassword);
    return (result > 0, null);
  }
}