import '../models/customer_model.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService;

  CustomerService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all customers with optional filters
  Future<ApiResponse<List<Customer>>> getCustomers({
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
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (assignedTo != null) {
      queryParams['assignedTo'] = assignedTo;
    }
    if (projectType != null) {
      queryParams['projectType'] = projectType;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }
    if (city != null) {
      queryParams['city'] = city;
    }
    if (state != null) {
      queryParams['state'] = state;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    return await _apiService.get<List<Customer>>(
      '/customers',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get customer by ID
  Future<ApiResponse<Customer>> getCustomer(String id) async {
    return await _apiService.get<Customer>(
      '/customers/$id',
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new customer
  Future<ApiResponse<Customer>> createCustomer(Customer customer) async {
    return await _apiService.post<Customer>(
      '/customers',
      body: customer.toJson(),
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update customer
  Future<ApiResponse<Customer>> updateCustomer(
    String id,
    Customer customer,
  ) async {
    return await _apiService.put<Customer>(
      '/customers/$id',
      body: customer.toJson(),
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete customer
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    return await _apiService.delete<void>('/customers/$id');
  }

  // Assign customer to user
  Future<ApiResponse<Customer>> assignCustomer(
    String customerId,
    String userId,
  ) async {
    return await _apiService.post<Customer>(
      '/customers/$customerId/assign',
      body: {'assignedTo': userId},
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get customer statistics
  Future<ApiResponse<Map<String, dynamic>>> getCustomerStats({
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
      '/customers/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's customers
  Future<ApiResponse<List<Customer>>> getTodaysCustomers() async {
    return await _apiService.get<List<Customer>>(
      '/customers/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get customer timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerTimeline(
    String customerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/customers/$customerId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get customer leads
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerLeads(
    String customerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/customers/$customerId/leads',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get customer bookings
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerBookings(
    String customerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/customers/$customerId/bookings',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get customer site visits
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerSiteVisits(
    String customerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/customers/$customerId/site-visits',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Update customer contact info
  Future<ApiResponse<Customer>> updateContactInfo(
    String customerId,
    String? phone,
    String? email,
    String? address,
  ) async {
    return await _apiService.patch<Customer>(
      '/customers/$customerId/contact',
      body: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      },
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Merge duplicate customers
  Future<ApiResponse<Customer>> mergeCustomers(
    String primaryCustomerId,
    List<String> duplicateCustomerIds,
  ) async {
    return await _apiService.post<Customer>(
      '/customers/merge',
      body: {
        'primaryCustomerId': primaryCustomerId,
        'duplicateCustomerIds': duplicateCustomerIds,
      },
      fromJson: (json) =>
          Customer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Search customers by phone or email
  Future<ApiResponse<List<Customer>>> searchCustomers(String query) async {
    return await _apiService.get<List<Customer>>(
      '/customers/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
