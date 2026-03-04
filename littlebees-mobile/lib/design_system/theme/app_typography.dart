import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.2,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.3,
      color: AppColors.textSecondary,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.5,
      color: AppColors.textOnPrimary,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
  );
}
