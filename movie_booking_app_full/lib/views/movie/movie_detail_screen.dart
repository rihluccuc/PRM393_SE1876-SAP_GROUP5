import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_routes.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../viewmodels/trailer_viewmodel.dart';
import '../../widgets/loading_widget.dart';
import '../../models/review_model.dart';

/// MovieDetailScreen - Màn hình chi tiết phim
class MovieDetailScreen extends ConsumerStatefulWidget {
  final int? movieId;

  const MovieDetailScreen({super.key, this.movieId});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load movie detail
    if (widget.movieId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(movieProvider.notifier).loadMovieDetail(widget.movieId!);
        ref.read(reviewProvider.notifier).loadReviews(widget.movieId!);
        ref.read(trailerProvider.notifier).loadTrailers(widget.movieId!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(movieProvider);
    final reviewState = ref.watch(reviewProvider);
    final trailerState = ref.watch(trailerProvider);

    if (movieState.selectedMovie == null && !movieState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết phim')),
        body: const Center(child: Text('Không tìm thấy phim')),
      );
    }

    final movie = movieState.selectedMovie;

    return Scaffold(
      body: movieState.isLoading
          ? const LoadingWidget(message: 'Đang tải chi tiết phim...')
          : CustomScrollView(
              slivers: [
                // Movie poster and basic info
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: movie?.imagePath != null
                        ? CachedNetworkImage(
                            imageUrl: movie!.imagePath!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.movie, size: 64),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 64),
                          ),
                  ),
                  title: Text(movie?.title ?? ''),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        if (movie != null) {
                          Share.share(
                            'Xem phim "${movie.title}" tại CGV! 🎬\n\n'
                            'Thể loại: ${movie.genre ?? "Không xác định"}\n'
                            'Đánh giá: ${movie.rating.toStringAsFixed(1)} ⭐\n'
                            'Thời lượng: ${movie.duration} phút\n\n'
                            'Đặt vé ngay trên ứng dụng CGV Cinema!',
                          );
                        }
                      },
                    ),
                  ],
                ),

                // Movie info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and rating
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                movie?.title ?? '',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (movie != null) ...[
                              const SizedBox(width: 8),
                              RatingBarIndicator(
                                rating: movie.rating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${movie.rating.toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Genre, duration, release date
                        Row(
                          children: [
                            if (movie?.genre != null) ...[
                              Chip(
                                label: Text(movie!.genre!),
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text('${movie?.duration ?? 0} phút'),
                            const SizedBox(width: 16),
                            if (movie?.releaseDate != null)
                              Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(movie!.releaseDate!))),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description
                        if (movie?.description != null) ...[
                          Text(
                            'Nội dung phim',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(movie!.description!),
                          const SizedBox(height: 16),
                        ],

                        // Book ticket button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (movie != null) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.selectCinema,
                                  arguments: movie.id,
                                );
                              }
                            },
                            icon: const Icon(Icons.local_movies),
                            label: const Text('Đặt vé ngay'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Trailer'),
                        Tab(text: 'Đánh giá'),
                        Tab(text: 'Thông tin'),
                      ],
                    ),
                  ),
                ),

                // Tab content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Trailer tab
                      _buildTrailerTab(trailerState),

                      // Reviews tab
                      _buildReviewsTab(reviewState, movie?.id),

                      // Info tab
                      _buildInfoTab(movie),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrailerTab(trailerState) {
    if (trailerState.isLoading) {
      return const LoadingWidget(message: 'Đang tải trailer...');
    }

    if (trailerState.trailers.isEmpty) {
      return const Center(child: Text('Không có trailer'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trailerState.trailers.length,
      itemBuilder: (context, index) {
        final trailer = trailerState.trailers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Image.network(
              trailer.thumbnailUrl,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.play_circle, size: 40),
            ),
            title: Text(trailer.title),
            subtitle: Text('${trailer.type} • ${trailer.duration}'),
            trailing: Text('${trailer.viewCount} lượt xem'),
            onTap: () {
              // TODO: Open YouTube or video player
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở trailer: ${trailer.title}')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(reviewState, int? movieId) {
    if (reviewState.isLoading) {
      return const LoadingWidget(message: 'Đang tải đánh giá...');
    }

    return Column(
      children: [
        // Add review button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              if (movieId != null) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.review,
                  arguments: movieId,
                );
              }
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Viết đánh giá'),
          ),
        ),

        // Reviews list
        Expanded(
          child: reviewState.reviews.isEmpty
              ? const Center(child: Text('Chưa có đánh giá nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviewState.reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewState.reviews[index];
                    return _buildReviewItem(review);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(review.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        review.date,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 16.0,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    review.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: review.isLiked ? Colors.blue : null,
                  ),
                  onPressed: () {
                    ref.read(reviewProvider.notifier).toggleLike(review.id);
                  },
                ),
                Text('${review.likeCount} thích'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(movie) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoItem('Tên phim', movie?.title ?? ''),
        _buildInfoItem('Thể loại', movie?.genre ?? ''),
        _buildInfoItem('Thời lượng', '${movie?.duration ?? 0} phút'),
        _buildInfoItem('Đánh giá', '${movie?.rating.toStringAsFixed(1) ?? 0.0} sao'),
        if (movie?.releaseDate != null)
          _buildInfoItem('Ngày phát hành', DateFormat('dd/MM/yyyy').format(DateTime.parse(movie!.releaseDate!))),
        _buildInfoItem('Trạng thái', movie?.status == 'active' ? 'Đang chiếu' : 'Ngừng chiếu'),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
