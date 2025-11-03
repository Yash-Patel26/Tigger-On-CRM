import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = Theme.of(context).scaffoldBackgroundColor;
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        // Base branded diagonal gradient
        gradient: LinearGradient(
          begin: const Alignment(-0.9, -1.0),
          end: const Alignment(1.0, 0.9),
          colors: <Color>[
            primary.withOpacity(isDark ? 0.10 : 0.12),
            surface,
            secondary.withOpacity(isDark ? 0.08 : 0.10),
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          // Subtle center glow to draw focus to logo/forms
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.2),
            radius: 0.9,
            colors: <Color>[
              primary.withOpacity(isDark ? 0.10 : 0.08),
              Colors.transparent,
            ],
            stops: const <double>[0.0, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
