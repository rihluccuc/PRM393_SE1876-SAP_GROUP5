import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// EditProfileScreen - Màn hình chỉnh sửa hồ sơ
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _showPasswordSection = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate phone number (Vietnamese format)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin cá nhân',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email (read-only)
                          TextFormField(
                            initialValue: user.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ tên *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 16),

                          // Phone
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

                          // City
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

                          // District
                          TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'Quận/Huyện',
                              hintText: 'Vd: Quận 1, Huyện Thanh Oai',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.map),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 2) {
                                return 'Tên quận/huyện phải có ít nhất 2 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Error message for profile
                          if (authState.error != null && !_showPasswordSection)
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

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: authState.isLoading ? null : _updateProfile,
                              icon: const Icon(Icons.save),
                              label: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Lưu thay đổi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password Change Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đổi mật khẩu',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: Icon(
                            _showPasswordSection
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPasswordSection = !_showPasswordSection;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_showPasswordSection) ...[
                      const SizedBox(height: 16),
                      Form(
                        key: _passwordFormKey,
                        child: Column(
                          children: [
                            // Old password
                            TextFormField(
                              controller: _oldPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu hiện tại *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu hiện tại';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // New password
                            TextFormField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu mới *',
                                hintText: 'Tối thiểu 6 ký tự',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),

                            // Confirm password
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Xác nhận mật khẩu mới *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Mật khẩu xác nhận không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Error message for password
                            if (authState.error != null && _showPasswordSection)
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

                            // Change password button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: authState.isLoading ? null : _changePassword,
                                icon: const Icon(Icons.check),
                                label: authState.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Đổi mật khẩu'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final updatedUser = User(
      id: user.id,
      name: _nameController.text.trim(),
      email: user.email,
      password: user.password,
      role: user.role,
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
    );

    final success = await ref.read(authProvider.notifier).updateProfile(updatedUser);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).changePassword(
      _oldPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _showPasswordSection = false;
        });
      }
    }
  }
}
