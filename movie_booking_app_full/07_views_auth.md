# 👤 Views - Authentication (Dat)

## Mô Tả
Module Authentication gồm 4 màn hình do **Dat** phụ trách:
1. **Login** - Đăng nhập
2. **Register** - Đăng ký
3. **Profile** - Xem thông tin cá nhân
4. **Edit Profile** - Chỉnh sửa thông tin cá nhân

---

## File: `lib/views/auth/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// LoginScreen - Màn hình đăng nhập
/// Người phụ trách: Dat
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controller cho các ô nhập liệu
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key để validate form

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị hủy
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Xử lý đăng nhập ──────────────────────────────────────────
  Future<void> _handleLogin() async {
    // Kiểm tra form hợp lệ
    if (!_formKey.currentState!.validate()) return;

    // Gọi ViewModel để đăng nhập
    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Đăng nhập thành công → chuyển đến trang chính
      Navigator.pushReplacementNamed(context, '/movie-list');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe state từ ViewModel
    final authState = ref.watch(authProvider);

    return Scaffold(
      // ─── AppBar ────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
        centerTitle: true,
      ),
      // ─── Body ──────────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo / Tiêu đề ──
              const Icon(Icons.movie, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'CGV Movie Booking',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // ── Ô nhập Email ──
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Ô nhập Password ──
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Ẩn mật khẩu
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // ── Hiển thị lỗi (nếu có) ──
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              // ── Nút Đăng nhập ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Link đăng ký ──
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## File: `lib/views/auth/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// RegisterScreen - Màn hình đăng ký tài khoản mới
/// Người phụ trách: Dat
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Xử lý đăng ký ────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/movie-list');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Ô nhập Họ tên ──
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập tên';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Ô nhập Email ──
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                  if (!value.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Ô nhập Mật khẩu ──
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Xác nhận mật khẩu ──
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // ── Hiển thị lỗi ──
              if (authState.error != null)
                Text(authState.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),

              // ── Nút Đăng ký ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ĐĂNG KÝ'),
                ),
              ),
              const SizedBox(height: 16),

              // ── Link quay lại đăng nhập ──
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đã có tài khoản? Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## File: `lib/views/auth/profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// ProfileScreen - Màn hình xem thông tin cá nhân
/// Người phụ trách: Dat
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy user hiện tại từ state
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
        actions: [
          // Nút chỉnh sửa profile
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: user == null
          // Chưa đăng nhập
          ? const Center(child: Text('Vui lòng đăng nhập'))
          // Đã đăng nhập → hiển thị thông tin
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // ── Avatar ──
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // ── Tên ──
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Role badge ──
                  Chip(
                    label: Text(user.role == 'admin' ? 'Admin' : 'Khách hàng'),
                    backgroundColor: user.role == 'admin' ? Colors.red : Colors.blue,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // ── Thông tin chi tiết ──
                  _buildInfoRow(Icons.email, 'Email', user.email),
                  _buildInfoRow(Icons.phone, 'Điện thoại', user.phone ?? 'Chưa cập nhật'),
                  _buildInfoRow(Icons.location_city, 'Thành phố', user.city ?? 'Chưa cập nhật'),
                  _buildInfoRow(Icons.map, 'Quận/Huyện', user.district ?? 'Chưa cập nhật'),

                  const SizedBox(height: 32),

                  // ── Nút Đăng xuất ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Widget hiển thị 1 dòng thông tin
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## File: `lib/views/auth/edit_profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// EditProfileScreen - Màn hình chỉnh sửa thông tin cá nhân
/// Người phụ trách: Dat
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;

  @override
  void initState() {
    super.initState();
    // Lấy user hiện tại để fill vào form
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  // ─── Xử lý lưu ────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(authProvider).user!;
    // Tạo user mới với thông tin đã chỉnh sửa
    final updatedUser = User(
      id: currentUser.id,
      name: _nameController.text.trim(),
      email: currentUser.email,        // Email không đổi
      password: currentUser.password,  // Password không đổi
      role: currentUser.role,          // Role không đổi
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
    );

    final success = await ref.read(authProvider.notifier).updateProfile(updatedUser);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh Sửa Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Họ tên ──
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Không được bỏ trống' : null,
              ),
              const SizedBox(height: 16),

              // ── Số điện thoại ──
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ── Thành phố ──
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Thành phố',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Quận/Huyện ──
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'Quận / Huyện',
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Nút Lưu ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LƯU THAY ĐỔI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
