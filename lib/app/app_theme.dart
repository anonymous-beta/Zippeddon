
import 'package:flutter/material.dart';

class AppTheme {
  static const Color background =
      Color(0xFF0B0F12);

  static const Color surface =
      Color(0xFF151C22);

  static const Color surfaceLight =
      Color(0xFF202A31);

  static const Color magma =
      Color(0xFFFF652F);

  static const Color toxic =
      Color(0xFFB6F34A);

  static const Color muted =
      Color(0xFF89949B);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: magma,
        secondary: toxic,
        surface: surface,
        error: Colors.redAccent,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: magma,
        thumbColor: toxic,
        inactiveTrackColor: surfaceLight,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: magma,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
