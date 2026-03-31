import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

enum LBToastType { success, error, warning, info }

/// Shows a premium styled overlay toast with haptic feedback.
void showLBToast(
  BuildContext context, {
  required String message,
  LBToastType type = LBToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  // Haptic feedback based on type
  switch (type) {
    case LBToastType.success:
      HapticFeedback.mediumImpact();
      break;
    case LBToastType.error:
      HapticFeedback.heavyImpact();
      break;
    case LBToastType.warning:
      HapticFeedback.lightImpact();
      break;
    case LBToastType.info:
      HapticFeedback.selectionClick();
      break;
  }

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _LBToastWidget(
      message: message,
      type: type,
      onDismiss: () => entry.remove(),
      duration: duration,
    ),
  );

  overlay.insert(entry);
}

class _LBToastWidget extends StatefulWidget {
  final String message;
  final LBToastType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _LBToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_LBToastWidget> createState() => _LBToastWidgetState();
}

class _LBToastWidgetState extends State<_LBToastWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (widget.type) {
      case LBToastType.success:
        bgColor = isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9);
        iconColor = AppColors.success;
        icon = LucideIcons.checkCircle2;
        break;
      case LBToastType.error:
        bgColor = isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFEBEE);
        iconColor = AppColors.error;
        icon = LucideIcons.alertCircle;
        break;
      case LBToastType.warning:
        bgColor = isDark ? const Color(0xFF3A2E1A) : const Color(0xFFFFF8E1);
        iconColor = AppColors.warning;
        icon = LucideIcons.alertTriangle;
        break;
      case LBToastType.info:
        bgColor = isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE3F2FD);
        iconColor = AppColors.info;
        icon = LucideIcons.info;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragEnd: (_) => widget.onDismiss(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withAlpha(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: isDark ? Colors.white54 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: -1, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }
}
