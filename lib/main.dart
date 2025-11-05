import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'data/services/auth_service.dart';
import 'core/constants/constants.dart';
import 'presentation/pages/auth_wrapper.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'shared/managers/notification_store.dart';
import 'shared/managers/auth_state_manager.dart';
import 'shared/services/permission_manager.dart';
import 'shared/services/push_notification_service.dart';

void main() {
  // Run app in error zone to catch all uncaught exceptions
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set up global error handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          debugPrint('Flutter Error: ${details.exception}');
          debugPrint('Stack trace: ${details.stack}');
        }
        // Log to crash reporting service in production
      };

      // Set up error widget builder to catch widget build errors
      ErrorWidget.builder = (FlutterErrorDetails details) {
        if (kDebugMode) {
          return ErrorWidget(details.exception);
        }
        // In production, show a user-friendly error screen
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please restart the app',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      };

      // Handle errors from async gaps
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          debugPrint('Platform Error: $error');
          debugPrint('Stack trace: $stack');
        }
        return true; // Return true to prevent app from crashing
      };

      // Initialize services with error handling
      bool supabaseInitialized = false;
      bool firebaseInitialized = false;

      // Initialize Supabase with error handling
      try {
        await supabase.Supabase.initialize(
          url: AppConstants.supabaseUrl,
          anonKey: AppConstants.supabaseAnonKey,
        );
        supabaseInitialized = true;
        if (kDebugMode) {
          debugPrint('✓ Supabase initialized successfully');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('✗ Supabase initialization failed: $e');
          debugPrint('Stack trace: $stackTrace');
        }
        // Continue app startup even if Supabase fails
      }

      // Initialize Firebase with error handling
      if (!kIsWeb) {
        try {
          await Firebase.initializeApp();
          firebaseInitialized = true;
          if (kDebugMode) {
            debugPrint('✓ Firebase initialized successfully');
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('✗ Firebase initialization failed: $e');
            debugPrint('Stack trace: $stackTrace');
          }
          // Continue app startup even if Firebase fails
        }

        // Initialize push notifications with error handling
        if (firebaseInitialized) {
          try {
            await PushNotificationService.instance.initialize(
              navigatorKey: MyApp.navigatorKey,
            );
            if (kDebugMode) {
              debugPrint('✓ Push notification service initialized');
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              debugPrint('✗ Push notification initialization failed: $e');
              debugPrint('Stack trace: $stackTrace');
            }
            // Continue app startup even if push notifications fail
          }

          // Request permissions (non-blocking)
          try {
            await PushNotificationService.instance
                .requestAndroidPermissionIfNeeded();
          } catch (e) {
            if (kDebugMode) {
              debugPrint('✗ Permission request failed: $e');
            }
          }

          // Save FCM token (non-blocking)
          try {
            if (supabaseInitialized) {
              final currentUser =
                  supabase.Supabase.instance.client.auth.currentUser;
              await PushNotificationService.instance.saveFcmTokenToSupabase(
                currentUser?.id,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('✗ FCM token save failed: $e');
            }
          }
        }
      }

      // Run the app even if some services failed to initialize
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Handle any uncaught errors
      if (kDebugMode) {
        debugPrint('Uncaught error: $error');
        debugPrint('Stack trace: $stackTrace');
      }
      // In production, send to crash reporting service
      // For now, we still try to run the app
      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<AuthStateManager>(
          create: (_) => AuthStateManager(),
        ),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<NotificationStore>(
          create: (_) => NotificationStore(),
        ),
      ],
      child: _buildApp(),
    );
  }

  Widget _buildApp() {
    // Color schema: #E55934 (Orange) as primary
    // Adopted mapping: Primary=#E55934, Secondary=#E55934 variants, Light surfaces=#E55934/90E0EF, Dark surfaces=#E55934 variants
    // New palette: surfaces/backgrounds use #E1F0E4; keep accents readable
    final Color primary = const Color(0xFF1E88E5); // accent blue for controls
    final Color secondary = const Color(0xFF1E88E5).withOpacity(0.9);
    final Color surfaceDark = const Color(0xFF1A1A1A);
    final Color surfaceDark2 = const Color(0xFF2A2A2A);

    final ThemeData baseDark = ThemeData.dark();

    final ThemeData darkTheme = baseDark.copyWith(
      scaffoldBackgroundColor: surfaceDark,
      colorScheme: baseDark.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
        onSurface: const Color(0xFFEAF7FC),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white70),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark2,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark2,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white70),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: baseDark.textTheme
          .apply(bodyColor: Colors.white, displayColor: Colors.white)
          .copyWith(
            titleLarge: const TextStyle(fontWeight: FontWeight.w700),
            bodyMedium: const TextStyle(color: Colors.white70),
          ),
      dividerColor: Colors.white12,
      splashColor: primary.withOpacity(0.15),
      highlightColor: Colors.white.withOpacity(0.05),
    );

    // Light theme
    final ThemeData baseLight = ThemeData.light();
    final Color surfaceLight = const Color(0xFFE1F0E4);
    final Color surfaceLight2 = const Color(0xFFE1F0E4);

    final ThemeData lightTheme = baseLight.copyWith(
      scaffoldBackgroundColor: surfaceLight,
      colorScheme: baseLight.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        onSurface: const Color(0xFF2A2A2A),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2A2A2A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2A2A2A),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF555555),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight2,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight2,
        labelStyle: const TextStyle(color: Color(0xFF666666)),
        hintStyle: const TextStyle(color: Color(0xFF888888)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x22000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0x33000000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF444444)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF555555)),
      textTheme: baseLight.textTheme
          .apply(
            bodyColor: const Color(0xFF1A1A1A),
            displayColor: const Color(0xFF1A1A1A),
          )
          .copyWith(
            titleLarge: const TextStyle(fontWeight: FontWeight.w700),
            bodyMedium: const TextStyle(color: Color(0xFF444444)),
          ),
      dividerColor: const Color(0x14000000),
      splashColor: primary.withOpacity(0.12),
      highlightColor: Colors.black.withOpacity(0.03),
    );

    // Attach foreground listener exactly once after first frame using the navigator context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Set navigator key for notification tap handling
      if (!kIsWeb) {
        PushNotificationService.instance.setNavigatorKey(MyApp.navigatorKey);
      }
      // Request permissions after first frame to avoid blocking splash (Android only)
      if (!kIsWeb) {
        await PermissionManager.ensureCorePermissions();
        await PushNotificationService.instance
            .requestAndroidPermissionIfNeeded();
      }

      if (!kIsWeb)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          final context = MyApp.navigatorKey.currentContext;
          if (context == null) return;
          final store = Provider.of<NotificationStore>(context, listen: false);
          await PushNotificationService.instance.handleForegroundMessage(
            message,
            store,
          );
        });
    });

    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      title: 'TiggerOn',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      builder: (BuildContext context, Widget? child) {
        try {
          // Handle app opened via notification (Android only)
          if (!kIsWeb) {
            FirebaseMessaging.onMessageOpenedApp.listen((
              RemoteMessage message,
            ) {
              try {
                final ctx = MyApp.navigatorKey.currentContext;
                if (ctx != null) {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Error handling notification tap: $e');
                }
              }
            });
            FirebaseMessaging.instance
                .getInitialMessage()
                .then((message) {
                  try {
                    if (message != null) {
                      final ctx = MyApp.navigatorKey.currentContext;
                      if (ctx != null) {
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('Error handling initial notification: $e');
                    }
                  }
                })
                .catchError((e) {
                  if (kDebugMode) {
                    debugPrint('Error getting initial message: $e');
                  }
                });
          }
          final MediaQueryData mq = MediaQuery.of(context);
          final double width = mq.size.width;
          // Slightly up-scale text on small/mobile screens for readability.
          final double scale = width < 360
              ? 1.18
              : width < 400
              ? 1.14
              : width < 480
              ? 1.10
              : 1.06;
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(scale)),
            child: child ?? const SizedBox.shrink(),
          );
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('Error in MaterialApp builder: $e');
            debugPrint('Stack trace: $stackTrace');
          }
          // Return a safe fallback widget
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Initialization Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please restart the app',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      home: const AuthWrapper(),
    );
  }
}
