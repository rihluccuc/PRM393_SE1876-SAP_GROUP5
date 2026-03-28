# Cập nhật tính năng Register & Edit Profile

## Tóm tắt thay đổi

Đã cập nhật màn hình Đăng ký (RegisterScreen) và Chỉnh sửa hồ sơ (EditProfileScreen) với các tính năng mới:

### 1. RegisterScreen - Màn hình Đăng ký

#### Trường bắt buộc (*):
- **Họ tên** - Tối thiểu 3 ký tự
- **Email** - Định dạng email hợp lệ (xxx@xxx.xx)
- **Số điện thoại** - 10 chữ số, bắt đầu bằng 0 (Định dạng Việt Nam)
- **Mật khẩu** - Tối thiểu 6 ký tự
- **Xác nhận mật khẩu** - Phải trùng khớp với mật khẩu

#### Trường tùy chọn:
- **Thành phố** - Tối thiểu 2 ký tự (nếu nhập)
- **Quận/Huyện** - Tối thiểu 2 ký tự (nếu nhập)

#### Validations:
- Tất cả trường bắt buộc phải được điền
- Email phải có định dạng hợp lệ
- Số điện thoại phải đúng định dạng Việt Nam
- Mật khẩu và xác nhận mật khẩu phải khớp
- Hiển thị thông báo lỗi chi tiết cho người dùng

### 2. EditProfileScreen - Màn hình Chỉnh sửa hồ sơ

#### Phần 1: Thông tin cá nhân
Cho phép cập nhật:
- **Họ tên** - Tối thiểu 3 ký tự (*)
- **Số điện thoại** - 10 chữ số, bắt đầu bằng 0 (*)
- **Thành phố** - Tùy chọn
- **Quận/Huyện** - Tùy chọn

Các trường không thể sửa:
- **Email** - Hiển thị và khóa (read-only)

Nút hành động:
- **Lưu thay đổi** - Cập nhật thông tin cá nhân

#### Phần 2: Đổi mật khẩu
Phần này có thể mở rộng/thu gọn để tiện ích hơn.

Cho phép nhập:
- **Mật khẩu hiện tại** - Bắt buộc (*)
- **Mật khẩu mới** - Tối thiểu 6 ký tự (*)
- **Xác nhận mật khẩu mới** - Phải trùng khớp (*)

Nút hành động:
- **Đổi mật khẩu** - Thay đổi mật khẩu sau khi xác thực

### 3. AuthService - Cập nhật dịch vụ xác thực

#### Phương thức mới:
```dart
// Đăng ký với thêm phone, city, district
Future<User> register({
  required String name,
  required String email,
  required String password,
  required String phone,
  String? city,
  String? district,
}) async { ... }

// Đổi mật khẩu
Future<void> changePassword(
  int userId,
  String oldPassword,
  String newPassword,
) async { ... }
```

### 4. AuthViewModel - Cập nhật view model

#### Phương thức cập nhật:
```dart
// Đăng ký với parameters mới
Future<bool> register(
  String name,
  String email,
  String password,
  String phone, {
  String? city,
  String? district,
}) async { ... }

// Đổi mật khẩu
Future<bool> changePassword(
  String oldPassword,
  String newPassword,
) async { ... }
```

## Hướng dẫn sử dụng

### Đăng ký tài khoản mới:
1. Nhập đầy đủ thông tin bắt buộc (Họ tên, Email, Số điện thoại, Mật khẩu)
2. Tùy chọn điền Thành phố và Quận/Huyện
3. Bấm nút "Đăng ký"
4. Hệ thống sẽ xác thực và đưa bạn về màn hình đăng nhập

### Chỉnh sửa hồ sơ:
1. Truy cập màn hình "Chỉnh sửa hồ sơ"
2. Cập nhật thông tin cá nhân (Họ tên, Số điện thoại, Thành phố, Quận/Huyện)
3. Bấm "Lưu thay đổi"
4. (Tùy chọn) Kéo xuống để mở phần "Đổi mật khẩu"
5. Nhập mật khẩu hiện tại, mật khẩu mới, và xác nhận
6. Bấm "Đổi mật khẩu"

## Các file được sửa

1. `lib/services/auth_service.dart` - Thêm params và changePassword method
2. `lib/viewmodels/auth_viewmodel.dart` - Cập nhật register signature và thêm changePassword
3. `lib/views/auth/register_screen.dart` - Cập nhật UI và validations
4. `lib/views/auth/edit_profile_screen.dart` - Tạo mới với đầy đủ tính năng

## Validations chi tiết

### Email Validation:
- Kiểm tra định dạng: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`

### Phone Validation (Việt Nam):
- Kiểm tra định dạng: `^0\d{9}$` (10 chữ số, bắt đầu bằng 0)

### Password Validation:
- Tối thiểu 6 ký tự
- Mật khẩu xác nhận phải trùng khớp

### Name Validation:
- Không để trống
- Tối thiểu 3 ký tự

### Address Validation:
- Tùy chọn nhập
- Nếu nhập phải tối thiểu 2 ký tự

## Notes

- Tất cả các validations được thực hiện cả ở client-side
- Trong môi trường production, cần thêm server-side validation
- Các thông báo lỗi hiển thị rõ ràng và thân thiện với người dùng
- UI được thiết kế responsively với Material Design

