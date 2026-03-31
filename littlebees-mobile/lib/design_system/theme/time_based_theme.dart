import 'package:flutter/material.dart';

/// Provides subtle time-based color accents for a premium feel.
/// Morning → cool/fresh tones, Afternoon → warm golden, Evening → warm amber.
class TimeBasedTheme {
  TimeBasedTheme._();

  static TimeOfDayPeriod get currentPeriod {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return TimeOfDayPeriod.morning;
    if (hour >= 12 && hour < 18) return TimeOfDayPeriod.afternoon;
    return TimeOfDayPeriod.evening;
  }

  /// Returns a subtle greeting gradient for home screen headers.
  static List<Color> get greetingGradient {
    switch (currentPeriod) {
      case TimeOfDayPeriod.morning:
        return const [Color(0xFFE8F4FD), Color(0xFFF0F7E6)];
      case TimeOfDayPeriod.afternoon:
        return const [Color(0xFFFFF8E1), Color(0xFFFFF3E0)];
      case TimeOfDayPeriod.evening:
        return const [Color(0xFFFCE4EC), Color(0xFFEDE7F6)];
    }
  }

  /// Returns dark mode greeting gradient.
  static List<Color> get greetingGradientDark {
    switch (currentPeriod) {
      case TimeOfDayPeriod.morning:
        return const [Color(0xFF1A2A3A), Color(0xFF1A2E1A)];
      case TimeOfDayPeriod.afternoon:
        return const [Color(0xFF2A2510), Color(0xFF2A2010)];
      case TimeOfDayPeriod.evening:
        return const [Color(0xFF2A1A2A), Color(0xFF1A1A2A)];
    }
  }

  /// Emoji for the greeting period.
  static String get greetingEmoji {
    switch (currentPeriod) {
      case TimeOfDayPeriod.morning:
        return '☀️';
      case TimeOfDayPeriod.afternoon:
        return '🌤️';
      case TimeOfDayPeriod.evening:
        return '🌙';
    }
  }
}

enum TimeOfDayPeriod { morning, afternoon, evening }
