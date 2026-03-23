import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/User.dart';

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
      version: 8,
      onCreate: (db, version) async {
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 8) {
          // Add new columns if they don't exist
          await db.execute('ALTER TABLE users ADD COLUMN city TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN district TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        }
      },
    );
  }

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
}