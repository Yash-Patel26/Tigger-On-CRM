import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/splash_background.dart';
import 'widgets/animated_glowing_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextPageBuilder});

  final WidgetBuilder nextPageBuilder;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_navigateToHomeAfterDelay());
  }

  Future<void> _navigateToHomeAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: widget.nextPageBuilder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SplashBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedGlowingLogo(
                child: SvgPicture.asset(
                  'assets/index.svg',
                  width: 120,
                  height: 120,
                  colorFilter: const ColorFilter.mode(
                    Colors.redAccent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TiggerOn',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// No placeholder needed; next page is injected from main.dart
