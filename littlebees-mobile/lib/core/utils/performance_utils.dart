import 'package:flutter/material.dart';

class PerformanceUtils {
  /// Wraps a widget with RepaintBoundary to optimize rendering
  static Widget withRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Debounces a function call
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Future.delayed(delay, callback);
  }

  /// Throttles a function call
  static DateTime? _lastCall;
  static void throttle(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) > duration) {
      _lastCall = now;
      callback();
    }
  }
}

/// Mixin to add performance optimizations to StatefulWidgets
mixin PerformanceOptimizations<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
