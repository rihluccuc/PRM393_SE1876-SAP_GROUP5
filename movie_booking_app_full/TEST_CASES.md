# Dữ liệu Test cho Register & Edit Profile

## Test Cases cho RegisterScreen

### Test Case 1: Đăng ký thành công
**Input:**
- Họ tên: "Nguyễn Văn A"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "0912345678"
- Thành phố: "Hà Nội"
- Quận/Huyện: "Quận 1"
- Mật khẩu: "password123"
- Xác nhận mật khẩu: "password123"

**Expected Result:**
- Đăng ký thành công
- Được chuyển về màn hình đăng nhập
- Hiển thị thông báo "Đăng ký thành công! Vui lòng đăng nhập."

---

### Test Case 2: Email không hợp lệ
**Input:**
- Họ tên: "Nguyễn Văn A"
- Email: "invalid-email"
- Số điện thoại: "0912345678"
- Mật khẩu: "password123"
- Xác nhận mật khẩu: "password123"

**Expected Result:**
- Hiển thị lỗi "Email không hợp lệ"
- Không thể submit form

---

### Test Case 3: Số điện thoại không hợp lệ
**Input:**
- Họ tên: "Nguyễn Văn A"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "123456789" (9 chữ số)
- Mật khẩu: "password123"
- Xác nhận mật khẩu: "password123"

**Expected Result:**
- Hiển thị lỗi "Số điện thoại phải là 10 chữ số, bắt đầu bằng 0"
- Không thể submit form

---

### Test Case 4: Mật khẩu xác nhận không khớp
**Input:**
- Họ tên: "Nguyễn Văn A"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "0912345678"
- Mật khẩu: "password123"
- Xác nhận mật khẩu: "password456"

**Expected Result:**
- Hiển thị lỗi "Mật khẩu xác nhận không khớp"
- Không thể submit form

---

### Test Case 5: Mật khẩu quá ngắn
**Input:**
- Họ tên: "Nguyễn Văn A"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "0912345678"
- Mật khẩu: "123"
- Xác nhận mật khẩu: "123"

**Expected Result:**
- Hiển thị lỗi "Mật khẩu phải có ít nhất 6 ký tự"
- Không thể submit form

---

### Test Case 6: Tên quá ngắn
**Input:**
- Họ tên: "AB"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "0912345678"
- Mật khẩu: "password123"
- Xác nhận mật khẩu: "password123"

**Expected Result:**
- Hiển thị lỗi "Họ tên phải có ít nhất 3 ký tự"
- Không thể submit form

---

## Test Cases cho EditProfileScreen

### Test Case 1: Cập nhật thông tin thành công
**Người dùng đã đăng nhập với:**
- Họ tên: "Nguyễn Văn A"
- Email: "nguyenvana@gmail.com"
- Số điện thoại: "0912345678"

**Thay đổi:**
- Họ tên: "Nguyễn Văn B"
- Số điện thoại: "0987654321"
- Thành phố: "TP. Hồ Chí Minh"
- Quận/Huyện: "Quận 7"

**Expected Result:**
- Cập nhật thành công
- Hiển thị thông báo "Cập nhật thông tin thành công!"
- Dữ liệu được lưu trong database

---

### Test Case 2: Đổi mật khẩu thành công
**Input:**
- Mật khẩu hiện tại: "password123"
- Mật khẩu mới: "newpassword456"
- Xác nhận mật khẩu mới: "newpassword456"

**Expected Result:**
- Đổi mật khẩu thành công
- Hiển thị thông báo "Đổi mật khẩu thành công!"
- Các trường mật khẩu được xóa
- Phần đổi mật khẩu được thu gọn

---

### Test Case 3: Mật khẩu hiện tại sai
**Input:**
- Mật khẩu hiện tại: "wrongpassword"
- Mật khẩu mới: "newpassword456"
- Xác nhận mật khẩu mới: "newpassword456"

**Expected Result:**
- Hiển thị lỗi "Mật khẩu hiện tại không đúng"
- Không thể đổi mật khẩu

---

### Test Case 4: Mật khẩu mới xác nhận không khớp
**Input:**
- Mật khẩu hiện tại: "password123"
- Mật khẩu mới: "newpassword456"
- Xác nhận mật khẩu mới: "wrongconfirm"

**Expected Result:**
- Hiển thị lỗi "Mật khẩu xác nhận không khớp"
- Không thể submit form

---

### Test Case 5: Số điện thoại không hợp lệ
**Input:**
- Số điện thoại: "12345678" (8 chữ số)

**Expected Result:**
- Hiển thị lỗi "Số điện thoại phải là 10 chữ số, bắt đầu bằng 0"
- Không thể submit form

---

## Dữ liệu Sample cho Database

Nếu cần test nhanh, có thể thêm user này vào database:

```sql
INSERT INTO users (name, email, password, phone, city, district, role) 
VALUES (
  'Test User',
  'testuser@example.com',
  'password123',
  '0912345678',
  'Hà Nội',
  'Quận 1',
  'user'
);
```

---

## Valid Phone Numbers (Vietnam)

Các định dạng số điện thoại hợp lệ:
- 0901234567
- 0912345678
- 0933456789
- 0944567890
- 0955678901
- 0966789012
- 0977890123
- 0988901234
- 0999012345

---

## Valid Email Formats

Các định dạng email hợp lệ:
- user@example.com
- john.doe@company.co.uk
- info+support@domain.org
- test_email@sub.domain.com

Các định dạng email **không** hợp lệ:
- plainaddress
- @missinglocal.com
- user.name@.com
- user..name@domain.com

