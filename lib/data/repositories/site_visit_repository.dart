import '../models/site_visit_model.dart';
import '../services/site_visit_service.dart';
import '../services/api_service.dart';

class SiteVisitRepository {
  final SiteVisitService _siteVisitService;

  SiteVisitRepository({SiteVisitService? siteVisitService})
    : _siteVisitService = siteVisitService ?? SiteVisitService();

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
    return _siteVisitService.getSiteVisits(
      search: search,
      status: status,
      visitMode: visitMode,
      visitType: visitType,
      customerId: customerId,
      projectId: projectId,
      telecallerId: telecallerId,
      attenderId: attenderId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<SiteVisit>> getSiteVisitById(String id) async {
    return _siteVisitService.getSiteVisit(id);
  }

  Future<ApiResponse<SiteVisit>> createSiteVisit(SiteVisit siteVisit) async {
    return _siteVisitService.createSiteVisit(siteVisit);
  }

  Future<ApiResponse<SiteVisit>> updateSiteVisit(
    String id,
    SiteVisit siteVisit,
  ) async {
    return _siteVisitService.updateSiteVisit(id, siteVisit);
  }

  Future<ApiResponse<void>> deleteSiteVisit(String id) async {
    return _siteVisitService.deleteSiteVisit(id);
  }

  Future<ApiResponse<SiteVisit>> updateSiteVisitStatus(
    String siteVisitId,
    SiteVisitStatus status,
    String? notes,
  ) async {
    return _siteVisitService.updateSiteVisitStatus(siteVisitId, status, notes);
  }

  Future<ApiResponse<SiteVisit>> completeSiteVisit(
    String siteVisitId,
    String minutes,
    String? feedback,
    List<String>? attachments,
  ) async {
    return _siteVisitService.completeSiteVisit(
      siteVisitId,
      minutes,
      feedback,
      attachments,
    );
  }

  Future<ApiResponse<SiteVisit>> rescheduleSiteVisit(
    String siteVisitId,
    DateTime newMeetingFrom,
    DateTime newMeetingTo,
    String? reason,
  ) async {
    return _siteVisitService.rescheduleSiteVisit(
      siteVisitId,
      newMeetingFrom,
      newMeetingTo,
      reason,
    );
  }

  Future<ApiResponse<SiteVisit>> assignSiteVisit(
    String siteVisitId,
    String attenderId,
    String? notes,
  ) async {
    return _siteVisitService.assignSiteVisit(siteVisitId, attenderId, notes);
  }

  Future<ApiResponse<Map<String, dynamic>>> getSiteVisitStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? telecallerId,
    String? attenderId,
    String? projectId,
  }) async {
    return _siteVisitService.getSiteVisitStats(
      fromDate: fromDate,
      toDate: toDate,
      telecallerId: telecallerId,
      attenderId: attenderId,
      projectId: projectId,
    );
  }

  Future<ApiResponse<List<SiteVisit>>> getTodaysSiteVisits() async {
    return _siteVisitService.getTodaysSiteVisits();
  }

  Future<ApiResponse<List<SiteVisit>>> getUpcomingSiteVisits() async {
    return _siteVisitService.getUpcomingSiteVisits();
  }

  Future<ApiResponse<List<SiteVisit>>> getLapsedSiteVisits() async {
    return _siteVisitService.getLapsedSiteVisits();
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSiteVisitTimeline(
    String siteVisitId,
  ) async {
    return _siteVisitService.getSiteVisitTimeline(siteVisitId);
  }

  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByLead(
    String leadId,
  ) async {
    return _siteVisitService.getSiteVisitsByLead(leadId);
  }

  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByCustomer(
    String customerId,
  ) async {
    return _siteVisitService.getSiteVisitsByCustomer(customerId);
  }

  Future<ApiResponse<List<SiteVisit>>> getSiteVisitsByProject(
    String projectId,
  ) async {
    return _siteVisitService.getSiteVisitsByProject(projectId);
  }

  Future<ApiResponse<SiteVisit>> addFeedback(
    String siteVisitId,
    String feedback,
    List<String>? attachments,
  ) async {
    return _siteVisitService.addFeedback(siteVisitId, feedback, attachments);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getSiteVisitCalendar({
    DateTime? fromDate,
    DateTime? toDate,
    String? attenderId,
  }) async {
    return _siteVisitService.getSiteVisitCalendar(
      fromDate: fromDate,
      toDate: toDate,
      attenderId: attenderId,
    );
  }
}
