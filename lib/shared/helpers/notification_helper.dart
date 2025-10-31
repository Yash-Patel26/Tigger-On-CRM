import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationHelper {
  // Create lead-related notifications
  static Future<Notification> createLeadAssignedNotification({
    required String userId,
    required String leadId,
    required String customerName,
    required String projectName,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    return NotificationService.createLeadNotification(
      userId: userId,
      leadId: leadId,
      customerName: customerName,
      projectName: projectName,
      priority: priority,
    );
  }

  static Future<Notification> createLeadStatusChangedNotification({
    required String userId,
    required String leadId,
    required String customerName,
    required String oldStatus,
    required String newStatus,
  }) async {
    return NotificationService.createNotification(
      title: 'Lead Status Updated',
      message:
          'Lead status for $customerName changed from $oldStatus to $newStatus',
      type: NotificationType.lead,
      priority: NotificationPriority.medium,
      userId: userId,
      relatedId: leadId,
      relatedType: 'lead',
      actionUrl: '/leads/$leadId',
      data: {
        'lead_id': leadId,
        'customer_name': customerName,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }

  static Future<Notification> createLeadFollowUpReminderNotification({
    required String userId,
    required String leadId,
    required String customerName,
    required DateTime followUpDate,
  }) async {
    return NotificationService.createReminderNotification(
      userId: userId,
      title: 'Follow-up Reminder',
      message:
          'Follow-up reminder for $customerName scheduled for ${followUpDate.day}/${followUpDate.month}/${followUpDate.year}',
      relatedId: leadId,
      relatedType: 'lead',
      actionUrl: '/leads/$leadId',
      priority: NotificationPriority.high,
      data: {
        'lead_id': leadId,
        'customer_name': customerName,
        'follow_up_date': followUpDate.toIso8601String(),
      },
    );
  }

  // Create site visit-related notifications
  static Future<Notification> createSiteVisitScheduledNotification({
    required String userId,
    required String siteVisitId,
    required String customerName,
    required String projectName,
    required DateTime visitTime,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    return NotificationService.createSiteVisitNotification(
      userId: userId,
      siteVisitId: siteVisitId,
      customerName: customerName,
      projectName: projectName,
      visitTime: visitTime,
      priority: priority,
    );
  }

  static Future<Notification> createSiteVisitCompletedNotification({
    required String userId,
    required String siteVisitId,
    required String customerName,
    required String projectName,
  }) async {
    return NotificationService.createNotification(
      title: 'Site Visit Completed',
      message:
          'Site visit for $customerName at $projectName has been completed',
      type: NotificationType.siteVisit,
      priority: NotificationPriority.medium,
      userId: userId,
      relatedId: siteVisitId,
      relatedType: 'site_visit',
      actionUrl: '/site-visits/$siteVisitId',
      data: {
        'site_visit_id': siteVisitId,
        'customer_name': customerName,
        'project_name': projectName,
      },
    );
  }

  static Future<Notification> createSiteVisitCancelledNotification({
    required String userId,
    required String siteVisitId,
    required String customerName,
    required String projectName,
    String? reason,
  }) async {
    return NotificationService.createNotification(
      title: 'Site Visit Cancelled',
      message:
          'Site visit for $customerName at $projectName has been cancelled${reason != null ? ': $reason' : ''}',
      type: NotificationType.siteVisit,
      priority: NotificationPriority.medium,
      userId: userId,
      relatedId: siteVisitId,
      relatedType: 'site_visit',
      actionUrl: '/site-visits/$siteVisitId',
      data: {
        'site_visit_id': siteVisitId,
        'customer_name': customerName,
        'project_name': projectName,
        'reason': reason,
      },
    );
  }

  // Create booking-related notifications
  static Future<Notification> createBookingConfirmedNotification({
    required String userId,
    required String bookingId,
    required String customerName,
    required String projectName,
    required double amount,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    return NotificationService.createBookingNotification(
      userId: userId,
      bookingId: bookingId,
      customerName: customerName,
      projectName: projectName,
      amount: amount,
      priority: priority,
    );
  }

  static Future<Notification> createBookingCancelledNotification({
    required String userId,
    required String bookingId,
    required String customerName,
    required String projectName,
    String? reason,
  }) async {
    return NotificationService.createNotification(
      title: 'Booking Cancelled',
      message:
          'Booking for $customerName at $projectName has been cancelled${reason != null ? ': $reason' : ''}',
      type: NotificationType.booking,
      priority: NotificationPriority.high,
      userId: userId,
      relatedId: bookingId,
      relatedType: 'booking',
      actionUrl: '/bookings/$bookingId',
      data: {
        'booking_id': bookingId,
        'customer_name': customerName,
        'project_name': projectName,
        'reason': reason,
      },
    );
  }

  static Future<Notification> createPaymentReceivedNotification({
    required String userId,
    required String bookingId,
    required String customerName,
    required double amount,
    required String paymentMode,
  }) async {
    return NotificationService.createNotification(
      title: 'Payment Received',
      message:
          'Payment of ₹${amount.toStringAsFixed(0)} received from $customerName via $paymentMode',
      type: NotificationType.booking,
      priority: NotificationPriority.high,
      userId: userId,
      relatedId: bookingId,
      relatedType: 'booking',
      actionUrl: '/bookings/$bookingId',
      data: {
        'booking_id': bookingId,
        'customer_name': customerName,
        'amount': amount,
        'payment_mode': paymentMode,
      },
    );
  }

  // Create ticket-related notifications
  static Future<Notification> createTicketCreatedNotification({
    required String userId,
    required String ticketId,
    required String issueTitle,
    required String contactName,
    NotificationPriority priority = NotificationPriority.medium,
  }) async {
    return NotificationService.createTicketNotification(
      userId: userId,
      ticketId: ticketId,
      issueTitle: issueTitle,
      contactName: contactName,
      priority: priority,
    );
  }

  static Future<Notification> createTicketResolvedNotification({
    required String userId,
    required String ticketId,
    required String issueTitle,
    required String contactName,
  }) async {
    return NotificationService.createNotification(
      title: 'Ticket Resolved',
      message: 'Ticket from $contactName: $issueTitle has been resolved',
      type: NotificationType.ticket,
      priority: NotificationPriority.medium,
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

  static Future<Notification> createTicketEscalatedNotification({
    required String userId,
    required String ticketId,
    required String issueTitle,
    required String contactName,
    required String escalatedTo,
  }) async {
    return NotificationService.createNotification(
      title: 'Ticket Escalated',
      message:
          'Ticket from $contactName: $issueTitle has been escalated to $escalatedTo',
      type: NotificationType.ticket,
      priority: NotificationPriority.high,
      userId: userId,
      relatedId: ticketId,
      relatedType: 'ticket',
      actionUrl: '/tickets/$ticketId',
      data: {
        'ticket_id': ticketId,
        'issue_title': issueTitle,
        'contact_name': contactName,
        'escalated_to': escalatedTo,
      },
    );
  }

  // Create system notifications
  static Future<Notification> createSystemMaintenanceNotification({
    required String title,
    required String message,
    required DateTime maintenanceStart,
    required DateTime maintenanceEnd,
    String? userId,
  }) async {
    return NotificationService.createSystemNotification(
      title: title,
      message: message,
      userId: userId,
      priority: NotificationPriority.medium,
      data: {
        'maintenance_start': maintenanceStart.toIso8601String(),
        'maintenance_end': maintenanceEnd.toIso8601String(),
      },
    );
  }

  static Future<Notification> createSystemUpdateNotification({
    required String version,
    required List<String> features,
    String? userId,
  }) async {
    return NotificationService.createSystemNotification(
      title: 'System Update Available',
      message:
          'New version $version is available with ${features.length} new features',
      userId: userId,
      priority: NotificationPriority.low,
      data: {'version': version, 'features': features},
    );
  }

  // Create alert notifications
  static Future<Notification> createHighPriorityAlertNotification({
    required String title,
    required String message,
    String? userId,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    return NotificationService.createAlertNotification(
      title: title,
      message: message,
      userId: userId,
      priority: NotificationPriority.urgent,
      relatedId: relatedId,
      relatedType: relatedType,
      actionUrl: actionUrl,
      data: data,
    );
  }

  static Future<Notification> createDeadlineAlertNotification({
    required String userId,
    required String title,
    required String message,
    required DateTime deadline,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
  }) async {
    return NotificationService.createAlertNotification(
      title: title,
      message: message,
      userId: userId,
      priority: NotificationPriority.urgent,
      relatedId: relatedId,
      relatedType: relatedType,
      actionUrl: actionUrl,
      data: {'deadline': deadline.toIso8601String(), 'is_deadline': true},
    );
  }

  // Create reminder notifications
  static Future<Notification> createTaskReminderNotification({
    required String userId,
    required String taskTitle,
    required DateTime dueDate,
    String? taskId,
  }) async {
    return NotificationService.createReminderNotification(
      userId: userId,
      title: 'Task Reminder',
      message:
          'Task "$taskTitle" is due on ${dueDate.day}/${dueDate.month}/${dueDate.year}',
      relatedId: taskId,
      relatedType: 'task',
      actionUrl: taskId != null ? '/tasks/$taskId' : null,
      priority: NotificationPriority.high,
      data: {'task_title': taskTitle, 'due_date': dueDate.toIso8601String()},
    );
  }

  static Future<Notification> createMeetingReminderNotification({
    required String userId,
    required String meetingTitle,
    required DateTime meetingTime,
    String? meetingId,
  }) async {
    return NotificationService.createReminderNotification(
      userId: userId,
      title: 'Meeting Reminder',
      message:
          'Meeting "$meetingTitle" is scheduled for ${meetingTime.day}/${meetingTime.month}/${meetingTime.year} at ${meetingTime.hour}:${meetingTime.minute.toString().padLeft(2, '0')}',
      relatedId: meetingId,
      relatedType: 'meeting',
      actionUrl: meetingId != null ? '/meetings/$meetingId' : null,
      priority: NotificationPriority.medium,
      data: {
        'meeting_title': meetingTitle,
        'meeting_time': meetingTime.toIso8601String(),
      },
    );
  }

  /// Send notifications for an event to all active admin/head users.
  static Future<void> notifyAdminsAndHeadsAboutEvent({
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    final client = Supabase.instance.client;
    final List<dynamic> adminsAndHeads = await client
        .from('users')
        .select('id')
        .or('role.eq.admin,role.eq.head')
        .eq('is_active', true);
    for (final user in adminsAndHeads) {
      await NotificationService.createNotification(
        title: title,
        message: message,
        type: type,
        priority: priority,
        userId: user['id'] as String,
        relatedId: relatedId,
        relatedType: relatedType,
        actionUrl: actionUrl,
        data: data,
      );
    }
  }

  // Utility methods
  static String formatAmount(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
