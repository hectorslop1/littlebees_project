import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  // Soft elevation system — Premium colored shadows
  static final shadowSm = BoxShadow(
    color: AppColors.primary.withAlpha(12), // ~5% opacity of primary
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static final shadowMd = BoxShadow(
    color: AppColors.primary.withAlpha(20), // ~8% opacity
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static const shadowLg = BoxShadow(
    color: Color(0x12000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Special: Warm glow for primary elements
  static const shadowGlow = BoxShadow(
    color: Color(0x20D4A853), // honey gold glow
    blurRadius: 20,
    offset: Offset(0, 4),
  );
}
