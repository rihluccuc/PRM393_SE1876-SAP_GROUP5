import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/User.dart';
import '../models/booking_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT,
            city TEXT,
            district TEXT,
            phone TEXT
          )
        ''');

        // Insert default admin account
        await db.insert('users', {
          'name': 'Admin',
          'email': 'admin1@gmail.com',
          'password': 'admin123',
          'role': 'admin',
          'city': null,
          'district': null,
          'phone': null
        });

        // Create bookings table
        await db.execute('''
          CREATE TABLE bookings(
            id TEXT PRIMARY KEY,
            movieTitle TEXT,
            movieImage TEXT,
            cinema TEXT,
            cinemaHall TEXT,
            format TEXT,
            bookingDate TEXT,
            time TEXT,
            seats TEXT,
            totalPrice REAL,
            status TEXT,
            createdAt TEXT
          )
        ''');

        // Insert sample booking data
        await _insertSampleBookings(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle users table upgrades
        if (oldVersion < 8) {
          await db.execute('ALTER TABLE users ADD COLUMN city TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN district TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        }

        // Create bookings table if upgrading from version 8
        if (oldVersion < 9) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS bookings(
              id TEXT PRIMARY KEY,
              movieTitle TEXT,
              movieImage TEXT,
              cinema TEXT,
              cinemaHall TEXT,
              format TEXT,
              bookingDate TEXT,
              time TEXT,
              seats TEXT,
              totalPrice REAL,
              status TEXT,
              createdAt TEXT
            )
          ''');
          await _insertSampleBookings(db);
        }
      },
    );
  }

  Future<void> _insertSampleBookings(Database db) async {
    List<Map<String, dynamic>> sampleBookings = [
      {
        'id': 'BK001',
        'movieTitle': 'Deadpool & Wolverine',
        'movieImage': 'https://disney.images.edge.bamgrid.com/ripcut-delivery/v2/variant/disney/f320e725-3dbd-4e49-ad38-f6e9eaa410b5/compose?aspectRatio=1.78&format=webp&width=1200',
        'cinema': 'CGV Vincom Mega Mall',
        'cinemaHall': 'Hall 7',
        'format': '3D',
        'bookingDate': '2026-02-28T00:00:00.000',
        'time': '19:30',
        'seats': 'E1,E2,E3',
        'totalPrice': 450000.0,
        'status': 'completed',
        'createdAt': '2026-02-15T14:30:00.000',
      },
      {
        'id': 'BK002',
        'movieTitle': 'Dune: Part Two',
        'movieImage': 'https://i.ytimg.com/vi/AkZBjK69VcE/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGH8gQygTMA8=&rs=AOn4CLA-B62hGQJB6Jbr6W7HPEW4d-BYRw',
        'cinema': 'CGV Vincom Tây Hồ',
        'cinemaHall': 'Hall 3',
        'format': 'IMAX',
        'bookingDate': '2026-03-15T00:00:00.000',
        'time': '20:00',
        'seats': 'A5,A6',
        'totalPrice': 600000.0,
        'status': 'confirmed',
        'createdAt': '2026-03-01T10:15:00.000',
      },
      {
        'id': 'BK003',
        'movieTitle': 'The Brutalist',
        'movieImage': 'https://m.media-amazon.com/images/M/MV5BM2U0MWRjZTMtMDVhNC00MzY4LTgwOTktZGQ2MDdiYTI4OWMxXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
        'cinema': 'CGV Hà Đông',
        'cinemaHall': 'Hall 2',
        'format': '2D',
        'bookingDate': '2026-03-10T00:00:00.000',
        'time': '16:45',
        'seats': 'D10,D11',
        'totalPrice': 300000.0,
        'status': 'pending',
        'createdAt': '2026-03-02T09:20:00.000',
      },
      {
        'id': 'BK004',
        'movieTitle': 'Oppenheimer',
        'movieImage': 'https://www.gardenofmemory.net/content/images/2023/07/oppenheimer-header.jpg',
        'cinema': 'CGV Aeon Tân Phú',
        'cinemaHall': 'Hall 1',
        'format': '2D',
        'bookingDate': '2026-02-20T00:00:00.000',
        'time': '18:00',
        'seats': 'B3,B4,B5,B6',
        'totalPrice': 400000.0,
        'status': 'cancelled',
        'createdAt': '2026-02-10T16:45:00.000',
      },
      {
        'id': 'BK005',
        'movieTitle': 'Inception',
        'movieImage': 'https://miro.medium.com/v2/resize:fit:1400/1*xLahrUiFfXAs8s_Q8JKcbA@2x.jpeg',
        'cinema': 'CGV Vincom Mega Mall',
        'cinemaHall': 'Hall 5',
        'format': '3D',
        'bookingDate': '2026-01-25T00:00:00.000',
        'time': '21:00',
        'seats': 'F7,F8',
        'totalPrice': 500000.0,
        'status': 'completed',
        'createdAt': '2026-01-10T12:00:00.000',
      },
    ];

    for (var booking in sampleBookings) {
      try {
        await db.insert('bookings', booking);
      } catch (e) {
        // Ignore if booking already exists
      }
    }
  }

  /// ============== USER METHODS ==============

  /// dang ki
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  /// dang nhap
  Future<User?> loginUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  /// Update user address
  Future<int> updateUserAddress(int userId, String city, String district) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'city': city,
        'district': district,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Change user password
  Future<int> changeUserPassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// ============== BOOKING METHODS ==============

  /// Get all bookings
  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Booking.fromMap(maps.first);
    }
    return null;
  }

  /// Update booking status
  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    final db = await database;
    await db.update(
      'bookings',
      {'status': status.nameString},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert booking
  Future<void> insertBooking(Booking booking) async {
    final db = await database;
    await db.insert('bookings', booking.toMap());
  }

  /// Delete booking
  Future<void> deleteBooking(String id) async {
    final db = await database;
    await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}