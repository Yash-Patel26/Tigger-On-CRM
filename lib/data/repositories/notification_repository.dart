import 'dart:async';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  static final NotificationRepository _instance =
      NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  // Cache for notifications
  final Map<String, List<Notification>> _notificationCache = {};
  final Map<String, Map<String, int>> _countCache = {};

  // Stream controllers for real-time updates
  final Map<String, StreamController<List<Notification>>> _streamControllers =
      {};
  final Map<String, StreamSubscription> _subscriptions = {};

  // Get notifications for a user with caching
  Future<List<Notification>> getNotifications({
    String? userId,
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    if (userId == null) {
      throw Exception('User ID is required');
    }
    return getUserNotifications(
      userId: userId,
      status: status,
      type: type,
      priority: priority,
      limit: limit,
      offset: offset,
      forceRefresh: forceRefresh,
    );
  }

  // Get notifications for a user with caching
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(
      userId,
      status,
      type,
      priority,
      limit,
      offset,
    );

    if (!forceRefresh && _notificationCache.containsKey(cacheKey)) {
      return _notificationCache[cacheKey]!;
    }

    try {
      final notifications = await NotificationService.getUserNotifications(
        userId: userId,
        status: status,
        type: type,
        priority: priority,
        limit: limit,
        offset: offset,
      );

      _notificationCache[cacheKey] = notifications;
      return notifications;
    } catch (e) {
      throw Exception('Failed to fetch user notifications: $e');
    }
  }

  // Get notification counts with caching
  Future<Map<String, int>> getNotificationCounts(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _countCache.containsKey(userId)) {
      return _countCache[userId]!;
    }

    try {
      final counts = await NotificationService.getNotificationCounts(userId);
      _countCache[userId] = counts;
      return counts;
    } catch (e) {
      throw Exception('Failed to fetch notification counts: $e');
    }
  }

  // Create a new notification
  Future<Notification> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    required NotificationPriority priority,
    String? userId,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = await NotificationService.createNotification(
        title: title,
        message: message,
        type: type,
        priority: priority,
        userId: userId,
        relatedId: relatedId,
        relatedType: relatedType,
        actionUrl: actionUrl,
        data: data,
      );

      // Clear cache for this user
      _clearUserCache(userId);

      // Update stream if active
      _updateStream(userId);

      return notification;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Mark notification as read
  Future<Notification> markAsRead(
    String notificationId, {
    String? userId,
  }) async {
    try {
      final notification = await NotificationService.markAsRead(notificationId);

      // Clear cache for this user
      if (userId != null) {
        _clearUserCache(userId);
        _updateStream(userId);
      }

      return notification;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark notification as unread
  Future<Notification> markAsUnread(
    String notificationId, {
    String? userId,
  }) async {
    try {
      final notification = await NotificationService.markAsUnread(
        notificationId,
      );

      // Clear cache for this user
      if (userId != null) {
        _clearUserCache(userId);
        _updateStream(userId);
      }

      return notification;
    } catch (e) {
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  // Archive notification
  Future<Notification> archiveNotification(
    String notificationId, {
    String? userId,
  }) async {
    try {
      final notification = await NotificationService.archiveNotification(
        notificationId,
      );

      // Clear cache for this user
      if (userId != null) {
        _clearUserCache(userId);
        _updateStream(userId);
      }

      return notification;
    } catch (e) {
      throw Exception('Failed to archive notification: $e');
    }
  }

  // Unarchive notification
  Future<Notification> unarchiveNotification(
    String notificationId, {
    String? userId,
  }) async {
    try {
      final notification = await NotificationService.unarchiveNotification(
        notificationId,
      );

      // Clear cache for this user
      if (userId != null) {
        _clearUserCache(userId);
        _updateStream(userId);
      }

      return notification;
    } catch (e) {
      throw Exception('Failed to unarchive notification: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await NotificationService.markAllAsRead(userId);

      // Clear cache for this user
      _clearUserCache(userId);
      _updateStream(userId);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(
    String notificationId, {
    String? userId,
  }) async {
    try {
      await NotificationService.deleteNotification(notificationId);

      // Clear cache for this user
      if (userId != null) {
        _clearUserCache(userId);
        _updateStream(userId);
      }
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Subscribe to real-time notifications
  Stream<List<Notification>> subscribeToUserNotifications(String userId) {
    if (!_streamControllers.containsKey(userId)) {
      _streamControllers[userId] =
          StreamController<List<Notification>>.broadcast();

      // Start real-time subscription
      _subscriptions[userId] =
          NotificationService.subscribeToUserNotifications(userId).listen((
            notifications,
          ) {
            _streamControllers[userId]!.add(notifications);

            // Update cache
            _notificationCache[_generateCacheKey(userId)] = notifications;
          });
    }

    return _streamControllers[userId]!.stream;
  }

  // Unsubscribe from real-time notifications
  void unsubscribeFromUserNotifications(String userId) {
    _subscriptions[userId]?.cancel();
    _subscriptions.remove(userId);

    _streamControllers[userId]?.close();
    _streamControllers.remove(userId);
  }

  // Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    final counts = await getNotificationCounts(userId);
    return counts['unread'] ?? 0;
  }

  // Get notifications by type
  Future<List<Notification>> getNotificationsByType({
    required String userId,
    required NotificationType type,
    NotificationStatus? status,
    int? limit,
  }) async {
    return getUserNotifications(
      userId: userId,
      type: type,
      status: status,
      limit: limit,
    );
  }

  // Get urgent notifications
  Future<List<Notification>> getUrgentNotifications(String userId) async {
    return getUserNotifications(
      userId: userId,
      priority: NotificationPriority.urgent,
      status: NotificationStatus.unread,
    );
  }

  // Get recent notifications
  Future<List<Notification>> getRecentNotifications(
    String userId, {
    int limit = 10,
  }) async {
    return getUserNotifications(userId: userId, limit: limit);
  }

  // Search notifications
  Future<List<Notification>> searchNotifications({
    required String userId,
    required String query,
    NotificationType? type,
    NotificationStatus? status,
  }) async {
    try {
      final allNotifications = await getUserNotifications(
        userId: userId,
        type: type,
        status: status,
      );

      return allNotifications.where((notification) {
        return notification.title.toLowerCase().contains(query.toLowerCase()) ||
            notification.message.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search notifications: $e');
    }
  }

  // Clear all cache
  void clearCache() {
    _notificationCache.clear();
    _countCache.clear();
  }

  // Clear cache for specific user
  void _clearUserCache(String? userId) {
    if (userId == null) return;

    _notificationCache.removeWhere((key, value) => key.contains(userId));
    _countCache.remove(userId);
  }

  // Update stream for user
  void _updateStream(String? userId) {
    if (userId == null || !_streamControllers.containsKey(userId)) return;

    // Trigger a refresh by fetching latest notifications
    getUserNotifications(userId: userId, forceRefresh: true).then((
      notifications,
    ) {
      _streamControllers[userId]!.add(notifications);
    });
  }

  // Generate cache key
  String _generateCacheKey(
    String userId, [
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
  ]) {
    final parts = [userId];
    if (status != null) parts.add('status:${status.name}');
    if (type != null) parts.add('type:${type.name}');
    if (priority != null) parts.add('priority:${priority.name}');
    if (limit != null) parts.add('limit:$limit');
    if (offset != null) parts.add('offset:$offset');
    return parts.join('|');
  }

  // Dispose resources
  void dispose() {
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();

    clearCache();
  }
}
