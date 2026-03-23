// lib/views/add_showtime/add_showtime_screen.dart
// =====================================================
// Màn hình: Thêm / Quản lý Lịch chiếu phim
// Riverpod: showtimeViewModelProvider + activeMoviesProvider + hallsProvider
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/cinema_model.dart';
import '../../models/movie_model.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/app_theme.dart';

class AddShowtimeScreen extends ConsumerStatefulWidget {
  const AddShowtimeScreen({super.key});

  @override
  ConsumerState<AddShowtimeScreen> createState() => _AddShowtimeScreenState();
}

class _AddShowtimeScreenState extends ConsumerState<AddShowtimeScreen>
    with SingleTickerProviderStateMixin {
  // ---- Tab controller: Tab 1 = Thêm mới, Tab 2 = Danh sách ----
  late TabController _tabController;

  // ---- State cho form thêm lịch chiếu ----
  final _formKey = GlobalKey<FormState>();
  Movie? _selectedMovie;         // Phim được chọn
  Hall? _selectedHall;           // Phòng chiếu được chọn
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  final TextEditingController _priceCtrl =
  TextEditingController(text: '75000');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  /// Tính giờ kết thúc tự động dựa vào thời lượng phim
  void _autoCalculateEndTime() {
    if (_selectedMovie == null) return;
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = startMinutes + _selectedMovie!.duration + 15; // +15 phút dọn dẹp
    setState(() {
      _endTime = TimeOfDay(
        hour: (endMinutes ~/ 60) % 24,
        minute: endMinutes % 60,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          const ColorScheme.dark(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          const ColorScheme.dark(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
      _autoCalculateEndTime(); // Tự tính giờ kết thúc
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          const ColorScheme.dark(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submitShowtime() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMovie == null) {
      showErrorSnackBar(context, 'Vui lòng chọn phim');
      return;
    }
    if (_selectedHall == null) {
      showErrorSnackBar(context, 'Vui lòng chọn phòng chiếu');
      return;
    }

    final showtime = Showtime(
      movieId: _selectedMovie!.id!,
      hallId: _selectedHall!.id!,
      showDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      ticketPrice:
      double.tryParse(_priceCtrl.text.trim()) ?? 75000,
      availableSeats: _selectedHall!.capacity,
    );

    final vm = ref.read(showtimeViewModelProvider.notifier);
    final success = await vm.addShowtime(showtime);

    if (mounted) {
      final state = ref.read(showtimeViewModelProvider);
      if (success) {
        showSuccessSnackBar(context, 'Thêm lịch chiếu thành công!');
        // Chuyển sang tab danh sách
        _tabController.animateTo(1);
        // Reset form
        setState(() {
          _selectedMovie = null;
          _selectedHall = null;
        });
      } else if (state.errorMessage != null) {
        showErrorSnackBar(context, state.errorMessage!);
        vm.clearMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕐 Lịch chiếu phim'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Thêm lịch chiếu'),
            Tab(icon: Icon(Icons.list_alt), text: 'Danh sách'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddForm(),
          _buildShowtimeList(),
        ],
      ),
    );
  }

  // ---- Tab 1: Form thêm lịch chiếu ----
  Widget _buildAddForm() {
    // Lấy danh sách phim và phòng chiếu từ Riverpod
    final moviesAsync = ref.watch(activeMoviesProvider);
    final hallsAsync  = ref.watch(hallsProvider);
    final state       = ref.watch(showtimeViewModelProvider);

    return moviesAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (movies) => hallsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (halls) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Chọn phim ----
                _buildSectionLabel('🎬 Chọn phim'),
                const SizedBox(height: 8),
                _buildMovieSelector(movies),
                const SizedBox(height: 16),

                // ---- Chọn phòng chiếu ----
                _buildSectionLabel('🏛️ Chọn phòng chiếu'),
                const SizedBox(height: 8),
                _buildHallSelector(halls),
                const SizedBox(height: 16),

                // ---- Chọn ngày ----
                _buildSectionLabel('📅 Ngày chiếu'),
                const SizedBox(height: 8),
                _buildDateSelector(),
                const SizedBox(height: 16),

                // ---- Chọn giờ ----
                _buildSectionLabel('⏰ Giờ chiếu'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTimeSelector('Bắt đầu', _startTime, _pickStartTime)),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward,
                        color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTimeSelector('Kết thúc', _endTime, _pickEndTime)),
                  ],
                ),
                if (_selectedMovie != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 Thời lượng phim: ${_selectedMovie!.duration} phút',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 16),

                // ---- Giá vé ----
                _buildSectionLabel('🎫 Giá vé (VNĐ)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Giá vé',
                    prefixIcon: Icon(Icons.attach_money,
                        color: AppTheme.textSecondary),
                    suffixText: 'VNĐ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nhập giá vé';
                    if (double.tryParse(v) == null) return 'Phải là số';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ---- Nút thêm ----
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _submitShowtime,
                    icon: state.isLoading
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_circle),
                    label: Text(
                      state.isLoading ? 'Đang thêm...' : 'Thêm lịch chiếu',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSelector(List<Movie> movies) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceColor.withOpacity(0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Movie>(
          value: _selectedMovie,
          isExpanded: true,
          isDense: true, // 👉 THÊM DÒNG NÀY
          dropdownColor: AppTheme.cardColor,
          hint: const Text('-- Chọn phim --',
              style: TextStyle(color: AppTheme.textSecondary)),
          style: const TextStyle(color: AppTheme.textPrimary),
          items: movies
              .map((m) => DropdownMenuItem(
            value: m,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  MoviePosterWidget(
                    imagePath: m.imagePath,
                    movieTitle: m.title,
                    width: 40,
                    height: 55,
                    borderRadius: 6,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${m.title} (${m.duration} phút)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ))
              .toList(),
          onChanged: (m) {
            setState(() => _selectedMovie = m);
            if (m != null) _autoCalculateEndTime();
          },
        ),
      ),
    );
  }

  Widget _buildHallSelector(List<Hall> halls) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceColor.withOpacity(0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Hall>(
          value: _selectedHall,
          isExpanded: true,
          dropdownColor: AppTheme.cardColor,
          hint: const Text('-- Chọn phòng chiếu --',
              style: TextStyle(color: AppTheme.textSecondary)),
          style: const TextStyle(color: AppTheme.textPrimary),
          items: halls
              .map((h) => DropdownMenuItem(
            value: h,
            child: Row(
              children: [
                Icon(
                  h.hallType == 'imax'
                      ? Icons.hd
                      : h.hallType == 'vip'
                      ? Icons.star
                      : Icons.weekend,
                  color: AppTheme.goldColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text('${h.name} (${h.capacity} ghế - ${h.hallType.toUpperCase()})'),
              ],
            ),
          ))
              .toList(),
          onChanged: (h) => setState(() => _selectedHall = h),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.surfaceColor.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppTheme.accentColor, size: 18),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
      String label, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.surfaceColor.withOpacity(0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ---- Tab 2: Danh sách lịch chiếu ----
  Widget _buildShowtimeList() {
    final showtimesAsync = ref.watch(showtimesProvider);

    return showtimesAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Lỗi: $e', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      data: (showtimes) {
        if (showtimes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, color: AppTheme.textSecondary, size: 64),
                SizedBox(height: 16),
                Text(
                  'Chưa có lịch chiếu nào\nHãy thêm lịch chiếu mới!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: showtimes.length,
          itemBuilder: (ctx, i) {
            final s = showtimes[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh
                    MoviePosterWidget(
                      imagePath: s.movieImage,
                      movieTitle: s.movieTitle,
                      width: 50,
                      height: 70,
                      borderRadius: 8,
                    ),

                    const SizedBox(width: 12),

                    // Nội dung
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.movieTitle ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12),
                              const SizedBox(width: 4),
                              Text(s.showDate, style: const TextStyle(fontSize: 12)),

                              const SizedBox(width: 10),

                              const Icon(Icons.meeting_room, size: 12),
                              const SizedBox(width: 4),
                              Text(s.hallName ?? '', style: const TextStyle(fontSize: 12)),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '${NumberFormat('#,###', 'vi').format(s.ticketPrice)} VNĐ/vé',
                            style: const TextStyle(
                              color: AppTheme.goldColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right side
                    Column(
                      children: [
                        StatusBadge(
                          label: s.status == 'active' ? 'Active' : s.status,
                          color: s.status == 'active'
                              ? AppTheme.successColor
                              : Colors.orange,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDeleteShowtime(s.id!),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteShowtime(int id) async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Xóa lịch chiếu',
      content: 'Bạn có chắc muốn xóa lịch chiếu này không?',
    );
    if (confirmed == true && mounted) {
      final vm = ref.read(showtimeViewModelProvider.notifier);
      await vm.deleteShowtime(id);
      final state = ref.read(showtimeViewModelProvider);
      if (state.successMessage != null) {
        showSuccessSnackBar(context, state.successMessage!);
        vm.clearMessages();
      }
    }
  }
}