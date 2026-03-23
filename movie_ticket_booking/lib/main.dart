import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_ticket_booking/view/Login.dart';
import 'services/LocalStorageService.dart';
import 'view/HomePage.dart';
import 'view/AdminPage.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

/// Splash screen để kiểm tra user đã đăng nhập chưa
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final localStorageService = LocalStorageService();
    final user = await localStorageService.getUser();

    if (mounted) {
      if (user != null) {
        // User đã đăng nhập, navigate dựa trên role
        if (user.role == "admin") {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AdminPage(user: user)),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(user: user)),
            (route) => false,
          );
        }
      } else {
        // Chưa đăng nhập, go to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}