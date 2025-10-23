import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/managers/auth_state_manager.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/screens/auth/email_login_screen.dart';
import '../../presentation/screens/dashboard/home_screen.dart';
import '../../core/utils/page_transitions.dart';

/// Wrapper widget that handles authentication state and routing
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when the wrapper is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStateManager>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, child) {
        // Show splash screen while initializing
        if (!authManager.isInitialized || authManager.isLoading) {
          return SplashScreen(
            nextPageBuilder: (_) => const AuthWrapper(),
          );
        }

        // Show error screen if there's an error during initialization
        if (authManager.error != null && !authManager.isAuthenticated) {
          return _buildErrorScreen(context, authManager);
        }

        // Route based on authentication status
        if (authManager.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const EmailLoginScreen();
        }
      },
    );
  }

  Widget _buildErrorScreen(BuildContext context, AuthStateManager authManager) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                authManager.error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        SmoothPageTransitions.slideFromRight<void>(
                          child: const EmailLoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Continue Offline'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      authManager.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
