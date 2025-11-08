import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class DatabaseServiceMasters {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Helper function to convert performedBy to UUID
  static String _convertToUuid(String performedBy) {
    if (performedBy == 'system') {
      return '00000000-0000-0000-0000-000000000000';
    }

    // Validate that performedBy is a valid UUID
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(performedBy)) {
      return performedBy;
    } else {
      // If not a valid UUID, use system UUID
      return '00000000-0000-0000-0000-000000000000';
    }
  }

  // Lead Status Methods
  static Future<List<Map<String, dynamic>>> getLeadStatuses() async {
    try {
      final response = await _client
          .from('lead_status_master')
          .select('*')
          .eq('is_active', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch lead statuses: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeadSubStatuses(
    String statusId,
  ) async {
    try {
      final response = await _client
          .from('lead_sub_status_master')
          .select('*')
          .eq('is_active', true)
          .eq('status_id', statusId)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch lead sub statuses: $e');
    }
  }

  // Property Categories
  static Future<List<Map<String, dynamic>>> getPropertyCategories() async {
    try {
      final response = await _client
          .from('property_categories')
          .select('*')
          .eq('is_active', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch property categories: $e');
    }
  }

  // Property Types
  static Future<List<Map<String, dynamic>>> getPropertyTypes() async {
    try {
      final response = await _client
          .from('property_types_master')
          .select('*')
          .eq('is_active', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch property types: $e');
    }
  }

  // Visit Modes
  static Future<List<Map<String, dynamic>>> getVisitModes() async {
    try {
      final response = await _client
          .from('visit_modes_master')
          .select('*')
          .eq('is_active', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch visit modes: $e');
    }
  }

  // Lead Activities
  static Future<List<LeadActivity>> getLeadActivities({
    required String leadId,
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('lead_activities')
          .select('*')
          .eq('lead_id', leadId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((json) => LeadActivity.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead activities: $e');
    }
  }

  // Disposition Methods
  static Future<void> createDisposition({
    required String leadId,
    required String mainDispositionId,
    required String subDispositionId,
    required DateTime disposedAt,
    required String disposedBy,
    required String disposedFrom,
    String? remarks,
    String? performedBy,
    String? performedByName,
  }) async {
    try {
      await _client.from('lead_dispositions').insert({
        'lead_id': leadId,
        'main_disposition_id': mainDispositionId,
        'sub_disposition_id': subDispositionId,
        'disposed_at': disposedAt.toIso8601String(),
        'disposed_by': disposedBy,
        'disposed_from': disposedFrom,
        'remarks': remarks,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
      });
    } catch (e) {
      throw Exception('Failed to create disposition: $e');
    }
  }

  static Future<void> logDispositionActivity({
    required String leadId,
    required String mainDispositionName,
    required String subDispositionName,
    required String disposedBy,
    required String performedBy,
    required String performedByName,
    String? remarks,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'disposition_change',
        'action': 'disposition_applied',
        'description':
            'Disposition applied: $mainDispositionName - $subDispositionName',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {
          'main_disposition': mainDispositionName,
          'sub_disposition': subDispositionName,
          'disposed_by': disposedBy,
          'remarks': remarks,
        },
      });
    } catch (e) {
      throw Exception('Failed to log disposition activity: $e');
    }
  }

  static Future<void> createDispositionFollowUp({
    required String leadId,
    required String mainDispositionName,
    required String subDispositionName,
    required String performedBy,
    required String performedByName,
    String? assignedTo,
    String? assignedToName,
  }) async {
    try {
      // Update lead follow-up fields instead of creating a task
      final DateTime now = DateTime.now();
      final DateTime next = now.add(const Duration(days: 1));

      // Atomically increment follow_up_count using optimistic concurrency (CAS)
      // Try a few times in case of concurrent updates
      int attempts = 0;
      while (true) {
        attempts += 1;
        int currentCount = 0;
        try {
          final existing = await _client
              .from('leads')
              .select('follow_up_count')
              .eq('id', leadId)
              .maybeSingle();
          if (existing != null) {
            currentCount = (existing['follow_up_count'] as int?) ?? 0;
          }
        } catch (_) {}

        // Attempt conditional update: only succeed if count hasn't changed
        final List<dynamic> updated = await _client
            .from('leads')
            .update({
              'last_follow_up_date': now.toIso8601String(),
              'next_follow_up_date': next.toIso8601String(),
              'follow_up_count': currentCount + 1,
              if (assignedTo != null) 'assigned_to': assignedTo,
              if (assignedToName != null) 'assigned_to_name': assignedToName,
              'updated_by': _convertToUuid(performedBy),
              'updated_by_name': performedByName,
            })
            .eq('id', leadId)
            .eq('follow_up_count', currentCount)
            .select('id');

        if (updated.isNotEmpty) {
          break; // success
        }
        if (attempts >= 3) {
          throw Exception(
            'Failed to update follow up count due to concurrency',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }

      // Log an activity for auditing
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'follow_up',
        'action': 'scheduled',
        'description':
            'Follow-up scheduled from disposition: $mainDispositionName - $subDispositionName',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {
          'next_follow_up_date': next.toIso8601String(),
          if (assignedTo != null) 'assigned_to': assignedTo,
          if (assignedToName != null) 'assigned_to_name': assignedToName,
        },
      });

      // Notify the assignee of this lead about the newly scheduled follow-up
      try {
        // Resolve assignee (prefer explicit assignedTo parameter; otherwise read from DB)
        String? assigneeId = assignedTo;
        String? customerName;
        if (assigneeId == null || assigneeId.isEmpty) {
          final dynamic leadRow = await _client
              .from('leads')
              .select('assigned_to, customer_name')
              .eq('id', leadId)
              .maybeSingle();
          if (leadRow != null) {
            assigneeId = (leadRow['assigned_to'] as String?);
            customerName = (leadRow['customer_name'] as String?);
          }
        } else {
          // Also fetch customer name when available
          try {
            final dynamic leadRow = await _client
                .from('leads')
                .select('customer_name')
                .eq('id', leadId)
                .maybeSingle();
            if (leadRow != null) {
              customerName = (leadRow['customer_name'] as String?);
            }
          } catch (_) {}
        }

        if (assigneeId != null && assigneeId.isNotEmpty) {
          await NotificationService.createReminderNotification(
            userId: assigneeId,
            title: 'Follow-up Reminder',
            message:
                'Follow-up reminder for \'${customerName ?? 'lead'}\' scheduled for '
                '${next.day}/${next.month}/${next.year}',
            relatedId: leadId,
            relatedType: 'lead',
            actionUrl: '/leads/$leadId',
            priority: NotificationPriority.high,
            data: {
              'lead_id': leadId,
              'next_follow_up_date': next.toIso8601String(),
              'performed_by': _convertToUuid(performedBy),
              'performed_by_name': performedByName,
              'disposition': <String, String>{
                'main': mainDispositionName,
                'sub': subDispositionName,
              },
            },
          );
        }
      } catch (_) {
        // Best-effort notification; do not fail the flow
      }

      // Notify admin and head users about the follow-up
      try {
        final List<dynamic> recipients = await _client
            .from('users')
            .select('id, name, role, is_active')
            .or('role.eq.admin,role.eq.head')
            .eq('is_active', true);

        if (recipients.isNotEmpty) {
          final String title = 'Lead Follow-up Scheduled';
          final String message =
              'Follow-up set for lead $leadId by $performedByName: $mainDispositionName - $subDispositionName';

          final List<Map<String, dynamic>> notifRows = recipients
              .map<Map<String, dynamic>>(
                (dynamic u) => <String, dynamic>{
                  'title': title,
                  'message': message,
                  'type': 'reminder',
                  'priority': 'medium',
                  'status': 'unread',
                  'user_id': u['id'],
                  'related_id': leadId,
                  'related_type': 'lead',
                  'data': <String, dynamic>{
                    'lead_id': leadId,
                    'next_follow_up_date': next.toIso8601String(),
                    'performed_by': _convertToUuid(performedBy),
                    'performed_by_name': performedByName,
                    if (assignedTo != null) 'assigned_to': assignedTo,
                    if (assignedToName != null)
                      'assigned_to_name': assignedToName,
                    'disposition': <String, String>{
                      'main': mainDispositionName,
                      'sub': subDispositionName,
                    },
                  },
                },
              )
              .toList();

          // Bulk insert notifications for recipients
          await _client.from('notifications').insert(notifRows);
        }
      } catch (e) {
        // Best-effort notifications; do not fail the follow-up creation
      }
    } catch (e) {
      throw Exception('Failed to create disposition follow-up: $e');
    }
  }

  // Lead Status Change Logging
  static Future<void> logLeadStatusChange({
    required String leadId,
    required String oldStatus,
    required String newStatus,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'status_change',
        'action': 'status_updated',
        'description': 'Lead status changed from $oldStatus to $newStatus',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'old_status': oldStatus, 'new_status': newStatus},
      });
    } catch (e) {
      throw Exception('Failed to log lead status change: $e');
    }
  }

  // Lead Assignment Logging
  static Future<void> logLeadAssignment({
    required String leadId,
    required String? oldAssignee,
    required String? newAssignee,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'assignment_change',
        'action': 'lead_assigned',
        'description':
            'Lead assigned from ${oldAssignee ?? 'Unassigned'} to ${newAssignee ?? 'Unassigned'}',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'old_assignee': oldAssignee, 'new_assignee': newAssignee},
      });
    } catch (e) {
      throw Exception('Failed to log lead assignment: $e');
    }
  }

  // Site Visit Logging
  static Future<void> logSiteVisitScheduled({
    required String leadId,
    required String siteVisitId,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'site_visit',
        'action': 'site_visit_scheduled',
        'description': 'Site visit scheduled',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'site_visit_id': siteVisitId},
      });
    } catch (e) {
      throw Exception('Failed to log site visit scheduled: $e');
    }
  }

  // Task Creation Logging
  static Future<void> logTaskCreated({
    required String leadId,
    required String taskId,
    required String taskTitle,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'task',
        'action': 'task_created',
        'description': 'Task created: $taskTitle',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'task_id': taskId, 'task_title': taskTitle},
      });
    } catch (e) {
      throw Exception('Failed to log task created: $e');
    }
  }

  // Communication Activity Logging
  static Future<void> logCallInitiated({
    required String leadId,
    required String phoneNumber,
    required String performedBy,
    required String performedByName,
    String? recordingUrl,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'call_initiated',
        'action': 'call_initiated',
        'description': 'Call initiated to $phoneNumber',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {
          'phone_number': phoneNumber,
          // Also include common key 'phone' for consumers expecting this
          'phone': phoneNumber,
          if (recordingUrl != null) 'recording_url': recordingUrl,
        },
      });
    } catch (e) {
      throw Exception('Failed to log call initiated: $e');
    }
  }

  static Future<void> logEmailInitiated({
    required String leadId,
    required String emailAddress,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'email_initiated',
        'action': 'email_initiated',
        'description': 'Email initiated to $emailAddress',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'email_address': emailAddress},
      });
    } catch (e) {
      throw Exception('Failed to log email initiated: $e');
    }
  }

  static Future<void> logMessageInitiated({
    required String leadId,
    required String phoneNumber,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': 'message_initiated',
        'action': 'message_initiated',
        'description': 'SMS initiated to $phoneNumber',
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'phone_number': phoneNumber},
      });
    } catch (e) {
      throw Exception('Failed to log message initiated: $e');
    }
  }

  static Future<void> logWhatsAppInitiated({
    required String leadId,
    required String phoneNumber,
    required String performedBy,
    required String performedByName,
    bool isOffline = false,
  }) async {
    try {
      final type = isOffline
          ? 'offline_whatsapp_initiated'
          : 'whatsapp_initiated';
      final action = isOffline
          ? 'offline_whatsapp_initiated'
          : 'whatsapp_initiated';
      final description = isOffline
          ? 'Offline WhatsApp initiated to $phoneNumber'
          : 'WhatsApp initiated to $phoneNumber';

      await _client.from('lead_activities').insert({
        'lead_id': leadId,
        'type': type,
        'action': action,
        'description': description,
        'performed_by': _convertToUuid(performedBy),
        'performed_by_name': performedByName,
        'metadata': {'phone_number': phoneNumber, 'is_offline': isOffline},
      });
    } catch (e) {
      throw Exception('Failed to log WhatsApp initiated: $e');
    }
  }

  /// Populate sample data for demonstration purposes
  static Future<void> populateSampleData({
    required String leadId,
    String? customerName,
    String? phoneNumber,
    String? emailAddress,
  }) async {
    try {
      print('Starting to populate sample data for lead: $leadId');
      print(
        'Customer: $customerName, Phone: $phoneNumber, Email: $emailAddress',
      );

      final currentUser = _client.auth.currentUser;
      final String userId = _convertToUuid(currentUser?.id ?? 'system');
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      print('User ID: $userId, User Name: $userName');

      // Generate sample data for all activity types
      final List<Map<String, dynamic>> sampleActivities = [
        // Call activities
        {
          'lead_id': leadId,
          'type': 'call_initiated',
          'action': 'call_initiated',
          'description': 'Call initiated to ${phoneNumber ?? 'customer'}',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'phone_number': phoneNumber ?? '+91-9876543210',
            'duration':
                '${(3 + (DateTime.now().millisecond % 10))}:${(10 + (DateTime.now().second % 50)).toString().padLeft(2, '0')}',
            'status': [
              'completed',
              'missed',
              'busy',
            ][DateTime.now().millisecond % 3],
            'recording_url': DateTime.now().millisecond % 2 == 0
                ? 'https://example.com/recordings/call_${DateTime.now().millisecondsSinceEpoch}.mp3'
                : null,
          },
        },
        // Email activities
        {
          'lead_id': leadId,
          'type': 'email_initiated',
          'action': 'email_initiated',
          'description':
              'Email initiated to ${emailAddress ?? 'customer@example.com'}',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'email_address': emailAddress ?? 'customer@example.com',
            'subject':
                'Property Investment Opportunity - ${customerName ?? 'Customer'}',
            'message':
                'Dear ${customerName ?? 'Customer'}, I wanted to follow up on our conversation about the new property investment opportunity...',
          },
        },
        // SMS activities
        {
          'lead_id': leadId,
          'type': 'message_initiated',
          'action': 'message_initiated',
          'description': 'SMS initiated to ${phoneNumber ?? '+91-9876543210'}',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'phone_number': phoneNumber ?? '+91-9876543210',
            'message':
                'Hi ${customerName ?? 'Customer'}, this is $userName from Tigger. I wanted to follow up on our property discussion. Please call me back at your convenience.',
          },
        },
        // WhatsApp activities
        {
          'lead_id': leadId,
          'type': 'whatsapp_initiated',
          'action': 'whatsapp_initiated',
          'description':
              'WhatsApp initiated to ${phoneNumber ?? '+91-9876543210'}',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'phone_number': phoneNumber ?? '+91-9876543210',
            'message':
                'Hi ${customerName ?? 'Customer'}! 👋 I wanted to share some exciting property options with you. When would be a good time to discuss?',
          },
        },
        // Offline WhatsApp activities
        {
          'lead_id': leadId,
          'type': 'offline_whatsapp_initiated',
          'action': 'offline_whatsapp_initiated',
          'description':
              'Offline WhatsApp initiated to ${phoneNumber ?? '+91-9876543210'}',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'phone_number': phoneNumber ?? '+91-9876543210',
            'message':
                'Hi ${customerName ?? 'Customer'}! I have some great news about the property pricing. Please check your WhatsApp when you get a chance.',
            'is_offline': true,
          },
        },
        // Assignment activities
        {
          'lead_id': leadId,
          'type': 'assigned',
          'action': 'assigned',
          'description': 'Lead assigned to sales team',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'assigned_to':
                'sales_team_${DateTime.now().millisecondsSinceEpoch % 1000}',
            'assigned_to_name':
                'Sales Team ${['Alpha', 'Beta', 'Gamma'][DateTime.now().millisecond % 3]}',
            'reason': 'High priority lead requiring immediate attention',
          },
        },
        // Site visit activities
        {
          'lead_id': leadId,
          'type': 'site_visit',
          'action': 'scheduled',
          'description': 'Site visit scheduled for property viewing',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'visitor_name': customerName ?? 'Customer',
            'visitor_email': emailAddress ?? 'customer@example.com',
            'project': [
              'Luxury Apartments Phase 2',
              'Garden Villas',
              'Commercial Complex',
            ][DateTime.now().millisecond % 3],
            'visit_date': DateTime.now()
                .add(Duration(days: 1 + (DateTime.now().millisecond % 7)))
                .toIso8601String()
                .split('T')[0],
            'visit_time':
                '${14 + (DateTime.now().millisecond % 6)}:${(DateTime.now().second % 60).toString().padLeft(2, '0')}',
          },
        },
        // Disposition activities
        {
          'lead_id': leadId,
          'type': 'disposition_change',
          'action': 'disposition_applied',
          'description': 'Disposition applied: Hot Lead - Interested',
          'performed_by': userId,
          'performed_by_name': userName,
          'metadata': {
            'old_values': {'sub_status': 'newLead'},
            'new_values': {'sub_status': 'interested'},
            'main_disposition': 'Hot Lead',
            'sub_disposition': 'Interested',
            'remarks':
                'Customer showed strong interest during call, wants to see property',
            'disposed_by': 'agent',
          },
        },
      ];

      // Insert all sample activities
      print('Inserting ${sampleActivities.length} sample activities...');
      await _client.from('lead_activities').insert(sampleActivities);
      print('Sample data inserted successfully!');
    } catch (e) {
      print('Error populating sample data: $e');
      throw Exception('Failed to populate sample data: $e');
    }
  }

  /// Check if lead has activities and populate if empty
  static Future<void> ensureLeadHasActivities({
    required String leadId,
    String? customerName,
    String? phoneNumber,
    String? emailAddress,
  }) async {
    try {
      print('Checking activities for lead: $leadId');
      // Check if lead already has activities
      final response = await _client
          .from('lead_activities')
          .select('id')
          .eq('lead_id', leadId)
          .limit(1);

      print('Found ${response.length} existing activities');

      // If no activities exist, populate sample data
      if (response.isEmpty) {
        print('No activities found, populating sample data for lead: $leadId');
        await populateSampleData(
          leadId: leadId,
          customerName: customerName,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
        );
        print('Sample data populated successfully for lead: $leadId');
      } else {
        print('Lead already has activities, skipping population');
      }
    } catch (e) {
      print('Error in ensureLeadHasActivities: $e');
      throw Exception('Failed to ensure lead has activities: $e');
    }
  }
}
