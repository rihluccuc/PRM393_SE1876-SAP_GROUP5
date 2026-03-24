import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/review.dart';
import '../../viewmodel/reviewViewmodel.dart';
import '../widgets/commonWidgets.dart';

class ReviewScreen extends ConsumerWidget {
  final int    movieId;
  final String movieTitle;

  const ReviewScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewViewModelProvider(movieId));
    final vm    = ref.read(reviewViewModelProvider(movieId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movieTitle,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Text('Đánh giá & Nhận xét',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
      body: state.isLoading
          ? const FullScreenLoading()
          : Column(
        children: [
          _StatsHeader(state: state),
          const Divider(color: Colors.white10, height: 1),

          Expanded(
            child: state.reviews.isEmpty
                ? const EmptyView(
              icon:     Icons.rate_review_outlined,
              title:    'Chưa có đánh giá',
              subtitle: 'Hãy là người đầu tiên đánh giá!',
            )
                : _ReviewList(
              reviews: state.reviews,
              onLike:  vm.toggleLike,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteSheet(context, ref),
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
        label: const Text('Viết đánh giá',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showWriteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141428),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _WriteReviewSheet(
        movieTitle: movieTitle,
        onSubmit: (rating, comment) async {
          Navigator.pop(context);
          final vm  = ref.read(reviewViewModelProvider(movieId).notifier);
          final ok  = await vm.submitReview(rating: rating, comment: comment);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Đã gửi đánh giá!' : 'Lỗi, thử lại sau'),
              backgroundColor:
              ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Header
// ─────────────────────────────────────────────────────────────────────────────
class _StatsHeader extends StatelessWidget {
  final ReviewState state;
  const _StatsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final dist  = state.distribution;
    final total = state.reviews.length;

    return Container(
      color: const Color(0xFF141428),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
              const Text('/10',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < (state.averageRating / 2).round()
                      ? Icons.star
                      : Icons.star_border,
                  color: const Color(0xFFFFD700),
                  size: 14,
                )),
              ),
              const SizedBox(height: 3),
              Text('$total đánh giá',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [10, 9, 8, 7, 6, 5].map((star) {
                final count   = dist[star] ?? 0;
                final percent = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text('$star',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 3),
                      const Icon(Icons.star,
                          color: Color(0xFFFFD700), size: 10),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percent.toDouble(),
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFD700)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review List
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewList extends StatelessWidget {
  final List<ReviewModel>      reviews;
  final Function(int reviewId) onLike;

  const _ReviewList({required this.reviews, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reviews.length,
      separatorBuilder: (_, __) =>
      const Divider(color: Colors.white10, height: 24),
      itemBuilder: (_, i) => _ReviewItem(
        review: reviews[i],
        onLike: () => onLike(reviews[i].id),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Item
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewItem extends StatelessWidget {
  final ReviewModel  review;
  final VoidCallback onLike;

  const _ReviewItem({required this.review, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _avatarColor(review.userName),
              child: Text(
                review.userName.isNotEmpty
                    ? review.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(_formatDate(review.date),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _ratingColor(review.rating),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 12),
                  const SizedBox(width: 3),
                  Text(review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(review.comment,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.6)),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: onLike,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: review.isLiked
                  ? const Color(0xFFE50914).withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: review.isLiked
                    ? const Color(0xFFE50914).withOpacity(0.5)
                    : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  review.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: review.isLiked
                      ? const Color(0xFFE50914)
                      : Colors.white38,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text('${review.likeCount}',
                    style: TextStyle(
                        color: review.isLiked
                            ? const Color(0xFFE50914)
                            : Colors.white38,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFFE50914), Color(0xFF1565C0), Color(0xFF2E7D32),
      Color(0xFF6A1B9A), Color(0xFFE65100), Color(0xFF00838F),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Color _ratingColor(double r) {
    if (r >= 8) return const Color(0xFF2E7D32);
    if (r >= 6) return const Color(0xFFE65100);
    return const Color(0xFFB71C1C);
  }

  String _formatDate(String d) {
    try {
      final p = d.substring(0, 10).split('-');
      return '${p[2]}/${p[1]}/${p[0]}';
    } catch (_) {
      return d;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Write Review Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  final String movieTitle;
  final Future<void> Function(double rating, String comment) onSubmit;

  const _WriteReviewSheet({
    required this.movieTitle,
    required this.onSubmit,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  double _rating = 0;
  final _ctrl    = TextEditingController();
  bool  _submitting = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _label(double r) {
    if (r == 0) return 'Chọn điểm';
    if (r <= 2)  return 'Rất tệ';
    if (r <= 4)  return 'Tệ';
    if (r <= 6)  return 'Bình thường';
    if (r <= 8)  return 'Tốt';
    if (r < 10)  return 'Rất tốt';
    return 'Xuất sắc!';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              const SectionTitle('Viết đánh giá'),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(widget.movieTitle,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(10, (i) {
                        final starVal = i + 1.0;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starVal),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              _rating >= starVal
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: _rating >= starVal
                                  ? const Color(0xFFFFD700)
                                  : Colors.white24,
                              size: 28,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rating > 0
                          ? '${_rating.toStringAsFixed(0)}/10 — ${_label(_rating)}'
                          : _label(0),
                      style: TextStyle(
                        color: _rating > 0
                            ? const Color(0xFFFFD700)
                            : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _ctrl,
                maxLines:   4,
                maxLength:  500,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Chia sẻ cảm nhận của bạn...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  errorText: _error,
                  counterStyle:
                  const TextStyle(color: Colors.white38, fontSize: 11),
                  filled:      true,
                  fillColor:   const Color(0xFF1E1E35),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE50914), width: 1.5)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    disabledBackgroundColor:
                    const Color(0xFFE50914).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi đánh giá',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Vui lòng chọn điểm đánh giá');
      return;
    }
    if (_ctrl.text.trim().length < 10) {
      setState(() => _error = 'Nhận xét ít nhất 10 ký tự');
      return;
    }
    setState(() { _error = null; _submitting = true; });
    await widget.onSubmit(_rating, _ctrl.text.trim());
    if (mounted) setState(() => _submitting = false);
  }
}

