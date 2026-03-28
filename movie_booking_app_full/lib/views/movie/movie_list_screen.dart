import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_routes.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/movie_card.dart';

/// MovieListScreen - Màn hình danh sách phim
class MovieListScreen extends ConsumerStatefulWidget {
  const MovieListScreen({super.key});

  @override
  ConsumerState<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends ConsumerState<MovieListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load movies khi vào screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movieProvider.notifier).loadMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(movieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phim đang chiếu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.bookingHistory);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phim...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(movieProvider.notifier).loadMovies();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(movieProvider.notifier).searchMovies(value);
              },
            ),
          ),

          // Movie list
          Expanded(
            child: movieState.isLoading
                ? const LoadingWidget(message: 'Đang tải danh sách phim...')
                : movieState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Lỗi: ${movieState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(movieProvider.notifier).loadMovies();
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : movieState.movies.isEmpty
                        ? const Center(child: Text('Không có phim nào'))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(movieProvider.notifier).loadMovies();
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: movieState.movies.length,
                              itemBuilder: (context, index) {
                                final movie = movieState.movies[index];
                                return MovieCard(
                                  movie: movie,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.movieDetail,
                                      arguments: movie.id,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
