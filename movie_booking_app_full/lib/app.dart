import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/movie/movie_list_screen.dart';
import 'views/admin/statistics_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'models/user.dart';

/// MyApp - Root widget của ứng dụng
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái đăng nhập
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'CGV Cinema',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Tự động theo hệ thống

      // Route management
      initialRoute: authState.user != null ? AppRoutes.home : AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,

      // Home screen dựa trên role
      home: _buildHomeScreen(authState.user),
    );
  }

  /// Xây dựng home screen dựa trên user role
  Widget? _buildHomeScreen(User? user) {
    if (user == null) {
      return const LoginScreen();
    }

    // Nếu là admin → đi thẳng đến admin screen
    if (user.role == 'admin') {
      return const StatisticsScreen();
    }

    // Nếu là user thường → đi đến movie list
    return const MovieListScreen();
  }
}
