import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cinema.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'cinema.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE seats(
            id TEXT PRIMARY KEY,
            label TEXT,
            isSelected INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE cinemas(
            id TEXT PRIMARY KEY,
            name TEXT,
            distance REAL,
            showtimes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE booked_seats(
            id TEXT PRIMARY KEY,
            cinemaName TEXT,
            showTime TEXT,
            seatLabel TEXT,
            bookedAt TEXT
          )
        ''');
      },
    );
  }

  // Insert cinema
  static Future<void> insertCinema(Cinema cinema) async {
    final db = await database;
    await db.insert(
      'cinemas',
      {
        'id': cinema.id,
        'name': cinema.name,
        'distance': cinema.distance,
        'showtimes': jsonEncode(cinema.showtimes),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all cinemas
  static Future<List<Cinema>> getCinemas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cinemas');
    return List.generate(maps.length, (i) {
      return Cinema(
        id: maps[i]['id'],
        name: maps[i]['name'],
        distance: maps[i]['distance'],
        showtimes: List<String>.from(jsonDecode(maps[i]['showtimes'])),
      );
    });
  }

  // Insert booked seat
  static Future<void> insertBookedSeat(String cinemaName, String showTime, String seatLabel) async {
    final db = await database;
    final id = "${cinemaName}_${showTime}_$seatLabel";
    await db.insert(
      'booked_seats',
      {
        'id': id,
        'cinemaName': cinemaName,
        'showTime': showTime,
        'seatLabel': seatLabel,
        'bookedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Get booked seats for specific cinema and showtime
  static Future<List<String>> getBookedSeats(String cinemaName, String showTime) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'booked_seats',
      where: 'cinemaName = ? AND showTime = ?',
      whereArgs: [cinemaName, showTime],
    );
    return maps.map((m) => m['seatLabel'] as String).toList();
  }

  // Insert multiple booked seats
  static Future<void> insertMultipleBookedSeats(String cinemaName, String showTime, List<String> seats) async {
    final db = await database;
    final batch = db.batch();
    for (var seat in seats) {
      final id = "${cinemaName}_${showTime}_$seat";
      batch.insert(
        'booked_seats',
        {
          'id': id,
          'cinemaName': cinemaName,
          'showTime': showTime,
          'seatLabel': seat,
          'bookedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit();
  }
}