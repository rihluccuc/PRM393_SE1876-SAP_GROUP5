import '../models/cinema.dart';
import '../repositories/cinema_repository.dart';

/// CinemaService - Xử lý logic liên quan đến rạp chiếu phim
class CinemaService {
  final CinemaRepository _cinemaRepo = CinemaRepository();

  // ─── Lấy danh sách rạp ─────────────────────────────────────────
  Future<List<Cinema>> getAllCinemas() async {
    return await _cinemaRepo.getAllCinemas();
  }

  // ─── Lấy chi tiết rạp ──────────────────────────────────────────
  Future<Cinema?> getCinemaDetail(int id) async {
    return await _cinemaRepo.getCinemaById(id);
  }

  // ─── Thêm rạp mới (Admin) ──────────────────────────────────────
  Future<int> addCinema(Cinema cinema) async {
    return await _cinemaRepo.insertCinema(cinema);
  }

  // ─── Cập nhật rạp (Admin) ──────────────────────────────────────
  Future<void> updateCinema(Cinema cinema) async {
    await _cinemaRepo.updateCinema(cinema);
  }

  // ─── Xóa rạp (Admin) ───────────────────────────────────────────
  Future<void> deleteCinema(int id) async {
    await _cinemaRepo.deleteCinema(id);
  }
}
