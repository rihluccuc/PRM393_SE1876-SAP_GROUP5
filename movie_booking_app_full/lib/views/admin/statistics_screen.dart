import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/loading_widget.dart';

/// StatisticsScreen - Màn hình thống kê cho admin
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: adminState.isLoading
          ? const LoadingWidget(message: 'Đang tải thống kê...')
          : adminState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Lỗi: ${adminState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(adminProvider.notifier).loadStatistics();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(adminProvider.notifier).loadStatistics();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text(
                          'Tổng quan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Statistics cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Tổng phim',
                                adminState.totalMovies.toString(),
                                Icons.movie,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Tổng vé',
                                adminState.totalBookings.toString(),
                                Icons.confirmation_number,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildStatCard(
                          'Tổng doanh thu',
                          '${NumberFormat('#,###').format(adminState.totalRevenue)} VND',
                          Icons.attach_money,
                          Colors.orange,
                          isFullWidth: true,
                        ),

                        const SizedBox(height: 32),

                        // Quick actions
                        const Text(
                          'Quản lý',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildActionCard(
                              'Thêm phim',
                              Icons.add_circle,
                              Colors.blue,
                              () {
                                Navigator.pushNamed(context, '/add-movie');
                              },
                            ),
                            _buildActionCard(
                              'Quản lý rạp',
                              Icons.location_city,
                              Colors.green,
                              () {
                                Navigator.pushNamed(context, '/manage-cinema');
                              },
                            ),
                            _buildActionCard(
                              'Thêm suất chiếu',
                              Icons.schedule,
                              Colors.orange,
                              () {
                                Navigator.pushNamed(context, '/add-showtime');
                              },
                            ),
                            _buildActionCard(
                              'Danh sách phim',
                              Icons.list,
                              Colors.purple,
                              () {
                                ref.read(adminProvider.notifier).loadMovies();
                                // TODO: Navigate to movie list
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Recent activity
                        const Text(
                          'Hoạt động gần đây',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildActivityItem(
                          'Phim mới: Avengers: Endgame',
                          'Đã thêm vào hệ thống',
                          '2 giờ trước',
                          Icons.movie,
                        ),
                        _buildActivityItem(
                          'Rạp mới: CGV Vincom',
                          'Đã được cập nhật',
                          '5 giờ trước',
                          Icons.location_city,
                        ),
                        _buildActivityItem(
                          'Đặt vé: 15 vé',
                          'Đã được bán trong ngày',
                          '1 ngày trước',
                          Icons.confirmation_number,
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(adminProvider.notifier).loadStatistics();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Làm mới',
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
