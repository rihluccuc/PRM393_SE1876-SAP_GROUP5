# ⚙️ Views - Admin (Long)

## Mô Tả
Module Admin gồm 4 màn hình do **Long** phụ trách:
1. **Add Movie** - Thêm phim mới
2. **Add Showtime** - Thêm suất chiếu
3. **Manage Cinema** - Quản lý rạp
4. **Statistics** - Thống kê

---

## File: `lib/views/admin/add_movie_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/movie.dart';

/// AddMovieScreen - Thêm phim mới (Admin)
/// Người phụ trách: Long
class AddMovieScreen extends ConsumerStatefulWidget {
  const AddMovieScreen({super.key});
  @override
  ConsumerState<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends ConsumerState<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _durationCtrl.dispose(); _genreCtrl.dispose();
    _imageCtrl.dispose(); super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final movie = Movie(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      duration: int.parse(_durationCtrl.text.trim()),
      genre: _genreCtrl.text.trim(),
      imagePath: _imageCtrl.text.trim(),
    );
    final success = await ref.read(adminProvider.notifier).addMovie(movie);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm phim thành công!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Phim Mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(key: _formKey, child: Column(children: [
          // Tên phim
          TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Tên phim *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
          const SizedBox(height: 12),
          // Mô tả
          TextFormField(controller: _descCtrl, maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          // Thời lượng
          TextFormField(controller: _durationCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Thời lượng (phút) *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Bắt buộc' : null),
          const SizedBox(height: 12),
          // Thể loại
          TextFormField(controller: _genreCtrl, decoration: const InputDecoration(labelText: 'Thể loại', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          // Link ảnh
          TextFormField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'Link ảnh poster', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          // Nút Thêm
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: state.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: state.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('THÊM PHIM'),
          )),
        ])),
      ),
    );
  }
}
```

---

## File: `lib/views/admin/add_showtime_screen.dart`

```dart
import 'package:flutter/material.dart';

/// AddShowtimeScreen - Thêm suất chiếu (Admin)
/// Người phụ trách: Long
class AddShowtimeScreen extends StatefulWidget {
  const AddShowtimeScreen({super.key});
  @override
  State<AddShowtimeScreen> createState() => _AddShowtimeScreenState();
}

class _AddShowtimeScreenState extends State<AddShowtimeScreen> {
  String? _selectedMovie;
  String? _selectedCinema;
  String? _selectedHall;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  double _ticketPrice = 75000;

  // Dữ liệu mẫu
  final _movies = ['Avengers: Endgame', 'Spider-Man: No Way Home', 'Lật Mặt 7'];
  final _cinemas = ['CGV Vincom Đồng Khởi', 'CGV Aeon Mall', 'CGV Landmark 81'];
  final _halls = ['Phòng 1', 'Phòng 2', 'Phòng 3', 'Phòng 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Suất Chiếu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Chọn phim
          DropdownButtonFormField<String>(
            value: _selectedMovie,
            decoration: const InputDecoration(labelText: 'Chọn phim *', border: OutlineInputBorder()),
            items: _movies.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _selectedMovie = v),
          ),
          const SizedBox(height: 12),
          // Chọn rạp
          DropdownButtonFormField<String>(
            value: _selectedCinema,
            decoration: const InputDecoration(labelText: 'Chọn rạp *', border: OutlineInputBorder()),
            items: _cinemas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCinema = v),
          ),
          const SizedBox(height: 12),
          // Chọn phòng
          DropdownButtonFormField<String>(
            value: _selectedHall,
            decoration: const InputDecoration(labelText: 'Chọn phòng *', border: OutlineInputBorder()),
            items: _halls.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
            onChanged: (v) => setState(() => _selectedHall = v),
          ),
          const SizedBox(height: 12),
          // Chọn ngày
          ListTile(
            title: const Text('Ngày chiếu'),
            subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _selectedDate,
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          // Chọn giờ
          ListTile(
            title: const Text('Giờ chiếu'),
            subtitle: Text('${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
          ),
          const SizedBox(height: 12),
          // Giá vé
          TextFormField(
            initialValue: '75000',
            decoration: const InputDecoration(labelText: 'Giá vé (VNĐ)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => _ticketPrice = double.tryParse(v) ?? 75000,
          ),
          const SizedBox(height: 24),
          // Nút Thêm
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm suất chiếu thành công!')));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('THÊM SUẤT CHIẾU'),
          )),
        ]),
      ),
    );
  }
}
```

---

## File: `lib/views/admin/manage_cinema_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/cinema.dart';

/// ManageCinemaScreen - Quản lý rạp (Admin)
/// Người phụ trách: Long
class ManageCinemaScreen extends ConsumerStatefulWidget {
  const ManageCinemaScreen({super.key});
  @override
  ConsumerState<ManageCinemaScreen> createState() => _ManageCinemaScreenState();
}

class _ManageCinemaScreenState extends ConsumerState<ManageCinemaScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadCinemas());
  }

  void _showAddCinemaDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Thêm Rạp Mới'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên rạp')),
        TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ')),
        TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: () async {
          final cinema = Cinema(name: nameCtrl.text, address: addressCtrl.text, phone: phoneCtrl.text);
          await ref.read(adminProvider.notifier).addCinema(cinema);
          if (mounted) Navigator.pop(context);
        }, child: const Text('Thêm')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Rạp')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCinemaDialog, backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cinemas.length,
              itemBuilder: (_, i) {
                final c = state.cinemas[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.theaters, color: Colors.red),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c.address}\n${c.totalHalls} phòng chiếu'),
                    isThreeLine: true,
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {/* TODO: Edit */}),
                  ),
                );
              },
            ),
    );
  }
}
```

---

## File: `lib/views/admin/statistics_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/admin_viewmodel.dart';
import 'package:intl/intl.dart';

/// StatisticsScreen - Thống kê doanh thu (Admin)
/// Người phụ trách: Long
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});
  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Thống Kê')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // ── Card Doanh thu ──
                _statCard('💰 Doanh Thu', '${formatter.format(state.totalRevenue)}đ', Colors.green),
                const SizedBox(height: 12),
                // ── Card Tổng booking ──
                _statCard('🎫 Tổng Đặt Vé', '${state.totalBookings}', Colors.blue),
                const SizedBox(height: 12),
                // ── Card Tổng phim ──
                _statCard('🎬 Tổng Phim', '${state.totalMovies}', Colors.orange),
                const SizedBox(height: 24),
                // ── Quick links ──
                const Text('Quản lý nhanh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _linkTile(Icons.movie, 'Thêm Phim', '/add-movie'),
                _linkTile(Icons.access_time, 'Thêm Suất Chiếu', '/add-showtime'),
                _linkTile(Icons.theaters, 'Quản Lý Rạp', '/manage-cinema'),
              ]),
            ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ])),
    ])));
  }

  Widget _linkTile(IconData icon, String title, String route) {
    return Card(child: ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    ));
  }
}
```
