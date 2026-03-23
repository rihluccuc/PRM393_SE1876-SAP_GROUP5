// lib/views/home/home_screen.dart
// =====================================================
// Màn hình chính: Dashboard Admin
// Hiển thị 4 menu chức năng như trong yêu cầu:
//   - Add Movie, Add Showtime, Manage Cinema, Statistics
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/app_theme.dart';
import '../add_movie/add_movie_screen.dart';
import '../add_showtime/add_showtime_screen.dart';
import '../manage_cinema/manage_cinema_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe stats để hiển thị số liệu trên dashboard
    final overallAsync = ref.watch(overallStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---- AppBar cuộn được ----
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.secondaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'CINEMA ADMIN',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient nền AppBar
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.accentColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Pattern trang trí
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    bottom: 50,
                    child: Icon(
                      Icons.movie_filter,
                      size: 48,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Mini stats header ----
                  overallAsync.when(
                    loading: () => const SizedBox(height: 8),
                    error: (_, __) => const SizedBox(),
                    data: (stats) => _buildMiniStats(stats),
                  ),
                  const SizedBox(height: 24),

                  // ---- Label "Quản lý" ----
                  const Text(
                    'CHỨC NĂNG QUẢN LÝ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- 4 Menu chính (2x2 grid) ----
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _MenuCard(
                        title: 'Add Movie',
                        subtitle: 'Thêm phim mới\nvào hệ thống',
                        icon: Icons.movie_creation,
                        color: AppTheme.accentColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddMovieScreen(),
                          ),
                        ).then((_) => ref.invalidate(overallStatsProvider)),
                      ),
                      _MenuCard(
                        title: 'Add Showtime',
                        subtitle: 'Tạo lịch chiếu\nphim mới',
                        icon: Icons.event_available,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddShowtimeScreen(),
                          ),
                        ).then((_) => ref.invalidate(overallStatsProvider)),
                      ),
                      _MenuCard(
                        title: 'Manage Cinema',
                        subtitle: 'Quản lý rạp\nvà phòng chiếu',
                        icon: Icons.business,
                        color: AppTheme.goldColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageCinemaScreen(),
                          ),
                        ).then((_) => ref.invalidate(overallStatsProvider)),
                      ),
                      _MenuCard(
                        title: 'Statistics',
                        subtitle: 'Báo cáo &\nthống kê doanh thu',
                        icon: Icons.bar_chart,
                        color: AppTheme.successColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---- Danh sách phim gần đây ----
                  const Text(
                    'PHIM MỚI THÊM',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentMoviesList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mini stats bar ở đầu trang
  Widget _buildMiniStats(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.2),
            AppTheme.surfaceColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: AppTheme.accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _MiniStat(
              label: 'Phim', value: '${stats['total_movies'] ?? 0}'),
          _Divider(),
          _MiniStat(
              label: 'Suất chiếu',
              value: '${stats['total_showtimes'] ?? 0}'),
          _Divider(),
          _MiniStat(
              label: 'Vé bán',
              value: '${stats['total_tickets'] ?? 0}'),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.surfaceColor.withOpacity(0.7),
    );
  }
}

/// Card menu chức năng
class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Danh sách phim vừa thêm (dùng Riverpod để lấy dữ liệu)
class _RecentMoviesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(moviesProvider);

    return moviesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor)),
      error: (e, _) => Text('Lỗi: $e',
          style: const TextStyle(color: Colors.red)),
      data: (movies) {
        if (movies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Chưa có phim nào. Hãy thêm phim đầu tiên!',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        // Chỉ hiển thị 5 phim gần nhất
        final recent = movies.take(5).toList();

        return Column(
          children: recent.map((movie) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Poster phim
                  MoviePosterWidget(
                    imagePath: movie.imagePath,
                    width: 44,
                    height: 60,
                    borderRadius: 6,
                  ),
                  const SizedBox(width: 12),
                  // Thông tin phim
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (movie.genre != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  movie.genre!,
                                  style: const TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            const Icon(Icons.timer,
                                size: 12,
                                color: AppTheme.textSecondary),
                            const SizedBox(width: 2),
                            Text(
                              '${movie.duration} phút',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rating + status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.goldColor, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      StatusBadge(
                        label: movie.status == 'active' ? 'Active' : 'Off',
                        color: movie.status == 'active'
                            ? AppTheme.successColor
                            : Colors.grey,
                      ),
                    ],
                  ),
                  // Nút Edit
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddMovieScreen(existingMovie: movie),
                      ),
                    ).then((_) => ref.invalidate(moviesProvider)),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}