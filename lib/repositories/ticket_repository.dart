import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import '../services/api_service.dart';

class TicketRepository {
  final TicketService _ticketService;

  TicketRepository({TicketService? ticketService})
    : _ticketService = ticketService ?? TicketService();

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
    return _ticketService.getTickets(
      search: search,
      status: status,
      priority: priority,
      ticketType: ticketType,
      serviceType: serviceType,
      assignedTo: assignedTo,
      leadId: leadId,
      customerId: customerId,
      projectId: projectId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Ticket>> getTicketById(String id) async {
    return _ticketService.getTicket(id);
  }

  Future<ApiResponse<Ticket>> createTicket(Ticket ticket) async {
    return _ticketService.createTicket(ticket);
  }

  Future<ApiResponse<Ticket>> updateTicket(String id, Ticket ticket) async {
    return _ticketService.updateTicket(id, ticket);
  }

  Future<ApiResponse<void>> deleteTicket(String id) async {
    return _ticketService.deleteTicket(id);
  }

  Future<ApiResponse<Ticket>> updateTicketStatus(
    String ticketId,
    TicketStatus status,
    String? notes,
  ) async {
    return _ticketService.updateTicketStatus(ticketId, status, notes);
  }

  Future<ApiResponse<Ticket>> assignTicket(
    String ticketId,
    String assignedTo,
    String? notes,
  ) async {
    return _ticketService.assignTicket(ticketId, assignedTo, notes);
  }

  Future<ApiResponse<Ticket>> resolveTicket(
    String ticketId,
    String resolution,
    String? notes,
  ) async {
    return _ticketService.resolveTicket(ticketId, resolution, notes);
  }

  Future<ApiResponse<Ticket>> closeTicket(
    String ticketId,
    String? notes,
  ) async {
    return _ticketService.closeTicket(ticketId, notes);
  }

  Future<ApiResponse<Map<String, dynamic>>> getTicketStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
    String? serviceType,
  }) async {
    return _ticketService.getTicketStats(
      fromDate: fromDate,
      toDate: toDate,
      assignedTo: assignedTo,
      serviceType: serviceType,
    );
  }

  Future<ApiResponse<List<Ticket>>> getTodaysTickets() async {
    return _ticketService.getTodaysTickets();
  }

  Future<ApiResponse<List<Ticket>>> getMyTickets() async {
    return _ticketService.getMyTickets();
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTicketTimeline(
    String ticketId,
  ) async {
    return _ticketService.getTicketTimeline(ticketId);
  }

  Future<ApiResponse<Ticket>> addComment(
    String ticketId,
    String comment,
    List<String>? attachments,
  ) async {
    return _ticketService.addComment(ticketId, comment, attachments);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTicketComments(
    String ticketId,
  ) async {
    return _ticketService.getTicketComments(ticketId);
  }

  Future<ApiResponse<List<Ticket>>> searchTickets(String query) async {
    return _ticketService.searchTickets(query);
  }

  Future<ApiResponse<List<Ticket>>> getTicketsByLead(String leadId) async {
    return _ticketService.getTicketsByLead(leadId);
  }

  Future<ApiResponse<List<Ticket>>> getTicketsByCustomer(
    String customerId,
  ) async {
    return _ticketService.getTicketsByCustomer(customerId);
  }

  Future<ApiResponse<List<Ticket>>> getTicketsByProject(
    String projectId,
  ) async {
    return _ticketService.getTicketsByProject(projectId);
  }
}
