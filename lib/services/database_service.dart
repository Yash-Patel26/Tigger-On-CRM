import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

class DatabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Lead operations
  static Future<List<Lead>> getLeads({
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
      var query = _client.from('leads').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'customer_name.ilike.%$search%,lead_id.ilike.%$search%,project_name.ilike.%$search%',
        );
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (subStatus != null) {
        query = query.eq('sub_status', subStatus.name);
      }

      if (source != null) {
        query = query.eq('source', source.name);
      }

      if (propertyType != null) {
        query = query.eq('property_type', propertyType.name);
      }

      if (categoryType != null) {
        query = query.eq('category_type', categoryType.name);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Lead.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  static Future<Lead?> getLeadById(String id) async {
    try {
      final response = await _client
          .from('leads')
          .select('*')
          .eq('id', id)
          .single();

      return Lead.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  static Future<Lead> createLead(Lead lead) async {
    try {
      final response = await _client
          .from('leads')
          .insert(lead.toJson())
          .select()
          .single();

      return Lead.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  static Future<Lead> updateLead(String id, Lead lead) async {
    try {
      final response = await _client
          .from('leads')
          .update(lead.toJson())
          .eq('id', id)
          .select()
          .single();

      return Lead.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  static Future<void> deleteLead(String id) async {
    try {
      await _client.from('leads').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }

  // Customer operations
  static Future<List<Customer>> getCustomers({
    String? search,
    String? assignedTo,
    String? projectType,
    String? projectId,
    String? city,
    String? state,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('customers').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'name.ilike.%$search%,phone.ilike.%$search%,email.ilike.%$search%',
        );
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (projectType != null) {
        query = query.eq('project_type', projectType);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (city != null) {
        query = query.eq('city', city);
      }

      if (state != null) {
        query = query.eq('state', state);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Project operations
  static Future<List<Project>> getProjects({
    String? search,
    ProjectType? type,
    ProjectStatus? status,
    String? developerId,
    String? city,
    String? state,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    List<String>? propertyTypes,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('projects').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,description.ilike.%$search%');
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (developerId != null) {
        query = query.eq('developer_id', developerId);
      }

      if (city != null) {
        query = query.eq('city', city);
      }

      if (state != null) {
        query = query.eq('state', state);
      }

      if (minPrice != null) {
        query = query.gte('starting_price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('max_price', maxPrice);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  // Developer operations
  static Future<List<Developer>> getDevelopers({
    String? search,
    bool? isActive,
    String? city,
    String? state,
    CompanyType? companyType,
    bool? isReraRegistered,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('developers').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,website.ilike.%$search%');
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (city != null) {
        query = query.eq('city', city);
      }

      if (state != null) {
        query = query.eq('state', state);
      }

      if (companyType != null) {
        query = query.eq('company_type', companyType.name);
      }

      if (isReraRegistered != null) {
        query = query.eq('is_rera_registered', isReraRegistered);
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List)
          .map((json) => Developer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch developers: $e');
    }
  }

  // Booking operations
  static Future<List<Booking>> getBookings({
    String? search,
    BookingStatus? status,
    String? customerId,
    String? leadId,
    String? projectId,
    String? assignedTo,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('bookings').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('sr_no.ilike.%$search%,customer_name.ilike.%$search%');
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (leadId != null) {
        query = query.eq('lead_id', leadId);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Site Visit operations
  static Future<List<SiteVisit>> getSiteVisits({
    String? search,
    SiteVisitStatus? status,
    String? leadId,
    String? customerId,
    String? projectId,
    String? assignedTo,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('site_visits').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('purpose.ilike.%$search%,notes.ilike.%$search%');
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (leadId != null) {
        query = query.eq('lead_id', leadId);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List)
          .map((json) => SiteVisit.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch site visits: $e');
    }
  }

  // Task operations
  static Future<List<Task>> getTasks({
    String? search,
    TaskStatus? status,
    TaskPriority? priority,
    TaskType? type,
    String? assignedTo,
    String? createdBy,
    String? leadId,
    String? customerId,
    String? projectId,
    String? siteVisitId,
    DateTime? fromDate,
    DateTime? toDate,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('tasks').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (createdBy != null) {
        query = query.eq('created_by', createdBy);
      }

      if (leadId != null) {
        query = query.eq('lead_id', leadId);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (siteVisitId != null) {
        query = query.eq('site_visit_id', siteVisitId);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      if (dueDateFrom != null) {
        query = query.gte('due_date', dueDateFrom.toIso8601String());
      }

      if (dueDateTo != null) {
        query = query.lte('due_date', dueDateTo.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Ticket operations
  static Future<List<Ticket>> getTickets({
    String? search,
    TicketStatus? status,
    TicketPriority? priority,
    TicketType? type,
    ServiceType? serviceType,
    String? assignedTo,
    String? createdBy,
    String? leadId,
    String? customerId,
    String? projectId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('tickets').select('*');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'ticket_number.ilike.%$search%,issue_description.ilike.%$search%',
        );
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      if (type != null) {
        query = query.eq('type', type.name);
      }

      if (serviceType != null) {
        query = query.eq('service_type', serviceType.name);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      if (createdBy != null) {
        query = query.eq('created_by', createdBy);
      }

      if (leadId != null) {
        query = query.eq('lead_id', leadId);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      // Apply pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to) as PostgrestFilterBuilder<PostgrestList>;

      // Order by created_at desc
      query =
          query.order('created_at', ascending: false)
              as PostgrestFilterBuilder<PostgrestList>;

      final response = await query;

      return (response as List).map((json) => Ticket.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tickets: $e');
    }
  }

  // Dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get today's date range
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Get counts for today (fetch IDs and use length for compatibility)
      final todayLeadsList = await _client
          .from('leads')
          .select('id')
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String());

      final todayFollowUpsList = await _client
          .from('leads')
          .select('id')
          .gte('last_follow_up_date', todayStart.toIso8601String())
          .lt('last_follow_up_date', todayEnd.toIso8601String());

      final todaySiteVisitsList = await _client
          .from('site_visits')
          .select('id')
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String());

      final todayBookingsList = await _client
          .from('bookings')
          .select('id')
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String());

      final totalFollowUpsList = await _client
          .from('leads')
          .select('id')
          .not('last_follow_up_date', 'is', null);

      final totalSiteVisitsList = await _client
          .from('site_visits')
          .select('id');

      final totalBookingsList = await _client.from('bookings').select('id');

      final totalCustomersList = await _client.from('customers').select('id');

      return {
        'today': {
          'followUps': (todayFollowUpsList as List).length,
          'hotLeads': 0,
          'siteVisits': (todaySiteVisitsList as List).length,
          'bookings': (todayBookingsList as List).length,
          'customers': (todayLeadsList as List).length, // placeholder
          'disqualified': 0,
        },
        'total': {
          'followUps': (totalFollowUpsList as List).length,
          'hotLeads': 0,
          'siteVisits': (totalSiteVisitsList as List).length,
          'bookings': (totalBookingsList as List).length,
          'customers': (totalCustomersList as List).length,
          'disqualified': 0,
        },
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}
