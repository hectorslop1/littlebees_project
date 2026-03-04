import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: KsColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KsColors.primary,
        primary: KsColors.primary,
        secondary: KsColors.secondary,
        surface: KsColors.card,
        error: KsColors.error,
        brightness: Brightness.light,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: KsColors.foreground,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: KsColors.foreground,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: KsColors.foreground,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: KsColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: KsColors.foreground,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: KsColors.muted,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: KsColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KsColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KsColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KsColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KsColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KsColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: KsColors.primary,
        unselectedItemColor: KsColors.muted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: KsColors.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KsColors.card,
        foregroundColor: KsColors.foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: KsColors.foreground,
        ),
      ),
    );
  }
}
