# Hướng dẫn Tích hợp & Sử dụng Chi tiết

## 1. Cập nhật trong App

### 1.1 Đảm bảo EditProfileScreen được gọi từ đâu đó

Trong file navigation của bạn (app.dart hoặc routes), hãy thêm route để navigation đến EditProfileScreen:

```dart
// Trong app_routes.dart hoặc route configuration của bạn
static const String editProfile = '/edit-profile';

// Hoặc trong named routes:
'/edit-profile': (context) => const EditProfileScreen(),
```

### 1.2 Gọi EditProfileScreen từ ProfileScreen

Trong profile_screen.dart (nếu có), thêm nút để navigate đến edit profile:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.editProfile);
  },
  child: const Text('Chỉnh sửa hồ sơ'),
),
```

---

## 2. Cấu trúc dữ liệu Database

Đảm bảo database schema hỗ trợ các trường sau:

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  phone TEXT,
  city TEXT,
  district TEXT,
  role TEXT DEFAULT 'user'
);
```

---

## 3. Kiểm tra UserRepository

Đảm bảo UserRepository có các method sau:

```dart
// Lấy user theo email
Future<User?> getUserByEmail(String email) { ... }

// Lấy user theo ID
Future<User?> getUserById(int id) { ... }

// Thêm user mới
Future<int> insertUser(User user) { ... }

// Cập nhật user
Future<void> updateUser(User user) { ... }
```

---

## 4. Testing Flow

### 4.1 Test Đăng ký
1. Khởi động app
2. Điều hướng đến RegisterScreen
3. Nhập tất cả các trường bắt buộc hợp lệ
4. Bấm "Đăng ký"
5. Kiểm tra:
   - Thông báo thành công
   - Chuyển về login screen
   - Dữ liệu lưu trong database

### 4.2 Test Chỉnh sửa hồ sơ
1. Đăng nhập
2. Điều hướng đến EditProfileScreen
3. Sửa thông tin (Họ tên, Số điện thoại, Thành phố, Quận/Huyện)
4. Bấm "Lưu thay đổi"
5. Kiểm tra:
   - Thông báo thành công
   - Dữ liệu cập nhật trong database

### 4.3 Test Đổi mật khẩu
1. Điều hướng đến EditProfileScreen
2. Mở phần "Đổi mật khẩu"
3. Nhập mật khẩu hiện tại (chính xác)
4. Nhập mật khẩu mới (tối thiểu 6 ký tự)
5. Xác nhận mật khẩu mới (phải khớp)
6. Bấm "Đổi mật khẩu"
7. Kiểm tra:
   - Thông báo thành công
   - Có thể đăng nhập với mật khẩu mới

---

## 5. Troubleshooting

### Vấn đề: "User không tồn tại" khi đổi mật khẩu
**Giải pháp:**
- Kiểm tra user.id không null
- Kiểm tra user đã được lưu trong database
- Xác nhận SharedPrefService lưu userId chính xác

### Vấn đề: "Email đã được sử dụng"
**Giải pháp:**
- Kiểm tra database không có email trùng
- Xóa dữ liệu cũ nếu cần
- Sử dụng email duy nhất trong test

### Vấn đề: Validations không hoạt động
**Giải pháp:**
- Kiểm tra Form key: `_formKey.currentState!.validate()`
- Đảm bảo TextFormField có validator
- Kiểm tra BuildContext còn mounted

### Vấn đề: Data không lưu vào database
**Giải pháp:**
- Kiểm tra UserRepository.updateUser() implementation
- Xác nhận database connection hoạt động
- Kiểm tra user.id không null (required cho update)

---

## 6. Security Considerations

⚠️ **IMPORTANT FOR PRODUCTION:**

### Password Hashing (Chưa implement)
```dart
// Nên thêm hashing thay vì lưu plaintext password
// Sử dụng package like: crypto, bcrypt
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}
```

### Email Verification (Nâng cao)
```dart
// Có thể thêm xác thực email:
// 1. Gửi OTP khi đăng ký
// 2. Kiểm tra OTP trước khi activate account
```

### Rate Limiting (Nâng cao)
```dart
// Kiểm tra quá nhiều attempt sai mật khẩu
// Khóa tài khoản tạm thời nếu cố gắng quá nhiều
```

---

## 7. Enhancements đề xuất

### 7.1 Phone Number Formatting
```dart
// Tự động format số điện thoại
String formatPhone(String phone) {
  if (phone.length == 10) {
    return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    // 0912345678 -> 091-234-5678
  }
  return phone;
}
```

### 7.2 Real-time Email Verification
```dart
// Kiểm tra email sẵn có ngay khi người dùng nhập
// Thay vì chỉ khi submit
```

### 7.3 Password Strength Indicator
```dart
// Hiển thị chỉ số mật khẩu mạnh/yếu
// Gợi ý độ phức tạp
```

### 7.4 Social Login Integration
```dart
// Thêm đăng ký/đăng nhập qua Google, Facebook, etc.
```

---

## 8. API Integration (Nếu có backend)

Nếu sau này tích hợp với backend, hãy update:

```dart
// AuthService - đổi từ database local sang API
Future<User> register({...}) async {
  // Gọi API backend thay vì database local
  final response = await http.post(
    Uri.parse('https://api.example.com/auth/register'),
    body: {...},
  );
  
  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Đăng ký thất bại');
  }
}
```

---

## 9. Performance Tips

### Caching
```dart
// Cache user data để tránh query database liên tục
final _userCache = <int, User>{};

Future<User?> getUserById(int id) async {
  if (_userCache.containsKey(id)) {
    return _userCache[id];
  }
  
  final user = await _database.query(...);
  if (user != null) {
    _userCache[id] = user;
  }
  return user;
}
```

### Lazy Loading
```dart
// Load user data khi cần thay vì load tất cả
// Sử dụng pagination cho danh sách
```

---

## 10. Testing Code

```dart
// Ví dụ unit test cho validations
void main() {
  test('Email validation should return null for valid email', () {
    final validator = _validateEmail('test@example.com');
    expect(validator, isNull);
  });

  test('Phone validation should fail for invalid format', () {
    final validator = _validatePhone('12345678');
    expect(validator, isNotNull);
  });

  test('Password confirmation should match', () {
    final validator = _validateConfirmPassword('password123', 'password123');
    expect(validator, isNull);
  });
}
```

---

## 11. Checklist trước khi Release

- [ ] Tất cả validations hoạt động đúng
- [ ] Database queries thành công
- [ ] Error handling bắt hết exceptions
- [ ] UI responsive trên tất cả screen sizes
- [ ] Performance chấp nhận được (< 2s per action)
- [ ] Không có memory leaks
- [ ] Text tiếng Việt hiển thị đúng
- [ ] Tested on actual devices (không chỉ emulator)
- [ ] Analytics integrated (nếu cần)
- [ ] Crash reporting setup (nếu cần)

---

## 12. Các links hữu ích

- [Flutter Riverpod Documentation](https://riverpod.dev)
- [Flutter Form Validation](https://flutter.dev/docs/cookbook/forms/validation)
- [SQLite in Flutter](https://flutter.dev/docs/cookbook/persistence/sqlite)
- [RegExp in Dart](https://api.dart.dev/stable/latest/dart-core/RegExp-class.html)

