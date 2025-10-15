import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../services/api_service.dart';

class CustomerRepository {
  final CustomerService _customerService;

  CustomerRepository({CustomerService? customerService})
    : _customerService = customerService ?? CustomerService();

  // Get all customers with caching
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
    bool forceRefresh = false,
  }) async {
    // In a real implementation, you would check local cache first
    // and only fetch from API if cache is empty or forceRefresh is true

    return await _customerService.getCustomers(
      search: search,
      assignedTo: assignedTo,
      projectType: projectType,
      projectId: projectId,
      city: city,
      state: state,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  // Get customer by ID with caching
  Future<ApiResponse<Customer>> getCustomer(
    String id, {
    bool forceRefresh = false,
  }) async {
    // Check local cache first
    // if (!forceRefresh && _localCache.containsKey(id)) {
    //   return ApiResponse.success(_localCache[id]);
    // }

    final response = await _customerService.getCustomer(id);

    // Cache the result
    // if (response.success && response.data != null) {
    //   _localCache[id] = response.data!;
    // }

    return response;
  }

  // Create customer
  Future<ApiResponse<Customer>> createCustomer(Customer customer) async {
    final response = await _customerService.createCustomer(customer);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[response.data!.id] = response.data!;
    // }

    return response;
  }

  // Update customer
  Future<ApiResponse<Customer>> updateCustomer(
    String id,
    Customer customer,
  ) async {
    final response = await _customerService.updateCustomer(id, customer);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[id] = response.data!;
    // }

    return response;
  }

  // Delete customer
  Future<ApiResponse<void>> deleteCustomer(String id) async {
    final response = await _customerService.deleteCustomer(id);

    // Remove from local cache if successful
    // if (response.success) {
    //   _localCache.remove(id);
    // }

    return response;
  }

  // Assign customer
  Future<ApiResponse<Customer>> assignCustomer(
    String customerId,
    String userId,
  ) async {
    final response = await _customerService.assignCustomer(customerId, userId);

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[customerId] = response.data!;
    // }

    return response;
  }

  // Get customer statistics
  Future<ApiResponse<Map<String, dynamic>>> getCustomerStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
  }) async {
    return await _customerService.getCustomerStats(
      fromDate: fromDate,
      toDate: toDate,
      assignedTo: assignedTo,
    );
  }

  // Get today's customers
  Future<ApiResponse<List<Customer>>> getTodaysCustomers() async {
    return await _customerService.getTodaysCustomers();
  }

  // Get customer timeline
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerTimeline(
    String customerId,
  ) async {
    return await _customerService.getCustomerTimeline(customerId);
  }

  // Get customer leads
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerLeads(
    String customerId,
  ) async {
    return await _customerService.getCustomerLeads(customerId);
  }

  // Get customer bookings
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerBookings(
    String customerId,
  ) async {
    return await _customerService.getCustomerBookings(customerId);
  }

  // Get customer site visits
  Future<ApiResponse<List<Map<String, dynamic>>>> getCustomerSiteVisits(
    String customerId,
  ) async {
    return await _customerService.getCustomerSiteVisits(customerId);
  }

  // Update customer contact info
  Future<ApiResponse<Customer>> updateContactInfo(
    String customerId,
    String? phone,
    String? email,
    String? address,
  ) async {
    final response = await _customerService.updateContactInfo(
      customerId,
      phone,
      email,
      address,
    );

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[customerId] = response.data!;
    // }

    return response;
  }

  // Merge duplicate customers
  Future<ApiResponse<Customer>> mergeCustomers(
    String primaryCustomerId,
    List<String> duplicateCustomerIds,
  ) async {
    final response = await _customerService.mergeCustomers(
      primaryCustomerId,
      duplicateCustomerIds,
    );

    // Update local cache if successful
    // if (response.success && response.data != null) {
    //   _localCache[primaryCustomerId] = response.data!;
    //   // Remove duplicate customers from cache
    //   for (final id in duplicateCustomerIds) {
    //     _localCache.remove(id);
    //   }
    // }

    return response;
  }

  // Search customers
  Future<ApiResponse<List<Customer>>> searchCustomers(String query) async {
    return await _customerService.searchCustomers(query);
  }

  // Search customers locally (if cached)
  List<Customer> searchCustomersLocally(
    String query,
    List<Customer> customers,
  ) {
    if (query.isEmpty) return customers;

    final queryLower = query.toLowerCase();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(queryLower) ||
          customer.email.toLowerCase().contains(queryLower) ||
          customer.phone.contains(query) ||
          (customer.city?.toLowerCase().contains(queryLower) ?? false) ||
          (customer.state?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  // Filter customers locally
  List<Customer> filterCustomersLocally(
    List<Customer> customers, {
    String? assignedTo,
    String? projectType,
    String? projectId,
    String? city,
    String? state,
    bool? isActive,
  }) {
    return customers.where((customer) {
      if (assignedTo != null && customer.assignedTo != assignedTo) return false;
      if (projectType != null && customer.projectType != projectType) {
        return false;
      }
      if (projectId != null && customer.projectId != projectId) return false;
      if (city != null && customer.city != city) return false;
      if (state != null && customer.state != state) return false;
      if (isActive != null && customer.isActive != isActive) return false;
      return true;
    }).toList();
  }

  // Get customers by project
  List<Customer> getCustomersByProject(
    List<Customer> customers,
    String projectId,
  ) {
    return customers
        .where((customer) => customer.projectId == projectId)
        .toList();
  }

  // Get customers by city
  List<Customer> getCustomersByCity(List<Customer> customers, String city) {
    return customers.where((customer) => customer.city == city).toList();
  }

  // Get active customers
  List<Customer> getActiveCustomers(List<Customer> customers) {
    return customers.where((customer) => customer.isActive).toList();
  }

  // Clear local cache
  void clearCache() {
    // _localCache.clear();
  }
}
