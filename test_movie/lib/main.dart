import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/databaseHelper.dart';
import 'database/localPrefs.dart';
import 'view/pages/movieListPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Khởi tạo DB & SharedPreferences trước khi chạy app ──────────────────
  await Future.wait([
    DatabaseHelper.instance.database, // mở DB, seed mock data nếu cần
    LocalPrefs.instance.init(),       // khởi tạo SharedPreferences
  ]);

  // Thanh trạng thái trong suốt
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
  ));

  runApp(
    // ProviderScope bao ngoài toàn app — bắt buộc với Riverpod
    const ProviderScope(child: MovieBookingApp()),
  );
}

class MovieBookingApp extends StatelessWidget {
  const MovieBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'CGV Movie Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3:       true,
        brightness:         Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor:  const Color(0xFFE50914),
          brightness: Brightness.dark,
          primary:    const Color(0xFFE50914),
          surface:    const Color(0xFF141428),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation:       0,
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Shell
// ─────────────────────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = <Widget>[
    MovieListPage(),
    _PlaceholderPage(icon: Icons.theaters_outlined,      label: 'Rạp chiếu'),
    _PlaceholderPage(icon: Icons.confirmation_number_outlined, label: 'Vé của tôi'),
    _PlaceholderPage(icon: Icons.person_outline,         label: 'Tài khoản'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color:  Color(0xFF141428),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex:   _index,
          onTap:          (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          selectedItemColor:   const Color(0xFFE50914),
          unselectedItemColor: Colors.white38,
          type:      BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.movie_outlined),
                activeIcon: Icon(Icons.movie),
                label: 'Phim'),
            BottomNavigationBarItem(
                icon: Icon(Icons.theaters_outlined),
                activeIcon: Icon(Icons.theaters),
                label: 'Rạp'),
            BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                activeIcon: Icon(Icons.confirmation_number),
                label: 'Vé'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tôi'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white24, size: 56),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Đang phát triển...',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
