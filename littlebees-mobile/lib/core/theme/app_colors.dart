import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFFFDB913);
  static const Color primaryDark = Color(0xFFE5A711);
  static const Color primaryLight = Color(0xFFFECA3D);

  // Colores secundarios
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF34495E);

  // Colores de estado
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Colores de actividades (para quick register)
  static const Color checkIn = Color(0xFF27AE60);
  static const Color meal = Color(0xFFF39C12);
  static const Color nap = Color(0xFF3498DB);
  static const Color activity = Color(0xFF9B59B6);
  static const Color checkOut = Color(0xFFE74C3C);

  // Colores de fondo
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Colores de texto
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);

  // Colores de borde
  static const Color border = Color(0xFFE1E8ED);
  static const Color borderLight = Color(0xFFF1F3F5);

  // Colores de sombra
  static const Color shadow = Color(0x1A000000);

  // Colores de overlay
  static const Color overlay = Color(0x80000000);

  // Colores de estado de ánimo (mood)
  static const Color moodHappy = Color(0xFF27AE60);
  static const Color moodNeutral = Color(0xFFF39C12);
  static const Color moodSad = Color(0xFFE74C3C);

  // Método helper para obtener color por tipo de actividad
  static Color getActivityColor(String type) {
    switch (type) {
      case 'check_in':
        return checkIn;
      case 'meal':
        return meal;
      case 'nap':
        return nap;
      case 'activity':
        return activity;
      case 'check_out':
        return checkOut;
      default:
        return primary;
    }
  }

  // Método helper para obtener color con alpha
  static Color withOpacityValue(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }
}
