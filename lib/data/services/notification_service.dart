import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new notification
  static Future<Notification> createNotification({
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
      final notificationData = {
        'title': title,
        'message': message,
        'type': type.name,
        'priority': priority.name,
        'status': NotificationStatus.unread.name,
        'user_id': userId,
        'related_id': relatedId,
        'related_type': relatedType,
        'action_url': actionUrl,
        'data': data,
      };

      final response = await _supabase
          .from('notifications')
          .insert(notificationData)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get notifications for a specific user
  static Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
    bool sortByPriority = true,
  }) async {
    try {
      var query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      // Apply ordering, limit, and range
      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;

      List<Notification> notifications = response
          .map<Notification>((json) => Notification.fromJson(json))
          .toList();

      // Sort by priority if requested
      if (sortByPriority) {
        notifications.sort(
          (a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder),
        );
      }

      return notifications;
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Get all notifications (for admin/system use)
  static Future<List<Notification>> getAllNotifications({
    NotificationStatus? status,
    NotificationType? type,
    NotificationPriority? priority,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase.from('notifications').select();

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      // Apply ordering, limit, and range
      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;

      return response
          .map<Notification>((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all notifications: $e');
    }
  }

  // Mark notification as read
  static Future<Notification> markAsRead(String notificationId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .update({
            'status': NotificationStatus.read.name,
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark notification as unread
  static Future<Notification> markAsUnread(String notificationId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .update({
            'status': NotificationStatus.unread.name,
            'is_read': false,
            'read_at': null,
          })
          .eq('id', notificationId)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  // Archive notification
  static Future<Notification> archiveNotification(String notificationId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .update({
            'status': NotificationStatus.archived.name,
            'is_archived': true,
            'archived_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to archive notification: $e');
    }
  }

  // Unarchive notification
  static Future<Notification> unarchiveNotification(
    String notificationId,
  ) async {
    try {
      final response = await _supabase
          .from('notifications')
          .update({
            'status': NotificationStatus.unread.name,
            'is_archived': false,
            'archived_at': null,
          })
          .eq('id', notificationId)
          .select()
          .single();

      return Notification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to unarchive notification: $e');
    }
  }

  // Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'status': NotificationStatus.read.name,
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', NotificationStatus.unread.name);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get notification count for a user
  static Future<Map<String, int>> getNotificationCounts(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('status, type')
          .eq('user_id', userId);

      Map<String, int> counts = {
        'total': response.length,
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

      for (var notification in response) {
        // Count by status
        switch (notification['status']) {
          case 'unread':
            counts['unread'] = (counts['unread'] ?? 0) + 1;
            break;
          case 'read':
            counts['read'] = (counts['read'] ?? 0) + 1;
            break;
          case 'archived':
            counts['archived'] = (counts['archived'] ?? 0) + 1;
            break;
        }

        // Count by type
        final type = notification['type'] as String;
        if (counts.containsKey(type)) {
          counts[type] = (counts[type] ?? 0) + 1;
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get notification counts: $e');
    }
  }

  // Subscribe to real-time notifications for a user
  static Stream<List<Notification>> subscribeToUserNotifications(
    String userId,
  ) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map<Notification>((json) => Notification.fromJson(json))
              .toList(),
        );
  }

  // Subscribe to all notifications (for admin/system use)
  static Stream<List<Notification>> subscribeToAllNotifications() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data
              .map<Notification>((json) => Notification.fromJson(json))
              .toList(),
        );
  }

  // Create notification templates for common scenarios
  static Future<Notification> createLeadNotification({
    required String userId,
    required String leadId,
    required String customerName,
    required String projectName,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    return createNotification(
      title: 'New Lead Assignment',
      message:
          'A new lead has been assigned to you: $customerName for $projectName',
      type: NotificationType.lead,
      priority: priority,
      userId: userId,
      relatedId: leadId,
      relatedType: 'lead',
      actionUrl: '/leads/$leadId',
      data: {
        'lead_id': leadId,
        'customer_name': customerName,
        'project_name': projectName,
      },
    );
  }

  static Future<Notification> createSiteVisitNotification({
    required String userId,
    required String siteVisitId,
    required String customerName,
    required String projectName,
    required DateTime visitTime,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    return createNotification(
      title: 'Site Visit Scheduled',
      message:
          'Site visit scheduled for $customerName at $projectName on ${visitTime.day}/${visitTime.month}/${visitTime.year} at ${visitTime.hour}:${visitTime.minute.toString().padLeft(2, '0')}',
      type: NotificationType.siteVisit,
      priority: priority,
      userId: userId,
      relatedId: siteVisitId,
      relatedType: 'site_visit',
      actionUrl: '/site-visits/$siteVisitId',
      data: {
        'site_visit_id': siteVisitId,
        'customer_name': customerName,
        'project_name': projectName,
        'visit_time': visitTime.toIso8601String(),
      },
    );
  }

  static Future<Notification> createBookingNotification({
    required String userId,
    required String bookingId,
    required String customerName,
    required String projectName,
    required double amount,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    return createNotification(
      title: 'Booking Confirmed',
      message:
          'Booking confirmed for $customerName at $projectName - Amount: ₹${amount.toStringAsFixed(0)}',
      type: NotificationType.booking,
      priority: priority,
      userId: userId,
      relatedId: bookingId,
      relatedType: 'booking',
      actionUrl: '/bookings/$bookingId',
      data: {
        'booking_id': bookingId,
        'customer_name': customerName,
        'project_name': projectName,
        'amount': amount,
      },
    );
  }

  static Future<Notification> createTicketNotification({
    required String userId,
    required String ticketId,
    required String issueTitle,
    required String contactName,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    return createNotification(
      title: 'New Support Ticket',
      message: 'New support ticket from $contactName: $issueTitle',
      type: NotificationType.ticket,
      priority: priority,
      userId: userId,
      relatedId: ticketId,
      relatedType: 'ticket',
      actionUrl: '/tickets/$ticketId',
      data: {
        'ticket_id': ticketId,
        'issue_title': issueTitle,
        'contact_name': contactName,
      },
    );
  }

  static Future<Notification> createSystemNotification({
    required String title,
    required String message,
    String? userId,
    NotificationPriority priority = NotificationPriority.low,
    Map<String, dynamic>? data,
  }) async {
    return createNotification(
      title: title,
      message: message,
      type: NotificationType.system,
      priority: priority,
      userId: userId,
      relatedType: 'system',
      data: data,
    );
  }

  static Future<Notification> createReminderNotification({
    required String userId,
    required String title,
    required String message,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
  }) async {
    return createNotification(
      title: title,
      message: message,
      type: NotificationType.reminder,
      priority: priority,
      userId: userId,
      relatedId: relatedId,
      relatedType: relatedType,
      actionUrl: actionUrl,
      data: data,
    );
  }

  static Future<Notification> createAlertNotification({
    required String title,
    required String message,
    String? userId,
    NotificationPriority priority = NotificationPriority.high,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    return createNotification(
      title: title,
      message: message,
      type: NotificationType.alert,
      priority: priority,
      userId: userId,
      relatedId: relatedId,
      relatedType: relatedType,
      actionUrl: actionUrl,
      data: data,
    );
  }
}
