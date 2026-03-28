import '../database/database_helper.dart';
import '../models/user.dart';

/// UserRepository - Thao tác CRUD với bảng users
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ─── Tạo user mới ──────────────────────────────────────────────
  /// Thêm user vào database, trả về ID của user mới
  Future<int> insertUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // ─── Lấy user theo email ───────────────────────────────────────
  /// Tìm user theo email (dùng cho đăng nhập)
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',       // Điều kiện tìm kiếm
      whereArgs: [email],       // Giá trị truyền vào
    );
    // Nếu tìm thấy thì chuyển sang User, không thì trả về null
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ─── Lấy user theo ID ──────────────────────────────────────────
  /// Tìm user theo ID
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // ─── Cập nhật user ─────────────────────────────────────────────
  /// Cập nhật thông tin user, trả về số dòng bị ảnh hưởng
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ─── Lấy tất cả users ──────────────────────────────────────────
  /// Lấy danh sách tất cả users (dùng cho admin)
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }
}
