import '../models/movie.dart';
import '../repositories/movie_repository.dart';

/// MovieService - Xử lý logic nghiệp vụ liên quan đến phim
class MovieService {
  final MovieRepository _movieRepo = MovieRepository();

  // ─── Lấy danh sách phim ────────────────────────────────────────
  /// Lấy tất cả phim đang chiếu
  Future<List<Movie>> getActiveMovies() async {
    return await _movieRepo.getAllMovies();
  }

  // ─── Lấy chi tiết phim ─────────────────────────────────────────
  /// Lấy thông tin chi tiết 1 phim theo ID
  Future<Movie?> getMovieDetail(int id) async {
    return await _movieRepo.getMovieById(id);
  }

  // ─── Tìm kiếm phim ─────────────────────────────────────────────
  /// Tìm phim theo tên
  Future<List<Movie>> searchMovies(String keyword) async {
    if (keyword.isEmpty) return await getActiveMovies();
    return await _movieRepo.searchMovies(keyword);
  }

  // ─── Thêm phim (Admin) ─────────────────────────────────────────
  /// Thêm phim mới vào database
  Future<int> addMovie(Movie movie) async {
    return await _movieRepo.insertMovie(movie);
  }

  // ─── Cập nhật phim (Admin) ──────────────────────────────────────
  Future<void> updateMovie(Movie movie) async {
    await _movieRepo.updateMovie(movie);
  }

  // ─── Xóa phim (Admin) ──────────────────────────────────────────
  Future<void> deleteMovie(int id) async {
    await _movieRepo.deleteMovie(id);
  }

  // ─── Thống kê (Admin) ──────────────────────────────────────────
  Future<int> getTotalMovies() async {
    return await _movieRepo.getMovieCount();
  }
}
