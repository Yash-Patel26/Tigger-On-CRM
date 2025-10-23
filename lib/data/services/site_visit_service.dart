import '../models/site_visit_model.dart';
import '../models/meeting_status_model.dart';
import 'api_service.dart';

class SiteVisitService {
  final ApiService _apiService;

  SiteVisitService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all site visits with optional filters
  Future<ApiResponse<List<SiteVisit>>> getSiteVisits({
    String? search,
    SiteVisitStatus? status,
    VisitMode? visitMode,
    VisitType? visitType,
    String? customerId,
    String? projectId,
    String? telecallerId,
    String? attenderId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': ((page - 1) * limit).toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['or'] =
          'purpose.ilike.%$search%,notes.ilike.%$search%,customer_name.ilike.%$search%';
    }
    if (status != null) {
      queryParams['status'] = 'eq.${status.toString().split('.').last}';
    }
    if (visitMode != null) {
      queryParams['visit_mode'] = 'eq.${visitMode.toString().split('.').last}';
    }
    if (visitType != null) {
      queryParams['visit_type'] = 'eq.${visitType.toString().split('.').last}';
    }
    if (customerId != null) {
      queryParams['customer_id'] = 'eq.$customerId';
    }
    if (projectId != null) {
      queryParams['project_id'] = 'eq.$projectId';
    }
    if (telecallerId != null) {
      queryParams['telecaller_id'] = 'eq.$telecallerId';
    }
    if (attenderId != null) {
      queryParams['attender_id'] = 'eq.$attenderId';
    }
    if (fromDate != null) {
      queryParams['meeting_from'] = 'gte.${fromDate.toIso8601String()}';
    }
    if (toDate != null) {
      queryParams['meeting_to'] = 'lte.${toDate.toIso8601String()}';
    }

    return await _apiService.get<List<SiteVisit>>(
      '/site_visits',
      queryParams: queryParams,
      fromJson: (json) => (json as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get site visit by ID
  Future<ApiResponse<SiteVisit>> getSiteVisit(String id) async {
    return await _apiService.get<SiteVisit>(
      '/site_visits?id=eq.$id',
      fromJson: (json) {
        final List<dynamic> data = json as List;
        if (data.isEmpty) {
          throw Exception('Site visit not found');
        }
        return SiteVisit.fromJson(data.first as Map<String, dynamic>);
      },
    );
  }

  // Create new site visit
  Future<ApiResponse<SiteVisit>> createSiteVisit(SiteVisit siteVisit) async {
    return await _apiService.post<SiteVisit>(
      '/site_visits',
      body: siteVisit.toJson(),
      fromJson: (json) {
        final List<dynamic> data = json as List;
        if (data.isEmpty) {
          throw Exception('Failed to create site visit');
        }
        return SiteVisit.fromJson(data.first as Map<String, dynamic>);
      },
    );
  }

  // Update site visit
  Future<ApiResponse<SiteVisit>> updateSiteVisit(
    String id,
    SiteVisit siteVisit,
  ) async {
    return await _apiService.put<SiteVisit>(
      '/site_visits?id=eq.$id',
      body: siteVisit.toJson(),
      fromJson: (json) {
        final List<dynamic> data = json as List;
        if (data.isEmpty) {
          throw Exception('Site visit not found');
        }
        return SiteVisit.fromJson(data.first as Map<String, dynamic>);
      },
    );
  }

  // Delete site visit
  Future<ApiResponse<void>> deleteSiteVisit(String id) async {
    return await _apiService.delete<void>('/site_visits?id=eq.$id');
  }

  // Update site visit status
  Future<ApiResponse<SiteVisit>> updateSiteVisitStatus(
    String siteVisitId,
    SiteVisitStatus status,
    String? notes,
  ) async {
    final body = <String, dynamic>{
      'status': status.toString().split('.').last,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (notes != null) {
      body['notes'] = notes;
    }

    return await _apiService.patch<SiteVisit>(
      '/site_visits?id=eq.$siteVisitId',
      body: body,
      fromJson: (json) {
        final List<dynamic> data = json as List;
        if (data.isEmpty) {
          throw Exception('Site visit not found');
        }
        return SiteVisit.fromJson(data.first as Map<String, dynamic>);
      },
    );
  }

  // Complete site visit
  Future<ApiResponse<SiteVisit>> completeSiteVisit(
    String siteVisitId,
    String minutes,
    String? feedback,
    List<String>? attachments,
  ) async {
    return await _apiService.post<SiteVisit>(
      '/site-visits/$siteVisitId/complete',
      body: {
        'minutes': minutes,
        if (feedback != null) 'feedback': feedback,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) =>
          SiteVisit.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Reschedule site visit
  Future<ApiResponse<SiteVisit>> rescheduleSiteVisit(
    String siteVisitId,
    DateTime newMeetingFrom,
    DateTime newMeetingTo,
    String? reason,
  ) async {
    return await _apiService.post<SiteVisit>(
      '/site-visits/$siteVisitId/reschedule',
      body: {
        'meetingFrom': newMeetingFrom.toIso8601String(),
        'meetingTo': newMeetingTo.toIso8601String(),
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) =>
          SiteVisit.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Assign site visit to attender
  Future<ApiResponse<SiteVisit>> assignSiteVisit(
    String siteVisitId,
    String attenderId,
    String? notes,
  ) async {
    return await _apiService.post<SiteVisit>(
      '/site-visits/$siteVisitId/assign',
      body: {'attenderId': attenderId, if (notes != null) 'notes': notes},
      fromJson: (json) =>
          SiteVisit.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get site visit statistics
  Future<ApiResponse<Map<String, dynamic>>> getSiteVisitStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? telecallerId,
    String? attenderId,
    String? projectId,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (telecallerId != null) {
      queryParams['telecallerId'] = telecallerId;
    }
    if (attenderId != null) {
      queryParams['attenderId'] = attenderId;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/site-visits/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's site visits
  Future<ApiResponse<List<SiteVisit>>> getTodaysSiteVisits() async {
    return await _apiService.get<List<SiteVisit>>(
      '/site-visits/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get upcoming site visits
  Future<ApiResponse<List<SiteVisit>>> getUpcomingSiteVisits() async {
    return await _apiService.get<List<SiteVisit>>(
      '/site-visits/upcoming',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get lapsed site visits
  Future<ApiResponse<List<SiteVisit>>> getLapsedSiteVisits() async {
    return await _apiService.get<List<SiteVisit>>(
      '/site-visits/lapsed',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get site visit timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getSiteVisitTimeline(
    String siteVisitId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/site_visit_timeline?site_visit_id=eq.$siteVisitId',
      queryParams: {'order': 'created_at.desc'},
      fromJson: (json) =>
          (json as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get site visits by lead
  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByLead(
    String leadId,
  ) async {
    return await _apiService.get<List<SiteVisit>>(
      '/leads/$leadId/site-visits',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get site visits by customer
  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByCustomer(
    String customerId,
  ) async {
    return await _apiService.get<List<SiteVisit>>(
      '/customers/$customerId/site-visits',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get site visits by project
  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByProject(
    String projectId,
  ) async {
    return await _apiService.get<List<SiteVisit>>(
      '/projects/$projectId/site-visits',
      fromJson: (json) => (json['data'] as List)
          .map((e) => SiteVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Add site visit feedback
  Future<ApiResponse<SiteVisit>> addFeedback(
    String siteVisitId,
    String feedback,
    List<String>? attachments,
  ) async {
    return await _apiService.post<SiteVisit>(
      '/site-visits/$siteVisitId/feedback',
      body: {
        'feedback': feedback,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) =>
          SiteVisit.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get site visit calendar
  Future<ApiResponse<List<Map<String, dynamic>>>> getSiteVisitCalendar({
    DateTime? fromDate,
    DateTime? toDate,
    String? attenderId,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (attenderId != null) {
      queryParams['attenderId'] = attenderId;
    }

    return await _apiService.get<List<Map<String, dynamic>>>(
      '/site-visits/calendar',
      queryParams: queryParams,
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get meeting status options from master table
  Future<ApiResponse<List<MeetingStatusOption>>>
  getMeetingStatusOptions() async {
    return await _apiService.get<List<MeetingStatusOption>>(
      '/meeting_status_options?is_active=eq.true',
      queryParams: {'order': 'sort_order'},
      fromJson: (json) => (json as List)
          .map((e) => MeetingStatusOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
