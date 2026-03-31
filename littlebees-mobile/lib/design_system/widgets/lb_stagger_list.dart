import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps a child widget with a staggered fade+slide entrance animation.
/// Use [index] to calculate the delay offset for each item in a list.
class LBStaggerItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration staggerDelay;
  final Duration duration;

  const LBStaggerItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = Duration.zero,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    // Cap the delay so lists with many items don't wait too long
    final cappedIndex = index.clamp(0, 8);
    final delay = baseDelay + staggerDelay * cappedIndex;

    return child
        .animate()
        .fadeIn(duration: duration, delay: delay)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: duration,
          delay: delay,
          curve: Curves.easeOutCubic,
        );
  }
}
