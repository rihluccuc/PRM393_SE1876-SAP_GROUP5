// lib/repositories/cinema_repository.dart
// =====================================================
// Repository: CinemaRepository + HallRepository
// Xử lý CRUD cho bảng cinemas và halls
// =====================================================

import '../database/database_helper.dart';
import '../models/cinema_model.dart';

class CinemaRepository {
  final DatabaseHelper _dbHelper;
  CinemaRepository(this._dbHelper);

  /// Lấy tất cả rạp chiếu phim
  Future<List<Cinema>> getAllCinemas() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cinemas', orderBy: 'name ASC');
    return maps.map((m) => Cinema.fromMap(m)).toList();
  }

  /// Lấy rạp theo ID
  Future<Cinema?> getCinemaById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cinemas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Cinema.fromMap(maps.first);
  }

  /// Thêm rạp mới
  Future<int> insertCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.insert('cinemas', cinema.toMap());
  }

  /// Cập nhật thông tin rạp
  Future<int> updateCinema(Cinema cinema) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cinemas',
      cinema.toMap(),
      where: 'id = ?',
      whereArgs: [cinema.id],
    );
  }

  /// Xóa rạp (cascade xóa halls và showtimes)
  Future<int> deleteCinema(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cinemas', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Quản lý Phòng chiếu (Hall) ----

  /// Lấy tất cả phòng chiếu của 1 rạp
  Future<List<Hall>> getHallsByCinema(int cinemaId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'halls',
      where: 'cinema_id = ?',
      whereArgs: [cinemaId],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Hall.fromMap(m)).toList();
  }

  /// Lấy tất cả phòng chiếu (dùng cho dropdown chọn phòng)
  Future<List<Hall>> getAllHalls() async {
    final db = await _dbHelper.database;
    final maps = await db.query('halls', orderBy: 'cinema_id, name ASC');
    return maps.map((m) => Hall.fromMap(m)).toList();
  }

  /// Thêm phòng chiếu mới
  Future<int> insertHall(Hall hall) async {
    final db = await _dbHelper.database;
    final hallId = await db.insert('halls', hall.toMap());
    // Cập nhật lại total_halls của rạp
    await _updateCinemaTotalHalls(hall.cinemaId);
    return hallId;
  }

  /// Cập nhật thông tin phòng chiếu
  Future<int> updateHall(Hall hall) async {
    final db = await _dbHelper.database;
    return await db.update(
      'halls',
      hall.toMap(),
      where: 'id = ?',
      whereArgs: [hall.id],
    );
  }

  /// Xóa phòng chiếu
  Future<void> deleteHall(int hallId, int cinemaId) async {
    final db = await _dbHelper.database;
    await db.delete('halls', where: 'id = ?', whereArgs: [hallId]);
    await _updateCinemaTotalHalls(cinemaId);
  }

  /// Cập nhật tổng số phòng trong rạp
  Future<void> _updateCinemaTotalHalls(int cinemaId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM halls WHERE cinema_id = ?',
      [cinemaId],
    );
    final count = result.first['count'] as int;
    await db.update(
      'cinemas',
      {'total_halls': count},
      where: 'id = ?',
      whereArgs: [cinemaId],
    );
  }
}

// =====================================================
// Repository: ShowtimeRepository
// Xử lý CRUD cho bảng showtimes
// =====================================================

class ShowtimeRepository {
  final DatabaseHelper _dbHelper;
  ShowtimeRepository(this._dbHelper);

  /// Lấy tất cả lịch chiếu, JOIN với movies và halls để lấy tên
  Future<List<Showtime>> getAllShowtimes() async {
    final db = await _dbHelper.database;
    // JOIN để lấy tên phim và tên phòng chiếu
    final maps = await db.rawQuery('''
      SELECT 
        s.*,
        m.title  AS movie_title,
        m.image_path AS movie_image,
        h.name   AS hall_name
      FROM showtimes s
      JOIN movies m ON s.movie_id = m.id
      JOIN halls  h ON s.hall_id  = h.id
      ORDER BY s.show_date DESC, s.start_time ASC
    ''');
    return maps.map((m) => Showtime.fromMap(m)).toList();
  }

  /// Lấy lịch chiếu theo ngày cụ thể
  Future<List<Showtime>> getShowtimesByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        s.*,
        m.title  AS movie_title,
         m.image_path AS movie_image,
        h.name   AS hall_name
      FROM showtimes s
      JOIN movies m ON s.movie_id = m.id
      JOIN halls  h ON s.hall_id  = h.id
      WHERE s.show_date = ?
      ORDER BY s.start_time ASC
    ''', [date]);
    return maps.map((m) => Showtime.fromMap(m)).toList();
  }

  /// Lấy lịch chiếu theo phim
  Future<List<Showtime>> getShowtimesByMovie(int movieId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT 
        s.*,
        m.title  AS movie_title,
         m.image_path AS movie_image, 
        h.name   AS hall_name
      FROM showtimes s
      JOIN movies m ON s.movie_id = m.id
      JOIN halls  h ON s.hall_id  = h.id
      WHERE s.movie_id = ?
      ORDER BY s.show_date DESC, s.start_time ASC
    ''', [movieId]);
    return maps.map((m) => Showtime.fromMap(m)).toList();
  }

  /// Thêm lịch chiếu mới
  Future<int> insertShowtime(Showtime showtime) async {
    final db = await _dbHelper.database;
    return await db.insert('showtimes', showtime.toMap());
  }

  /// Cập nhật lịch chiếu
  Future<int> updateShowtime(Showtime showtime) async {
    final db = await _dbHelper.database;
    return await db.update(
      'showtimes',
      showtime.toMap(),
      where: 'id = ?',
      whereArgs: [showtime.id],
    );
  }

  /// Xóa lịch chiếu
  Future<int> deleteShowtime(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('showtimes', where: 'id = ?', whereArgs: [id]);
  }

  /// Kiểm tra xem phòng đã có lịch chiếu trùng giờ chưa
  Future<bool> hasConflict({
    required int hallId,
    required String showDate,
    required String startTime,
    required String endTime,
    int? excludeId, // Bỏ qua ID này (dùng khi update)
  }) async {
    final db = await _dbHelper.database;
    final query = excludeId != null
        ? '''SELECT COUNT(*) as count FROM showtimes 
             WHERE hall_id = ? AND show_date = ? AND id != ?
             AND status = 'active'
             AND NOT (end_time <= ? OR start_time >= ?)'''
        : '''SELECT COUNT(*) as count FROM showtimes 
             WHERE hall_id = ? AND show_date = ? 
             AND status = 'active'
             AND NOT (end_time <= ? OR start_time >= ?)''';

    final args = excludeId != null
        ? [hallId, showDate, excludeId, startTime, endTime]
        : [hallId, showDate, startTime, endTime];

    final result = await db.rawQuery(query, args);
    return (result.first['count'] as int) > 0;
  }
}

// =====================================================
// Repository: StatisticsRepository
// Truy vấn dữ liệu thống kê phức tạp
// =====================================================

class StatisticsRepository {
  final DatabaseHelper _dbHelper;
  StatisticsRepository(this._dbHelper);

  /// Thống kê tổng quan: số phim, suất chiếu, vé bán, doanh thu
  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await _dbHelper.database;

    // Đếm số phim active
    final movieCount = await db.rawQuery(
      "SELECT COUNT(*) as count FROM movies WHERE status = 'active'",
    );

    // Đếm số suất chiếu active
    final showtimeCount = await db.rawQuery(
      "SELECT COUNT(*) as count FROM showtimes WHERE status = 'active'",
    );

    // Tổng vé bán và doanh thu
    final ticketStats = await db.rawQuery(
      'SELECT COUNT(*) as total_tickets, SUM(price) as total_revenue FROM tickets',
    );

    return {
      'total_movies': movieCount.first['count'],
      'total_showtimes': showtimeCount.first['count'],
      'total_tickets': ticketStats.first['total_tickets'] ?? 0,
      'total_revenue': ticketStats.first['total_revenue'] ?? 0.0,
    };
  }

  /// Top 5 phim bán nhiều vé nhất
  Future<List<Map<String, dynamic>>> getTopMovies({int limit = 5}) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        m.title,
        m.genre,
        m.image_path,
        COUNT(t.id)  AS ticket_count,
        SUM(t.price) AS revenue
      FROM movies m
      LEFT JOIN showtimes s ON m.id = s.movie_id
      LEFT JOIN tickets   t ON s.id = t.showtime_id
      GROUP BY m.id
      ORDER BY ticket_count DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Doanh thu theo từng ngày (7 ngày gần nhất)
  Future<List<Map<String, dynamic>>> getRevenueByDate({int days = 7}) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        DATE(t.sold_at) AS sale_date,
        COUNT(t.id)     AS ticket_count,
        SUM(t.price)    AS revenue
      FROM tickets t
      WHERE t.sold_at >= DATE('now', '-$days days')
      GROUP BY DATE(t.sold_at)
      ORDER BY sale_date ASC
    ''');
  }

  /// Thống kê theo thể loại phim
  Future<List<Map<String, dynamic>>> getStatsByGenre() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        m.genre,
        COUNT(DISTINCT m.id) AS movie_count,
        COUNT(t.id)          AS ticket_count,
        SUM(t.price)         AS revenue
      FROM movies m
      LEFT JOIN showtimes s ON m.id = s.movie_id
      LEFT JOIN tickets   t ON s.id = t.showtime_id
      GROUP BY m.genre
      ORDER BY revenue DESC
    ''');
  }

  /// Thêm vé bán (dùng để test thống kê)
  Future<void> insertSampleTickets() async {
    final db = await _dbHelper.database;
    // Kiểm tra xem đã có vé chưa
    final count = await db.rawQuery('SELECT COUNT(*) as c FROM tickets');
    if ((count.first['c'] as int) > 0) return;

    // Thêm vé mẫu cho các suất chiếu hiện có
    final showtimes = await db.query('showtimes', limit: 5);
    for (final s in showtimes) {
      for (int i = 1; i <= 10; i++) {
        await db.insert('tickets', {
          'showtime_id': s['id'],
          'seat_number': 'A$i',
          'customer_name': 'Khách hàng $i',
          'price': s['ticket_price'],
          'sold_at': DateTime.now()
              .subtract(Duration(days: i % 7))
              .toIso8601String(),
        });
      }
    }
  }
}