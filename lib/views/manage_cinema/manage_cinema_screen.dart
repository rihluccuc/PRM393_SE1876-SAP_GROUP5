// lib/views/manage_cinema/manage_cinema_screen.dart
// =====================================================
// Màn hình: Quản lý Rạp chiếu phim
// Tab 1: Danh sách rạp + Thêm rạp
// Tab 2: Quản lý phòng chiếu (Hall)
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cinema_model.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/app_theme.dart';

class ManageCinemaScreen extends ConsumerStatefulWidget {
  const ManageCinemaScreen({super.key});

  @override
  ConsumerState<ManageCinemaScreen> createState() => _ManageCinemaScreenState();
}

class _ManageCinemaScreenState extends ConsumerState<ManageCinemaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏛️ Quản lý rạp chiếu'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Rạp chiếu'),
            Tab(icon: Icon(Icons.meeting_room), text: 'Phòng chiếu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CinemaTab(),
          _HallTab(),
        ],
      ),
    );
  }
}

// =====================================================
// Tab 1: Danh sách rạp chiếu + CRUD
// =====================================================

class _CinemaTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cinemasAsync = ref.watch(cinemasProvider);

    return Scaffold(
      // FAB thêm rạp mới
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCinemaDialog(context, ref),
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Thêm rạp'),
      ),
      body: cinemasAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (cinemas) {
          if (cinemas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined,
                      size: 72, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có rạp chiếu nào\nNhấn nút + để thêm rạp mới',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: cinemas.length,
            itemBuilder: (ctx, i) => _CinemaCard(cinema: cinemas[i]),
          );
        },
      ),
    );
  }

  void _showAddCinemaDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CinemaFormDialog(existingCinema: null, ref: ref),
    );
  }
}

/// Card hiển thị thông tin 1 rạp chiếu
class _CinemaCard extends ConsumerWidget {
  final Cinema cinema;
  const _CinemaCard({required this.cinema});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tên rạp + actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie_creation,
                      color: AppTheme.accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cinema.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cinema.totalHalls} phòng chiếu',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Nút Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppTheme.goldColor, size: 20),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _CinemaFormDialog(
                        existingCinema: cinema, ref: ref),
                  ),
                  tooltip: 'Chỉnh sửa',
                ),
                // Nút Xóa
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteCinema(context, ref),
                  tooltip: 'Xóa',
                ),
              ],
            ),
            const Divider(height: 20),
            // Thông tin chi tiết
            _InfoRow(Icons.location_on, cinema.address),
            if (cinema.phone != null && cinema.phone!.isNotEmpty)
              _InfoRow(Icons.phone, cinema.phone!),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCinema(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Xóa rạp chiếu',
      content:
      'Xóa rạp "${cinema.name}" sẽ xóa tất cả phòng chiếu và lịch chiếu liên quan. Tiếp tục?',
    );
    if (confirmed == true) {
      final vm = ref.read(cinemaViewModelProvider.notifier);
      await vm.deleteCinema(cinema.id!, cinema.name);
      if (context.mounted) {
        final state = ref.read(cinemaViewModelProvider);
        if (state.successMessage != null) {
          showSuccessSnackBar(context, state.successMessage!);
          vm.clearMessages();
        }
      }
    }
  }
}

/// Row thông tin 1 dòng (icon + text)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// Dialog thêm / chỉnh sửa rạp chiếu
class _CinemaFormDialog extends ConsumerStatefulWidget {
  final Cinema? existingCinema;
  final WidgetRef ref;

  const _CinemaFormDialog({this.existingCinema, required this.ref});

  @override
  ConsumerState<_CinemaFormDialog> createState() => _CinemaFormDialogState();
}

class _CinemaFormDialogState extends ConsumerState<_CinemaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;

  bool get _isEdit => widget.existingCinema != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCinema;
    _nameCtrl    = TextEditingController(text: c?.name ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _phoneCtrl   = TextEditingController(text: c?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cinema = Cinema(
      id: widget.existingCinema?.id,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      totalHalls: widget.existingCinema?.totalHalls ?? 0,
    );

    final vm = ref.read(cinemaViewModelProvider.notifier);
    final success =
    _isEdit ? await vm.updateCinema(cinema) : await vm.addCinema(cinema);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        final state = ref.read(cinemaViewModelProvider);
        if (state.successMessage != null) {
          showSuccessSnackBar(context, state.successMessage!);
          vm.clearMessages();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cinemaViewModelProvider);

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(
        _isEdit ? '✏️ Chỉnh sửa rạp' : '🏛️ Thêm rạp mới',
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_nameCtrl, 'Tên rạp *', Icons.business, required: true),
              const SizedBox(height: 12),
              _buildField(_addressCtrl, 'Địa chỉ *', Icons.location_on, required: true),
              const SizedBox(height: 12),
              _buildField(_phoneCtrl, 'Số điện thoại', Icons.phone),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading
              ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEdit ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  Widget _buildField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        bool required = false,
      }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Không được để trống' : null
          : null,
    );
  }
}

// =====================================================
// Tab 2: Quản lý phòng chiếu (Hall)
// =====================================================

class _HallTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallsAsync   = ref.watch(hallsProvider);
    final cinemasAsync = ref.watch(cinemasProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => cinemasAsync.whenData(
              (cinemas) => showDialog(
            context: context,
            builder: (_) =>
                _HallFormDialog(cinemas: cinemas, ref: ref),
          ),
        ),
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Thêm phòng'),
      ),
      body: hallsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (halls) => cinemasAsync.when(
          loading: () => const SizedBox(),
          error: (e, _) => const SizedBox(),
          data: (cinemas) {
            if (halls.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room_outlined,
                        size: 72, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có phòng chiếu nào',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            // Nhóm halls theo cinema
            final Map<int, List<Hall>> grouped = {};
            for (final h in halls) {
              grouped.putIfAbsent(h.cinemaId, () => []).add(h);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              children: grouped.entries.map((entry) {
                // Tìm tên rạp
                final cinema = cinemas.firstWhere(
                      (c) => c.id == entry.key,
                  orElse: () => Cinema(
                      name: 'Rạp #${entry.key}',
                      address: '',
                      id: entry.key),
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header tên rạp
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.business,
                              color: AppTheme.accentColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            cinema.name,
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Danh sách phòng
                    ...entry.value.map(
                          (h) => _HallCard(hall: h, ref: ref),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// Card 1 phòng chiếu
class _HallCard extends ConsumerWidget {
  final Hall hall;
  final WidgetRef ref;
  const _HallCard({required this.hall, required this.ref});

  Color get _typeColor {
    switch (hall.hallType) {
      case 'vip':
        return AppTheme.goldColor;
      case 'imax':
        return Colors.blueAccent;
      default:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            hall.hallType == 'imax'
                ? Icons.hd
                : hall.hallType == 'vip'
                ? Icons.star
                : Icons.weekend,
            color: _typeColor,
          ),
        ),
        title: Text(hall.name,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${hall.capacity} ghế · ${hall.hallType.toUpperCase()}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(label: hall.hallType.toUpperCase(), color: _typeColor),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _deleteHall(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteHall(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Xóa phòng chiếu',
      content: 'Xóa phòng "${hall.name}"? Các lịch chiếu trong phòng này cũng sẽ bị xóa.',
    );
    if (confirmed == true && context.mounted) {
      final vm = ref.read(cinemaViewModelProvider.notifier);
      await vm.deleteHall(hall.id!, hall.cinemaId, hall.name);
      final state = ref.read(cinemaViewModelProvider);
      if (state.successMessage != null && context.mounted) {
        showSuccessSnackBar(context, state.successMessage!);
        vm.clearMessages();
      }
    }
  }
}

/// Dialog thêm phòng chiếu
class _HallFormDialog extends ConsumerStatefulWidget {
  final List<Cinema> cinemas;
  final WidgetRef ref;
  const _HallFormDialog({required this.cinemas, required this.ref});

  @override
  ConsumerState<_HallFormDialog> createState() => _HallFormDialogState();
}

class _HallFormDialogState extends ConsumerState<_HallFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '100');
  Cinema? _selectedCinema;
  String _hallType = 'standard';

  @override
  void initState() {
    super.initState();
    if (widget.cinemas.isNotEmpty) _selectedCinema = widget.cinemas.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCinema == null) return;

    final hall = Hall(
      cinemaId: _selectedCinema!.id!,
      name: _nameCtrl.text.trim(),
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 100,
      hallType: _hallType,
    );

    final vm = ref.read(cinemaViewModelProvider.notifier);
    final success = await vm.addHall(hall);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        final state = ref.read(cinemaViewModelProvider);
        if (state.successMessage != null) {
          showSuccessSnackBar(context, state.successMessage!);
          vm.clearMessages();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cinemaViewModelProvider);

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: const Text('🏛️ Thêm phòng chiếu',
          style: TextStyle(color: AppTheme.textPrimary)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chọn rạp
              DropdownButtonFormField<Cinema>(
                value: _selectedCinema,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thuộc rạp *',
                  prefixIcon: Icon(Icons.business,
                      color: AppTheme.textSecondary, size: 18),
                ),
                items: widget.cinemas
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCinema = c),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Tên phòng *',
                  prefixIcon: Icon(Icons.meeting_room,
                      color: AppTheme.textSecondary, size: 18),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nhập tên phòng' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số ghế',
                  prefixIcon: Icon(Icons.event_seat,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              // Loại phòng
              DropdownButtonFormField<String>(
                value: _hallType,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Loại phòng',
                  prefixIcon: Icon(Icons.category,
                      color: AppTheme.textSecondary, size: 18),
                ),
                items: const [
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'vip', child: Text('VIP')),
                  DropdownMenuItem(value: 'imax', child: Text('IMAX')),
                ],
                onChanged: (v) => setState(() => _hallType = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          child: const Text('Thêm phòng'),
        ),
      ],
    );
  }
}