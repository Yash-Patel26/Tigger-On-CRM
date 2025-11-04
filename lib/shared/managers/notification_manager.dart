import 'dart:async';
import '../../data/models/models.dart';
import '../../data/repositories/notification_repository.dart';
import '../services/push_notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationRepository _repository = NotificationRepository();

  // Current user ID
  String? _currentUserId;

  // Track last known notifications to detect new ones
  List<Notification> _lastKnownNotifications = [];

  // Fallback poller in case realtime is unavailable (e.g., emulator constraints)
  Timer? _pollTimer;

  // Stream controllers
  final StreamController<List<Notification>> _notificationsController =
      StreamController<List<Notification>>.broadcast();
  final StreamController<Map<String, int>> _countsController =
      StreamController<Map<String, int>>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  // Getters for streams
  Stream<List<Notification>> get notificationsStream =>
      _notificationsController.stream;
  Stream<Map<String, int>> get countsStream => _countsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Initialize with user ID
  void initialize(String userId) async {
    _currentUserId = userId;
    // Load initial notifications to establish baseline
    try {
      final initialNotifications = await getNotifications(limit: 50);
      _lastKnownNotifications = initialNotifications;
    } catch (e) {
      // If initial load fails, start with empty list
      _lastKnownNotifications = [];
    }
    _startRealTimeSubscription();
    _startFallbackPolling();
  }

  // Get notifications for current user
  Future<List<Notification>> getNotifications({
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    final notifications = await _repository.getUserNotifications(
      userId: _currentUserId!,
      status: status,
      type: type,
      priority: priority,
      limit: limit,
      offset: offset,
      forceRefresh: forceRefresh,
    );

    _notificationsController.add(notifications);
    return notifications;
  }

  // Get notification counts
  Future<Map<String, int>> getNotificationCounts({
    bool forceRefresh = false,
  }) async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    final counts = await _repository.getNotificationCounts(
      _currentUserId!,
      forceRefresh: forceRefresh,
    );
    _countsController.add(counts);
    _unreadCountController.add(counts['unread'] ?? 0);
    return counts;
  }

  // Create notification
  Future<Notification> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    final notification = await _repository.createNotification(
      title: title,
      message: message,
      type: type,
      priority: priority,
      userId: _currentUserId,
      relatedId: relatedId,
      relatedType: relatedType,
      actionUrl: actionUrl,
      data: data,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
    return notification;
  }

  // Mark as read
  Future<Notification> markAsRead(String notificationId) async {
    final notification = await _repository.markAsRead(
      notificationId,
      userId: _currentUserId,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
    return notification;
  }

  // Mark as unread
  Future<Notification> markAsUnread(String notificationId) async {
    final notification = await _repository.markAsUnread(
      notificationId,
      userId: _currentUserId,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
    return notification;
  }

  // Archive notification
  Future<Notification> archiveNotification(String notificationId) async {
    final notification = await _repository.archiveNotification(
      notificationId,
      userId: _currentUserId,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
    return notification;
  }

  // Unarchive notification
  Future<Notification> unarchiveNotification(String notificationId) async {
    final notification = await _repository.unarchiveNotification(
      notificationId,
      userId: _currentUserId,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
    return notification;
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    await _repository.markAllAsRead(_currentUserId!);

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _repository.deleteNotification(
      notificationId,
      userId: _currentUserId,
    );

    // Refresh data
    await getNotificationCounts(forceRefresh: true);
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    return await _repository.getUnreadCount(_currentUserId!);
  }

  // Get urgent notifications
  Future<List<Notification>> getUrgentNotifications() async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    return await _repository.getUrgentNotifications(_currentUserId!);
  }

  // Get recent notifications
  Future<List<Notification>> getRecentNotifications({int limit = 10}) async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    return await _repository.getRecentNotifications(
      _currentUserId!,
      limit: limit,
    );
  }

  // Search notifications
  Future<List<Notification>> searchNotifications({
    required String query,
    NotificationType? type,
    NotificationStatus? status,
  }) async {
    if (_currentUserId == null) {
      throw Exception(
        'NotificationManager not initialized. Call initialize() first.',
      );
    }

    return await _repository.searchNotifications(
      userId: _currentUserId!,
      query: query,
      type: type,
      status: status,
    );
  }

  // Start real-time subscription
  void _startRealTimeSubscription() {
    if (_currentUserId == null) return;

    _repository.subscribeToUserNotifications(_currentUserId!).listen((
      notifications,
    ) {
      // Detect new notifications (not in last known list)
      final Set<String> lastKnownIds = _lastKnownNotifications
          .map((n) => n.id)
          .toSet();
      final List<Notification> newNotifications = notifications
          .where(
            (n) =>
                !lastKnownIds.contains(n.id) &&
                n.status == NotificationStatus.unread,
          )
          .toList();

      // Show mobile notification bar for each new notification
      for (final notification in newNotifications) {
        PushNotificationService.instance.showLocalNotification(
          id: notification.id,
          title: notification.title,
          body: notification.message,
          payload: {
            'id': notification.id,
            'type': notification.type.name,
            'related_id': notification.relatedId ?? '',
            'related_type': notification.relatedType ?? '',
            'action_url': notification.actionUrl ?? '',
          },
        );
      }

      // Update last known list
      _lastKnownNotifications = List.from(notifications);

      _notificationsController.add(notifications);

      // Update counts
      _updateCountsFromNotifications(notifications);
    });
  }

  // Update counts from notifications
  void _updateCountsFromNotifications(List<Notification> notifications) {
    Map<String, int> counts = {
      'total': notifications.length,
      'unread': 0,
      'read': 0,
      'archived': 0,
      'lead': 0,
      'booking': 0,
      'siteVisit': 0,
      'ticket': 0,
      'system': 0,
      'reminder': 0,
      'alert': 0,
    };

    for (var notification in notifications) {
      // Count by status
      switch (notification.status) {
        case NotificationStatus.unread:
          counts['unread'] = (counts['unread'] ?? 0) + 1;
          break;
        case NotificationStatus.read:
          counts['read'] = (counts['read'] ?? 0) + 1;
          break;
        case NotificationStatus.archived:
          counts['archived'] = (counts['archived'] ?? 0) + 1;
          break;
      }

      // Count by type
      switch (notification.type) {
        case NotificationType.lead:
          counts['lead'] = (counts['lead'] ?? 0) + 1;
          break;
        case NotificationType.booking:
          counts['booking'] = (counts['booking'] ?? 0) + 1;
          break;
        case NotificationType.siteVisit:
          counts['siteVisit'] = (counts['siteVisit'] ?? 0) + 1;
          break;
        case NotificationType.ticket:
          counts['ticket'] = (counts['ticket'] ?? 0) + 1;
          break;
        case NotificationType.system:
          counts['system'] = (counts['system'] ?? 0) + 1;
          break;
        case NotificationType.reminder:
          counts['reminder'] = (counts['reminder'] ?? 0) + 1;
          break;
        case NotificationType.alert:
          counts['alert'] = (counts['alert'] ?? 0) + 1;
          break;
      }
    }

    _countsController.add(counts);
    _unreadCountController.add(counts['unread'] ?? 0);
  }

  // Clear cache
  void clearCache() {
    _repository.clearCache();
  }

  // Dispose
  void dispose() {
    _repository.dispose();
    _notificationsController.close();
    _countsController.close();
    _unreadCountController.close();
    _pollTimer?.cancel();
  }

  void _startFallbackPolling() {
    _pollTimer?.cancel();
    if (_currentUserId == null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      try {
        final latest = await _repository.getUserNotifications(
          userId: _currentUserId!,
          forceRefresh: true,
        );
        // Only emit if changed to avoid redundant rebuilds
        if (latest.isNotEmpty &&
            latest.first.id !=
                (_lastKnownNotifications.isNotEmpty
                    ? _lastKnownNotifications.first.id
                    : null)) {
          _lastKnownNotifications = List.from(latest);
          _notificationsController.add(latest);
          _updateCountsFromNotifications(latest);
        }
      } catch (_) {
        // ignore
      }
    });
  }
}
