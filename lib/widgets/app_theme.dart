// lib/widgets/app_theme.dart
// =====================================================
// AppTheme: Định nghĩa màu sắc, font, style toàn app
// =====================================================

import 'dart:io';
import 'package:flutter/material.dart';

class AppTheme {
  // ---- Bảng màu chính ----
  static const Color primaryColor   = Color(0xFF1A1A2E); // Navy đậm
  static const Color secondaryColor = Color(0xFF16213E); // Navy vừa
  static const Color accentColor    = Color(0xFFE94560);  // Đỏ-hồng nổi bật
  static const Color goldColor      = Color(0xFFFFD700);  // Vàng nhấn
  static const Color surfaceColor   = Color(0xFF0F3460); // Xanh đậm
  static const Color cardColor      = Color(0xFF1E2A4A); // Card nền
  static const Color textPrimary    = Color(0xFFFFFFFF); // Trắng
  static const Color textSecondary  = Color(0xFFB0BEC5); // Xám nhạt
  static const Color successColor   = Color(0xFF4CAF50); // Xanh lá
  static const Color warningColor   = Color(0xFFFF9800); // Cam

  /// Trả về ThemeData cho toàn bộ app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: goldColor,
        surface: secondaryColor,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: surfaceColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: surfaceColor.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }
}

// =====================================================
// Reusable Widgets dùng chung cho nhiều màn hình
// =====================================================

/// Widget hiển thị ảnh phim từ assets hoặc file path.
/// Nếu không có ảnh (hoặc ảnh lỗi), tự vẽ poster placeholder bằng Flutter —
/// không cần file ảnh trong assets.
class MoviePosterWidget extends StatelessWidget {
  final String? imagePath;
  final String? movieTitle;   // Truyền tên phim để hiển thị trên placeholder
  final double width;
  final double height;
  final double borderRadius;

  const MoviePosterWidget({
    super.key,
    this.imagePath,
    this.movieTitle,
    this.width = 80,
    this.height = 110,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPosterPlaceholder();
    }

    // Ảnh từ assets (tên bắt đầu bằng 'assets/')
    if (imagePath!.startsWith('assets/')) {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPosterPlaceholder(),
      );
    }

    // Ảnh từ file thật trong máy (đường dẫn tuyệt đối do image_picker trả về)
    return Image.file(
      File(imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPosterPlaceholder(),
    );
  }

  /// Vẽ poster phim giả bằng Flutter — trông như poster thật,
  /// không cần file ảnh nào trong assets.
  Widget _buildPosterPlaceholder() {
    // Tạo màu nền ngẫu nhiên dựa theo tên phim (nhất quán mỗi lần render)
    final colors = [
      [const Color(0xFF1A237E), const Color(0xFF283593)], // indigo
      [const Color(0xFF4A148C), const Color(0xFF6A1B9A)], // purple
      [const Color(0xFF880E4F), const Color(0xFFAD1457)], // pink
      [const Color(0xFF006064), const Color(0xFF00838F)], // teal
      [const Color(0xFF1B5E20), const Color(0xFF2E7D32)], // green
      [const Color(0xFFE65100), const Color(0xFFF57C00)], // orange
      [const Color(0xFF37474F), const Color(0xFF546E7A)], // blue-grey
    ];
    // Chọn màu dựa theo hash của tên phim → cùng phim luôn cùng màu
    final idx = (movieTitle ?? '').hashCode.abs() % colors.length;
    final bgTop = colors[idx][0];
    final bgBot = colors[idx][1];

    // Lấy chữ cái đầu của mỗi từ trong tên phim (tối đa 2 chữ)
    final initials = _getInitials(movieTitle ?? '?');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgTop, bgBot],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // --- Hoa văn trang trí góc trên phải ---
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: width * 0.6,
              height: width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // --- Hoa văn trang trí góc dưới trái ---
          Positioned(
            bottom: -8,
            left: -8,
            child: Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // --- Nội dung chính: icon + initials + "MOVIE" ---
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon máy quay
              Icon(
                Icons.movie_creation_outlined,
                color: Colors.white.withOpacity(0.5),
                size: width * 0.3,
              ),
              const SizedBox(height: 4),
              // Chữ cái đầu tên phim
              Text(
                initials,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              // Label "MOVIE" nhỏ phía dưới
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'MOVIE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: width * 0.1,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lấy chữ cái đầu: "Avengers Endgame" → "AE", "Inception" → "IN"
  String _getInitials(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      // Chỉ 1 từ → lấy 2 chữ cái đầu
      return title.length >= 2
          ? title.substring(0, 2).toUpperCase()
          : title.toUpperCase();
    }
    // Nhiều từ → lấy chữ đầu của 2 từ đầu tiên
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Badge hiển thị trạng thái (active/inactive, loại phòng...)
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Card thống kê hiển thị số liệu + icon
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Giá trị chính
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Phụ đề (nếu có)
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog xác nhận xóa
Future<bool?> showDeleteConfirmDialog(
    BuildContext context, {
      required String title,
      required String content,
    }) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
      content: Text(content, style: const TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Xóa'),
        ),
      ],
    ),
  );
}

/// SnackBar thông báo thành công
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppTheme.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// SnackBar thông báo lỗi
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 4),
    ),
  );
}