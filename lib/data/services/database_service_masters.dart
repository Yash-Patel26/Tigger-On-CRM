import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseServiceMasters {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Lead Status Methods
  static Future<List<Map<String, dynamic>>> getLeadStatuses() async {
    try {
      final response = await _client
          .from('ticket_disposition_main')
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
          .from('ticket_disposition_sub')
          .select('*')
          .eq('is_active', true)
          .eq('main_id', statusId)
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
        'performed_by': performedBy,
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
      // Create a follow-up task based on disposition
      await _client.from('tasks').insert({
        'title': 'Follow-up: $mainDispositionName - $subDispositionName',
        'description':
            'Follow-up task created from disposition: $mainDispositionName - $subDispositionName',
        'type': 'followUp',
        'priority': 'medium',
        'status': 'pending',
        'lead_id': leadId,
        'assigned_to': assignedTo,
        'assigned_to_name': assignedToName,
        'created_by': performedBy,
        'created_by_name': performedByName,
        'due_date': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
      });
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'metadata': {
          'phone_number': phoneNumber,
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
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
        'performed_by': performedBy,
        'performed_by_name': performedByName,
        'metadata': {'phone_number': phoneNumber, 'is_offline': isOffline},
      });
    } catch (e) {
      throw Exception('Failed to log WhatsApp initiated: $e');
    }
  }
}
