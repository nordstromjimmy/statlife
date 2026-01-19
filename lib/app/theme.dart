import 'package:flutter/material.dart';

class AppTheme {
  // Background Colors (matching landing page)
  static const _slate950 = Color(0xFF020617); // Main background
  static const _slate900 = Color(0xFF0f172a); // Card backgrounds
  static const _slate800 = Color(0xFF1e293b); // Borders, elevated surfaces

  // Text Colors
  static const _slate200 = Color(0xFFe2e8f0); // Secondary headings
  static const _slate400 = Color(0xFF94a3b8); // Body text
  static const _slate500 = Color(0xFF64748b); // Muted text

  // Accent Colors (Gradient Trio)
  static const _cyan400 = Color(0xFF22d3ee); // Primary accent (XP, Calendar)
  static const _cyan500 = Color(0xFF06b6d4);
  static const _cyan600 = Color(0xFF0891b2);
  static const _purple400 = Color(0xFFc084fc); // Secondary accent
  static const _purple600 = Color(0xFF9333ea);
  static const _pink400 = Color(0xFFf472b6); // Goal tracking
  static const _yellow400 = Color(0xFFfacc15); // Achievements

  // Orange for buttons (NEW)
  static const _orange500 = Color(0xFFff6532);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _cyan400,
        secondary: _cyan600,
        tertiary: _pink400,
        surface: _slate900,
        primaryContainer: _cyan600,
        surfaceContainerHighest: _slate800,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _slate200,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _slate950,
      cardColor: _slate900,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: _slate950,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards & Containers
      cardTheme: CardThemeData(
        color: _slate900.withValues(alpha: 0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _slate800, width: 1),
        ),
      ),

      // Dividers
      dividerColor: _slate800,

      // Text Theme
      textTheme: base.textTheme
          .apply(bodyColor: _slate400, displayColor: Colors.white)
          .copyWith(
            // Headings
            displayLarge: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),

            // Titles
            titleLarge: const TextStyle(
              color: _slate200,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: const TextStyle(
              color: _slate200,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: const TextStyle(
              color: _slate200,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),

            // Body text
            bodyLarge: const TextStyle(color: _slate400, fontSize: 16),
            bodyMedium: const TextStyle(color: _slate400, fontSize: 14),
            bodySmall: const TextStyle(color: _slate500, fontSize: 12),
          ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _slate900.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _slate800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _slate800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cyan400, width: 2),
        ),
        labelStyle: const TextStyle(color: _slate400),
        hintStyle: const TextStyle(color: _slate500),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _orange500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _slate900,
          foregroundColor: _cyan400,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _slate800),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _cyan400,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: _cyan400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _cyan400,
        foregroundColor: Colors.white,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: _slate900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _slate800),
        ),
      ),

      // Bottom Sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _slate900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _slate950,
        indicatorColor: _cyan400.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _cyan400, fontSize: 12);
          }
          return const TextStyle(color: _slate500, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _cyan400);
          }
          return const IconThemeData(color: _slate500);
        }),
      ),

      // Checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _cyan400;
          }
          return _slate800;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _cyan400),
    );
  }

  // Custom gradient colors for special UI elements
  static const List<Color> xpGradient = [_cyan500, _cyan400];
  static const List<Color> levelGradient = [_cyan400, _purple400];
  static const List<Color> goalGradient = [_pink400, _purple400];
  static const List<Color> achievementGradient = [
    _yellow400,
    Color(0xFFca8a04),
  ];
  static const List<Color> ctaGradient = [_purple600, _cyan600];

  // Semantic colors
  static const success = Color(0xFF4ade80);
  static const error = Color(0xFFf87171);
  static const warning = _yellow400;

  // Direct color access
  static const cyan = _cyan400;
  static const purple = _purple400;
  static const pink = _pink400;
  static const yellow = _yellow400;
}
