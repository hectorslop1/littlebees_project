import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Shows a brief full-screen success animation overlay.
/// Great for post-action confirmation (attendance saved, excuse submitted, etc.)
Future<void> showLBSuccessOverlay(
  BuildContext context, {
  String message = '¡Listo!',
  Duration displayDuration = const Duration(milliseconds: 1400),
}) async {
  HapticFeedback.mediumImpact();

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _SuccessOverlayWidget(
      message: message,
      onComplete: () => entry.remove(),
      displayDuration: displayDuration,
    ),
  );

  overlay.insert(entry);
  await Future.delayed(displayDuration + 400.ms);
}

class _SuccessOverlayWidget extends StatefulWidget {
  final String message;
  final VoidCallback onComplete;
  final Duration displayDuration;

  const _SuccessOverlayWidget({
    required this.message,
    required this.onComplete,
    required this.displayDuration,
  });

  @override
  State<_SuccessOverlayWidget> createState() => _SuccessOverlayWidgetState();
}

class _SuccessOverlayWidgetState extends State<_SuccessOverlayWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.displayDuration, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(100),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withAlpha(40),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  color: AppColors.success,
                  size: 36,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 200.ms),
              const SizedBox(height: 16),
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.3, end: 0, duration: 300.ms),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
