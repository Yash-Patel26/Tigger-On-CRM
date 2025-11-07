import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../shared/managers/notification_store.dart';
import '../../data/models/app_notification.dart';
import '../../presentation/screens/notifications/notification_screen.dart';
import '../../presentation/screens/leads/lead_screen.dart';
import '../../presentation/screens/leads/lead_detail_screen.dart';
import '../../presentation/screens/bookings/booking_screen.dart';
import '../../presentation/screens/projects/site_visit_screen.dart';
import '../../presentation/screens/projects/site_visit_detail_screen.dart';
import '../../presentation/screens/ticket_hub_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../core/utils/page_transitions.dart';

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background isolates
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  
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
        // Handle taps on local notifications - navigate to specific screen based on payload
        if (response.actionId == null || response.actionId == '') {
          final ctx = _navigatorKey?.currentContext;
          if (ctx != null && response.payload != null) {
            _handleNotificationNavigation(ctx, response.payload!);
          } else if (ctx != null) {
            // Fallback to notification screen if no payload
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
        payload: payload?.entries.map((e) => '${e.key}=${e.value}').join('&'),
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

  /// Parses notification payload and navigates to the appropriate screen
  void _handleNotificationNavigation(BuildContext context, String payload) {
    try {
      debugPrint(
        'PushNotificationService: Handling notification tap with payload: $payload',
      );

      // Parse payload (format: key=value&key2=value2)
      final Map<String, String> payloadMap = {};
      if (payload.isNotEmpty) {
        final pairs = payload.split('&');
        for (final pair in pairs) {
          final keyValue = pair.split('=');
          if (keyValue.length == 2) {
            payloadMap[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
          }
        }
      }

      final type = payloadMap['type']?.toLowerCase() ?? '';
      final relatedId = payloadMap['related_id'];
      final relatedType = payloadMap['related_type']?.toLowerCase() ?? '';
      final actionUrl = payloadMap['action_url'] ?? '';

      debugPrint(
        'PushNotificationService: Parsed payload - type: $type, relatedId: $relatedId, relatedType: $relatedType, actionUrl: $actionUrl',
      );

      // Navigate based on type and related data
      if (actionUrl.isNotEmpty) {
        _navigateToActionUrl(context, actionUrl);
      } else if (type == 'lead' || relatedType == 'lead') {
        if (relatedId != null && relatedId.isNotEmpty) {
          debugPrint(
            'PushNotificationService: Navigating to LeadDetailScreen with ID: $relatedId',
          );
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: LeadDetailScreen(leadId: relatedId),
            ),
          );
        } else {
          debugPrint('PushNotificationService: Navigating to LeadScreen');
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const LeadScreen(),
            ),
          );
        }
      } else if (type == 'booking' || relatedType == 'booking') {
        debugPrint('PushNotificationService: Navigating to BookingScreen');
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const BookingScreen(),
          ),
        );
      } else if (type == 'sitevisit' ||
          type == 'site_visit' ||
          relatedType == 'sitevisit' ||
          relatedType == 'site_visit') {
        if (relatedId != null && relatedId.isNotEmpty) {
          debugPrint(
            'PushNotificationService: Navigating to SiteVisitDetailScreen with ID: $relatedId',
          );
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: SiteVisitDetailScreen(
                siteVisitId: relatedId,
                siteVisitData: {},
              ),
            ),
          );
        } else {
          debugPrint('PushNotificationService: Navigating to SiteVisitScreen');
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const SiteVisitScreen(),
            ),
          );
        }
      } else if (type == 'ticket' || relatedType == 'ticket') {
        debugPrint('PushNotificationService: Navigating to TicketHubScreen');
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const TicketHubScreen(),
          ),
        );
      } else {
        // Default to notification screen
        debugPrint('PushNotificationService: Defaulting to NotificationScreen');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'PushNotificationService: Error handling notification navigation: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      // Fallback to notification screen on error
      try {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
      } catch (_) {
        // Ignore navigation errors
      }
    }
  }

  /// Navigates to a screen based on action URL
  void _navigateToActionUrl(BuildContext context, String actionUrl) {
    debugPrint('PushNotificationService: Navigating to action URL: $actionUrl');

    if (actionUrl.startsWith('/')) {
      // Internal navigation - map to specific screens
      if (actionUrl == '/dashboard') {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const DashboardScreen(),
          ),
        );
      } else if (actionUrl == '/leads') {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(child: const LeadScreen()),
        );
      } else if (actionUrl.startsWith('/leads/')) {
        final leadId = actionUrl.split('/')[2];
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: LeadDetailScreen(leadId: leadId),
          ),
        );
      } else if (actionUrl == '/bookings') {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const BookingScreen(),
          ),
        );
      } else if (actionUrl == '/site-visits' || actionUrl == '/site_visits') {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const SiteVisitScreen(),
          ),
        );
      } else if (actionUrl.startsWith('/site-visits/') ||
          actionUrl.startsWith('/site_visits/')) {
        final siteVisitId = actionUrl.split('/').last;
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: SiteVisitDetailScreen(
              siteVisitId: siteVisitId,
              siteVisitData: {},
            ),
          ),
        );
      } else if (actionUrl == '/tickets') {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const TicketHubScreen(),
          ),
        );
      } else {
        // Default to notification screen
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
      }
    } else {
      // External URL or unknown format - default to notification screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
    }
  }

  /// Handles navigation when app is opened from a Firebase notification
  void handleNotificationTap(RemoteMessage message) {
    final ctx = _navigatorKey?.currentContext;
    if (ctx == null) {
      debugPrint(
        'PushNotificationService: No context available for navigation',
      );
      return;
    }

    try {
      final data = message.data;
      final type = (data['type'] ?? '').toString().toLowerCase();
      final relatedId = data['related_id']?.toString();
      final relatedType = (data['related_type'] ?? '').toString().toLowerCase();
      final actionUrl = data['action_url']?.toString() ?? '';

      debugPrint(
        'PushNotificationService: Handling Firebase notification tap - type: $type, relatedId: $relatedId, relatedType: $relatedType, actionUrl: $actionUrl',
      );

      if (actionUrl.isNotEmpty) {
        _navigateToActionUrl(ctx, actionUrl);
      } else if (type == 'lead' || relatedType == 'lead') {
        if (relatedId != null && relatedId.isNotEmpty) {
          Navigator.of(ctx).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: LeadDetailScreen(leadId: relatedId),
            ),
          );
        } else {
          Navigator.of(ctx).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const LeadScreen(),
            ),
          );
        }
      } else if (type == 'booking' || relatedType == 'booking') {
        Navigator.of(ctx).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const BookingScreen(),
          ),
        );
      } else if (type == 'sitevisit' ||
          type == 'site_visit' ||
          relatedType == 'sitevisit' ||
          relatedType == 'site_visit') {
        if (relatedId != null && relatedId.isNotEmpty) {
          Navigator.of(ctx).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: SiteVisitDetailScreen(
                siteVisitId: relatedId,
                siteVisitData: {},
              ),
            ),
          );
        } else {
          Navigator.of(ctx).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const SiteVisitScreen(),
            ),
          );
        }
      } else if (type == 'ticket' || relatedType == 'ticket') {
        Navigator.of(ctx).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: const TicketHubScreen(),
          ),
        );
      } else {
        // Default to notification screen
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
      }
    } catch (e, stackTrace) {
      debugPrint(
        'PushNotificationService: Error handling Firebase notification tap: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      // Fallback to notification screen
      try {
        Navigator.of(
          ctx,
        ).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
      } catch (_) {
        // Ignore navigation errors
      }
    }
  }
}
