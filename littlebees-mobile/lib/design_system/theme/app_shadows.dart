import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  // Soft elevation system — Premium colored shadows
  static final shadowSm = BoxShadow(
    color: AppColors.primary.withAlpha(12), // ~5% opacity of primary
    blurRadius: 8,
    offset: const Offset(0, 3),
  );

  static final shadowMd = BoxShadow(
    color: AppColors.primary.withAlpha(20), // ~8% opacity
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  static const shadowLg = BoxShadow(
    color: Color(0x12000000),
    blurRadius: 18,
    offset: Offset(0, 6),
  );

  // Special: Warm glow for primary elements
  static const shadowGlow = BoxShadow(
    color: Color(0x20D4A853), // honey gold glow
    blurRadius: 16,
    offset: Offset(0, 3),
  );
}
