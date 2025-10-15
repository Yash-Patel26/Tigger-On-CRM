import 'package:flutter/material.dart';

class SmoothPageTransitions {
  static const Duration _transitionDuration = Duration(milliseconds: 400);
  static const Curve _transitionCurve = Curves.easeInOutCubic;

  static PageRouteBuilder<T> slideFromRight<T>({
    required Widget child,
    Duration duration = _transitionDuration,
    Curve curve = _transitionCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const Offset begin = Offset(1.0, 0.0);
        const Offset end = Offset.zero;
        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static PageRouteBuilder<T> slideFromBottom<T>({
    required Widget child,
    Duration duration = _transitionDuration,
    Curve curve = _transitionCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const Offset begin = Offset(0.0, 1.0);
        const Offset end = Offset.zero;
        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget child,
    Duration duration = _transitionDuration,
    Curve curve = _transitionCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget child,
    Duration duration = _transitionDuration,
    Curve curve = _transitionCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final Animation<double> fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}
