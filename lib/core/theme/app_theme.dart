import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // Background will be driven by gradient wrappers
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      // Using Montserrat for clean, premium body text, and Cinzel for elegant luxury headings
      textTheme: GoogleFonts.montserratTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 1.1),
        bodyLarge: GoogleFonts.montserrat(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
