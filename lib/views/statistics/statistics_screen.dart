// lib/views/statistics/statistics_screen.dart
// =====================================================
// Màn hình: Thống kê & Báo cáo
// Hiển thị: Tổng quan, Top phim, Doanh thu, Thể loại
// Riverpod: overallStatsProvider, topMoviesProvider, v.v.
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/app_theme.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  /// Format số tiền sang VNĐ
  String _formatMoney(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ VNĐ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu VNĐ';
    }
    return '${NumberFormat('#,###', 'vi').format(amount)} VNĐ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe tất cả providers cần thiết
    final overallAsync  = ref.watch(overallStatsProvider);
    final topMoviesAsync = ref.watch(topMoviesProvider);
    final revenueAsync  = ref.watch(revenueByDateProvider);
    final genreAsync    = ref.watch(statsByGenreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Thống kê & Báo cáo'),
        actions: [
          // Nút refresh tất cả
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(overallStatsProvider);
              ref.invalidate(topMoviesProvider);
              ref.invalidate(revenueByDateProvider);
              ref.invalidate(statsByGenreProvider);
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accentColor,
        onRefresh: () async {
          ref.invalidate(overallStatsProvider);
          ref.invalidate(topMoviesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== SECTION 1: Tổng quan =====
              _buildSectionTitle('📈 Tổng quan hệ thống'),
              const SizedBox(height: 12),
              overallAsync.when(
                loading: () => _buildStatsSkeleton(),
                error: (e, _) => _buildError('Lỗi tải thống kê: $e'),
                data: (stats) => _buildOverallStats(stats),
              ),
              const SizedBox(height: 24),

              // ===== SECTION 2: Top phim bán chạy =====
              _buildSectionTitle('🏆 Top phim bán vé nhiều nhất'),
              const SizedBox(height: 12),
              topMoviesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentColor)),
                error: (e, _) => _buildError('Lỗi: $e'),
                data: (topMovies) => _buildTopMovies(topMovies),
              ),
              const SizedBox(height: 24),

              // ===== SECTION 3: Doanh thu theo ngày =====
              _buildSectionTitle('📅 Doanh thu 7 ngày gần nhất'),
              const SizedBox(height: 12),
              revenueAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentColor)),
                error: (e, _) => _buildError('Lỗi: $e'),
                data: (revenue) => _buildRevenueChart(revenue),
              ),
              const SizedBox(height: 24),

              // ===== SECTION 4: Thống kê theo thể loại =====
              _buildSectionTitle('🎭 Phân tích theo thể loại phim'),
              const SizedBox(height: 12),
              genreAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentColor)),
                error: (e, _) => _buildError('Lỗi: $e'),
                data: (genres) => _buildGenreStats(genres),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 4 card thống kê tổng quan
  Widget _buildOverallStats(Map<String, dynamic> stats) {
    final totalRevenue =
        (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          title: 'Tổng phim',
          value: '${stats['total_movies'] ?? 0}',
          icon: Icons.movie,
          color: AppTheme.accentColor,
          subtitle: 'phim đang chiếu',
        ),
        StatCard(
          title: 'Suất chiếu',
          value: '${stats['total_showtimes'] ?? 0}',
          icon: Icons.event,
          color: Colors.blueAccent,
          subtitle: 'suất chiếu active',
        ),
        StatCard(
          title: 'Vé đã bán',
          value: '${stats['total_tickets'] ?? 0}',
          icon: Icons.confirmation_number,
          color: AppTheme.goldColor,
          subtitle: 'tổng vé bán ra',
        ),
        StatCard(
          title: 'Doanh thu',
          value: _formatMoney(totalRevenue),
          icon: Icons.monetization_on,
          color: AppTheme.successColor,
          subtitle: 'tổng doanh thu',
        ),
      ],
    );
  }

  /// Skeleton loading cho stats
  Widget _buildStatsSkeleton() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: List.generate(
        4,
            (_) => Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
                color: AppTheme.accentColor, strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  /// Danh sách top phim bán chạy
  Widget _buildTopMovies(List<Map<String, dynamic>> movies) {
    if (movies.isEmpty || movies.every((m) => (m['ticket_count'] ?? 0) == 0)) {
      return _buildEmptyState('Chưa có dữ liệu vé bán');
    }

    return Column(
      children: movies.asMap().entries.map((entry) {
        final index = entry.key;
        final movie = entry.value;
        final ticketCount = movie['ticket_count'] ?? 0;
        final revenue = (movie['revenue'] as num?)?.toDouble() ?? 0.0;

        // Màu sắc top 3
        final rankColors = [
          AppTheme.goldColor,
          const Color(0xFFC0C0C0),
          const Color(0xFFCD7F32),
        ];
        final rankColor =
        index < 3 ? rankColors[index] : AppTheme.textSecondary;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: index < 3
                ? Border.all(color: rankColor.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              // Thứ hạng
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tên phim
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie['title'] ?? 'Không rõ',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      movie['genre'] ?? '',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Số vé + doanh thu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$ticketCount vé',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatMoney(revenue),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Biểu đồ bar chart đơn giản cho doanh thu theo ngày
  Widget _buildRevenueChart(List<Map<String, dynamic>> revenue) {
    if (revenue.isEmpty) {
      return _buildEmptyState('Chưa có dữ liệu doanh thu');
    }

    // Tìm giá trị max để vẽ bar
    final maxRevenue = revenue
        .map((r) => (r['revenue'] as num?)?.toDouble() ?? 0.0)
        .fold<double>(0, (a, b) => a > b ? a : b);

    if (maxRevenue == 0) return _buildEmptyState('Chưa có doanh thu');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Bar chart thủ công bằng Flutter
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: revenue.map((r) {
                final rev =
                    (r['revenue'] as num?)?.toDouble() ?? 0.0;
                final barHeight = maxRevenue > 0
                    ? (rev / maxRevenue * 130).clamp(4.0, 130.0)
                    : 4.0;
                final date = r['sale_date'] as String? ?? '';
                final shortDate =
                date.length >= 10 ? date.substring(5) : date;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tooltip giá trị
                        if (rev > 0)
                          Text(
                            '${(rev / 1000).round()}K',
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Bar
                        Expanded(
                        child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                        height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentColor,
                                AppTheme.accentColor.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        ),
                        ),
                        const SizedBox(height: 6),
                        // Label ngày
                        Text(
                          shortDate,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Tổng doanh thu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng 7 ngày:',
                  style: TextStyle(color: AppTheme.textSecondary)),
              Text(
                _formatMoney(revenue.fold<double>(
                  0,
                      (sum, r) => sum + ((r['revenue'] as num?)?.toDouble() ?? 0),
                )),
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Thống kê theo thể loại - progress bar
  Widget _buildGenreStats(List<Map<String, dynamic>> genres) {
    if (genres.isEmpty) {
      return _buildEmptyState('Chưa có dữ liệu');
    }

    // Tổng doanh thu để tính %
    final totalRevenue = genres.fold<double>(
      0,
          (sum, g) => sum + ((g['revenue'] as num?)?.toDouble() ?? 0),
    );

    final genreColors = [
      AppTheme.accentColor,
      Colors.blueAccent,
      AppTheme.goldColor,
      AppTheme.successColor,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];

    return Column(
      children: genres.asMap().entries.map((entry) {
        final i = entry.key;
        final g = entry.value;
        final revenue = (g['revenue'] as num?)?.toDouble() ?? 0.0;
        final percent =
        totalRevenue > 0 ? revenue / totalRevenue : 0.0;
        final color = genreColors[i % genreColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    g['genre'] ?? 'Không rõ',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${g['movie_count'] ?? 0} phim · ${g['ticket_count'] ?? 0} vé',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(percent * 100).toStringAsFixed(1)}% doanh thu',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                  Text(
                    _formatMoney(revenue),
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.bar_chart_outlined,
                color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(msg, style: const TextStyle(color: Colors.redAccent)),
    );
  }
}