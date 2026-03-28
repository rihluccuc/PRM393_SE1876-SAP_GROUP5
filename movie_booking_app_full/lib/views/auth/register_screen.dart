import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// RegisterScreen - Màn hình đăng ký
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
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    // Simple email regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Validate phone number (Vietnamese format)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    // Vietnamese phone: 10 digits, starting with 0
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại phải là 10 chữ số, bắt đầu bằng 0';
    }
    return null;
  }

  // Validate name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.length < 3) {
      return 'Họ tên phải có ít nhất 3 ký tự';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    return null;
  }

  // Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên *',
                  hintText: 'Nhập đầy đủ họ tên của bạn',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  hintText: '0xxxxxxxxx',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // City field
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Thành phố',
                  hintText: 'Vd: Hà Nội, TP. Hồ Chí Minh',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Tên thành phố phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // District field
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'Phường/Xã',
                  hintText: 'Vd: Đống Đa, Hai Bà Trưng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Tên Phường/Xã phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu *',
                  hintText: 'Tối thiểu 8 ký tự',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 24),

              // Error message
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),

              const SizedBox(height: 16),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Đăng ký',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập ngay'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Note about required fields
              Text(
                '(*) Là các trường bắt buộc',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
    );

    if (success && mounted) {
      // Navigate to login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
