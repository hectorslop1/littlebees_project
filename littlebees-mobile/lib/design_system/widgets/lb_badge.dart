import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class LBBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;
  final bool showZero;

  const LBBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 18,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return const SizedBox.shrink();
    }

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? 5 : 0,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            color: textColor ?? AppColors.textOnPrimary,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 200.ms);
  }
}

class LBBadgeDot extends StatelessWidget {
  final Color? color;
  final double size;

  const LBBadgeDot({
    super.key,
    this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.2, 1.2),
          duration: 1000.ms,
        );
  }
}
