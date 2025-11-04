import '../models/models.dart';
import '../services/database_service.dart';
import '../services/database_service_masters.dart' as masters;
import '../../shared/helpers/notification_helper.dart';

class LeadService {
  LeadService();

  // Get all leads with optional filters
  Future<ApiResponse<List<Lead>>> getLeads({
    String? search,
    LeadStatus? status,
    LeadSubStatus? subStatus,
    LeadSource? source,
    PropertyType? propertyType,
    CategoryType? categoryType,
    String? assignedTo,
    String? projectId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final leads = await DatabaseService.getLeads(
        search: search,
        status: status,
        subStatus: subStatus,
        source: source,
        propertyType: propertyType,
        categoryType: categoryType,
        assignedTo: assignedTo,
        projectId: projectId,
        fromDate: fromDate,
        toDate: toDate,
        page: page,
        limit: limit,
      );

      return ApiResponse.success(data: leads);
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching leads: $e');
    }
  }

  // Get lead by ID
  Future<ApiResponse<Lead>> getLead(String id) async {
    try {
      final lead = await DatabaseService.getLeadById(id);
      if (lead != null) {
        return ApiResponse.success(data: lead);
      } else {
        return ApiResponse.error(error: 'Lead not found');
      }
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching lead: $e');
    }
  }

  // Create new lead
  Future<ApiResponse<Lead>> createLead(Lead lead) async {
    try {
      final createdLead = await DatabaseService.createLead(lead);
      return ApiResponse.success(data: createdLead);
    } catch (e) {
      return ApiResponse.error(error: 'Error creating lead: $e');
    }
  }

  // Update lead
  Future<ApiResponse<Lead>> updateLead(String id, Lead lead) async {
    try {
      final updatedLead = await DatabaseService.updateLead(id, lead);
      return ApiResponse.success(data: updatedLead);
    } catch (e) {
      return ApiResponse.error(error: 'Error updating lead: $e');
    }
  }

  // Delete lead
  Future<ApiResponse<void>> deleteLead(String id) async {
    try {
      await DatabaseService.deleteLead(id);
      return ApiResponse.success(data: null);
    } catch (e) {
      return ApiResponse.error(error: 'Error deleting lead: $e');
    }
  }

  // Update lead status
  Future<ApiResponse<Lead>> updateLeadStatus(
    String leadId,
    LeadStatus status,
    LeadSubStatus subStatus, {
    String? notes,
  }) async {
    try {
      final lead = await DatabaseService.getLeadById(leadId);
      if (lead == null) {
        return ApiResponse.error(error: 'Lead not found');
      }

      final updatedLead = lead.copyWith(
        status: status,
        subStatus: subStatus,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final result = await DatabaseService.updateLead(leadId, updatedLead);
      return ApiResponse.success(data: result);
    } catch (e) {
      return ApiResponse.error(error: 'Error updating lead status: $e');
    }
  }

  // Assign lead to user
  Future<ApiResponse<Lead>> assignLead(
    String leadId,
    String assignedTo, {
    String? assignedToName,
    String? notes,
  }) async {
    try {
      final lead = await DatabaseService.getLeadById(leadId);
      if (lead == null) {
        return ApiResponse.error(error: 'Lead not found');
      }

      final updatedLead = lead.copyWith(
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final result = await DatabaseService.updateLead(leadId, updatedLead);

      // Notify the assignee about the lead assignment (admin/head initiated)
      try {
        await NotificationHelper.createLeadAssignedNotification(
          userId: assignedTo,
          leadId: result.id,
          customerName: result.customerName,
          projectName: result.projectName ?? 'Project',
          priority: NotificationPriority.medium,
        );
      } catch (_) {
        // Best-effort; do not fail assignment on notification error
      }

      return ApiResponse.success(data: result);
    } catch (e) {
      return ApiResponse.error(error: 'Error assigning lead: $e');
    }
  }

  // Add follow-up note
  Future<ApiResponse<Lead>> addFollowUpNote(
    String leadId,
    String note,
    DateTime? nextFollowUpDate,
  ) async {
    try {
      final lead = await DatabaseService.getLeadById(leadId);
      if (lead == null) {
        return ApiResponse.error(error: 'Lead not found');
      }

      final updatedLead = lead.copyWith(
        lastFollowUpDate: DateTime.now(),
        nextFollowUpDate: nextFollowUpDate,
        notes: note,
        updatedAt: DateTime.now(),
      );

      final result = await DatabaseService.updateLead(leadId, updatedLead);
      return ApiResponse.success(data: result);
    } catch (e) {
      return ApiResponse.error(error: 'Error adding follow-up note: $e');
    }
  }

  // Mark lead as duplicate
  Future<ApiResponse<Lead>> markAsDuplicate(
    String leadId,
    String reason,
  ) async {
    try {
      final lead = await DatabaseService.getLeadById(leadId);
      if (lead == null) {
        return ApiResponse.error(error: 'Lead not found');
      }

      final updatedLead = lead.copyWith(
        status: LeadStatus.cold,
        subStatus: LeadSubStatus.closed,
        notes: reason,
        updatedAt: DateTime.now(),
      );

      final result = await DatabaseService.updateLead(leadId, updatedLead);
      return ApiResponse.success(data: result);
    } catch (e) {
      return ApiResponse.error(error: 'Error marking lead as duplicate: $e');
    }
  }

  // Get lead statistics
  Future<ApiResponse<Map<String, dynamic>>> getLeadStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    try {
      final stats = await DatabaseService.getDashboardStats();
      return ApiResponse.success(data: stats);
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching lead stats: $e');
    }
  }

  // Get today's follow-ups (by lastFollowUpDate)
  Future<ApiResponse<List<Lead>>> getTodaysFollowUps() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final leads = await DatabaseService.getLeads(limit: 200);
      final filtered = leads.where((l) {
        final d = l.lastFollowUpDate;
        return d != null && d.isAfter(todayStart) && d.isBefore(todayEnd);
      }).toList();
      return ApiResponse.success(data: filtered);
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching today\'s follow-ups: $e');
    }
  }

  // Get leads with site visits
  Future<ApiResponse<List<Lead>>> getLeadsWithVisits() async {
    try {
      // Fetch recent site visits and collect unique lead IDs
      final visits = await DatabaseService.getSiteVisits(limit: 1000);
      final Set<String> leadIds = visits
          .map((v) => v.leadId)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      // Load leads for those IDs
      final List<Lead> leadsWithVisits = [];
      await Future.wait(
        leadIds.map((id) async {
          try {
            final lead = await DatabaseService.getLeadById(id);
            if (lead != null) {
              leadsWithVisits.add(lead);
            }
          } catch (_) {}
        }),
      );

      return ApiResponse.success(data: leadsWithVisits);
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching leads with visits: $e');
    }
  }

  // Get lead timeline (placeholder implementation)
  Future<ApiResponse<List<Map<String, dynamic>>>> getLeadTimeline(
    String leadId,
  ) async {
    try {
      // Aggregate events from related entities
      final List<Map<String, dynamic>> timeline = [];

      // Fetch lead activities (including communication activities)
      final activities = await masters.DatabaseServiceMasters.getLeadActivities(
        leadId: leadId,
        limit: 200,
      );

      for (final activity in activities) {
        // Convert camelCase enum to snake_case for database compatibility
        String activityType = activity.type.toString().split('.').last;
        // Convert camelCase to snake_case
        activityType = activityType.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '_${match.group(1)!.toLowerCase()}',
        );

        timeline.add({
          'type': 'activity',
          'timestamp': activity.createdAt.toIso8601String(),
          'activity_type': activityType,
          'action': activity.action,
          'description': activity.description,
          'performed_by': activity.performedByName,
          'metadata': activity.metadata,
          'id': activity.id,
        });
      }

      // Site visits for this leady

      final visits = await DatabaseService.getSiteVisits(
        leadId: leadId,
        limit: 200,
      );
      for (final v in visits) {
        final DateTime dt = v.createdAt;
        timeline.add({
          'type': 'site_visit',
          'timestamp': dt.toIso8601String(),
          'status': v.status.name,
          'purpose': v.purpose,
          'notes': v.notes,
          'id': v.id,
        });
      }

      // Tasks for this lead
      final tasks = await DatabaseService.getTasks(leadId: leadId, limit: 200);
      for (final t in tasks) {
        final DateTime dt = t.updatedAt ?? t.dueDate ?? t.createdAt;
        timeline.add({
          'type': 'task',
          'timestamp': dt.toIso8601String(),
          'status': t.status.name,
          'priority': t.priority.name,
          'title': t.title,
          'id': t.id,
        });
      }

      // Bookings for this lead
      final bookings = await DatabaseService.getBookings(
        leadId: leadId,
        limit: 200,
      );
      for (final b in bookings) {
        final DateTime dt = b.updatedAt;
        timeline.add({
          'type': 'booking',
          'timestamp': dt.toIso8601String(),
          'status': b.status.name,
          'srNo': b.srNo,
          'amount': b.bookingAmount,
          'id': b.id,
        });
      }

      // Sort descending by timestamp
      timeline.sort(
        (a, b) =>
            (b['timestamp'] as String).compareTo(a['timestamp'] as String),
      );

      return ApiResponse.success(data: timeline);
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching lead timeline: $e');
    }
  }
}
