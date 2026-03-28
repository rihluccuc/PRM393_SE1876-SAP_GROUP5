import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// LoginScreen - Màn hình đăng nhập
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error message
              if (authState.error != null)
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Đăng nhập'),
                ),
              ),

              const SizedBox(height: 16),

              // Register link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),

              // Test accounts
              const SizedBox(height: 32),
              const Text('Tài khoản test:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('User: user@gmail.com / user123'),
              const Text('Admin: admin@cgv.vn / admin123'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Navigate to home based on role
      final user = ref.read(authProvider).user;
      if (user?.role == 'admin') {
        Navigator.pushReplacementNamed(context, AppRoutes.statistics);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.movieList);
      }
    }
  }
}
