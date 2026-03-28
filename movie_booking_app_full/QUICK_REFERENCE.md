# 🚀 Quick Reference Guide

## 📌 Files Modified Summary

### 1. `lib/services/auth_service.dart`
**What Changed:** Added support for phone, city, district in register + new changePassword method

**Key Methods:**
```dart
// Before: register(name, email, password)
// After:
Future<User> register({
  required String name,
  required String email,
  required String password,
  required String phone,          // ← NEW
  String? city,                   // ← NEW
  String? district,               // ← NEW
}) async { ... }

// NEW METHOD:
Future<void> changePassword(
  int userId,
  String oldPassword,
  String newPassword,
) async { ... }
```

### 2. `lib/viewmodels/auth_viewmodel.dart`
**What Changed:** Updated register signature + added changePassword method

**Key Methods:**
```dart
// Before: register(name, email, password)
// After:
Future<bool> register(
  String name,
  String email,
  String password,
  String phone,                   // ← NEW
  {String? city, String? district}
) async { ... }

// NEW METHOD:
Future<bool> changePassword(
  String oldPassword,
  String newPassword,
) async { ... }
```

### 3. `lib/views/auth/register_screen.dart`
**What Changed:** Completely redesigned UI + full validations

**New Features:**
- Phone, City, District input fields
- Email validation regex
- Phone validation regex (Vietnam format: `^0\d{9}$`)
- Better error messages
- Improved UI/UX

### 4. `lib/views/auth/edit_profile_screen.dart`
**What Changed:** Created from scratch with profile editing + password change

**Features:**
- Edit profile info (name, phone, city, district)
- Read-only email display
- Expandable password change section
- Full validations
- Success/error feedback

---

## 🎯 Usage Examples

### RegisterScreen Usage
```dart
// In your app, just navigate to RegisterScreen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const RegisterScreen()),
);

// Or using named routes:
Navigator.pushNamed(context, AppRoutes.register);
```

### EditProfileScreen Usage
```dart
// Navigate to edit profile
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
);

// Or using named routes:
Navigator.pushNamed(context, AppRoutes.editProfile);
```

### Accessing Auth State in Views
```dart
// Get current auth state
final authState = ref.watch(authProvider);
final user = authState.user;

// Register
final success = await ref.read(authProvider.notifier).register(
  'Nguyễn Văn A',
  'nguyenvana@gmail.com',
  'password123',
  '0912345678',
  city: 'Hà Nội',
  district: 'Quận 1',
);

// Change password
final success = await ref.read(authProvider.notifier).changePassword(
  'oldpassword',
  'newpassword',
);

// Update profile
final success = await ref.read(authProvider.notifier).updateProfile(updatedUser);
```

---

## ✅ Validation Rules Cheat Sheet

| Field | Must Have | Format/Rules |
|-------|:-:|---|
| Họ tên | ✅ | 3+ characters |
| Email | ✅ | `name@domain.extension` |
| Số ĐT | ✅ | 10 digits, starts with 0 |
| Thành phố | ❌ | 2+ chars if provided |
| Quận/Huyện | ❌ | 2+ chars if provided |
| Mật khẩu | ✅ | 6+ characters |
| Xác nhận MK | ✅ | Must match password |

---

## 📊 Database Schema

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

**Indexes for Performance:**
```sql
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_phone ON users(phone);
```

---

## 🔍 Testing Commands

```bash
# Run Flutter analyzer
flutter analyze

# Run the app
flutter run

# Run tests (if available)
flutter test

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

---

## 📱 Screen Navigation

```
LoginScreen
    ↓ Tap "Đăng ký"
RegisterScreen ─→ (Submit) ─→ LoginScreen (success)
                              
LoginScreen ─→ (Login) ─→ HomeScreen
                              ↓
                        Tap "Chỉnh sửa hồ sơ"
                              ↓
                        EditProfileScreen
                        ├─→ Update info
                        ├─→ Change password
                        └─→ Back to Profile
```

---

## 🛠️ Common Tasks

### Task 1: Add EditProfileScreen to Routes
```dart
// In app.dart or routes.dart
'/edit-profile': (context) => const EditProfileScreen(),

// Access:
Navigator.pushNamed(context, '/edit-profile');
```

### Task 2: Test Phone Validation
```dart
// Valid:
'0912345678'  ✅
'0987654321'  ✅

// Invalid:
'912345678'   ❌ (doesn't start with 0)
'09123456'    ❌ (9 digits, not 10)
'1234567890'  ❌ (doesn't start with 0)
```

### Task 3: Test Email Validation
```dart
// Valid:
'user@example.com'           ✅
'john.doe@company.co.uk'     ✅
'info+tag@domain.org'        ✅

// Invalid:
'userexample.com'            ❌ (no @)
'user@.com'                  ❌ (no domain)
'user@domain'                ❌ (no extension)
```

### Task 4: Debug User State
```dart
// In any ConsumerWidget
final authState = ref.watch(authProvider);
print('User: ${authState.user?.name}');
print('Email: ${authState.user?.email}');
print('Phone: ${authState.user?.phone}');
print('Loading: ${authState.isLoading}');
print('Error: ${authState.error}');
```

---

## 🐛 Quick Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| "Mật khẩu hiện tại không đúng" | Old password wrong | Check caps lock, try again |
| "Email đã được sử dụng" | Duplicate email | Use different email |
| Phone validation fails | Wrong format | Must be 10 digits, start with 0 |
| "User không tồn tại" | user.id is null | Check user saved to DB |
| Validations don't show | Form not validated | Call `_formKey.currentState!.validate()` |

---

## 📚 File Relationships

```
auth_service.dart ◄─── Called by ───► auth_viewmodel.dart
                                         ▲
                                         │
                                    Used by
                                         │
                                         ▼
register_screen.dart ◄──────────► edit_profile_screen.dart
                                         │
                                         │ Uses
                                         ▼
                                    User model
```

---

## ⚡ Performance Tips

1. **Lazy Load Data**
   ```dart
   // Load only when needed
   late TextEditingController _controller;
   
   @override
   void initState() {
     _controller = TextEditingController(
       text: ref.read(authProvider).user?.name ?? ''
     );
   }
   ```

2. **Cache User Data**
   ```dart
   // Don't call service multiple times
   final user = ref.watch(authProvider).user;
   ```

3. **Use SingleChildScrollView**
   ```dart
   // Prevent overflow on small screens
   SingleChildScrollView(
     child: Form(...),
   )
   ```

---

## 🔐 Security Checklist

- [x] Validate all inputs client-side
- [x] Check email format
- [x] Check phone format
- [x] Verify passwords match
- [x] Min password length
- [ ] Implement password hashing (TODO)
- [ ] Add rate limiting (TODO)
- [ ] Add email verification (TODO)
- [ ] Use HTTPS in production (TODO)

---

## 📋 State Management with Riverpod

```dart
// Watch state (rebuilds when changes)
final authState = ref.watch(authProvider);

// Read state (don't trigger rebuild)
final user = ref.read(authProvider).user;

// Call method
await ref.read(authProvider.notifier).register(...);
await ref.read(authProvider.notifier).changePassword(...);

// Access user
final currentUser = ref.watch(authProvider).user;
print(currentUser?.name);
print(currentUser?.email);
print(currentUser?.phone);
```

---

## 🎨 Styling

```dart
// Standard input field decoration
InputDecoration(
  labelText: 'Label',
  hintText: 'Hint text',
  prefixIcon: Icon(Icons.person),
  border: OutlineInputBorder(),
)

// Error colors
Colors.red.shade800  // Error text
Colors.red.shade100  // Error background

// Success colors
Colors.green        // Success message

// Read-only field
TextFormField(
  initialValue: 'Text',
  readOnly: true,
  enabled: false,
)
```

---

## 📞 Support Resources

- **FEATURE_UPDATE.md** - What was added/changed
- **TEST_CASES.md** - How to test manually
- **IMPLEMENTATION_GUIDE.md** - In-depth guide
- **VISUAL_GUIDE.md** - UI/UX flows
- **COMPLETION_CHECKLIST.md** - What's done
- **SUMMARY.md** - Executive summary

---

## 🎓 Learning Points

### Concepts Used
1. **Riverpod** - State management
2. **Validations** - Form validation with regex
3. **Async/Await** - Asynchronous operations
4. **Material Design** - UI components
5. **SQLite** - Local database
6. **Null Safety** - Dart null safety

### Patterns Applied
1. **MVVM** - Model-View-ViewModel
2. **Repository Pattern** - Data access abstraction
3. **Service Layer** - Business logic
4. **Consumer Pattern** - Riverpod consumption

---

## 🚀 Deployment Checklist

- [ ] Run `flutter analyze` - No warnings
- [ ] Run tests if available
- [ ] Test on physical device
- [ ] Test all validations
- [ ] Test error scenarios
- [ ] Check database operations
- [ ] Test navigation flows
- [ ] Performance test
- [ ] Memory leak check
- [ ] Build APK/IPA successfully

---

## 📈 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 26-03-2026 | Initial release with register & edit profile |

---

## 📝 Notes

- All text is in Vietnamese
- Phone format is for Vietnam only
- Email validation is basic regex (for production, use email verification)
- Password stored as plaintext (use hashing in production)
- Local SQLite database (consider backend API for production)

---

## ❓ FAQ

**Q: Can I change email?**
A: No, email is read-only in EditProfileScreen

**Q: What's the phone format?**
A: Vietnam format: 10 digits starting with 0 (e.g., 0912345678)

**Q: Can I skip optional fields?**
A: Yes, city and district are optional

**Q: Is password hashed?**
A: No, currently plaintext (TODO for production)

**Q: Can I undo changes?**
A: No, changes are permanent. Refresh to see current data.

**Q: Does email verification exist?**
A: No (TODO for production)

**Q: Is there rate limiting?**
A: No (TODO for production)

---

## 🎯 Next Sprint Tasks

- [ ] Implement password hashing
- [ ] Add email verification OTP
- [ ] Add rate limiting on auth attempts
- [ ] Integrate with backend API
- [ ] Add biometric authentication
- [ ] Implement session management
- [ ] Add profile picture upload
- [ ] Add 2FA support

---

**Last Updated:** 26-03-2026
**Status:** ✅ COMPLETE
**Ready for:** Testing & Review

