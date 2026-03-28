import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// DatabaseHelper - Singleton class quản lý SQLite database
/// Sử dụng pattern Singleton để đảm bảo chỉ có 1 instance database
class DatabaseHelper {
  // ─── Singleton Pattern ───────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Constructor private - không cho phép tạo instance từ bên ngoài
  DatabaseHelper._internal();

  // Factory constructor - trả về instance duy nhất
  factory DatabaseHelper() => _instance;

  // ─── Getter lấy database ────────────────────────────────────────
  /// Trả về database instance, tạo mới nếu chưa có
  Future<Database> get database async {
    // Nếu database đã tồn tại thì trả về luôn
    if (_database != null) return _database!;
    // Nếu chưa có thì khởi tạo
    _database = await _initDatabase();
    return _database!;
  }

  // ─── Khởi tạo Database ──────────────────────────────────────────
  /// Tạo database file và các bảng
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn thư mục database của thiết bị
    final dbPath = await getDatabasesPath();
    // Ghép tên file database
    final path = join(dbPath, 'movie_booking.db');

    return await openDatabase(
      path,
      version: 2, // Phiên bản database
      onCreate: _onCreate, // Hàm tạo bảng khi lần đầu mở
      onUpgrade: _onUpgrade, // Hàm nâng cấp database
    );
  }

  // ─── Tạo Bảng ───────────────────────────────────────────────────
  /// Tạo tất cả các bảng khi database được tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    // ───────── Bảng Users ─────────
    // Lưu thông tin người dùng (khách hàng và admin)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        city TEXT,
        district TEXT,
        phone TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // ───────── Bảng Movies ─────────
    // Lưu thông tin phim
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        duration INTEGER NOT NULL,
        genre TEXT,
        rating REAL DEFAULT 0.0,
        image_path TEXT,
        release_date TEXT,
        status TEXT DEFAULT 'active',
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // ───────── Bảng Cinemas ─────────
    // Lưu thông tin rạp chiếu phim
    await db.execute('''
      CREATE TABLE cinemas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT,
        total_halls INTEGER DEFAULT 1,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // ───────── Bảng Bookings ─────────
    // Lưu thông tin đặt vé
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        movieTitle TEXT NOT NULL,
        movieImage TEXT,
        cinema TEXT NOT NULL,
        cinemaHall TEXT NOT NULL,
        format TEXT NOT NULL,
        bookingDate TEXT NOT NULL,
        time TEXT NOT NULL,
        seats TEXT NOT NULL,
        totalPrice REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        createdAt TEXT DEFAULT (datetime('now'))
      )
    ''');

    // ───────── Bảng Reviews ─────────
    // Lưu đánh giá / nhận xét phim
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        date TEXT NOT NULL,
        like_count INTEGER DEFAULT 0,
        is_liked INTEGER DEFAULT 0,
        FOREIGN KEY (movie_id) REFERENCES movies(id)
      )
    ''');

    // ───────── Bảng Trailers ─────────
    // Lưu trailer / video của phim
    await db.execute('''
      CREATE TABLE trailers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        video_id TEXT NOT NULL,
        type TEXT DEFAULT 'Trailer',
        duration TEXT DEFAULT '0:00',
        view_count INTEGER DEFAULT 0,
        FOREIGN KEY (movie_id) REFERENCES movies(id)
      )
    ''');

    // ───────── Chèn dữ liệu mẫu ─────────
    await _insertSeedData(db);
  }

  // ─── Nâng Cấp Database ───────────────────────────────────────────
  /// Nâng cấp database khi có phiên bản mới
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột userId vào bảng bookings
      await db.execute('ALTER TABLE bookings ADD COLUMN userId TEXT NOT NULL DEFAULT ""');
    }
  }

  // ─── Dữ Liệu Mẫu ──────────────────────────────────────────────
  /// Chèn dữ liệu mẫu để test app
  Future<void> _insertSeedData(Database db) async {
    // ── Users mẫu ──
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@cgv.vn',
      'password': 'admin123',
      'role': 'admin',
      'city': 'Hồ Chí Minh',
      'district': 'Quận 1',
      'phone': '0901234567',
    });

    await db.insert('users', {
      'name': 'Nguyễn Văn A',
      'email': 'user@gmail.com',
      'password': 'user123',
      'role': 'user',
      'city': 'Hồ Chí Minh',
      'district': 'Quận 7',
      'phone': '0912345678',
    });

    // ── Movies mẫu ──
    await db.insert('movies', {
      'title': 'Avengers: Endgame',
      'description': 'Biệt đội siêu anh hùng tập hợp lần cuối để đánh bại Thanos.',
      'duration': 181,
      'genre': 'Hành động',
      'rating': 4.8,
      'image_path': 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukaturq76Q6z0Nb8i.jpg',
      'release_date': '2024-04-26',
      'status': 'active',
    });

    await db.insert('movies', {
      'title': 'Spider-Man: No Way Home',
      'description': 'Peter Parker đối mặt với các phản diện từ đa vũ trụ.',
      'duration': 148,
      'genre': 'Hành động',
      'rating': 4.7,
      'image_path': 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
      'release_date': '2024-12-17',
      'status': 'active',
    });

    await db.insert('movies', {
      'title': 'Lật Mặt 7',
      'description': 'Phim Việt Nam kịch tính về gia đình và tình người.',
      'duration': 132,
      'genre': 'Tâm lý',
      'rating': 4.5,
      'image_path': 'https://image.tmdb.org/t/p/w500/placeholder.jpg',
      'release_date': '2025-04-30',
      'status': 'active',
    });

    // ── Cinemas mẫu ──
    await db.insert('cinemas', {
      'name': 'CGV Vincom Đồng Khởi',
      'address': '72 Lê Thánh Tôn, Quận 1, TP.HCM',
      'phone': '1900 6017',
      'total_halls': 5,
    });

    await db.insert('cinemas', {
      'name': 'CGV Aeon Mall Tân Phú',
      'address': '30 Bờ Bao Tân Thắng, Tân Phú, TP.HCM',
      'phone': '1900 6017',
      'total_halls': 8,
    });

    await db.insert('cinemas', {
      'name': 'CGV Landmark 81',
      'address': '720A Điện Biên Phủ, Bình Thạnh, TP.HCM',
      'phone': '1900 6017',
      'total_halls': 6,
    });

    // ── Reviews mẫu ──
    await db.insert('reviews', {
      'movie_id': 1,
      'user_name': 'Nguyễn Văn A',
      'rating': 4.5,
      'comment': 'Phim rất hay, cảm động!',
      'date': '2025-03-20',
      'like_count': 12,
      'is_liked': 0,
    });

    // ── Trailers mẫu ──
    await db.insert('trailers', {
      'movie_id': 1,
      'title': 'Avengers: Endgame - Official Trailer',
      'video_id': 'TcMBFSGVi1c',
      'type': 'Trailer',
      'duration': '2:30',
      'view_count': 1500000,
    });
  }

  // ─── Đóng Database ──────────────────────────────────────────────
  /// Đóng kết nối database khi không dùng nữa
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
