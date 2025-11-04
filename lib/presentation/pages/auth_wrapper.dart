import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/managers/auth_state_manager.dart';
import '../../presentation/screens/auth/email_login_screen.dart';
import '../../presentation/screens/dashboard/home_screen.dart';
import 'role_gate.dart';
import '../../core/utils/page_transitions.dart';
import '../../data/services/follow_up_notification_service.dart';
import '../../shared/managers/notification_manager.dart';
import '../../shared/managers/notification_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../shared/services/push_notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Wrapper widget that handles authentication state and routing
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _notificationsInitialized = false;
  @override
  void initState() {
    super.initState();
    // Initialize auth state when the wrapper is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStateManager>().initialize();
      // Start follow-up notification checks when user is authenticated
      _checkAndStartFollowUpNotifications();
      // Wire FCM foreground handler to also display system tray notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final store = context.read<NotificationStore>();
        PushNotificationService.instance.handleForegroundMessage(
          message,
          store,
        );
      });
    });
  }

  void _checkAndStartFollowUpNotifications() {
    // Check periodically if user is authenticated and start follow-up notifications
    Future.delayed(const Duration(seconds: 2), () {
      final authManager = context.read<AuthStateManager>();
      if (authManager.isAuthenticated) {
        // Start periodic follow-up notification checks
        FollowUpNotificationService.startPeriodicCheck();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, child) {
        // Debug logging
        debugPrint(
          'AuthWrapper rebuild - isInitialized: ${authManager.isInitialized}, isAuthenticated: ${authManager.isAuthenticated}, isLoading: ${authManager.isLoading}',
        );

        // Show splash screen only during initial app load (checking for existing session)
        // Not during login attempts
        if (!authManager.isInitialized) {
          debugPrint('AuthWrapper: Showing splash placeholder (initializing)');
          return const Scaffold(
            body: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Show error screen if there's an error during initialization
        if (authManager.error != null && !authManager.isAuthenticated) {
          debugPrint('AuthWrapper: Showing error screen');
          return _buildErrorScreen(context, authManager);
        }

        // Route based on authentication status
        if (authManager.isAuthenticated) {
          debugPrint('AuthWrapper: Showing HomeScreen');
          // Initialize NotificationManager once per session
          if (!_notificationsInitialized) {
            final String? uid =
                supabase.Supabase.instance.client.auth.currentUser?.id;
            if (uid != null) {
              NotificationManager().initialize(uid);
              _notificationsInitialized = true;
            }
          }
          return const RoleGate(child: HomeScreen());
        } else {
          debugPrint('AuthWrapper: Showing EmailLoginScreen');
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
