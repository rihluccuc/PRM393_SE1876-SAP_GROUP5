// lib/main.dart
// =====================================================
// Entry point của ứng dụng Cinema Admin
// Khởi tạo Riverpod ProviderScope bao bọc toàn bộ app
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/home/home_screen.dart';
import 'widgets/app_theme.dart';

void main() async {
  // Đảm bảo Flutter binding khởi tạo trước khi dùng plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo locale tiếng Việt cho package intl (format ngày giờ)
  await initializeDateFormatting('vi', null);

  runApp(
    // ProviderScope: BẮT BUỘC phải bọc toàn bộ app khi dùng Riverpod
    // Đây là nơi lưu trữ tất cả trạng thái (state) của các provider
    const ProviderScope(
      child: CinemaAdminApp(),
    ),
  );
}

class CinemaAdminApp extends StatelessWidget {
  const CinemaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Admin',
      debugShowCheckedModeBanner: false,  // Ẩn banner debug
      theme: AppTheme.darkTheme,           // Theme tối sang trọng
      home: const HomeScreen(),            // Màn hình chính
    );
  }
}