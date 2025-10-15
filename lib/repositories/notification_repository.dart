import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

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
    return _notificationService.getNotifications(
      search: search,
      type: type,
      priority: priority,
      status: status,
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Notification>> getNotificationById(String id) async {
    return _notificationService.getNotification(id);
  }

  Future<ApiResponse<Notification>> createNotification(
    Notification notification,
  ) async {
    return _notificationService.createNotification(notification);
  }

  Future<ApiResponse<Notification>> updateNotification(
    String id,
    Notification notification,
  ) async {
    return _notificationService.updateNotification(id, notification);
  }

  Future<ApiResponse<void>> deleteNotification(String id) async {
    return _notificationService.deleteNotification(id);
  }

  Future<ApiResponse<Notification>> markAsRead(String notificationId) async {
    return _notificationService.markAsRead(notificationId);
  }

  Future<ApiResponse<Notification>> markAsUnread(String notificationId) async {
    return _notificationService.markAsUnread(notificationId);
  }

  Future<ApiResponse<Notification>> archiveNotification(
    String notificationId,
  ) async {
    return _notificationService.archiveNotification(notificationId);
  }

  Future<ApiResponse<Notification>> unarchiveNotification(
    String notificationId,
  ) async {
    return _notificationService.unarchiveNotification(notificationId);
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    return _notificationService.markAllAsRead();
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    return _notificationService.getUnreadCount();
  }

  Future<ApiResponse<Map<String, dynamic>>> getNotificationStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
  }) async {
    return _notificationService.getNotificationStats(
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
    );
  }

  Future<ApiResponse<List<Notification>>> getTodaysNotifications() async {
    return _notificationService.getTodaysNotifications();
  }

  Future<ApiResponse<List<Notification>>> getUnreadNotifications() async {
    return _notificationService.getUnreadNotifications();
  }

  Future<ApiResponse<List<Notification>>> getArchivedNotifications() async {
    return _notificationService.getArchivedNotifications();
  }

  Future<ApiResponse<List<Notification>>> searchNotifications(
    String query,
  ) async {
    return _notificationService.searchNotifications(query);
  }

  Future<ApiResponse<List<Notification>>> getNotificationsByType(
    NotificationType type,
  ) async {
    return _notificationService.getNotificationsByType(type);
  }

  Future<ApiResponse<List<Notification>>> getNotificationsByPriority(
    NotificationPriority priority,
  ) async {
    return _notificationService.getNotificationsByPriority(priority);
  }

  Future<ApiResponse<void>> clearAllNotifications() async {
    return _notificationService.clearAllNotifications();
  }

  Future<ApiResponse<Map<String, dynamic>>> getNotificationPreferences() async {
    return _notificationService.getNotificationPreferences();
  }

  Future<ApiResponse<Map<String, dynamic>>> updateNotificationPreferences(
    Map<String, dynamic> preferences,
  ) async {
    return _notificationService.updateNotificationPreferences(preferences);
  }
}
