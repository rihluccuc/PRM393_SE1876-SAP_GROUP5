import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/movie.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// AddMovieScreen - Màn hình thêm phim mới
class AddMovieScreen extends ConsumerStatefulWidget {
  const AddMovieScreen({super.key});

  @override
  ConsumerState<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends ConsumerState<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _imageController = TextEditingController();
  final _durationController = TextEditingController();
  final _ratingController = TextEditingController();

  DateTime? _releaseDate;
  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _imageController.dispose();
    _durationController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm phim mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              CustomTextField(
                controller: _titleController,
                labelText: 'Tên phim *',
                hintText: 'Nhập tên phim',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên phim';
                  }
                  if (value.trim().length < 2) {
                    return 'Tên phim phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Mô tả phim *',
                hintText: 'Nhập mô tả chi tiết về phim',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả phim';
                  }
                  if (value.trim().length < 10) {
                    return 'Mô tả phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Genre
              CustomTextField(
                controller: _genreController,
                labelText: 'Thể loại',
                hintText: 'Ví dụ: Hành động, Tình cảm, Hài hước',
              ),
              const SizedBox(height: 12),

              // Duration
              CustomTextField(
                controller: _durationController,
                labelText: 'Thời lượng (phút) *',
                hintText: 'Ví dụ: 120',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập thời lượng';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Thời lượng phải là số dương';
                  }
                  if (duration > 300) {
                    return 'Thời lượng không được quá 300 phút';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Rating
              CustomTextField(
                controller: _ratingController,
                labelText: 'Đánh giá (0.0 - 5.0)',
                hintText: 'Ví dụ: 4.5',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final rating = double.tryParse(value);
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'Đánh giá phải từ 0.0 đến 5.0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Release Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày phát hành',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _releaseDate != null
                        ? '${_releaseDate!.day}/${_releaseDate!.month}/${_releaseDate!.year}'
                        : 'Chọn ngày phát hành',
                    style: TextStyle(
                      color: _releaseDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Image URL
              CustomTextField(
                controller: _imageController,
                labelText: 'URL ảnh poster',
                hintText: 'https://example.com/poster.jpg',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.startsWith('http')) {
                      return 'URL phải bắt đầu bằng http hoặc https';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Status
              const Text(
                'Trạng thái',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Phim đang chiếu'),
                subtitle: const Text('Cho phép khách hàng đặt vé'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Error message
              if (adminState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    adminState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              // Submit button
              CustomButton(
                text: 'Thêm phim',
                isLoading: adminState.isLoading,
                onPressed: _addMovie,
              ),

              const SizedBox(height: 24),

              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Lưu ý khi thêm phim:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Tên phim nên chính xác và đầy đủ'),
                    Text('• Mô tả nên hấp dẫn và không spoil nội dung'),
                    Text('• Thời lượng tính bằng phút'),
                    Text('• Đánh giá dựa trên các nguồn uy tín'),
                    Text('• Ảnh poster nên có tỷ lệ 2:3 (300x450px)'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  Future<void> _addMovie() async {
    if (!_formKey.currentState!.validate()) return;

    final duration = int.parse(_durationController.text.trim());
    final rating = _ratingController.text.trim().isEmpty
        ? 0.0
        : double.parse(_ratingController.text.trim());

    final movie = Movie(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      duration: duration,
      genre: _genreController.text.trim().isEmpty ? null : _genreController.text.trim(),
      rating: rating,
      imagePath: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
      releaseDate: _releaseDate?.toIso8601String(),
      status: _isActive ? 'active' : 'inactive',
    );

    final success = await ref.read(adminProvider.notifier).addMovie(movie);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm phim thành công!')),
      );
      Navigator.pop(context);
    }
  }
}
