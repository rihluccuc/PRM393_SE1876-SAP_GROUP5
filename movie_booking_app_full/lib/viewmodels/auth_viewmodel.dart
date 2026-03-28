import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── State class ──────────────────────────────────────────────────
/// AuthState - Trạng thái của authentication
class AuthState {
  final User? user;         // User hiện tại (null = chưa đăng nhập)
  final bool isLoading;     // Đang xử lý
  final String? error;      // Lỗi (nếu có)

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Tạo bản sao state với một số field thay đổi
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── ViewModel (StateNotifier) ────────────────────────────────────
/// AuthViewModel - Quản lý state cho đăng nhập/đăng ký
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  // Khởi tạo với state rỗng
  AuthViewModel() : super(const AuthState());

  // ─── Đăng nhập ─────────────────────────────────────────────────
  /// Gọi AuthService.login() và cập nhật state
  Future<bool> login(String email, String password) async {
    // Bắt đầu loading
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Gọi service đăng nhập
      final user = await _authService.login(
        email: email,
        password: password,
      );
      // Thành công → cập nhật user vào state
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      // Thất bại → hiển thị lỗi
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ─── Đăng ký ───────────────────────────────────────────────────
  Future<bool> register(
    String name,
    String email,
    String password,
    String phone, {
    String? city,
    String? district,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        city: city,
        district: district,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ─── Đăng xuất ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(); // Reset state về mặc định
  }

  // ─── Kiểm tra đăng nhập ────────────────────────────────────────
  Future<void> checkLoginStatus() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  // ─── Cập nhật profile ──────────────────────────────────────────
  Future<bool> updateProfile(User updatedUser) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.updateProfile(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  // ─── Đổi mật khẩu ──────────────────────────────────────────────
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.user == null) {
      state = state.copyWith(error: 'User chưa đăng nhập');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.changePassword(
        state.user!.id!,
        oldPassword,
        newPassword,
      );
      // Cập nhật user với password mới
      final updatedUser = User(
        id: state.user!.id,
        name: state.user!.name,
        email: state.user!.email,
        password: newPassword,
        role: state.user!.role,
        phone: state.user!.phone,
        city: state.user!.city,
        district: state.user!.district,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────
/// Provider toàn cục cho AuthViewModel
/// Dùng: ref.watch(authProvider) hoặc ref.read(authProvider.notifier)
final authProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);
