import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const background = Color(0xFFF0F2F5); // Cool pale gray for depth
  static const surface = Color(0xFFFFFFFF); // Pure white cards
  static const surfaceVariant = Color(0xFFF5F3EE); // Subtle warm gray

  // Brand Colors
  static const primary = Color(0xFFD4A853); // Honey gold (muted, elegant)
  static const primaryLight = Color(0xFFF0DFA8); // Light honey
  static const primarySurface = Color(0xFFFBF6E9); // Honey tint for backgrounds

  // Secondary
  static const secondary = Color(0xFF8FAE8B); // Sage green (soft, calming)
  static const secondaryLight = Color(0xFFC5D9C3); // Light sage
  static const secondarySurface = Color(0xFFF0F5EF); // Sage tint

  // Semantic Colors
  static const success = Color(0xFF6BA368); // Soft green
  static const warning = Color(0xFFE8B84B); // Warm amber
  static const error = Color(0xFFD4655E); // Muted coral red
  static const info = Color(0xFF7BA7C4); // Calm blue

  // Text Colors
  static const textPrimary = Color(0xFF2C2C2C); // Deep neutral (not pure black)
  static const textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const textTertiary = Color(0xFFA0A0A0); // Light gray
  static const textOnPrimary = Color(0xFFFFFFFF); // White on primary

  // Border & Divider
  static const border = Color(0xFFE8E6E1); // Warm border
  static const divider = Color(0xFFF0EDE8); // Subtle divider

  /// Theme-aware color resolver — use this in widgets for dark mode support
  static Color of(BuildContext context, Color lightColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return lightColor;

    // Map light colors to their dark equivalents
    if (lightColor == background) return const Color(0xFF121212);
    if (lightColor == surface) return const Color(0xFF1E1E1E);
    if (lightColor == surfaceVariant) return const Color(0xFF2C2C2C);
    if (lightColor == primary) return const Color(0xFFE5C068);
    if (lightColor == primaryLight) return const Color(0xFF4A3F28);
    if (lightColor == primarySurface) return const Color(0xFF2A2518);
    if (lightColor == secondary) return const Color(0xFFA5C5A1);
    if (lightColor == secondaryLight) return const Color(0xFF2A3529);
    if (lightColor == secondarySurface) return const Color(0xFF1E251E);
    if (lightColor == success) return const Color(0xFF81C784);
    if (lightColor == warning) return const Color(0xFFFFD54F);
    if (lightColor == error) return const Color(0xFFEF9A9A);
    if (lightColor == info) return const Color(0xFF90CAF9);
    if (lightColor == textPrimary) return const Color(0xFFE8E8E8);
    if (lightColor == textSecondary) return const Color(0xFFB0B0B0);
    if (lightColor == textTertiary) return const Color(0xFF808080);
    if (lightColor == textOnPrimary) return const Color(0xFF1A1A1A);
    if (lightColor == border) return const Color(0xFF3A3A3A);
    if (lightColor == divider) return const Color(0xFF2A2A2A);
    return lightColor;
  }
}

/// Extension for easy dark-mode-aware colors: context.appColor(AppColors.textPrimary)
extension AppColorsX on BuildContext {
  Color appColor(Color lightColor) => AppColors.of(this, lightColor);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
