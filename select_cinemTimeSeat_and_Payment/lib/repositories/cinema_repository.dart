import '../models/cinema.dart';
import '../db/app_database.dart';

class CinemaRepository {
  Future<List<Cinema>> getCinemas() async {
    // Insert initial data if not exists (check if table is empty)
    List<Cinema> existing = await AppDatabase.getCinemas();
    if (existing.isEmpty) {
      await _insertInitialData();
    }
    return AppDatabase.getCinemas();
  }

  Future<void> _insertInitialData() async {
    List<Cinema> cinemas = [
      Cinema(
        id: "1",
        name: "CGV Vincom Bà Triệu",
        distance: 1.0,
        showtimes: ["09:50", "10:45", "13:30"],
      ),
      Cinema(
        id: "2",
        name: "CGV Tràng Tiền",
        distance: 1.9,
        showtimes: ["09:30", "11:00"],
      ),
    ];
    for (var cinema in cinemas) {
      await AppDatabase.insertCinema(cinema);
    }
  }
}