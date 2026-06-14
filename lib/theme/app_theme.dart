import 'package:flutter/material.dart';

/// StitchHub App Theme
/// Comprehensive theme configuration following the design system
class AppTheme {
  // Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenLighter = Color(0xFF66BB6A);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenDarkest = Color(0xFF0D3E11);

  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);

  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  static const Color black = Color(0xFF000000);

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Spacing Scale
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 999.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Breakpoints
  static const double mobileBreakpoint = 0;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  // Shadows
  static List<BoxShadow> get shadow1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadow2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadow3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadow4 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: primaryGreenLight,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: gray900,
        onError: white,
      ),
      scaffoldBackgroundColor: gray50,
      fontFamily: 'Roboto',
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
    );
  }

  // Text Theme
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.2,
        color: gray900,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.3,
        color: gray900,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: gray900,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: gray900,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: gray900,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: gray900,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.15,
        height: 1.5,
        color: gray600,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        height: 1.5,
        color: gray600,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        height: 1.4,
        color: gray500,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: white,
      ),
    );
  }

  // AppBar Theme
  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: primaryGreen,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: white,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: white),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 2,
        shadowColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: gray200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(
        color: gray700,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: gray500,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Card Theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.only(bottom: spacing16),
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    );
  }

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: gray500,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  // Responsive Utilities
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(spacing32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(spacing24);
    }
    return const EdgeInsets.all(spacing16);
  }

  static int responsiveColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}


