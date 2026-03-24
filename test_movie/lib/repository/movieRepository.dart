import '../database/databaseHelper.dart';
import '../model/movie.dart';

/// MovieRepository — lớp duy nhất ViewModel dùng để lấy dữ liệu phim
///
/// Hiện tại lấy từ SQLite (mock data đã seed vào DB).
/// Sau này chỉ cần thêm API call rồi upsert vào DB — ViewModel không cần thay đổi.
class MovieRepository {
  final DatabaseHelper _db;

  MovieRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy danh sách phim đang chiếu
  Future<List<MovieModel>> getNowShowing() => _db.getNowShowingMovies();

  /// Lấy danh sách phim sắp chiếu
  Future<List<MovieModel>> getComingSoon() => _db.getComingSoonMovies();

  /// Lấy chi tiết một phim theo ID
  Future<MovieModel?> getById(int id) => _db.getMovieById(id);

  /// Lấy tất cả phim (dùng cho banner, search)
  Future<List<MovieModel>> getAll() => _db.getAllMovies();

  /// Tìm kiếm phim theo tên
  Future<List<MovieModel>> search(String query) async {
    final all = await _db.getAllMovies();
    final q   = query.toLowerCase();
    return all
        .where((m) => m.title.toLowerCase().contains(q))
        .toList();
  }

  /// Lưu cache movies từ API
  Future<void> cacheMovies(List<MovieModel> movies) =>
      _db.upsertMovies(movies);
}
