import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// App integrations
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../shared/managers/notification_store.dart';
import '../../data/models/app_notification.dart';

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

  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_initialized) return;

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
        // Handle taps on local notifications
        final payload = response.payload;
        // Implement routing if needed using payload
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

  Future<void> requestAndroidPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;
    // Android 13+ requires runtime permission; the plugin helps request it
    final androidImplementation = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showLocalNotification({
    required String id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_notification',
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

  void handleForegroundMessage(RemoteMessage message, NotificationStore store) {
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
    showLocalNotification(
      id: message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      payload: message.data.map((k, v) => MapEntry(k, '$v')),
    );
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
