// lib/database/database_helper.dart
// =====================================================
// DatabaseHelper: Khởi tạo và quản lý SQLite database
// Dùng Singleton pattern để chỉ có 1 instance duy nhất
// =====================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // --- Singleton pattern ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Trả về database, tạo mới nếu chưa tồn tại
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Khởi tạo database: tạo file + các bảng
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn lưu database trên thiết bị
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cinema.db');

    return await openDatabase(
      path,
      version: 3, // Tăng version → kích hoạt onUpgrade
      onCreate: _onCreate,       // Gọi khi tạo lần đầu
      onUpgrade: _onUpgrade,     // Gọi khi nâng version
    );
  }

  /// Tạo các bảng khi database được khởi tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    // ---- Bảng CINEMA (Thông tin rạp chiếu phim) ----
    await db.execute('''
      CREATE TABLE cinemas (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,          -- Tên rạp
        address    TEXT    NOT NULL,          -- Địa chỉ
        phone      TEXT,                      -- Số điện thoại
        total_halls INTEGER DEFAULT 1,        -- Tổng số phòng chiếu
        created_at TEXT    DEFAULT (datetime('now'))
      )
    ''');

    // ---- Bảng MOVIES (Thông tin phim) ----
    await db.execute('''
      CREATE TABLE movies (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,         -- Tên phim
        description TEXT,                     -- Mô tả / tóm tắt
        duration    INTEGER NOT NULL,         -- Thời lượng (phút)
        genre       TEXT,                     -- Thể loại (Action, Drama...)
        rating      REAL    DEFAULT 0.0,      -- Điểm đánh giá (0-10)
        image_path  TEXT,                     -- Đường dẫn ảnh poster (trong assets)
        release_date TEXT,                    -- Ngày khởi chiếu
        status      TEXT    DEFAULT 'active', -- Trạng thái: active / inactive
        created_at  TEXT    DEFAULT (datetime('now'))
      )
    ''');

    // ---- Bảng HALLS (Phòng chiếu trong rạp) ----
    await db.execute('''
      CREATE TABLE halls (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        cinema_id INTEGER NOT NULL,           -- Thuộc rạp nào
        name      TEXT    NOT NULL,           -- Tên phòng (VD: Phòng 1, Hall A)
        capacity  INTEGER DEFAULT 100,        -- Sức chứa (số ghế)
        hall_type TEXT    DEFAULT 'standard', -- Loại: standard / vip / imax
        FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE CASCADE
      )
    ''');

    // ---- Bảng SHOWTIMES (Lịch chiếu phim) ----
    await db.execute('''
      CREATE TABLE showtimes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id    INTEGER NOT NULL,         -- Phim nào được chiếu
        hall_id     INTEGER NOT NULL,         -- Chiếu tại phòng nào
        show_date   TEXT    NOT NULL,         -- Ngày chiếu (yyyy-MM-dd)
        start_time  TEXT    NOT NULL,         -- Giờ bắt đầu (HH:mm)
        end_time    TEXT    NOT NULL,         -- Giờ kết thúc (HH:mm)
        ticket_price REAL   DEFAULT 75000,    -- Giá vé (VNĐ)
        available_seats INTEGER,              -- Số ghế còn trống
        status      TEXT    DEFAULT 'active', -- active / cancelled / full
        created_at  TEXT    DEFAULT (datetime('now')),
        FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
        FOREIGN KEY (hall_id)  REFERENCES halls(id)  ON DELETE CASCADE
      )
    ''');

    // ---- Bảng TICKETS (Vé đã bán - dùng cho Statistics) ----
    await db.execute('''
      CREATE TABLE tickets (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        showtime_id INTEGER NOT NULL,         -- Thuộc suất chiếu nào
        seat_number TEXT    NOT NULL,         -- Số ghế
        customer_name TEXT,                   -- Tên khách hàng
        price       REAL    NOT NULL,         -- Giá vé thực tế
        sold_at     TEXT    DEFAULT (datetime('now')),
        FOREIGN KEY (showtime_id) REFERENCES showtimes(id) ON DELETE CASCADE
      )
    ''');

    // Chèn dữ liệu mẫu để demo
    await _insertSampleData(db);
  }

  /// Xử lý nâng cấp database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration v1 → v2: cập nhật image_path cho phim mẫu
    // Thêm/sửa tên file ảnh cho đúng với file bạn đặt trong assets/images/
    // Migration v1→v2 (đã chạy trước đó)
    if (oldVersion < 2) {
      await db.rawUpdate("""
        UPDATE movies
        SET image_path = CASE title
          WHEN 'Avengers: Endgame' THEN 'assets/images/endgame.png'
          WHEN 'Inception'         THEN 'assets/images/Inception.png'
          ELSE image_path
        END
      """);
    }
    // Migration v2→v3: sửa lỗi tên file Inception viết hoa
    if (oldVersion < 3) {
      await db.rawUpdate("""
        UPDATE movies
        SET image_path = 'assets/images/Inception.png'
        WHERE title = 'Inception'
      """);
    }
  }

  /// Chèn dữ liệu mẫu để demo ngay khi cài lần đầu
  Future<void> _insertSampleData(Database db) async {
    // Thêm rạp mẫu
    final cinemaId = await db.insert('cinemas', {
      'name': 'CGV Vincom Center',
      'address': '72 Lê Thánh Tôn, Q.1, TP.HCM',
      'phone': '1900 6017',
      'total_halls': 3,
    });

    // Thêm phòng chiếu mẫu
    await db.insert('halls', {
      'cinema_id': cinemaId,
      'name': 'Phòng 1',
      'capacity': 120,
      'hall_type': 'standard',
    });
    await db.insert('halls', {
      'cinema_id': cinemaId,
      'name': 'Phòng 2 VIP',
      'capacity': 60,
      'hall_type': 'vip',
    });
    await db.insert('halls', {
      'cinema_id': cinemaId,
      'name': 'Phòng IMAX',
      'capacity': 200,
      'hall_type': 'imax',
    });

    // Thêm phim mẫu
    await db.insert('movies', {
      'title': 'Avengers: Endgame',
      'description': 'Siêu anh hùng Marvel hợp lực chống lại Thanos.',
      'duration': 181,
      'genre': 'Action',
      'rating': 8.4,
      'image_path': 'assets/images/movie_placeholder.png',
      'release_date': '2024-01-15',
      'status': 'active',
    });
    await db.insert('movies', {
      'title': 'Inception',
      'description': 'Một tên trộm xâm nhập vào giấc mơ của người khác.',
      'duration': 148,
      'genre': 'Sci-Fi',
      'rating': 8.8,
      'image_path': 'assets/images/movie_placeholder.png',
      'release_date': '2024-02-20',
      'status': 'active',
    });
  }
}