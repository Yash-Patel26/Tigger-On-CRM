import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'notification_service.dart';
import '../models/notification_model.dart';

/// Service to handle follow-up date notifications for leads
class FollowUpNotificationService {
  static final supabase.SupabaseClient _client =
      supabase.Supabase.instance.client;

  /// Check for leads with follow-up dates today and create notifications
  static Future<void> checkAndCreateFollowUpNotifications() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Query leads with follow-up dates today
      final response = await _client
          .from('leads')
          .select('id, customer_name, next_follow_up_date, assigned_to')
          .gte('next_follow_up_date', startOfDay.toIso8601String())
          .lte('next_follow_up_date', endOfDay.toIso8601String())
          .not('assigned_to', 'is', null);

      if (response.isEmpty) {
        return;
      }

      final List<Map<String, dynamic>> leads = List<Map<String, dynamic>>.from(
        response,
      );

      // Create notifications for each lead
      for (final lead in leads) {
        final assignedTo = lead['assigned_to'] as String?;
        if (assignedTo == null) continue;

        final customerName = lead['customer_name'] as String? ?? 'Customer';
        final leadId = lead['id'] as String;
        final followUpDate = DateTime.parse(
          lead['next_follow_up_date'] as String,
        );

        // Check if notification already exists for today
        final existingNotifications = await _client
            .from('notifications')
            .select('id')
            .eq('user_id', assignedTo)
            .eq('related_id', leadId)
            .eq('related_type', 'lead')
            .eq('type', 'reminder')
            .gte('created_at', startOfDay.toIso8601String())
            .lte('created_at', endOfDay.toIso8601String())
            .maybeSingle();

        // Only create notification if it doesn't exist
        if (existingNotifications == null) {
          await NotificationService.createReminderNotification(
            userId: assignedTo,
            title: 'Follow-up Reminder',
            message: 'Follow-up reminder for $customerName scheduled for today',
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
      }
    } catch (e) {
      print('Error checking follow-up notifications: $e');
    }
  }

  /// Check for leads with follow-up dates tomorrow and create notifications
  static Future<void> checkAndCreateTomorrowFollowUpNotifications() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final endOfDay = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        23,
        59,
        59,
      );

      // Query leads with follow-up dates tomorrow
      final response = await _client
          .from('leads')
          .select('id, customer_name, next_follow_up_date, assigned_to')
          .gte('next_follow_up_date', startOfDay.toIso8601String())
          .lte('next_follow_up_date', endOfDay.toIso8601String())
          .not('assigned_to', 'is', null);

      if (response.isEmpty) {
        return;
      }

      final List<Map<String, dynamic>> leads = List<Map<String, dynamic>>.from(
        response,
      );

      // Create notifications for each lead
      for (final lead in leads) {
        final assignedTo = lead['assigned_to'] as String?;
        if (assignedTo == null) continue;

        final customerName = lead['customer_name'] as String? ?? 'Customer';
        final leadId = lead['id'] as String;
        final followUpDate = DateTime.parse(
          lead['next_follow_up_date'] as String,
        );

        // Check if notification already exists for tomorrow
        final existingNotifications = await _client
            .from('notifications')
            .select('id')
            .eq('user_id', assignedTo)
            .eq('related_id', leadId)
            .eq('related_type', 'lead')
            .eq('type', 'reminder')
            .gte('created_at', DateTime.now().toIso8601String())
            .maybeSingle();

        // Only create notification if it doesn't exist
        if (existingNotifications == null) {
          await NotificationService.createReminderNotification(
            userId: assignedTo,
            title: 'Follow-up Reminder',
            message:
                'Follow-up reminder for $customerName scheduled for tomorrow',
            relatedId: leadId,
            relatedType: 'lead',
            actionUrl: '/leads/$leadId',
            priority: NotificationPriority.medium,
            data: {
              'lead_id': leadId,
              'customer_name': customerName,
              'follow_up_date': followUpDate.toIso8601String(),
            },
          );
        }
      }
    } catch (e) {
      print('Error checking tomorrow follow-up notifications: $e');
    }
  }

  /// Schedule periodic checks for follow-up notifications
  /// This should be called when the app starts
  static void startPeriodicCheck() {
    // Check immediately
    checkAndCreateFollowUpNotifications();
    checkAndCreateTomorrowFollowUpNotifications();

    // Check every hour
    Future.delayed(const Duration(hours: 1), () {
      startPeriodicCheck();
    });
  }
}
