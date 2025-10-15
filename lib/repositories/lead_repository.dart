import '../models/lead_model.dart';
import '../services/lead_service.dart';
import '../services/api_service.dart';

class LeadRepository {
  final LeadService _leadService;

  LeadRepository({LeadService? leadService})
    : _leadService = leadService ?? LeadService();

  // Get all leads with caching
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
    bool forceRefresh = false,
  }) async {
    // In a real implementation, you would check local cache first
    // and only fetch from API if cache is empty or forceRefresh is true

    return await _leadService.getLeads(
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
  }

  // Get lead by ID with caching
  Future<ApiResponse<Lead>> getLead(
    String id, {
    bool forceRefresh = false,
  }) async {
    // Check local cache first
    // if (!forceRefresh && _localCache.containsKey(id)) {
    //   return ApiResponse.success(_localCache[id]);
    // }

    final response = await _leadService.getLead(id);

    // Cache the result
    // if (response.success && response.data != null) {
    //   _localCache[id] = response.data!;
    // }

    return response;
  }

  // Create lead
  Future<ApiResponse<Lead>> createLead(Lead lead) async {
    final response = await _leadService.createLead(lead);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[response.data!.id] = response.data!;
    // }

    return response;
  }

  // Update lead
  Future<ApiResponse<Lead>> updateLead(String id, Lead lead) async {
    final response = await _leadService.updateLead(id, lead);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[id] = response.data!;
    // }

    return response;
  }

  // Delete lead
  Future<ApiResponse<void>> deleteLead(String id) async {
    final response = await _leadService.deleteLead(id);

    // Remove from local cache if successful
    // if (response.success) {
    //   _localCache.remove(id);
    // }

    return response;
  }

  // Assign lead
  Future<ApiResponse<Lead>> assignLead(
    String leadId,
    String userId,
    String description,
  ) async {
    final response = await _leadService.assignLead(leadId, userId, description);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[leadId] = response.data!;
    // }

    return response;
  }

  // Update lead status
  Future<ApiResponse<Lead>> updateLeadStatus(
    String leadId,
    LeadStatus status,
    LeadSubStatus subStatus,
  ) async {
    final response = await _leadService.updateLeadStatus(
      leadId,
      status,
      subStatus,
    );

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[leadId] = response.data!;
    // }

    return response;
  }

  // Get lead statistics
  Future<ApiResponse<Map<String, dynamic>>> getLeadStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    return await _leadService.getLeadStats(
      fromDate: fromDate,
      toDate: toDate,
      assignedTo: assignedTo,
    );
  }

  // Get today's follow-ups
  Future<ApiResponse<List<Lead>>> getTodaysFollowUps() async {
    return await _leadService.getTodaysFollowUps();
  }

  // Get leads with site visits
  Future<ApiResponse<List<Lead>>> getLeadsWithVisits() async {
    return await _leadService.getLeadsWithVisits();
  }

  // Mark lead as duplicate
  Future<ApiResponse<Lead>> markAsDuplicate(
    String leadId,
    String reason,
  ) async {
    final response = await _leadService.markAsDuplicate(leadId, reason);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[leadId] = response.data!;
    // }

    return response;
  }

  // Get lead timeline
  Future<ApiResponse<List<Map<String, dynamic>>>> getLeadTimeline(
    String leadId,
  ) async {
    return await _leadService.getLeadTimeline(leadId);
  }

  // Add follow-up note
  Future<ApiResponse<Lead>> addFollowUpNote(
    String leadId,
    String note,
    DateTime? nextFollowUpDate,
  ) async {
    final response = await _leadService.addFollowUpNote(
      leadId,
      note,
      nextFollowUpDate,
    );

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[leadId] = response.data!;
    // }

    return response;
  }

  // Search leads locally (if cached)
  List<Lead> searchLeadsLocally(String query, List<Lead> leads) {
    if (query.isEmpty) return leads;

    final queryLower = query.toLowerCase();
    return leads.where((lead) {
      return lead.customerName.toLowerCase().contains(queryLower) ||
          lead.email.toLowerCase().contains(queryLower) ||
          lead.phone.contains(query) ||
          lead.leadId.toLowerCase().contains(queryLower) ||
          (lead.projectName?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  // Filter leads locally
  List<Lead> filterLeadsLocally(
    List<Lead> leads, {
    LeadStatus? status,
    LeadSubStatus? subStatus,
    LeadSource? source,
    PropertyType? propertyType,
    CategoryType? categoryType,
    String? assignedTo,
    String? projectId,
  }) {
    return leads.where((lead) {
      if (status != null && lead.status != status) return false;
      if (subStatus != null && lead.subStatus != subStatus) return false;
      if (source != null && lead.source != source) return false;
      if (propertyType != null && lead.propertyType != propertyType) {
        return false;
      }
      if (categoryType != null && lead.categoryType != categoryType) {
        return false;
      }
      if (assignedTo != null && lead.assignedTo != assignedTo) return false;
      if (projectId != null && lead.projectId != projectId) return false;
      return true;
    }).toList();
  }

  // Clear local cache
  void clearCache() {
    // _localCache.clear();
  }
}
