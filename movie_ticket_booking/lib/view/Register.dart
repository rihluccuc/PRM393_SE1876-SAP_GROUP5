import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/AuthViewmodels.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final phoneController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) =>
                v!.isEmpty ? "Không được để trống" : null,
              ),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v!.isEmpty) {
                    return "Không được để trống";
                  }
                  if (!isValidEmail(v)) {
                    return "Email không hợp lệ";
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) {
                  if (v!.isEmpty) {
                    return "Không được để trống";
                  }
                  if (v.length < 8) {
                    return "Mật khẩu phải có ít nhất 8 ký tự";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// City field
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) =>
                v!.isEmpty ? "Không được để trống" : null,
              ),

              const SizedBox(height: 16),

              /// District field
              TextFormField(
                controller: districtController,
                decoration: const InputDecoration(labelText: "District"),
                validator: (v) =>
                v!.isEmpty ? "Không được để trống" : null,
              ),

              const SizedBox(height: 16),

              /// Phone field
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v!.isEmpty) {
                    return "Không được để trống";
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(v)) {
                    return "Số điện thoại phải có 10-11 chữ số";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final (success, error) = await ref
                        .read(authViewModelProvider.notifier)
                        .register(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      cityController.text,
                      districtController.text,
                      phoneController.text,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Register success")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Register failed: ${error ?? 'Unknown error'}")),
                      );
                    }
                  }
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}