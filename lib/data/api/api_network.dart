import 'api_helper.dart';

/// Centralized network endpoints and thin wrappers around [ApiClient].
/// Add new endpoints and methods here to keep API access in one place.
class ApiNetwork {
  ApiNetwork._internal({ApiClient? client, String? baseUrl})
    : _client = client ?? ApiClient(baseUrl: baseUrl ?? ApiEndpoints.baseUrl);

  static final ApiNetwork instance = ApiNetwork._internal();

  final ApiClient _client;

  // Base URL and endpoints (customize as per backend)
  static String baseUrl = ApiEndpoints.baseUrl;

  // Leads
  static const String _leads = '/leads';
  static String _leadById(String id) => '/leads/$id';
  static String _leadAssign(String id) => '/leads/$id/assign';
  static String _leadStatus(String id) => '/leads/$id/status';
  static const String _leadsStats = '/leads/stats';
  static const String _leadsTodayFollowups = '/leads/today-followups';
  static const String _leadsWithVisits = '/leads/with-visits';
  static String _leadDuplicate(String id) => '/leads/$id/duplicate';
  static String _leadTimeline(String id) => '/leads/$id/timeline';
  static String _leadFollowup(String id) => '/leads/$id/followup';

  // Vendors
  static const String _vendors = '/vendors';
  static String _vendorById(String id) => '/vendors/$id';

  // Customers
  static const String _customers = '/customers';
  static String _customerById(String id) => '/customers/$id';
  static const String _customersStats = '/customers/stats';
  static const String _customersToday = '/customers/today';
  static String _customerTimeline(String id) => '/customers/$id/timeline';
  static String _customerLeads(String id) => '/customers/$id/leads';
  static String _customerBookings(String id) => '/customers/$id/bookings';
  static String _customerSiteVisits(String id) => '/customers/$id/site-visits';
  static String _customerContact(String id) => '/customers/$id/contact';
  static const String _customersMerge = '/customers/merge';
  static const String _customersSearch = '/customers/search';

  // Projects
  static const String _projects = '/projects';
  static String _projectById(String id) => '/projects/$id';
  static const String _projectsStats = '/projects/stats';
  static const String _projectsSearch = '/projects/search';
  static const String _projectsFeatured = '/projects/featured';
  static const String _projectsUpcoming = '/projects/upcoming';
  static String _projectStatus(String id) => '/projects/$id/status';
  static String _projectPricing(String id) => '/projects/$id/pricing';
  static String _projectAvailability(String id) => '/projects/$id/availability';
  static String _projectsByDeveloper(String devId) =>
      '/developers/$devId/projects';
  static const String _projectsByLocation = '/projects/by-location';
  static String _projectTimeline(String id) => '/projects/$id/timeline';
  static String _projectLeads(String id) => '/projects/$id/leads';
  static String _projectBookings(String id) => '/projects/$id/bookings';
  static String _projectSiteVisits(String id) => '/projects/$id/site-visits';
  static String _projectPerformance(String id) => '/projects/$id/performance';
  static String _projectPriceHistory(String id) =>
      '/projects/$id/price-history';
  static String _projectAmenities(String id) => '/projects/$id/amenities';
  static String _projectPropertyTypes(String id) =>
      '/projects/$id/property-types';

  // Site Visits
  static const String _siteVisits = '/site-visits';
  static String _siteVisitById(String id) => '/site-visits/$id';
  static String _siteVisitStatus(String id) => '/site-visits/$id/status';
  static String _siteVisitComplete(String id) => '/site-visits/$id/complete';
  static String _siteVisitReschedule(String id) =>
      '/site-visits/$id/reschedule';
  static String _siteVisitAssign(String id) => '/site-visits/$id/assign';
  static const String _siteVisitsStats = '/site-visits/stats';
  static const String _siteVisitsToday = '/site-visits/today';
  static const String _siteVisitsUpcoming = '/site-visits/upcoming';
  static const String _siteVisitsLapsed = '/site-visits/lapsed';
  static String _siteVisitTimeline(String id) => '/site-visits/$id/timeline';
  static String _leadSiteVisits(String leadId) => '/leads/$leadId/site-visits';
  static String _customerSiteVisitsByCustomer(String id) =>
      '/customers/$id/site-visits';
  static String _projectSiteVisitsByProject(String id) =>
      '/projects/$id/site-visits';
  static String _siteVisitFeedback(String id) => '/site-visits/$id/feedback';
  static const String _siteVisitCalendar = '/site-visits/calendar';

  // Tasks
  static const String _tasks = '/tasks';
  static String _taskById(String id) => '/tasks/$id';
  static String _taskStatus(String id) => '/tasks/$id/status';
  static String _taskAssign(String id) => '/tasks/$id/assign';
  static String _taskComplete(String id) => '/tasks/$id/complete';
  static String _taskCancel(String id) => '/tasks/$id/cancel';
  static const String _tasksStats = '/tasks/stats';
  static const String _tasksToday = '/tasks/today';
  static const String _tasksOverdue = '/tasks/overdue';
  static const String _tasksMy = '/tasks/my-tasks';
  static String _leadTasks(String id) => '/leads/$id/tasks';
  static String _customerTasks(String id) => '/customers/$id/tasks';
  static String _projectTasks(String id) => '/projects/$id/tasks';
  static String _siteVisitTasks(String id) => '/site-visits/$id/tasks';
  static String _taskTimeline(String id) => '/tasks/$id/timeline';
  static String _taskComments(String id) => '/tasks/$id/comments';
  static const String _tasksSearch = '/tasks/search';
  static const String _tasksUpcoming = '/tasks/upcoming';
  static const String _tasksByPriority = '/tasks/by-priority';
  static const String _tasksByType = '/tasks/by-type';

  // Developers
  static const String _developers = '/developers';
  static String _developerById(String id) => '/developers/$id';
  static const String _developersStats = '/developers/stats';
  static String _developerStatus(String id) => '/developers/$id/status';
  static String _developerProjects(String id) => '/developers/$id/projects';
  static String _developerTimeline(String id) => '/developers/$id/timeline';
  static const String _developersSearch = '/developers/search';
  static const String _developersByCity = '/developers/by-city';
  static const String _developersReraRegistered = '/developers/rera-registered';
  static String _developerPerformance(String id) =>
      '/developers/$id/performance';
  static const String _developersMerge = '/developers/merge';
  static String _developerLeads(String id) => '/developers/$id/leads';
  static String _developerBookings(String id) => '/developers/$id/bookings';
  static String _developerContacts(String id) => '/developers/$id/contacts';
  static String _developerContactById(String devId, String contactId) =>
      '/developers/$devId/contacts/$contactId';
  static String _developerContactPrimary(String devId, String contactId) =>
      '/developers/$devId/contacts/$contactId/primary';

  // Bookings
  static const String _bookings = '/bookings';
  static String _bookingById(String id) => '/bookings/$id';
  static const String _bookingsStats = '/bookings/stats';
  static const String _bookingsToday = '/bookings/today';
  static const String _bookingsPendingApprovals = '/bookings/pending-approvals';
  static String _bookingTimeline(String id) => '/bookings/$id/timeline';
  static String _bookingStatus(String id) => '/bookings/$id/status';
  static String _bookingApprove(String id) => '/bookings/$id/approve';
  static String _bookingCancel(String id) => '/bookings/$id/cancel';
  static String _bookingPayment(String id) => '/bookings/$id/payment';
  static String _bookingReceipt(String id) => '/bookings/$id/receipt';
  static const String _bookingCommissionReport = '/bookings/commission-report';
  static const String _bookingSearchSrNo = '/bookings/search/sr-no';

  // Notifications
  static const String _notifications = '/notifications';
  static String _notificationById(String id) => '/notifications/$id';
  static const String _notificationsStats = '/notifications/stats';
  static const String _notificationsToday = '/notifications/today';
  static const String _notificationsUnread = '/notifications/unread';
  static const String _notificationsArchived = '/notifications/archived';
  static const String _notificationsSearch = '/notifications/search';
  static const String _notificationsByType = '/notifications/by-type';
  static const String _notificationsByPriority = '/notifications/by-priority';
  static const String _notificationsClearAll = '/notifications/clear-all';
  static const String _notificationsPreferences = '/notifications/preferences';
  static const String _notificationsMarkAllRead =
      '/notifications/mark-all-read';
  static const String _notificationsUnreadCount = '/notifications/unread-count';
  static String _notificationRead(String id) => '/notifications/$id/read';
  static String _notificationUnread(String id) => '/notifications/$id/unread';
  static String _notificationArchive(String id) => '/notifications/$id/archive';
  static String _notificationUnarchive(String id) =>
      '/notifications/$id/unarchive';

  // Tickets
  static const String _tickets = '/tickets';
  static String _ticketById(String id) => '/tickets/$id';
  static const String _ticketsStats = '/tickets/stats';
  static const String _ticketsToday = '/tickets/today';
  static const String _ticketsMy = '/tickets/my-tickets';
  static const String _ticketsSearch = '/tickets/search';
  static String _ticketStatus(String id) => '/tickets/$id/status';
  static String _ticketAssign(String id) => '/tickets/$id/assign';
  static String _ticketResolve(String id) => '/tickets/$id/resolve';
  static String _ticketClose(String id) => '/tickets/$id/close';
  static String _ticketTimeline(String id) => '/tickets/$id/timeline';
  static String _ticketComments(String id) => '/tickets/$id/comments';
  static String _leadTickets(String id) => '/leads/$id/tickets';
  static String _customerTickets(String id) => '/customers/$id/tickets';
  static String _projectTickets(String id) => '/projects/$id/tickets';

  // ---- Lead APIs ----
  Future<Map<String, dynamic>> fetchLeads({Map<String, dynamic>? query}) {
    return _client.get(_leads, query: query);
  }

  Future<Map<String, dynamic>> fetchLeadById(String id) {
    return _client.get(_leadById(id));
  }

  Future<Map<String, dynamic>> createLead(Map<String, dynamic> body) {
    return _client.post(_leads, body: body);
  }

  Future<Map<String, dynamic>> updateLead(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_leadById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteLead(String id) {
    return _client.delete(_leadById(id));
  }

  Future<Map<String, dynamic>> assignLead(
    String leadId,
    String userId,
    String description,
  ) {
    return _client.post(
      _leadAssign(leadId),
      body: {'assignedTo': userId, 'description': description},
    );
  }

  Future<Map<String, dynamic>> updateLeadStatus(
    String leadId,
    String status,
    String subStatus,
  ) {
    return _client.patch(
      _leadStatus(leadId),
      body: {'status': status, 'subStatus': subStatus},
    );
  }

  Future<Map<String, dynamic>> getLeadStats({Map<String, dynamic>? query}) {
    return _client.get(_leadsStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysFollowUps() {
    return _client.get(_leadsTodayFollowups);
  }

  Future<Map<String, dynamic>> getLeadsWithVisits() {
    return _client.get(_leadsWithVisits);
  }

  Future<Map<String, dynamic>> markLeadAsDuplicate(
    String leadId,
    String reason,
  ) {
    return _client.post(_leadDuplicate(leadId), body: {'reason': reason});
  }

  Future<Map<String, dynamic>> getLeadTimeline(String leadId) {
    return _client.get(_leadTimeline(leadId));
  }

  Future<Map<String, dynamic>> addFollowUpNote(
    String leadId,
    String note, {
    String? nextFollowUpIso,
  }) {
    return _client.post(
      _leadFollowup(leadId),
      body: {
        'note': note,
        if (nextFollowUpIso != null) 'nextFollowUpDate': nextFollowUpIso,
      },
    );
  }

  // ---- Vendor APIs ----
  Future<Map<String, dynamic>> fetchVendors({Map<String, dynamic>? query}) {
    return _client.get(_vendors, query: query);
  }

  Future<Map<String, dynamic>> fetchVendorById(String id) {
    return _client.get(_vendorById(id));
  }

  Future<Map<String, dynamic>> createVendor(Map<String, dynamic> body) {
    return _client.post(_vendors, body: body);
  }

  // ---- Customer APIs ----
  Future<Map<String, dynamic>> fetchCustomers({Map<String, dynamic>? query}) {
    return _client.get(_customers, query: query);
  }

  Future<Map<String, dynamic>> fetchCustomerById(String id) {
    return _client.get(_customerById(id));
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> body) {
    return _client.post(_customers, body: body);
  }

  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_customerById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteCustomer(String id) {
    return _client.delete(_customerById(id));
  }

  Future<Map<String, dynamic>> assignCustomer(
    String customerId,
    String userId,
  ) {
    return _client.post(
      '/customers/$customerId/assign',
      body: {'assignedTo': userId},
    );
  }

  Future<Map<String, dynamic>> getCustomerStats({Map<String, dynamic>? query}) {
    return _client.get(_customersStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysCustomers() {
    return _client.get(_customersToday);
  }

  Future<Map<String, dynamic>> getCustomerTimeline(String id) {
    return _client.get(_customerTimeline(id));
  }

  Future<Map<String, dynamic>> getCustomerLeads(String id) {
    return _client.get(_customerLeads(id));
  }

  Future<Map<String, dynamic>> getCustomerBookings(String id) {
    return _client.get(_customerBookings(id));
  }

  Future<Map<String, dynamic>> getCustomerSiteVisits(String id) {
    return _client.get(_customerSiteVisits(id));
  }

  Future<Map<String, dynamic>> updateCustomerContact(
    String id, {
    String? phone,
    String? email,
    String? address,
  }) {
    return _client.patch(
      _customerContact(id),
      body: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      },
    );
  }

  Future<Map<String, dynamic>> mergeCustomers(
    String primaryCustomerId,
    List<String> duplicateCustomerIds,
  ) {
    return _client.post(
      _customersMerge,
      body: {
        'primaryCustomerId': primaryCustomerId,
        'duplicateCustomerIds': duplicateCustomerIds,
      },
    );
  }

  Future<Map<String, dynamic>> searchCustomers(String query) {
    return _client.get(_customersSearch, query: {'q': query});
  }

  // ---- Project APIs ----
  Future<Map<String, dynamic>> fetchProjects({Map<String, dynamic>? query}) {
    return _client.get(_projects, query: query);
  }

  Future<Map<String, dynamic>> fetchProjectById(String id) {
    return _client.get(_projectById(id));
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> body) {
    return _client.post(_projects, body: body);
  }

  Future<Map<String, dynamic>> updateProject(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_projectById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteProject(String id) {
    return _client.delete(_projectById(id));
  }

  Future<Map<String, dynamic>> updateProjectStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _client.patch(
      _projectStatus(id),
      body: {'status': status, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> updateProjectPricing(
    String id, {
    double? startingPrice,
    double? maxPrice,
    String? priceUnit,
  }) {
    return _client.patch(
      _projectPricing(id),
      body: {
        if (startingPrice != null) 'startingPrice': startingPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (priceUnit != null) 'priceUnit': priceUnit,
      },
    );
  }

  Future<Map<String, dynamic>> updateProjectAvailability(
    String id, {
    int? totalUnits,
    int? availableUnits,
  }) {
    return _client.patch(
      _projectAvailability(id),
      body: {
        if (totalUnits != null) 'totalUnits': totalUnits,
        if (availableUnits != null) 'availableUnits': availableUnits,
      },
    );
  }

  Future<Map<String, dynamic>> getProjectStats({Map<String, dynamic>? query}) {
    return _client.get(_projectsStats, query: query);
  }

  Future<Map<String, dynamic>> getProjectsByDeveloper(String developerId) {
    return _client.get(_projectsByDeveloper(developerId));
  }

  Future<Map<String, dynamic>> getProjectsByLocation({
    required String city,
    String? state,
  }) {
    final Map<String, dynamic> q = {'city': city};
    if (state != null) q['state'] = state;
    return _client.get(_projectsByLocation, query: q);
  }

  Future<Map<String, dynamic>> getProjectTimeline(String id) {
    return _client.get(_projectTimeline(id));
  }

  Future<Map<String, dynamic>> getProjectLeads(String id) {
    return _client.get(_projectLeads(id));
  }

  Future<Map<String, dynamic>> getProjectBookings(String id) {
    return _client.get(_projectBookings(id));
  }

  Future<Map<String, dynamic>> getProjectSiteVisits(String id) {
    return _client.get(_projectSiteVisits(id));
  }

  Future<Map<String, dynamic>> searchProjects(String query) {
    return _client.get(_projectsSearch, query: {'q': query});
  }

  Future<Map<String, dynamic>> getFeaturedProjects() {
    return _client.get(_projectsFeatured);
  }

  Future<Map<String, dynamic>> getUpcomingProjects() {
    return _client.get(_projectsUpcoming);
  }

  Future<Map<String, dynamic>> getProjectPerformance(String id) {
    return _client.get(_projectPerformance(id));
  }

  Future<Map<String, dynamic>> getProjectPriceHistory(String id) {
    return _client.get(_projectPriceHistory(id));
  }

  Future<Map<String, dynamic>> updateProjectAmenities(
    String id,
    List<String> amenities,
  ) {
    return _client.patch(_projectAmenities(id), body: {'amenities': amenities});
  }

  Future<Map<String, dynamic>> updateProjectPropertyTypes(
    String id,
    List<String> propertyTypes,
  ) {
    return _client.patch(
      _projectPropertyTypes(id),
      body: {'propertyTypes': propertyTypes},
    );
  }

  // ---- Site Visit APIs ----
  Future<Map<String, dynamic>> fetchSiteVisits({Map<String, dynamic>? query}) {
    return _client.get(_siteVisits, query: query);
  }

  Future<Map<String, dynamic>> fetchSiteVisitById(String id) {
    return _client.get(_siteVisitById(id));
  }

  Future<Map<String, dynamic>> createSiteVisit(Map<String, dynamic> body) {
    return _client.post(_siteVisits, body: body);
  }

  Future<Map<String, dynamic>> updateSiteVisit(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_siteVisitById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteSiteVisit(String id) {
    return _client.delete(_siteVisitById(id));
  }

  Future<Map<String, dynamic>> updateSiteVisitStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _client.patch(
      _siteVisitStatus(id),
      body: {'status': status, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> completeSiteVisit(
    String id,
    String minutes, {
    String? feedback,
    List<String>? attachments,
  }) {
    return _client.post(
      _siteVisitComplete(id),
      body: {
        'minutes': minutes,
        if (feedback != null) 'feedback': feedback,
        if (attachments != null) 'attachments': attachments,
      },
    );
  }

  Future<Map<String, dynamic>> rescheduleSiteVisit(
    String id,
    String meetingFromIso,
    String meetingToIso, {
    String? reason,
  }) {
    return _client.post(
      _siteVisitReschedule(id),
      body: {
        'meetingFrom': meetingFromIso,
        'meetingTo': meetingToIso,
        if (reason != null) 'reason': reason,
      },
    );
  }

  Future<Map<String, dynamic>> assignSiteVisit(
    String id,
    String attenderId, {
    String? notes,
  }) {
    return _client.post(
      _siteVisitAssign(id),
      body: {'attenderId': attenderId, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> getSiteVisitStats({
    Map<String, dynamic>? query,
  }) {
    return _client.get(_siteVisitsStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysSiteVisits() {
    return _client.get(_siteVisitsToday);
  }

  Future<Map<String, dynamic>> getUpcomingSiteVisits() {
    return _client.get(_siteVisitsUpcoming);
  }

  Future<Map<String, dynamic>> getLapsedSiteVisits() {
    return _client.get(_siteVisitsLapsed);
  }

  Future<Map<String, dynamic>> getSiteVisitTimeline(String id) {
    return _client.get(_siteVisitTimeline(id));
  }

  Future<Map<String, dynamic>> getSiteVisitsByLead(String leadId) {
    return _client.get(_leadSiteVisits(leadId));
  }

  Future<Map<String, dynamic>> getSiteVisitsByCustomer(String customerId) {
    return _client.get(_customerSiteVisitsByCustomer(customerId));
  }

  Future<Map<String, dynamic>> getSiteVisitsByProject(String projectId) {
    return _client.get(_projectSiteVisitsByProject(projectId));
  }

  Future<Map<String, dynamic>> addSiteVisitFeedback(
    String id,
    String feedback, {
    List<String>? attachments,
  }) {
    return _client.post(
      _siteVisitFeedback(id),
      body: {
        'feedback': feedback,
        if (attachments != null) 'attachments': attachments,
      },
    );
  }

  Future<Map<String, dynamic>> getSiteVisitCalendar({
    Map<String, dynamic>? query,
  }) {
    return _client.get(_siteVisitCalendar, query: query);
  }

  // ---- Task APIs ----
  Future<Map<String, dynamic>> fetchTasks({Map<String, dynamic>? query}) {
    return _client.get(_tasks, query: query);
  }

  Future<Map<String, dynamic>> fetchTaskById(String id) {
    return _client.get(_taskById(id));
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> body) {
    return _client.post(_tasks, body: body);
  }

  Future<Map<String, dynamic>> updateTask(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_taskById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteTask(String id) {
    return _client.delete(_taskById(id));
  }

  Future<Map<String, dynamic>> updateTaskStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _client.patch(
      _taskStatus(id),
      body: {'status': status, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> assignTask(
    String id,
    String assignedTo, {
    String? notes,
  }) {
    return _client.post(
      _taskAssign(id),
      body: {'assignedTo': assignedTo, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> completeTask(String id, {String? notes}) {
    return _client.post(
      _taskComplete(id),
      body: {if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> cancelTask(
    String id,
    String reason, {
    String? notes,
  }) {
    return _client.post(
      _taskCancel(id),
      body: {'reason': reason, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> getTaskStats({Map<String, dynamic>? query}) {
    return _client.get(_tasksStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysTasks() {
    return _client.get(_tasksToday);
  }

  Future<Map<String, dynamic>> getOverdueTasks() {
    return _client.get(_tasksOverdue);
  }

  Future<Map<String, dynamic>> getMyTasks() {
    return _client.get(_tasksMy);
  }

  Future<Map<String, dynamic>> getTasksByLead(String leadId) {
    return _client.get(_leadTasks(leadId));
  }

  Future<Map<String, dynamic>> getTasksByCustomer(String customerId) {
    return _client.get(_customerTasks(customerId));
  }

  Future<Map<String, dynamic>> getTasksByProject(String projectId) {
    return _client.get(_projectTasks(projectId));
  }

  Future<Map<String, dynamic>> getTasksBySiteVisit(String siteVisitId) {
    return _client.get(_siteVisitTasks(siteVisitId));
  }

  Future<Map<String, dynamic>> getTaskTimeline(String id) {
    return _client.get(_taskTimeline(id));
  }

  Future<Map<String, dynamic>> addTaskComment(
    String id,
    String comment, {
    List<String>? attachments,
  }) {
    return _client.post(
      _taskComments(id),
      body: {
        'comment': comment,
        if (attachments != null) 'attachments': attachments,
      },
    );
  }

  Future<Map<String, dynamic>> getTaskComments(String id) {
    return _client.get(_taskComments(id));
  }

  Future<Map<String, dynamic>> searchTasks(String query) {
    return _client.get(_tasksSearch, query: {'q': query});
  }

  Future<Map<String, dynamic>> getUpcomingTasks({int days = 7}) {
    return _client.get(_tasksUpcoming, query: {'days': days.toString()});
  }

  Future<Map<String, dynamic>> getTasksByPriority(String priority) {
    return _client.get(_tasksByPriority, query: {'priority': priority});
  }

  Future<Map<String, dynamic>> getTasksByType(String type) {
    return _client.get(_tasksByType, query: {'type': type});
  }

  // ---- Developer APIs ----
  Future<Map<String, dynamic>> fetchDevelopers({Map<String, dynamic>? query}) {
    return _client.get(_developers, query: query);
  }

  Future<Map<String, dynamic>> fetchDeveloperById(String id) {
    return _client.get(_developerById(id));
  }

  Future<Map<String, dynamic>> createDeveloper(Map<String, dynamic> body) {
    return _client.post(_developers, body: body);
  }

  Future<Map<String, dynamic>> updateDeveloper(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_developerById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteDeveloper(String id) {
    return _client.delete(_developerById(id));
  }

  Future<Map<String, dynamic>> updateDeveloperStatus(String id, bool isActive) {
    return _client.patch(_developerStatus(id), body: {'isActive': isActive});
  }

  Future<Map<String, dynamic>> getDeveloperStats() {
    return _client.get(_developersStats);
  }

  Future<Map<String, dynamic>> getDeveloperProjects(String id) {
    return _client.get(_developerProjects(id));
  }

  Future<Map<String, dynamic>> addDeveloperContact(
    String id,
    Map<String, dynamic> contact,
  ) {
    return _client.post(_developerContacts(id), body: contact);
  }

  Future<Map<String, dynamic>> updateDeveloperContact(
    String id,
    String contactId,
    Map<String, dynamic> contact,
  ) {
    return _client.put(_developerContactById(id, contactId), body: contact);
  }

  Future<Map<String, dynamic>> deleteDeveloperContact(
    String id,
    String contactId,
  ) {
    return _client.delete(_developerContactById(id, contactId));
  }

  Future<Map<String, dynamic>> setPrimaryDeveloperContact(
    String id,
    String contactId,
  ) {
    return _client.post(_developerContactPrimary(id, contactId));
  }

  Future<Map<String, dynamic>> getDeveloperTimeline(String id) {
    return _client.get(_developerTimeline(id));
  }

  Future<Map<String, dynamic>> searchDevelopers(String query) {
    return _client.get(_developersSearch, query: {'q': query});
  }

  Future<Map<String, dynamic>> getDevelopersByCity(String city) {
    return _client.get(_developersByCity, query: {'city': city});
  }

  Future<Map<String, dynamic>> getReraRegisteredDevelopers() {
    return _client.get(_developersReraRegistered);
  }

  Future<Map<String, dynamic>> getDeveloperPerformance(String id) {
    return _client.get(_developerPerformance(id));
  }

  Future<Map<String, dynamic>> mergeDevelopers(
    String primaryDeveloperId,
    List<String> duplicateDeveloperIds,
  ) {
    return _client.post(
      _developersMerge,
      body: {
        'primaryDeveloperId': primaryDeveloperId,
        'duplicateDeveloperIds': duplicateDeveloperIds,
      },
    );
  }

  Future<Map<String, dynamic>> getDeveloperLeads(String id) {
    return _client.get(_developerLeads(id));
  }

  Future<Map<String, dynamic>> getDeveloperBookings(String id) {
    return _client.get(_developerBookings(id));
  }

  // ---- Booking APIs ----
  Future<Map<String, dynamic>> fetchBookings({Map<String, dynamic>? query}) {
    return _client.get(_bookings, query: query);
  }

  Future<Map<String, dynamic>> fetchBookingById(String id) {
    return _client.get(_bookingById(id));
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body) {
    return _client.post(_bookings, body: body);
  }

  Future<Map<String, dynamic>> updateBooking(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_bookingById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteBooking(String id) {
    return _client.delete(_bookingById(id));
  }

  Future<Map<String, dynamic>> updateBookingStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _client.patch(
      _bookingStatus(id),
      body: {'status': status, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> approveBooking(
    String id,
    String approvedBy, {
    String? notes,
  }) {
    return _client.post(
      _bookingApprove(id),
      body: {'approvedBy': approvedBy, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> cancelBooking(
    String id,
    String reason, {
    String? notes,
  }) {
    return _client.post(
      _bookingCancel(id),
      body: {'reason': reason, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> getBookingStats({Map<String, dynamic>? query}) {
    return _client.get(_bookingsStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysBookings() {
    return _client.get(_bookingsToday);
  }

  Future<Map<String, dynamic>> getPendingApprovals() {
    return _client.get(_bookingsPendingApprovals);
  }

  Future<Map<String, dynamic>> getBookingTimeline(String id) {
    return _client.get(_bookingTimeline(id));
  }

  Future<Map<String, dynamic>> updateBookingPayment(
    String id, {
    double? advanceAmount,
    double? balanceAmount,
    String? paymentMode,
    String? paymentReference,
  }) {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (advanceAmount != null) body['advanceAmount'] = advanceAmount;
    if (balanceAmount != null) body['balanceAmount'] = balanceAmount;
    if (paymentMode != null) body['paymentMode'] = paymentMode;
    if (paymentReference != null) body['paymentReference'] = paymentReference;
    return _client.patch(_bookingPayment(id), body: body);
  }

  Future<Map<String, dynamic>> generateBookingReceipt(String id) {
    return _client.get(_bookingReceipt(id));
  }

  Future<Map<String, dynamic>> getCommissionReport({
    Map<String, dynamic>? query,
  }) {
    return _client.get(_bookingCommissionReport, query: query);
  }

  Future<Map<String, dynamic>> searchBookingsBySrNo(String srNo) {
    return _client.get(_bookingSearchSrNo, query: {'srNo': srNo});
  }

  // ---- Notification APIs ----
  Future<Map<String, dynamic>> fetchNotifications({
    Map<String, dynamic>? query,
  }) {
    return _client.get(_notifications, query: query);
  }

  Future<Map<String, dynamic>> fetchNotificationById(String id) {
    return _client.get(_notificationById(id));
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> body) {
    return _client.post(_notifications, body: body);
  }

  Future<Map<String, dynamic>> updateNotification(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_notificationById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteNotification(String id) {
    return _client.delete(_notificationById(id));
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) {
    return _client.patch(_notificationRead(id));
  }

  Future<Map<String, dynamic>> markNotificationUnread(String id) {
    return _client.patch(_notificationUnread(id));
  }

  Future<Map<String, dynamic>> archiveNotification(String id) {
    return _client.patch(_notificationArchive(id));
  }

  Future<Map<String, dynamic>> unarchiveNotification(String id) {
    return _client.patch(_notificationUnarchive(id));
  }

  Future<Map<String, dynamic>> markAllNotificationsAsRead() {
    return _client.post(_notificationsMarkAllRead);
  }

  Future<Map<String, dynamic>> getUnreadNotificationCount() {
    return _client.get(_notificationsUnreadCount);
  }

  Future<Map<String, dynamic>> getNotificationStats({
    Map<String, dynamic>? query,
  }) {
    return _client.get(_notificationsStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysNotifications() {
    return _client.get(_notificationsToday);
  }

  Future<Map<String, dynamic>> getUnreadNotifications() {
    return _client.get(_notificationsUnread);
  }

  Future<Map<String, dynamic>> getArchivedNotifications() {
    return _client.get(_notificationsArchived);
  }

  Future<Map<String, dynamic>> searchNotifications(String query) {
    return _client.get(_notificationsSearch, query: {'q': query});
  }

  Future<Map<String, dynamic>> getNotificationsByType(String type) {
    return _client.get(_notificationsByType, query: {'type': type});
  }

  Future<Map<String, dynamic>> getNotificationsByPriority(String priority) {
    return _client.get(_notificationsByPriority, query: {'priority': priority});
  }

  Future<Map<String, dynamic>> clearAllNotifications() {
    return _client.delete(_notificationsClearAll);
  }

  Future<Map<String, dynamic>> getNotificationPreferences() {
    return _client.get(_notificationsPreferences);
  }

  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> prefs,
  ) {
    return _client.put(_notificationsPreferences, body: prefs);
  }

  // ---- Ticket APIs ----
  Future<Map<String, dynamic>> fetchTickets({Map<String, dynamic>? query}) {
    return _client.get(_tickets, query: query);
  }

  Future<Map<String, dynamic>> fetchTicketById(String id) {
    return _client.get(_ticketById(id));
  }

  Future<Map<String, dynamic>> createTicket(Map<String, dynamic> body) {
    return _client.post(_tickets, body: body);
  }

  Future<Map<String, dynamic>> updateTicket(
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.put(_ticketById(id), body: body);
  }

  Future<Map<String, dynamic>> deleteTicket(String id) {
    return _client.delete(_ticketById(id));
  }

  Future<Map<String, dynamic>> updateTicketStatus(
    String id,
    String status, {
    String? notes,
  }) {
    return _client.patch(
      _ticketStatus(id),
      body: {'status': status, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> assignTicket(
    String id,
    String assignedTo, {
    String? notes,
  }) {
    return _client.post(
      _ticketAssign(id),
      body: {'assignedTo': assignedTo, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> resolveTicket(
    String id,
    String resolution, {
    String? notes,
  }) {
    return _client.post(
      _ticketResolve(id),
      body: {'resolution': resolution, if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> closeTicket(String id, {String? notes}) {
    return _client.post(
      _ticketClose(id),
      body: {if (notes != null) 'notes': notes},
    );
  }

  Future<Map<String, dynamic>> getTicketStats({Map<String, dynamic>? query}) {
    return _client.get(_ticketsStats, query: query);
  }

  Future<Map<String, dynamic>> getTodaysTickets() {
    return _client.get(_ticketsToday);
  }

  Future<Map<String, dynamic>> getMyTickets() {
    return _client.get(_ticketsMy);
  }

  Future<Map<String, dynamic>> getTicketTimeline(String id) {
    return _client.get(_ticketTimeline(id));
  }

  Future<Map<String, dynamic>> addTicketComment(
    String id,
    String comment, {
    List<String>? attachments,
  }) {
    return _client.post(
      _ticketComments(id),
      body: {
        'comment': comment,
        if (attachments != null) 'attachments': attachments,
      },
    );
  }

  Future<Map<String, dynamic>> getTicketComments(String id) {
    return _client.get(_ticketComments(id));
  }

  Future<Map<String, dynamic>> searchTickets(String query) {
    return _client.get(_ticketsSearch, query: {'q': query});
  }

  Future<Map<String, dynamic>> getTicketsByLead(String leadId) {
    return _client.get(_leadTickets(leadId));
  }

  Future<Map<String, dynamic>> getTicketsByCustomer(String customerId) {
    return _client.get(_customerTickets(customerId));
  }

  Future<Map<String, dynamic>> getTicketsByProject(String projectId) {
    return _client.get(_projectTickets(projectId));
  }

  // ---- Configuration ----
  /// Optionally override the base URL used by the underlying ApiClient.
  static void configure({String? newBaseUrl}) {
    if (newBaseUrl != null) {
      baseUrl = newBaseUrl;
    }
  }
}
