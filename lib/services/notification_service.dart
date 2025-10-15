import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all notifications with optional filters
  Future<ApiResponse<List<Notification>>> getNotifications({
    String? search,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    String? userId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (type != null) {
      queryParams['type'] = type.name;
    }
    if (priority != null) {
      queryParams['priority'] = priority.name;
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (userId != null) {
      queryParams['userId'] = userId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    return await _apiService.get<List<Notification>>(
      '/notifications',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get notification by ID
  Future<ApiResponse<Notification>> getNotification(String id) async {
    return await _apiService.get<Notification>(
      '/notifications/$id',
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new notification
  Future<ApiResponse<Notification>> createNotification(
    Notification notification,
  ) async {
    return await _apiService.post<Notification>(
      '/notifications',
      body: notification.toJson(),
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update notification
  Future<ApiResponse<Notification>> updateNotification(
    String id,
    Notification notification,
  ) async {
    return await _apiService.put<Notification>(
      '/notifications/$id',
      body: notification.toJson(),
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete notification
  Future<ApiResponse<void>> deleteNotification(String id) async {
    return await _apiService.delete<void>('/notifications/$id');
  }

  // Mark notification as read
  Future<ApiResponse<Notification>> markAsRead(String notificationId) async {
    return await _apiService.patch<Notification>(
      '/notifications/$notificationId/read',
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Mark notification as unread
  Future<ApiResponse<Notification>> markAsUnread(String notificationId) async {
    return await _apiService.patch<Notification>(
      '/notifications/$notificationId/unread',
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Archive notification
  Future<ApiResponse<Notification>> archiveNotification(
    String notificationId,
  ) async {
    return await _apiService.patch<Notification>(
      '/notifications/$notificationId/archive',
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Unarchive notification
  Future<ApiResponse<Notification>> unarchiveNotification(
    String notificationId,
  ) async {
    return await _apiService.patch<Notification>(
      '/notifications/$notificationId/unarchive',
      fromJson: (json) =>
          Notification.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    return await _apiService.post<void>('/notifications/mark-all-read');
  }

  // Get unread notifications count
  Future<ApiResponse<int>> getUnreadCount() async {
    return await _apiService.get<int>(
      '/notifications/unread-count',
      fromJson: (json) => json['data'] as int,
    );
  }

  // Get notification statistics
  Future<ApiResponse<Map<String, dynamic>>> getNotificationStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/notifications/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's notifications
  Future<ApiResponse<List<Notification>>> getTodaysNotifications() async {
    return await _apiService.get<List<Notification>>(
      '/notifications/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get unread notifications
  Future<ApiResponse<List<Notification>>> getUnreadNotifications() async {
    return await _apiService.get<List<Notification>>(
      '/notifications/unread',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get archived notifications
  Future<ApiResponse<List<Notification>>> getArchivedNotifications() async {
    return await _apiService.get<List<Notification>>(
      '/notifications/archived',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Search notifications
  Future<ApiResponse<List<Notification>>> searchNotifications(
    String query,
  ) async {
    return await _apiService.get<List<Notification>>(
      '/notifications/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get notifications by type
  Future<ApiResponse<List<Notification>>> getNotificationsByType(
    NotificationType type,
  ) async {
    return await _apiService.get<List<Notification>>(
      '/notifications/by-type',
      queryParams: {'type': type.name},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get notifications by priority
  Future<ApiResponse<List<Notification>>> getNotificationsByPriority(
    NotificationPriority priority,
  ) async {
    return await _apiService.get<List<Notification>>(
      '/notifications/by-priority',
      queryParams: {'priority': priority.name},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Clear all notifications
  Future<ApiResponse<void>> clearAllNotifications() async {
    return await _apiService.delete<void>('/notifications/clear-all');
  }

  // Get notification preferences
  Future<ApiResponse<Map<String, dynamic>>> getNotificationPreferences() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/notifications/preferences',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Update notification preferences
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationPreferences(
    Map<String, dynamic> preferences,
  ) async {
    return await _apiService.put<Map<String, dynamic>>(
      '/notifications/preferences',
      body: preferences,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }
}
