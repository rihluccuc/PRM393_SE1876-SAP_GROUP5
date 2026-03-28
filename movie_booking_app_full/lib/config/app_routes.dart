import 'package:flutter/material.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/profile_screen.dart';
import '../views/auth/edit_profile_screen.dart';
import '../views/auth/favorites_screen.dart';
import '../views/auth/notifications_screen.dart';
import '../views/auth/settings_screen.dart';
import '../views/movie/movie_list_screen.dart';
import '../views/movie/movie_detail_screen.dart';
import '../views/movie/trailer_screen.dart';
import '../views/movie/review_screen.dart';
import '../views/booking/select_cinema_screen.dart';
import '../views/booking/select_time_screen.dart';
import '../views/booking/select_seat_screen.dart';
import '../views/booking/payment_screen.dart';
import '../views/history/booking_history_screen.dart';
import '../views/history/ticket_detail_screen.dart';
import '../views/history/qr_code_screen.dart';
import '../views/history/cancel_ticket_screen.dart';
import '../views/admin/add_movie_screen.dart';
import '../views/admin/add_showtime_screen.dart';
import '../views/admin/manage_cinema_screen.dart';
import '../views/admin/statistics_screen.dart';

/// App Routes - Định nghĩa tất cả routes trong app
class AppRoutes {
  // ─── Auth Routes ────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // ─── Movie Routes ───────────────────────────────────────────────
  static const String movieList = '/movies';
  static const String movieDetail = '/movie-detail';
  static const String trailer = '/trailer';
  static const String review = '/review';

  // ─── Booking Routes ─────────────────────────────────────────────
  static const String selectCinema = '/select-cinema';
  static const String selectTime = '/select-time';
  static const String selectSeat = '/select-seat';
  static const String payment = '/payment';

  // ─── History Routes ─────────────────────────────────────────────
  static const String bookingHistory = '/booking-history';
  static const String ticketDetail = '/ticket-detail';
  static const String qrCode = '/qr-code';
  static const String cancelTicket = '/cancel-ticket';

  // ─── Admin Routes ───────────────────────────────────────────────
  static const String addMovie = '/add-movie';
  static const String addShowtime = '/add-showtime';
  static const String manageCinema = '/manage-cinema';
  static const String statistics = '/statistics';

  // ─── Home Route ─────────────────────────────────────────────────
  static const String home = '/';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      // Auth
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      // Movie
      case movieList:
        return MaterialPageRoute(builder: (_) => const MovieListScreen());
      case movieDetail:
        final movieId = routeSettings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movieId: movieId ?? 0),
        );
      case trailer:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TrailerScreen(
            movieId: args?['movieId'] ?? 0,
            trailerId: args?['trailerId'] ?? '',
          ),
        );
      case review:
        final movieId = routeSettings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(movieId: movieId ?? 0),
        );

      // Booking
      case selectCinema:
        final movieId = routeSettings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => SelectCinemaScreen(movieId: movieId ?? 0),
        );
      case selectTime:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SelectTimeScreen(
            movieId: args?['movieId'] ?? 0,
            cinemaId: args?['cinemaId'] ?? 0,
          ),
        );
      case selectSeat:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SelectSeatScreen(
            movieId: args?['movieId'] ?? 0,
            cinemaId: args?['cinemaId'] ?? 0,
            showtime: args?['showtime'] ?? '',
            format: args?['format'] ?? '2D',
          ),
        );
      case payment:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingData: args?['bookingData'] ?? {},
          ),
        );

      // History
      case bookingHistory:
        return MaterialPageRoute(builder: (_) => const BookingHistoryScreen());
      case ticketDetail:
        final bookingId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TicketDetailScreen(bookingId: bookingId ?? ''),
        );
      case qrCode:
        final bookingId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => QrCodeScreen(bookingId: bookingId ?? ''),
        );
      case cancelTicket:
        final bookingId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CancelTicketScreen(bookingId: bookingId ?? ''),
        );

      // Admin
      case addMovie:
        return MaterialPageRoute(builder: (_) => const AddMovieScreen());
      case addShowtime:
        return MaterialPageRoute(builder: (_) => const AddShowtimeScreen());
      case manageCinema:
        return MaterialPageRoute(builder: (_) => const ManageCinemaScreen());
      case statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());

      // Home - default for authenticated users
      case home:
        return MaterialPageRoute(builder: (_) => const MovieListScreen());

      // Default
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
