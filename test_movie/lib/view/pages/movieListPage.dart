import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/movie.dart';
import '../../viewmodel/movieListViewmodel.dart';
import '../widgets/commonWidgets.dart';
import 'movieDetailPage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOVIE LIST PAGE
// ─────────────────────────────────────────────────────────────────────────────
class MovieListPage extends ConsumerWidget {
  const MovieListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(movieListViewModelProvider);
    final vm    = ref.read(movieListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: _buildAppBar(),
      body: state.isLoading
          ? const FullScreenLoading()
          : state.errorMessage != null
          ? ErrorView(
        message: state.errorMessage!,
        onRetry: vm.loadMovies,
      )
          : _Body(state: state, vm: vm),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D0D1A),
      elevation: 0,
      title: const Text('CGV',
          style: TextStyle(
              color: Color(0xFFE50914),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3)),
      actions: [
        IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {}),
      ],
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final MovieListState    state;
  final MovieListViewModel vm;

  const _Body({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SectionTitle('PHIM ĐANG CHIẾU'),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                state.displayedMovies.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: EmptyView(
                    icon:     Icons.movie_filter_outlined,
                    title:    'Không có phim',
                    subtitle: 'Thử lại sau',
                  ),
                )
                    : _MovieGrid(
                  movies:      state.displayedMovies,
                  isComingSoon: false,
                  favorites:   state.favoriteIds,
                  onTap:       (m) => _goDetail(context, m.id),
                  onFavorite:  (m) => vm.toggleFavorite(m.id),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goDetail(BuildContext context, int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: movieId)),
    );
  }
}

// ── Movie Grid ────────────────────────────────────────────────────────────────
class _MovieGrid extends StatelessWidget {
  final List<MovieModel>     movies;
  final bool                 isComingSoon;
  final List<int>            favorites;
  final Function(MovieModel) onTap;
  final Function(MovieModel) onFavorite;

  const _MovieGrid({
    required this.movies,
    required this.isComingSoon,
    required this.favorites,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (_, i) => _MovieGridItem(
        movie:       movies[i],
        isComingSoon: isComingSoon,
        isFavorite:  favorites.contains(movies[i].id),
        onTap:       () => onTap(movies[i]),
        onFavorite:  () => onFavorite(movies[i]),
      ),
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  final MovieModel movie;
  final bool       isComingSoon;
  final bool       isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _MovieGridItem({
    required this.movie,
    required this.isComingSoon,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MoviePosterCard(
                    posterUrl: movie.posterUrl, ageRating: movie.ageRating),

                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? const Color(0xFFE50914)
                            : Colors.white60,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                if (!isComingSoon)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text('Mua vé',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3)),

          if (movie.rating > 0) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 12),
                const SizedBox(width: 3),
                Text(movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text('(${_formatCount(movie.ratingCount)})',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}


