import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'shared_pref_service.dart';

/// AuthService - Xử lý logic đăng nhập, đăng ký, profile
class AuthService {
  final UserRepository _userRepo = UserRepository();
  final SharedPrefService _prefService = SharedPrefService();

  // ─── Đăng ký ────────────────────────────────────────────────────
  /// Đăng ký tài khoản mới
  /// Trả về User nếu thành công, throw Exception nếu email đã tồn tại
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? city,
    String? district,
  }) async {
    // Kiểm tra email đã tồn tại chưa
    final existingUser = await _userRepo.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email đã được sử dụng');
    }

    // Tạo user mới
    final user = User(
      name: name,
      email: email,
      password: password,
      role: 'user', // Mặc định là user thường
      phone: phone,
      city: city,
      district: district,
    );

    // Lưu vào database
    final id = await _userRepo.insertUser(user);

    // Lưu trạng thái đăng nhập vào SharedPreferences
    await _prefService.saveUserId(id);
    await _prefService.saveUserRole('user');

    // Trả về user với ID từ database
    return User(
      id: id,
      name: name,
      email: email,
      password: password,
      role: 'user',
      phone: phone,
      city: city,
      district: district,
    );
  }

  // ─── Đổi mật khẩu ──────────────────────────────────────────────
  /// Đổi mật khẩu người dùng
  Future<void> changePassword(int userId, String oldPassword, String newPassword) async {
    final user = await _userRepo.getUserById(userId);
    if (user == null) {
      throw Exception('User không tồn tại');
    }

    if (user.password != oldPassword) {
      throw Exception('Mật khẩu hiện tại không đúng');
    }

    final updatedUser = User(
      id: user.id,
      name: user.name,
      email: user.email,
      password: newPassword,
      role: user.role,
      phone: user.phone,
      city: user.city,
      district: user.district,
    );

    await _userRepo.updateUser(updatedUser);
  }

  // ─── Đăng nhập ─────────────────────────────────────────────────
  /// Đăng nhập bằng email và password
  /// Trả về User nếu thành công, throw Exception nếu sai
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Tìm user theo email
    final user = await _userRepo.getUserByEmail(email);
    if (user == null) {
      throw Exception('Email không tồn tại');
    }

    // Kiểm tra password
    if (user.password != password) {
      throw Exception('Mật khẩu không đúng');
    }

    // Lưu trạng thái đăng nhập
    await _prefService.saveUserId(user.id!);
    await _prefService.saveUserRole(user.role);

    return user;
  }

  // ─── Đăng xuất ──────────────────────────────────────────────────
  /// Xóa trạng thái đăng nhập
  Future<void> logout() async {
    await _prefService.clearAll();
  }

  // ─── Lấy user hiện tại ─────────────────────────────────────────
  /// Lấy thông tin user đang đăng nhập (từ SharedPreferences)
  Future<User?> getCurrentUser() async {
    final userId = await _prefService.getUserId();
    if (userId == null) return null;
    return await _userRepo.getUserById(userId);
  }

  // ─── Cập nhật profile ───────────────────────────────────────────
  /// Cập nhật thông tin cá nhân
  Future<void> updateProfile(User user) async {
    await _userRepo.updateUser(user);
  }
}
