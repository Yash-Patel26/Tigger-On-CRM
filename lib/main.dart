import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'data/services/auth_service.dart';
import 'core/constants/constants.dart';
import 'presentation/pages/auth_wrapper.dart';
import 'presentation/screens/notifications/notification_screen.dart';
import 'shared/managers/notification_store.dart';
import 'shared/managers/auth_state_manager.dart';
import 'shared/services/permission_manager.dart';
import 'shared/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await supabase.Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  // Initialize push (Android only); request permissions after first frame
  if (!kIsWeb) {
    await PushNotificationService.instance.initialize();
    final currentUser = supabase.Supabase.instance.client.auth.currentUser;
    await PushNotificationService.instance.saveFcmTokenToSupabase(
      currentUser?.id,
    );
  }

  // Ensure Android 13+ notifications permission and initialize push
  // Defer full wiring to widget tree stage

  runApp(const MyApp());
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
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final context = MyApp.navigatorKey.currentContext;
          if (context == null) return;
          final store = Provider.of<NotificationStore>(context, listen: false);
          PushNotificationService.instance.handleForegroundMessage(
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
        // Handle app opened via notification (Android only)
        if (!kIsWeb)
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            final ctx = MyApp.navigatorKey.currentContext;
            if (ctx != null) {
              Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            }
          });
        if (!kIsWeb)
          FirebaseMessaging.instance.getInitialMessage().then((message) {
            if (message != null) {
              final ctx = MyApp.navigatorKey.currentContext;
              if (ctx != null) {
                Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              }
            }
          });
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
      },
      home: const AuthWrapper(),
    );
  }
}
