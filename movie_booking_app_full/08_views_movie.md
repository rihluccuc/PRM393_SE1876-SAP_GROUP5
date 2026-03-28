# 🎬 Views - Movie (Khanh)

## Mô Tả
Module Movie gồm 4 màn hình do **Khanh** phụ trách:
1. **Movie List** - Danh sách phim
2. **Movie Detail** - Chi tiết phim
3. **Trailer Screen** - Xem trailer
4. **Review Screen** - Đánh giá phim

---

## File: `lib/views/movie/movie_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../models/movie.dart';

/// MovieListScreen - Danh sách phim (trang chính)
/// Người phụ trách: Khanh
class MovieListScreen extends ConsumerStatefulWidget {
  const MovieListScreen({super.key});
  @override
  ConsumerState<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends ConsumerState<MovieListScreen> {
  @override
  void initState() {
    super.initState();
    // Load phim khi mở màn hình
    Future.microtask(() => ref.read(movieProvider.notifier).loadMovies());
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(movieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 CGV Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Hiện dialog tìm kiếm
              showDialog(
                context: context,
                builder: (_) {
                  final ctrl = TextEditingController();
                  return AlertDialog(
                    title: const Text('Tìm kiếm phim'),
                    content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Nhập tên phim...')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                      TextButton(
                        onPressed: () { ref.read(movieProvider.notifier).searchMovies(ctrl.text); Navigator.pop(context); },
                        child: const Text('Tìm'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: movieState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movieState.movies.length,
              itemBuilder: (context, index) {
                final movie = movieState.movies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Image.network(movie.imagePath ?? '', width: 60, height: 90, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 60, height: 90, color: Colors.grey[300], child: const Icon(Icons.movie))),
                    title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(movie.genre ?? 'Chưa phân loại'),
                      Text('${movie.duration} phút'),
                      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(' ${movie.rating}/5.0')]),
                    ]),
                    onTap: () => Navigator.pushNamed(context, '/movie-detail', arguments: movie.id),
                  ),
                );
              },
            ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Phim'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/booking-history');
          if (i == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}
```

---

## File: `lib/views/movie/movie_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/movie_viewmodel.dart';

/// MovieDetailScreen - Chi tiết phim
/// Người phụ trách: Khanh
class MovieDetailScreen extends ConsumerStatefulWidget {
  const MovieDetailScreen({super.key});
  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movieId = ModalRoute.of(context)!.settings.arguments as int;
    ref.read(movieProvider.notifier).loadMovieDetail(movieId);
  }

  @override
  Widget build(BuildContext context) {
    final movie = ref.watch(movieProvider).selectedMovie;

    return Scaffold(
      body: movie == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: [
              // Ảnh poster lớn
              SliverAppBar(
                expandedHeight: 300, pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(movie.title),
                  background: Image.network(movie.imagePath ?? '', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey, child: const Icon(Icons.movie, size: 80))),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Thông tin cơ bản
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber), Text(' ${movie.rating}/5.0'),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time), Text(' ${movie.duration} phút'),
                      const SizedBox(width: 16),
                      Chip(label: Text(movie.genre ?? 'N/A')),
                    ]),
                    const SizedBox(height: 16),
                    // Mô tả
                    const Text('Mô tả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(movie.description ?? 'Chưa có mô tả'),
                    const SizedBox(height: 24),
                    // Nút Trailer & Đánh giá
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/trailer', arguments: movie.id),
                      icon: const Icon(Icons.play_circle_outline), label: const Text('Xem Trailer'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/reviews', arguments: movie.id),
                      icon: const Icon(Icons.rate_review), label: const Text('Xem Đánh Giá'),
                    ),
                    const SizedBox(height: 24),
                    // Nút Đặt vé
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/select-cinema', arguments: movie),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('ĐẶT VÉ NGAY', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
    );
  }
}
```

---

## File: `lib/views/movie/trailer_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/trailer_viewmodel.dart';

/// TrailerScreen - Xem trailer phim (mở YouTube)
/// Người phụ trách: Khanh
class TrailerScreen extends ConsumerStatefulWidget {
  const TrailerScreen({super.key});
  @override
  ConsumerState<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends ConsumerState<TrailerScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movieId = ModalRoute.of(context)!.settings.arguments as int;
    ref.read(trailerProvider.notifier).loadTrailers(movieId);
  }

  Future<void> _openYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trailerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trailer')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.trailers.isEmpty
              ? const Center(child: Text('Chưa có trailer'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.trailers.length,
                  itemBuilder: (_, i) {
                    final t = state.trailers[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _openYouTube(t.videoId),
                        child: Column(children: [
                          // Thumbnail + nút play
                          Stack(alignment: Alignment.center, children: [
                            Image.network(t.thumbnailUrl, width: double.infinity, height: 200, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey[300])),
                            const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                          ]),
                          Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Row(children: [Chip(label: Text(t.type)), const SizedBox(width: 8), Text(t.duration), const Spacer(), Text('${t.viewCount} views')]),
                          ])),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
```

---

## File: `lib/views/movie/review_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../models/review_model.dart';

/// ReviewScreen - Đánh giá phim
/// Người phụ trách: Khanh
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late int movieId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movieId = ModalRoute.of(context)!.settings.arguments as int;
    ref.read(reviewProvider.notifier).loadReviews(movieId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh Giá')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Dialog thêm đánh giá
          double rating = 3.0;
          final ctrl = TextEditingController();
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Viết đánh giá'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              // Rating: dùng Slider đơn giản
              StatefulBuilder(builder: (ctx, setState) => Column(children: [
                Text('⭐ ${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 20)),
                Slider(value: rating, min: 1, max: 5, divisions: 8, onChanged: (v) => setState(() => rating = v)),
              ])),
              TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Nhận xét...', border: OutlineInputBorder())),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
              ElevatedButton(onPressed: () {
                final review = ReviewModel(id: DateTime.now().millisecondsSinceEpoch, movieId: movieId,
                    userName: 'Người dùng', rating: rating, comment: ctrl.text,
                    date: DateTime.now().toString().substring(0, 10), likeCount: 0);
                ref.read(reviewProvider.notifier).addReview(review);
                Navigator.pop(context);
              }, child: const Text('Gửi')),
            ],
          ));
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (_, i) {
                final r = state.reviews[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(r.date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ]),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: List.generate(5, (j) => Icon(j < r.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                      const SizedBox(height: 4),
                      Text(r.comment),
                      Row(children: [
                        IconButton(icon: Icon(r.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 18,
                            color: r.isLiked ? Colors.blue : Colors.grey),
                            onPressed: () => ref.read(reviewProvider.notifier).toggleLike(r.id)),
                        Text('${r.likeCount}'),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
```
