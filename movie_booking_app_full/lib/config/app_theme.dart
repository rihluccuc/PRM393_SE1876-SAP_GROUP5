import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

/// App Theme - Theme chung cho toàn app
class AppTheme {
  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Colors
    primaryColor: const Color(AppConstants.primaryColor),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(AppConstants.primaryColor),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Text
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        color: Colors.black87,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(AppConstants.primaryColor),
          width: 2,
        ),
      ),
    ),

    // Card
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  // ─── Dark Theme ─────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Colors
    primaryColor: const Color(AppConstants.primaryColor),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(AppConstants.primaryColor),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    // Text
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        color: Colors.white70,
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(AppConstants.primaryColor),
          width: 2,
        ),
      ),
    ),

    // Card
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
