import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/movie.dart';
import '../../viewmodel/movieDetailViewmodel.dart';
import '../widgets/commonWidgets.dart';
import 'trailerPage.dart';
import 'reviewPage.dart';

class MovieDetailPage extends ConsumerWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(movieDetailViewModelProvider(movieId));
    final vm    = ref.read(movieDetailViewModelProvider(movieId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: FullScreenLoading(),
      );
    }

    if (state.errorMessage != null || state.movie == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        appBar: AppBar(backgroundColor: const Color(0xFF0D0D1A)),
        body: ErrorView(
          message: state.errorMessage ?? 'Không tìm thấy phim',
          onRetry: vm.loadDetail,
        ),
      );
    }

    return _DetailView(movie: state.movie!, isFavorite: state.isFavorite, vm: vm);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _DetailView extends StatefulWidget {
  final MovieModel           movie;
  final bool                 isFavorite;
  final MovieDetailViewModel vm;

  const _DetailView({
    required this.movie,
    required this.isFavorite,
    required this.vm,
  });

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildHeader(m)],
        body: _InfoTab(movie: m),
      ),
      bottomNavigationBar: _BottomBar(movie: m),
    );
  }

  // ── Sliver Header ────────────────────────────────────────────────────────────
  SliverAppBar _buildHeader(MovieModel m) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D1A),
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorite ? const Color(0xFFE50914) : Colors.white,
          ),
          onPressed: widget.vm.toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(m.backdropUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A2E))),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    const Color(0xFF0D0D1A),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(m.posterUrl,
                        width: 90, height: 130, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 90, height: 130,
                            color: const Color(0xFF2A2A3E))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                        const SizedBox(height: 6),
                        if (m.rating > 0)
                          Row(children: [
                            const Icon(Icons.star,
                                color: Color(0xFFFFD700), size: 14),
                            const SizedBox(width: 3),
                            Text('${m.rating.toStringAsFixed(1)}/10',
                                style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        const SizedBox(height: 4),
                        _MetaRow(Icons.access_time,
                            '${m.durationMinutes} phút'),
                        _MetaRow(Icons.language, m.language),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            AgeRatingBadge(m.ageRating, fontSize: 11),
                            ...m.genreList.take(2).map(
                                  (g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(g,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Tab ──────────────────────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final MovieModel movie;
  const _InfoTab({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Nội dung'),
          const SizedBox(height: 8),
          _ExpandText(movie.synopsis),
          const SizedBox(height: 20),

          const SectionTitle('Thông tin phim'),
          const SizedBox(height: 10),
          _InfoRow('Đạo diễn',   movie.director),
          _InfoRow('Thể loại',   movie.genreList.join(', ')),
          _InfoRow('Thời lượng', '${movie.durationMinutes} phút'),
          _InfoRow('Ngôn ngữ',   movie.language),
          _InfoRow('Khởi chiếu', movie.releaseDate),
          const SizedBox(height: 20),

          SectionTitle('Trailer', trailing: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => TrailerScreen(movieId: movie.id,
                        movieTitle: movie.title))),
            child: const Text('Xem tất cả',
                style: TextStyle(color: Color(0xFFE50914), fontSize: 12)),
          )),
          const SizedBox(height: 8),
          _TrailerThumb(
            backdropUrl: movie.backdropUrl,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => TrailerScreen(
                        movieId: movie.id, movieTitle: movie.title))),
          ),
          const SizedBox(height: 20),

          SectionTitle('Đánh giá', trailing: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => ReviewScreen(movieId: movie.id,
                        movieTitle: movie.title))),
            child: const Text('Xem tất cả',
                style: TextStyle(color: Color(0xFFE50914), fontSize: 12)),
          )),
          if (movie.rating > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold)),
                const Text('/10',
                    style: TextStyle(color: Colors.white38, fontSize: 18)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < (movie.rating / 2).round()
                            ? Icons.star
                            : Icons.star_border,
                        color: const Color(0xFFFFD700), size: 18,
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text('${_formatCount(movie.ratingCount)} đánh giá',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int c) =>
      c >= 1000 ? '${(c / 1000).toStringAsFixed(1)}k' : '$c';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final MovieModel movie;
  const _BottomBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF141428),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                          movieId: movie.id, movieTitle: movie.title))),
              icon: const Icon(Icons.star_border,
                  color: Color(0xFFE50914), size: 16),
              label: const Text('Đánh giá',
                  style: TextStyle(color: Color(0xFFE50914))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                side: const BorderSide(color: Color(0xFFE50914)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_movies,
                    color: Colors.white, size: 16),
                label: const Text('MUA VÉ NGAY',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _MetaRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Colors.white38, size: 13),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    ]);
  }
}

class _TrailerThumb extends StatelessWidget {
  final String     backdropUrl;
  final VoidCallback onTap;
  const _TrailerThumb({required this.backdropUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF1E1E35),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(backdropUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A2E))),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.45),
              ),
            ),
            Center(
              child: Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(
                    color: Color(0xFFE50914), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow,
                    color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandText extends StatefulWidget {
  final String text;
  const _ExpandText(this.text);

  @override
  State<_ExpandText> createState() => _ExpandTextState();
}

class _ExpandTextState extends State<_ExpandText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text,
            maxLines: _expanded ? null : 3,
            overflow:
            _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white60, fontSize: 14, height: 1.6)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Thu gọn' : 'Xem thêm',
            style: const TextStyle(
                color: Color(0xFFE50914),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

