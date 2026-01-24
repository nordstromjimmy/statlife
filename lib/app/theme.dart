import 'package:flutter/material.dart';

class AppTheme {
  // Background Colors (keeping dark slate for contrast)
  static const _slate950 = Color(0xFF020617); // Main background
  static const _slate900 = Color(0xFF0f172a); // Card backgrounds
  static const _slate800 = Color(0xFF1e293b); // Borders, elevated surfaces

  // Text Colors
  static const _slate200 = Color(0xFFe2e8f0); // Secondary headings
  static const _slate400 = Color(0xFF94a3b8); // Body text
  static const _slate500 = Color(0xFF64748b); // Muted text

  // Brand Colors from Logo (blue/cyan focused)
  static const _brandOrange = Color(
    0xFFFF6B35,
  ); // "evo" orange - for special accents
  static const _brandPurple = Color(0xFFAB47BC); // "v" purple - secondary
  static const _brandBlue = Color(0xFF42A5F5); // "em" blue - main accent
  static const _brandCyan = Color(0xFF26C6DA); // cyan - primary accent

  // Lighter variants for containers
  static const _orangeLight = Color(0xFFFF8A65);
  static const _purpleLight = Color(0xFFCE93D8);
  static const _blueLight = Color(0xFF64B5F6);
  static const _cyanLight = Color(0xFF4DD0E1);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _brandCyan, // Main accent - cyan
        secondary: _brandBlue, // Secondary accent - blue
        tertiary: _brandOrange, // Tertiary accent - purple
        onTertiary: _brandOrange,
        surface: _slate900,
        primaryContainer: _brandCyan.withValues(alpha: 0.3),
        secondaryContainer: _brandBlue.withValues(alpha: 0.3),
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
          borderSide: const BorderSide(color: _brandCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: _slate400),
        hintStyle: const TextStyle(color: _slate500),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _brandOrange,
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
          foregroundColor: _brandCyan,
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
          foregroundColor: _brandCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: _brandCyan),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brandOrange,
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
        indicatorColor: _brandCyan.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: _brandCyan, fontSize: 12);
          }
          return const TextStyle(color: _slate500, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _brandCyan);
          }
          return const IconThemeData(color: _slate500);
        }),
      ),

      // Checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _brandCyan;
          }
          return _slate800;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _brandCyan,
      ),
    );
  }

  // Custom gradient colors for special UI elements
  static const List<Color> xpGradient = [_brandCyan, _brandBlue];
  static const List<Color> levelGradient = [_brandBlue, _brandPurple];
  static const List<Color> goalGradient = [_brandPurple, _brandBlue];
  static const List<Color> achievementGradient = [_brandOrange, _cyanLight];
  static const List<Color> ctaGradient = [_brandBlue, _brandCyan];

  // Full brand gradient (logo-inspired, blue focused)
  static const List<Color> brandGradient = [
    _brandOrange, // warm start
    _brandPurple, // middle
    _brandBlue, // cool
    _brandCyan, // coolest
  ];

  // Semantic colors
  static const success = Color(0xFF4ade80);
  static const error = Color(0xFFf87171);
  static const warning = Color(0xFFfbbf24);

  // Direct color access
  static const orange = _brandOrange;
  static const purple = _brandPurple;
  static const blue = _brandBlue;
  static const cyan = _brandCyan;
}
