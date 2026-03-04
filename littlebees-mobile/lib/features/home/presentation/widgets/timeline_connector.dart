import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';

class TimelineConnector extends StatelessWidget {
  final bool isLast;
  final IconData icon;
  final Color color;

  const TimelineConnector({
    super.key,
    required this.isLast,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(45), // More visible icon background
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40), // More visible line
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
