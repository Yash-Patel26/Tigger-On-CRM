import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// App integrations
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../shared/managers/notification_store.dart';
import '../../data/models/app_notification.dart';
import '../../presentation/screens/notifications/notification_screen.dart';

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolates
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  // Nothing else needed here; Android will show notification if provided.
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_initialized) return;

    if (navigatorKey != null) {
      _navigatorKey = navigatorKey;
    }

    // Firebase init should have been called by main.dart
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Local notifications initialization
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_stat_notification');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle taps on local notifications - navigate to notification screen
        if (response.actionId == null || response.actionId == '') {
          final ctx = _navigatorKey?.currentContext;
          if (ctx != null) {
            Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          }
        }
      },
    );

    // Android channel
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  Future<bool> requestAndroidPermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;
    // Android 13+ requires runtime permission; the plugin helps request it
    final androidImplementation = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidImplementation
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<bool> checkAndroidPermission() async {
    if (!Platform.isAndroid) return true;
    final androidImplementation = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }

  Future<void> showLocalNotification({
    required String id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    try {
      // Check if service is initialized
      if (!_initialized) {
        debugPrint(
          'PushNotificationService: Not initialized, initializing now...',
        );
        await initialize(navigatorKey: _navigatorKey);
      }

      // Check and request permissions if needed (Android 13+)
      if (Platform.isAndroid) {
        final hasPermission = await checkAndroidPermission();
        if (!hasPermission) {
          debugPrint(
            'PushNotificationService: Requesting notification permission...',
          );
          final granted = await requestAndroidPermissionIfNeeded();
          if (!granted) {
            debugPrint(
              'PushNotificationService: Notification permission denied',
            );
            return;
          }
        }
      }

      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        // Let the system/initialization icon be used; avoid explicit icon
      );

      await _local.show(
        id.hashCode,
        title,
        body,
        NotificationDetails(android: androidDetails),
        payload: payload == null
            ? null
            : payload.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      debugPrint(
        'PushNotificationService: Notification shown successfully - $title',
      );
    } catch (e, stackTrace) {
      debugPrint('PushNotificationService: Error showing notification: $e');
      debugPrint('Stack trace: $stackTrace');
      // Re-throw to allow caller to handle if needed
      rethrow;
    }
  }

  Future<void> saveFcmTokenToSupabase(String? userId) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || userId == null) return;
      final client = supabase.Supabase.instance.client;
      // Upsert token to a user_devices table if available; otherwise fallback to profiles
      try {
        await client.from('user_devices').upsert({
          'user_id': userId,
          'fcm_token': token,
          'platform': 'android',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      } catch (_) {
        await client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', userId);
      }
    } catch (_) {
      // Ignore token save failures silently
    }
  }

  Future<void> handleForegroundMessage(
    RemoteMessage message,
    NotificationStore store,
  ) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    // Mirror into in-app store
    store.add(
      AppNotification(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: body,
        time: DateTime.now().toIso8601String(),
        type: _mapType(message.data['type']),
        unread: true,
        createdAt: DateTime.now(),
      ),
    );

    // Show system tray notification while app is foregrounded
    try {
      await showLocalNotification(
        id: message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        payload: message.data.map((k, v) => MapEntry(k, '$v')),
      );
    } catch (e) {
      debugPrint(
        'PushNotificationService: Error showing foreground notification: $e',
      );
    }
  }

  AppNotificationType _mapType(dynamic raw) {
    final value = (raw ?? '').toString().toLowerCase();
    switch (value) {
      case 'lead':
        return AppNotificationType.lead;
      case 'calendar':
        return AppNotificationType.calendar;
      case 'booking':
        return AppNotificationType.booking;
      case 'followup':
      case 'follow_up':
        return AppNotificationType.followUp;
      default:
        return AppNotificationType.followUp;
    }
  }
}
