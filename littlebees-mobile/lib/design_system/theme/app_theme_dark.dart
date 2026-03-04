import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radii.dart';

class AppThemeDark {
  static ThemeData get theme {
    final baseTheme = ThemeData.dark();

    return baseTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: const Color(0xFF1C1C1E),
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.dark().textTheme,
          ).apply(
            bodyColor: AppColors.textOnPrimary,
            displayColor: AppColors.textOnPrimary,
          ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusXl),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2E),
        thickness: 1,
      ),
    );
  }
}
