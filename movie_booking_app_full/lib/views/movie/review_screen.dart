import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/review_model.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// ReviewScreen - Màn hình viết đánh giá phim
class ReviewScreen extends ConsumerStatefulWidget {
  final int? movieId;

  const ReviewScreen({super.key, this.movieId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viết đánh giá'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating section
              const Text(
                'Đánh giá của bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${_rating.toStringAsFixed(1)} sao',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Comment section
              const Text(
                'Nhận xét của bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _commentController,
                hintText: 'Chia sẻ cảm nhận của bạn về bộ phim...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nhận xét';
                  }
                  if (value.trim().length < 10) {
                    return 'Nhận xét phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Error message
              if (reviewState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    reviewState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                text: 'Gửi đánh giá',
                isLoading: reviewState.isLoading,
                onPressed: _submitReview,
              ),

              const SizedBox(height: 16),

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
                      '💡 Mẹo viết đánh giá hay:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Chia sẻ cảm nhận cá nhân về nội dung phim'),
                    Text('• Đánh giá diễn xuất, kịch bản, hình ảnh'),
                    Text('• Tránh spoil (tiết lộ nội dung) cho người khác'),
                    Text('• Giữ thái độ tôn trọng và tích cực'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.movieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy ID phim')),
      );
      return;
    }

    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      movieId: widget.movieId!,
      userName: 'Người dùng', // TODO: Get from auth
      rating: _rating,
      comment: _commentController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      likeCount: 0,
      isLiked: false,
    );

    try {
      await ref.read(reviewProvider.notifier).addReview(review);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đánh giá đã được gửi thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }
}
