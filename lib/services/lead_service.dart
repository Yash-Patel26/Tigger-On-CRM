import '../models/lead_model.dart';
import 'api_service.dart';

class LeadService {
  final ApiService _apiService;

  LeadService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

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
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (subStatus != null) {
      queryParams['subStatus'] = subStatus.name;
    }
    if (source != null) {
      queryParams['source'] = source.name;
    }
    if (propertyType != null) {
      queryParams['propertyType'] = propertyType.name;
    }
    if (categoryType != null) {
      queryParams['categoryType'] = categoryType.name;
    }
    if (assignedTo != null) {
      queryParams['assignedTo'] = assignedTo;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    return await _apiService.get<List<Lead>>(
      '/leads',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Lead.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get lead by ID
  Future<ApiResponse<Lead>> getLead(String id) async {
    return await _apiService.get<Lead>(
      '/leads/$id',
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new lead
  Future<ApiResponse<Lead>> createLead(Lead lead) async {
    return await _apiService.post<Lead>(
      '/leads',
      body: lead.toJson(),
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update lead
  Future<ApiResponse<Lead>> updateLead(String id, Lead lead) async {
    return await _apiService.put<Lead>(
      '/leads/$id',
      body: lead.toJson(),
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete lead
  Future<ApiResponse<void>> deleteLead(String id) async {
    return await _apiService.delete<void>('/leads/$id');
  }

  // Assign lead to user
  Future<ApiResponse<Lead>> assignLead(
    String leadId,
    String userId,
    String description,
  ) async {
    return await _apiService.post<Lead>(
      '/leads/$leadId/assign',
      body: {'assignedTo': userId, 'description': description},
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update lead status
  Future<ApiResponse<Lead>> updateLeadStatus(
    String leadId,
    LeadStatus status,
    LeadSubStatus subStatus,
  ) async {
    return await _apiService.patch<Lead>(
      '/leads/$leadId/status',
      body: {'status': status.name, 'subStatus': subStatus.name},
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get lead statistics
  Future<ApiResponse<Map<String, dynamic>>> getLeadStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (assignedTo != null) {
      queryParams['assignedTo'] = assignedTo;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/leads/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's follow-ups
  Future<ApiResponse<List<Lead>>> getTodaysFollowUps() async {
    return await _apiService.get<List<Lead>>(
      '/leads/today-followups',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Lead.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get leads with site visits
  Future<ApiResponse<List<Lead>>> getLeadsWithVisits() async {
    return await _apiService.get<List<Lead>>(
      '/leads/with-visits',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Lead.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Mark lead as duplicate
  Future<ApiResponse<Lead>> markAsDuplicate(
    String leadId,
    String reason,
  ) async {
    return await _apiService.patch<Lead>(
      '/leads/$leadId/duplicate',
      body: {'reason': reason},
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get lead timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getLeadTimeline(
    String leadId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/leads/$leadId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Add follow-up note
  Future<ApiResponse<Lead>> addFollowUpNote(
    String leadId,
    String note,
    DateTime? nextFollowUpDate,
  ) async {
    return await _apiService.post<Lead>(
      '/leads/$leadId/followup',
      body: {
        'note': note,
        'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
      },
      fromJson: (json) => Lead.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
