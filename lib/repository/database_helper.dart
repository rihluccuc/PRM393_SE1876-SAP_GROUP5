import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
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
      await db.insert('bookings', booking);
    }
  }

  Future<List<Booking>> getAllBookings() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<Booking?> getBookingById(String id) async {
    Database db = await database;
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

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    Database db = await database;
    await db.update(
      'bookings',
      {'status': status.nameString},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertBooking(Booking booking) async {
    Database db = await database;
    await db.insert('bookings', booking.toMap());
  }

  Future<void> deleteBooking(String id) async {
    Database db = await database;
    await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
