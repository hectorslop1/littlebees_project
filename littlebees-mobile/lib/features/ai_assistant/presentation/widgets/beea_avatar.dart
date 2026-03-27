import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';

class BeeaAvatar extends StatelessWidget {
  const BeeaAvatar({
    super.key,
    this.size = 40,
    this.outerColor = Colors.transparent,
    this.padding = const EdgeInsets.all(2),
    this.showShadow = true,
  });

  final double size;
  final Color outerColor;
  final EdgeInsets padding;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: outerColor,
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: size * 0.16,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/Beea.gif',
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
