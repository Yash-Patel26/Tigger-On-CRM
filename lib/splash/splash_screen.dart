import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/splash_background.dart';
import 'widgets/animated_glowing_logo.dart';
import '../utils/page_transitions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../screens/home_screen.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final supabase.SupabaseClient client = supabase.Supabase.instance.client;
    final bool hasSession = client.auth.currentSession != null;
    final Widget target = hasSession
        ? const HomeScreen()
        : widget.nextPageBuilder(context);
    Navigator.of(context).pushReplacement(
      SmoothPageTransitions.fadeTransition<void>(child: target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedGlowingLogo(
                child: Image.asset(
                  'assets/favicon.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TiggerOn',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
