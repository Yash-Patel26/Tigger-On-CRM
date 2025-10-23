import 'package:flutter/material.dart';

import 'glowing_logo_circle.dart';

class AnimatedGlowingLogo extends StatefulWidget {
  const AnimatedGlowingLogo({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.primaryGlow = Colors.red,
    this.secondaryGlow = Colors.redAccent,
  });

  final Widget child;
  final Duration duration;
  final Color primaryGlow;
  final Color secondaryGlow;

  @override
  State<AnimatedGlowingLogo> createState() => _AnimatedGlowingLogoState();
}

class _AnimatedGlowingLogoState extends State<AnimatedGlowingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _rotation;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ).drive(Tween<double>(begin: 0.9, end: 1.1));
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    ).drive(Tween<double>(begin: 0.7, end: 1.0));
    _rotation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ).drive(Tween<double>(begin: -0.03, end: 0.03));
    _shimmer = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ).drive(Tween<double>(begin: -0.8, end: 1.8));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GlowingLogoCircle(
          primaryGlow: widget.primaryGlow,
          secondaryGlow: widget.secondaryGlow,
          glowStrength: _opacity.value,
          scale: _scale.value,
          rotation: _rotation.value,
          shimmerPosition: _shimmer.value,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
