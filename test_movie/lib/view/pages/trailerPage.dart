import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/trailer.dart';
import '../../viewmodel/trailerViewmodel.dart';
import '../widgets/commonWidgets.dart';

class TrailerScreen extends ConsumerWidget {
  final int    movieId;
  final String movieTitle;

  const TrailerScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trailerViewModelProvider(movieId));
    final vm    = ref.read(trailerViewModelProvider(movieId).notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movieTitle,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Text('Trailer & Video',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
      body: state.isLoading
          ? const FullScreenLoading()
          : state.errorMessage != null
          ? ErrorView(
          message: state.errorMessage!,
          onRetry: vm.loadTrailers)
          : state.trailers.isEmpty
          ? const EmptyView(
          icon:     Icons.videocam_off_outlined,
          title:    'Chưa có trailer',
          subtitle: 'Trailer sẽ được cập nhật sớm')
          : _TrailerBody(state: state, vm: vm),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TrailerBody extends StatelessWidget {
  final TrailerState    state;
  final TrailerViewModel vm;

  const _TrailerBody({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedTrailer!;

    return Column(
      children: [
        // ── Main player ──────────────────────────────────────────────────────
        _VideoPlayer(trailer: selected),

        // ── Info ─────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _TypeBadge(selected.type),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(selected.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 2),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                '${_formatViews(selected.viewCount)}  •  ${selected.duration}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white10, height: 1),

        // ── Playlist label ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: SectionTitle('Danh sách (${state.trailers.length})'),
        ),

        // ── Playlist ──────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.trailers.length,
            itemBuilder: (_, i) => _PlaylistItem(
              trailer:    state.trailers[i],
              isSelected: state.selectedIndex == i,
              onTap:      () => vm.selectTrailer(i),
            ),
          ),
        ),
      ],
    );
  }

  String _formatViews(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M lượt xem';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(0)}K lượt xem';
    return '$n lượt xem';
  }
}

// ── Video Player (thumbnail + play button) ────────────────────────────────────
class _VideoPlayer extends StatefulWidget {
  final TrailerModel trailer;
  const _VideoPlayer({required this.trailer});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  bool _playing = false;

  @override
  void didUpdateWidget(_VideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.trailer.id != widget.trailer.id) {
      setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          Image.network(
            widget.trailer.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A2E)),
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(_playing ? 0.7 : 0.3)),

          if (_playing)
          // Giả lập đang phát
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill,
                    color: Color(0xFFE50914), size: 56),
                const SizedBox(height: 8),
                const Text('Mở YouTube để xem đầy đủ',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                TextButton(
                  onPressed: () => setState(() => _playing = false),
                  child: const Text('Đóng',
                      style: TextStyle(color: Colors.white38)),
                ),
              ],
            )
          else
          // Nút play
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _playing = true),
                child: Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE50914), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 38),
                ),
              ),
            ),

          // Duration badge
          if (!_playing)
            Positioned(
              bottom: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(widget.trailer.duration,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Playlist Item ─────────────────────────────────────────────────────────────
class _PlaylistItem extends StatelessWidget {
  final TrailerModel trailer;
  final bool         isSelected;
  final VoidCallback onTap;

  const _PlaylistItem({
    required this.trailer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E1E35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE50914).withOpacity(0.5)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail nhỏ
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    trailer.thumbnailUrl,
                    width: 110, height: 62, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 110, height: 62,
                        color: const Color(0xFF2A2A3E),
                        child: const Icon(Icons.play_circle_outline,
                            color: Colors.white24)),
                  ),
                ),
                Positioned(
                  bottom: 3, right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(3)),
                    child: Text(trailer.duration,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                if (isSelected)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        color: const Color(0xFFE50914).withOpacity(0.3),
                        child: const Center(
                          child: Icon(Icons.play_circle_fill,
                              color: Color(0xFFE50914), size: 28),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeBadge(trailer.type),
                  const SizedBox(height: 4),
                  Text(trailer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color:
                          isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type Badge ────────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  Color get _color {
    switch (type) {
      case 'Trailer':           return const Color(0xFFE50914);
      case 'Teaser':            return const Color(0xFF1565C0);
      case 'Clip':              return const Color(0xFF2E7D32);
      case 'Behind the scenes': return const Color(0xFF6A1B9A);
      default:                  return const Color(0xFF424242);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
      BoxDecoration(color: _color, borderRadius: BorderRadius.circular(4)),
      child: Text(type,
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
