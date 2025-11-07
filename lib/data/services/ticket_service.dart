import '../models/ticket_model.dart';
import 'api_service.dart';

class TicketService {
  final ApiService _apiService;

  TicketService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all tickets with optional filters
  Future<ApiResponse<List<Ticket>>> getTickets({
    String? search,
    TicketStatus? status,
    TicketPriority? priority,
    TicketType? ticketType,
    ServiceType? serviceType,
    String? assignedTo,
    String? leadId,
    String? customerId,
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
    if (priority != null) {
      queryParams['priority'] = priority.name;
    }
    if (ticketType != null) {
      queryParams['ticketType'] = ticketType.name;
    }
    if (serviceType != null) {
      queryParams['serviceType'] = serviceType.name;
    }
    if (assignedTo != null && assignedTo.isNotEmpty) {
      // Only pass assignedTo if it's a valid UUID (not a name string)
      // Check if it looks like a UUID
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(assignedTo);
      if (isUuid) {
        queryParams['assignedTo'] = assignedTo;
      }
    }
    if (leadId != null) {
      queryParams['leadId'] = leadId;
    }
    if (customerId != null) {
      queryParams['customerId'] = customerId;
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

    return await _apiService.get<List<Ticket>>(
      '/tickets',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get ticket by ID
  Future<ApiResponse<Ticket>> getTicket(String id) async {
    return await _apiService.get<Ticket>(
      '/tickets/$id',
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new ticket
  Future<ApiResponse<Ticket>> createTicket(Ticket ticket) async {
    return await _apiService.post<Ticket>(
      '/tickets',
      body: ticket.toJson(),
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update ticket
  Future<ApiResponse<Ticket>> updateTicket(String id, Ticket ticket) async {
    return await _apiService.put<Ticket>(
      '/tickets/$id',
      body: ticket.toJson(),
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete ticket
  Future<ApiResponse<void>> deleteTicket(String id) async {
    return await _apiService.delete<void>('/tickets/$id');
  }

  // Update ticket status
  Future<ApiResponse<Ticket>> updateTicketStatus(
    String ticketId,
    TicketStatus status,
    String? notes,
  ) async {
    return await _apiService.patch<Ticket>(
      '/tickets/$ticketId/status',
      body: {'status': status.name, if (notes != null) 'notes': notes},
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Assign ticket
  Future<ApiResponse<Ticket>> assignTicket(
    String ticketId,
    String assignedTo,
    String? notes,
  ) async {
    return await _apiService.post<Ticket>(
      '/tickets/$ticketId/assign',
      body: {'assignedTo': assignedTo, if (notes != null) 'notes': notes},
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Resolve ticket
  Future<ApiResponse<Ticket>> resolveTicket(
    String ticketId,
    String resolution,
    String? notes,
  ) async {
    return await _apiService.post<Ticket>(
      '/tickets/$ticketId/resolve',
      body: {'resolution': resolution, if (notes != null) 'notes': notes},
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Close ticket
  Future<ApiResponse<Ticket>> closeTicket(
    String ticketId,
    String? notes,
  ) async {
    return await _apiService.post<Ticket>(
      '/tickets/$ticketId/close',
      body: {if (notes != null) 'notes': notes},
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get ticket statistics
  Future<ApiResponse<Map<String, dynamic>>> getTicketStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
    String? serviceType,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (assignedTo != null && assignedTo.isNotEmpty) {
      // Only pass assignedTo if it's a valid UUID (not a name string)
      // Check if it looks like a UUID
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(assignedTo);
      if (isUuid) {
        queryParams['assignedTo'] = assignedTo;
      }
    }
    if (serviceType != null) {
      queryParams['serviceType'] = serviceType;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/tickets/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's tickets
  Future<ApiResponse<List<Ticket>>> getTodaysTickets() async {
    return await _apiService.get<List<Ticket>>(
      '/tickets/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get my tickets
  Future<ApiResponse<List<Ticket>>> getMyTickets() async {
    return await _apiService.get<List<Ticket>>(
      '/tickets/my-tickets',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get ticket timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getTicketTimeline(
    String ticketId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/tickets/$ticketId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Add ticket comment
  Future<ApiResponse<Ticket>> addComment(
    String ticketId,
    String comment,
    List<String>? attachments,
  ) async {
    return await _apiService.post<Ticket>(
      '/tickets/$ticketId/comments',
      body: {
        'comment': comment,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) => Ticket.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get ticket comments
  Future<ApiResponse<List<Map<String, dynamic>>>> getTicketComments(
    String ticketId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/tickets/$ticketId/comments',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Search tickets
  Future<ApiResponse<List<Ticket>>> searchTickets(String query) async {
    return await _apiService.get<List<Ticket>>(
      '/tickets/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tickets by lead
  Future<ApiResponse<List<Ticket>>> getTicketsByLead(String leadId) async {
    return await _apiService.get<List<Ticket>>(
      '/leads/$leadId/tickets',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tickets by customer
  Future<ApiResponse<List<Ticket>>> getTicketsByCustomer(
    String customerId,
  ) async {
    return await _apiService.get<List<Ticket>>(
      '/customers/$customerId/tickets',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tickets by project
  Future<ApiResponse<List<Ticket>>> getTicketsByProject(
    String projectId,
  ) async {
    return await _apiService.get<List<Ticket>>(
      '/projects/$projectId/tickets',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
