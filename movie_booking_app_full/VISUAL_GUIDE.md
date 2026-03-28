# 📱 UI Flow & Visual Guide

## RegisterScreen Flow

```
┌─────────────────────────────────────┐
│         REGISTER SCREEN              │
├─────────────────────────────────────┤
│ ↑                                   │
│ Single Child Scroll View            │
│ ↓                                   │
│  ┌───────────────────────────────┐  │
│  │  Họ tên                     │  │ *required
│  │  [                        ] │  │ min 3 chars
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Email                      │  │ *required
│  │  [                        ] │  │ valid format
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Số điện thoại              │  │ *required
│  │  [0xxxxxxxxx              ] │  │ Vietnam format
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Thành phố                  │  │ optional
│  │  [                        ] │  │ min 2 if filled
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Quận/Huyện                 │  │ optional
│  │  [                        ] │  │ min 2 if filled
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Mật khẩu                   │  │ *required
│  │  [•••••••••••••••••••••••] │  │ min 6 chars
│  └───────────────────────────────┘  │
│  SizedBox(16)                       │
│  ┌───────────────────────────────┐  │
│  │  Xác nhận mật khẩu          │  │ *required
│  │  [•••••••••••••••••••••••] │  │ must match
│  └───────────────────────────────┘  │
│  SizedBox(24)                       │
│  [ERROR MESSAGE IF ANY]             │
│  ┌─────────────────────────────────┐│
│  │  📝 Đăng ký                  │  │
│  │  (or ⏳ CircularProgress)    │  │
│  └─────────────────────────────────┘│
│  SizedBox(16)                       │
│  ┌─────────────────────────────────┐│
│  │  Đã có tài khoản?              │  │
│  │          🔗 Đăng nhập ngay     │  │
│  └─────────────────────────────────┘│
│  SizedBox(24)                       │
│  (*) Là các trường bắt buộc        │
│                                     │
└─────────────────────────────────────┘
```

### Validation States:

**Empty Field:**
```
┌─────────────────────────────┐
│ Email                       │
│ [                         ] │
│ ❌ Vui lòng nhập email     │
└─────────────────────────────┘
```

**Invalid Format:**
```
┌─────────────────────────────┐
│ Email                       │
│ [invalid-email            ] │
│ ❌ Email không hợp lệ     │
└─────────────────────────────┘
```

**Valid:**
```
┌─────────────────────────────┐
│ Email                       │
│ [user@example.com         ] │
│ ✅                          │
└─────────────────────────────┘
```

---

## EditProfileScreen Flow

```
┌─────────────────────────────────────┐
│      EDIT PROFILE SCREEN             │
├─────────────────────────────────────┤
│ ↑                                   │
│ SingleChildScrollView               │
│ ↓                                   │
│  ┌───────────────────────────────┐  │
│  │ 📋 THÔNG TIN CÁ NHÂN          │  │
│  ├───────────────────────────────┤  │
│  │                               │  │
│  │ Email (read-only)           │  │
│  │ [user@example.com          ] │  │
│  │ 🔒 Disabled                 │  │
│  │                               │  │
│  │ Họ tên *                    │  │
│  │ [Nguyễn Văn A             ] │  │
│  │                               │  │
│  │ Số điện thoại *            │  │
│  │ [0912345678                ] │  │
│  │                               │  │
│  │ Thành phố                   │  │
│  │ [Hà Nội                    ] │  │
│  │                               │  │
│  │ Quận/Huyện                 │  │
│  │ [Quận 1                    ] │  │
│  │                               │  │
│  │ ┌──────────────────────────┐ │  │
│  │ │ 💾 Lưu thay đổi      │ │  │
│  │ └──────────────────────────┘ │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│  SizedBox(24)                       │
│  ┌───────────────────────────────┐  │
│  │ 🔐 ĐỔI MẬT KHẨU             │  │
│  │ [>] Expand Button    [v] ... │  │
│  │                               │  │
│  │ ┌─ EXPANDED ─────────────────┐│  │
│  │ │                           ││  │
│  │ │ Mật khẩu hiện tại *     ││  │
│  │ │ [•••••••••••••••••   ] ││  │
│  │ │                           ││  │
│  │ │ Mật khẩu mới *         ││  │
│  │ │ [•••••••••••••••••   ] ││  │
│  │ │                           ││  │
│  │ │ Xác nhận mật khẩu mới * ││  │
│  │ │ [•••••••••••••••••   ] ││  │
│  │ │                           ││  │
│  │ │ ┌────────────────────────┐││  │
│  │ │ │ ✅ Đổi mật khẩu   │││  │
│  │ │ └────────────────────────┘││  │
│  │ │                           ││  │
│  │ └───────────────────────────┘│  │
│  │                               │  │
│  └───────────────────────────────┘  │
│  SizedBox(32)                       │
│                                     │
└─────────────────────────────────────┘
```

### Profile Update Success:

```
┌─────────────────────────────┐
│ ✅ Cập nhật thành công!    │
│                             │
│ (Green SnackBar at bottom)  │
└─────────────────────────────┘
```

### Password Change Section (Collapsed):

```
┌────────────────────────────────────┐
│ 🔐 ĐỔI MẬT KHẨU                   │
│ [>] Expand                    [v]  │
└────────────────────────────────────┘
```

### Password Change Section (Expanded):

```
┌────────────────────────────────────┐
│ 🔐 ĐỔI MẬT KHẨU                   │
│ [v] Collapse                  [^]  │
├────────────────────────────────────┤
│                                    │
│ Mật khẩu hiện tại *              │
│ [••••••••••••••••••••••••••••••] │
│                                    │
│ Mật khẩu mới * (min 6 chars)     │
│ [••••••••••••••••••••••••••••••] │
│                                    │
│ Xác nhận mật khẩu mới *          │
│ [••••••••••••••••••••••••••••••] │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ ✅ Đổi mật khẩu            │ │
│ └────────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
```

---

## Validation Flow Diagram

```
USER INPUT
    ↓
[TextFormField with validator]
    ↓
    ├─→ Check if empty
    │   ├─→ Show "Vui lòng nhập..."
    │   └─→ Prevent submit
    │
    ├─→ Check length
    │   ├─→ Show "Phải có ít nhất X ký tự"
    │   └─→ Prevent submit
    │
    ├─→ Check format (email/phone)
    │   ├─→ Show "Định dạng không hợp lệ"
    │   └─→ Prevent submit
    │
    └─→ Check match (password confirm)
        ├─→ Show "Không khớp"
        └─→ Prevent submit

IF ALL VALID
    ↓
Form Submit ✅
    ↓
[Call API/Service]
    ↓
    ├─→ Success: Show SnackBar + Navigate
    └─→ Error: Show error message + Retry
```

---

## Error States

### Email Validation States:

```
State 1: Empty
┌─────────────────────────┐
│ Email *                 │
│ [                     ] │
│ ❌ Vui lòng nhập email │
└─────────────────────────┘

State 2: Invalid Format
┌─────────────────────────┐
│ Email *                 │
│ [invalid.email        ] │
│ ❌ Email không hợp lệ │
└─────────────────────────┘

State 3: Valid
┌─────────────────────────┐
│ Email *                 │
│ [user@example.com     ] │
│ ✅                      │
└─────────────────────────┘
```

### Phone Validation States:

```
State 1: Empty
┌──────────────────────────────┐
│ Số điện thoại *              │
│ [                          ] │
│ ❌ Vui lòng nhập số ĐT     │
└──────────────────────────────┘

State 2: Invalid Length
┌──────────────────────────────┐
│ Số điện thoại *              │
│ [123456                    ] │
│ ❌ Phải là 10 chữ số,       │
│    bắt đầu bằng 0           │
└──────────────────────────────┘

State 3: Wrong Start
┌──────────────────────────────┐
│ Số điện thoại *              │
│ [9123456789                ] │
│ ❌ Phải là 10 chữ số,       │
│    bắt đầu bằng 0           │
└──────────────────────────────┘

State 4: Valid
┌──────────────────────────────┐
│ Số điện thoại *              │
│ [0912345678                ] │
│ ✅                           │
└──────────────────────────────┘
```

---

## Loading States

### Register Button Loading:

```
┌────────────────────────────────┐
│                                │
│  ⏳ [Loading Spinner]         │
│  (Button disabled during load) │
│                                │
└────────────────────────────────┘
```

### After Success:

```
┌────────────────────────────────┐
│ ✅ Đăng ký thành công!        │
│    Vui lòng đăng nhập.        │
│                                │
│ [Navigate to Login Screen]     │
└────────────────────────────────┘
```

---

## Color Scheme

```
Primary Color:      [Brand Color - from app_theme.dart]
Secondary Color:    [Accent Color]
Success Color:      ✅ Colors.green
Error Color:        ❌ Colors.red.shade800
Disabled Color:     🔒 Colors.grey
Background:         Colors.white / Colors.grey.shade50
Text Color:         Colors.black
Hint Text:          Colors.grey.shade600
Border Color:       Colors.grey.shade300
Focus Border Color: [Primary Color]
```

---

## Icons Used

```
Field               Icon
─────────────────────────────
Họ tên              👤 Icons.person
Email               ✉️  Icons.email
Số điện thoại       📞 Icons.phone
Thành phố           🏙️  Icons.location_city
Quận/Huyện          🗺️  Icons.map
Mật khẩu            🔒 Icons.lock
Xác nhận MK          🔓 Icons.lock_outline
Lưu                 💾 Icons.save
Đổi mật khẩu        ✅ Icons.check
Mở rộng             ▼ Icons.expand_more
Thu gọn             ▲ Icons.expand_less
```

---

## Responsive Behavior

```
Mobile (< 600px)
├─ Full width form (padding 16)
├─ Single column layout
├─ Normal button height (48px)
└─ Bottom SnackBar

Tablet (600-1200px)
├─ Form centered, max width 500px
├─ Single column layout
├─ Normal button height (48px)
└─ Bottom SnackBar

Desktop (> 1200px)
├─ Form centered, max width 600px
├─ Single column layout
├─ Normal button height (48px)
└─ Centered SnackBar
```

---

## Animation States

```
Form Submit Button:
  Normal         ──┐
                   ├─→ Pressed (Scale down)
  Hover Effect  ──┘       ↓
                    Disabled (Gray)
                         ↓
                    Loading (Spinner)
                         ↓
                    Success (Navigate) OR
                    Error (Show message)

Expand/Collapse:
  Collapsed ──→ [Tap] ──→ Expanded
                           (Smooth expand animation)
  Expanded ──→ [Tap] ──→ Collapsed
                         (Smooth collapse animation)

SnackBar:
  Hidden ──→ Slide up ──→ Display 2-3s ──→ Slide down ──→ Hidden
```

---

## Accessibility

```
✅ All fields have proper labels
✅ Icons provide visual aid
✅ Error messages in Vietnamese
✅ Sufficient color contrast
✅ Proper tab order
✅ Loading indicator for async operations
✅ Disabled state for buttons during loading
✅ Keyboard support
✅ Touch targets >= 48x48 dp
```

---

## Data Flow Diagram

```
┌──────────────────┐
│  RegisterScreen  │
└────────┬─────────┘
         │ User Input
         ↓
┌──────────────────────┐
│  Validation Logic    │
├──────────────────────┤
│ - Email format       │
│ - Phone format       │
│ - Password match     │
│ - Length checks      │
└────────┬─────────────┘
         │ Valid Data
         ↓
┌──────────────────────┐
│  AuthViewModel       │
│  register()          │
└────────┬─────────────┘
         │
         ↓
┌──────────────────────┐
│  AuthService         │
│  register()          │
└────────┬─────────────┘
         │
         ↓
┌──────────────────────┐
│  UserRepository      │
│  insertUser()        │
└────────┬─────────────┘
         │
         ↓
┌──────────────────────┐
│  SQLite Database     │
│  users table         │
└──────────────────────┘
```

---

## Update Profile Data Flow

```
┌──────────────────────────┐
│  EditProfileScreen       │
│  Load current user data  │
└────────┬─────────────────┘
         │ Display in form
         ↓
┌──────────────────────────┐
│  User edits information  │
└────────┬─────────────────┘
         │ Click save
         ↓
┌──────────────────────────┐
│  Validation checks       │
│  ✓ Name (3+ chars)      │
│  ✓ Phone (0xxxxxxxxx)   │
│  ✓ City (2+ if filled)  │
│  ✓ District (2+ if...)  │
└────────┬─────────────────┘
         │ Valid
         ↓
┌──────────────────────────┐
│  AuthViewModel           │
│  updateProfile()         │
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  AuthService             │
│  updateProfile()         │
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  UserRepository          │
│  updateUser()            │
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  SQLite Database update  │
└────────┬─────────────────┘
         │
         ↓
┌──────────────────────────┐
│  Update local state      │
│  Show success message    │
└──────────────────────────┘
```

---

## Change Password Flow

```
┌─────────────────────────────┐
│  EditProfileScreen          │
│  Expand Password Section    │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│  User enters:               │
│  - Old password             │
│  - New password             │
│  - Confirm password         │
└────────┬────────────────────┘
         │ Click 'Đổi mật khẩu'
         ↓
┌─────────────────────────────┐
│  Validation:                │
│  ✓ Old PW not empty         │
│  ✓ New PW >= 6 chars        │
│  ✓ Confirm matches new      │
└────────┬────────────────────┘
         │ Valid
         ↓
┌─────────────────────────────┐
│  AuthViewModel              │
│  changePassword()           │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│  AuthService                │
│  changePassword()           │
│  - Verify old PW            │
│  - Update to new PW         │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│  UserRepository             │
│  updateUser()               │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│  Database update            │
│  Clear form fields          │
│  Show success message       │
│  Collapse password section  │
└─────────────────────────────┘
```

---

This visual guide should help you understand the UI structure, flow, and behavior of both screens!

