    // lib/views/add_movie/add_movie_screen.dart
    // =====================================================
    // Màn hình: Thêm / Chỉnh sửa Phim
    // MVVM: View gọi ViewModel, ViewModel gọi Repository
    // Riverpod: movieViewModelProvider cung cấp state
    // =====================================================

    import 'dart:io';                          // Để dùng File() đọc ảnh từ máy
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:image_picker/image_picker.dart'; // Chọn ảnh từ thư viện máy
    import '../../models/movie_model.dart';
    import '../../viewmodels/providers.dart';
    import '../../widgets/app_theme.dart';

    class AddMovieScreen extends ConsumerStatefulWidget {
      /// Nếu truyền vào movie thì là chế độ chỉnh sửa, ngược lại là thêm mới
      final Movie? existingMovie;

      const AddMovieScreen({super.key, this.existingMovie});

      @override
      ConsumerState<AddMovieScreen> createState() => _AddMovieScreenState();
    }

    class _AddMovieScreenState extends ConsumerState<AddMovieScreen> {
      // ---- Form key để validate ----
      final _formKey = GlobalKey<FormState>();

      // ---- Controllers cho các TextField ----
      late final TextEditingController _titleCtrl;
      late final TextEditingController _descCtrl;
      late final TextEditingController _durationCtrl;
      late final TextEditingController _ratingCtrl;

      // ---- State của dropdown và selections ----
      List<String> _selectedGenres = ['Action'];
      String _status = 'active';
      String? _pickedFilePath; // Đường dẫn ảnh chọn từ máy (File thật)
      String? _selectedImagePath; // Đường dẫn ảnh assets (phim có sẵn, chỉ dùng khi edit)
      DateTime? _selectedReleaseDate;
      final ImagePicker _picker = ImagePicker(); // Instance image_picker

      /// Danh sách thể loại phim
      static const List<String> _genres = [
        'Action', 'Drama', 'Comedy', 'Horror', 'Sci-Fi',
        'Romance', 'Thriller', 'Animation', 'Documentary', 'Fantasy',
      ];


      bool get _isEditMode => widget.existingMovie != null;

      @override
      void initState() {
        super.initState();
        // Nếu edit, điền sẵn thông tin phim vào form
        final m = widget.existingMovie;
        _titleCtrl = TextEditingController(text: m?.title ?? '');
        _descCtrl = TextEditingController(text: m?.description ?? '');
        _durationCtrl = TextEditingController(text: m?.duration.toString() ?? '');
        _ratingCtrl = TextEditingController(text: m?.rating.toString() ?? '7.0');
        _selectedGenres = m?.genre?.split(',') ?? ['Action'];
        _status = m?.status ?? 'active';
        _selectedImagePath = m?.imagePath;
      }

      @override
      void dispose() {
        // Giải phóng controllers để tránh memory leak
        _titleCtrl.dispose();
        _descCtrl.dispose();
        _durationCtrl.dispose();
        _ratingCtrl.dispose();
        super.dispose();
      }

      /// Xử lý submit form
      Future<void> _submitForm() async {
        // Validate trước khi xử lý
        if (!_formKey.currentState!.validate()) return;

        // Tạo Movie object từ dữ liệu form
        final movie = Movie(
          id: widget.existingMovie?.id,
          // null nếu thêm mới
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text
              .trim()
              .isEmpty ? null : _descCtrl.text.trim(),
          duration: int.parse(_durationCtrl.text.trim()),
          genre: _selectedGenres.join(','),
          rating: double.tryParse(_ratingCtrl.text.trim()) ?? 0.0,
          // Ưu tiên ảnh chọn từ máy, nếu không có thì giữ ảnh assets cũ (khi edit)
          imagePath: _pickedFilePath ?? _selectedImagePath,
          releaseDate: _selectedReleaseDate
              ?.toIso8601String()
              .split('T')
              .first,
          status: _status,
        );

        // Gọi ViewModel để xử lý
        final vm = ref.read(movieViewModelProvider.notifier);
        final success = _isEditMode
            ? await vm.updateMovie(movie)
            : await vm.addMovie(movie);

        if (mounted) {
          if (success) {
            showSuccessSnackBar(
              context,
              _isEditMode ? 'Cập nhật phim thành công!' : 'Thêm phim thành công!',
            );
            Navigator.pop(context); // Quay lại màn hình trước
          } else {
            // Hiển thị lỗi từ ViewModel
            final state = ref.read(movieViewModelProvider);
            if (state.errorMessage != null) {
              showErrorSnackBar(context, state.errorMessage!);
              vm.clearMessages();
            }
          }
        }
      }

      /// Chọn ngày phát hành
      Future<void> _pickReleaseDate() async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedReleaseDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(primary: AppTheme.accentColor),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedReleaseDate = picked);
        }
      }

      @override
      Widget build(BuildContext context) {
        // Lắng nghe trạng thái loading từ ViewModel
        final movieState = ref.watch(movieViewModelProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? '✏️ Chỉnh sửa phim' : '🎬 Thêm phim mới'),
            actions: [
              // Nút Save trên AppBar
              TextButton.icon(
                onPressed: movieState.isLoading ? null : _submitForm,
                icon: movieState.isLoading
                    ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save, color: AppTheme.accentColor),
                label: Text(
                  'Lưu',
                  style: TextStyle(
                    color: movieState.isLoading
                        ? AppTheme.textSecondary
                        : AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---- Chọn ảnh poster ----
                  _buildImagePicker(),
                  const SizedBox(height: 20),

                  // ---- Thông tin cơ bản ----
                  _buildSectionTitle('Thông tin cơ bản'),

                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _titleCtrl,
                    label: 'Tên phim *',
                    icon: Icons.movie,
                    validator: (v) =>
                    v == null || v
                        .trim()
                        .isEmpty ? 'Vui lòng nhập tên phim' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _descCtrl,
                    label: 'Mô tả / Tóm tắt nội dung',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // ---- Thời lượng + Rating (2 cột) ----
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _durationCtrl,
                          label: 'Thời lượng (phút) *',
                          icon: Icons.timer,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Bắt buộc';
                            if (int.tryParse(v) == null) return 'Phải là số';
                            if (int.parse(v) <= 0) return 'Phải > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _ratingCtrl,
                          label: 'Điểm đánh giá (0-10)',
                          icon: Icons.star,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return null; // Không bắt buộc
                            final d = double.tryParse(v);
                            if (d == null) return 'Phải là số';
                            if (d < 0 || d > 10) return '0 đến 10';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---- Phân loại ----
                  _buildSectionTitle('Phân loại & Trạng thái'),
                  const SizedBox(height: 12),
                  _buildMultiGenre(),


                  const SizedBox(height: 12),

                  // Ngày phát hành
                  GestureDetector(
                    onTap: _pickReleaseDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.surfaceColor.withOpacity(0.7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.textSecondary, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _selectedReleaseDate != null
                                ? 'Ngày phát hành: ${_selectedReleaseDate!
                                .day}/${_selectedReleaseDate!
                                .month}/${_selectedReleaseDate!.year}'
                                : 'Chọn ngày phát hành',
                            style: TextStyle(
                              color: _selectedReleaseDate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Toggle trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.toggle_on,
                            color: AppTheme.textSecondary, size: 18),
                        const SizedBox(width: 12),
                        const Text('Trạng thái phim',
                            style: TextStyle(color: AppTheme.textPrimary)),
                        const Spacer(),
                        // Switch toggle
                        Switch(
                          value: _status == 'active',
                          activeColor: AppTheme.accentColor,
                          onChanged: (v) =>
                              setState(() => _status = v ? 'active' : 'inactive'),
                        ),
                        Text(
                          _status == 'active' ? 'Đang chiếu' : 'Ngừng chiếu',
                          style: TextStyle(
                            color: _status == 'active'
                                ? AppTheme.successColor
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ---- Nút Lưu ----
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: movieState.isLoading ? null : _submitForm,
                      icon: movieState.isLoading
                          ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(
                        movieState.isLoading
                            ? 'Đang lưu...'
                            : (_isEditMode ? 'Cập nhật phim' : 'Thêm phim'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }

      /// Mở thư viện ảnh máy để chọn poster phim
      Future<void> _pickImageFromGallery() async {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85, // Nén nhẹ để tiết kiệm bộ nhớ
          maxWidth: 800,
        );
        if (picked != null) {
          setState(() {
            _pickedFilePath = picked.path; // Lưu đường dẫn file thật trong máy
          });
        }
      }

      /// Widget chọn ảnh: nhấn để mở gallery, hiển thị ảnh đã chọn
      Widget _buildImagePicker() {
        // Xác định widget ảnh hiển thị
        Widget imageWidget;

        if (_pickedFilePath != null) {
          // Ảnh vừa chọn từ máy — dùng File()
          imageWidget = Image.file(
            File(_pickedFilePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          );
        } else if (_selectedImagePath != null &&
            _selectedImagePath!.startsWith('assets/')) {
          // Ảnh assets (phim có sẵn, chế độ edit)
          imageWidget = Image.asset(
            _selectedImagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          );
        } else {
          // Chưa chọn ảnh nào — hiện placeholder mời chọn
          imageWidget = _imagePlaceholder();
        }

        return GestureDetector(
          onTap: _pickImageFromGallery, // Nhấn vào ảnh → mở gallery
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                SizedBox(width: 120, height: 160, child: imageWidget),

                // Overlay icon camera ở giữa khi chưa có ảnh
                if (_pickedFilePath == null && _selectedImagePath == null)
                  const SizedBox.shrink(),

                // Badge "Đổi ảnh" ở góc dưới khi đã có ảnh
                if (_pickedFilePath != null || _selectedImagePath != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.black54,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('Đổi ảnh',
                              style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      /// Placeholder khi chưa chọn ảnh — trông như nút mời chọn
      Widget _imagePlaceholder() {
        return Container(
          color: AppTheme.surfaceColor,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate,
                  color: AppTheme.accentColor, size: 36),
              SizedBox(height: 8),
              Text(
                'Chọn ảnh\ntừ thư viện',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        );
      }

      Widget _buildSectionTitle(String title) {
        return Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      }

      Widget _buildTextField({
        required TextEditingController controller,
        required String label,
        required IconData icon,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
        return TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
          ),
          validator: validator,
        );
      }

      Widget _buildMultiGenre() {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _genres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);

              return CheckboxListTile(
                value: isSelected,
                activeColor: AppTheme.accentColor,
                title: Text(
                  genre,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
      }
    }