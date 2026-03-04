import 'package:flutter/material.dart';

class LBPageTransitions {
  static const Duration _defaultDuration = Duration(milliseconds: 300);

  static PageTransitionsBuilder get builder => const CupertinoPageTransitionsBuilder();

  static Route<T> fadeTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = _defaultDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> slideTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = _defaultDuration,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static Route<T> scaleTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = _defaultDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        
        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
