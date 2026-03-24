import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Các widget nhỏ dùng chung — không có logic, chỉ hiển thị
// ─────────────────────────────────────────────────────────────────────────────

/// Thanh đỏ dọc đứng trước tiêu đề section
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Badge tuổi phim (T13, T16, G, ...)
class AgeRatingBadge extends StatelessWidget {
  final String rating;
  final double fontSize;

  const AgeRatingBadge(this.rating, {super.key, this.fontSize = 10});

  Color get _color {
    switch (rating) {
      case 'G':   return const Color(0xFF4CAF50);
      case 'PG':  return const Color(0xFF2196F3);
      case 'T13': return const Color(0xFFFF9800);
      case 'T16': return const Color(0xFFFF5722);
      case 'T18': return const Color(0xFFF44336);
      default:    return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.6, vertical: fontSize * 0.2),
      decoration:
      BoxDecoration(color: _color, borderRadius: BorderRadius.circular(4)),
      child: Text(rating,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold)),
    );
  }
}

/// Loading indicator toàn màn hình
class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFE50914)),
    );
  }
}

/// Hiển thị lỗi + nút thử lại
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state chung
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 64),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
              const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Chip thể loại phim
class GenreFilterChip extends StatelessWidget {
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;

  const GenreFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE50914)
              : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE50914) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Card phim đơn giản — dùng trong grid & list
class MoviePosterCard extends StatelessWidget {
  final String posterUrl;
  final String ageRating;
  final double aspectRatio;

  const MoviePosterCard({
    super.key,
    required this.posterUrl,
    required this.ageRating,
    this.aspectRatio = 2 / 3,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              posterUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                color: const Color(0xFF2A2A3E),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFE50914), strokeWidth: 2),
                ),
              ),
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2A2A3E),
                child: const Icon(Icons.movie, color: Colors.white24, size: 40),
              ),
            ),
          ),
          Positioned(
            top: 6, left: 6,
            child: AgeRatingBadge(ageRating),
          ),
        ],
      ),
    );
  }
}
