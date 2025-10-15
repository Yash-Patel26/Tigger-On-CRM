import '../models/developer_model.dart';
import 'api_service.dart';

class DeveloperService {
  final ApiService _apiService;

  DeveloperService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all developers with optional filters
  Future<ApiResponse<List<Developer>>> getDevelopers({
    String? search,
    bool? isActive,
    String? city,
    String? state,
    CompanyType? companyType,
    bool? isReraRegistered,
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
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }
    if (city != null) {
      queryParams['city'] = city;
    }
    if (state != null) {
      queryParams['state'] = state;
    }
    if (companyType != null) {
      queryParams['companyType'] = companyType.name;
    }
    if (isReraRegistered != null) {
      queryParams['isReraRegistered'] = isReraRegistered.toString();
    }

    return await _apiService.get<List<Developer>>(
      '/developers',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Developer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get developer by ID
  Future<ApiResponse<Developer>> getDeveloper(String id) async {
    return await _apiService.get<Developer>(
      '/developers/$id',
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new developer
  Future<ApiResponse<Developer>> createDeveloper(Developer developer) async {
    return await _apiService.post<Developer>(
      '/developers',
      body: developer.toJson(),
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update developer
  Future<ApiResponse<Developer>> updateDeveloper(
    String id,
    Developer developer,
  ) async {
    return await _apiService.put<Developer>(
      '/developers/$id',
      body: developer.toJson(),
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete developer
  Future<ApiResponse<void>> deleteDeveloper(String id) async {
    return await _apiService.delete<void>('/developers/$id');
  }

  // Update developer status
  Future<ApiResponse<Developer>> updateDeveloperStatus(
    String developerId,
    bool isActive,
  ) async {
    return await _apiService.patch<Developer>(
      '/developers/$developerId/status',
      body: {'isActive': isActive},
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get developer statistics
  Future<ApiResponse<Map<String, dynamic>>> getDeveloperStats() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/developers/stats',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get developer projects
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperProjects(
    String developerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/developers/$developerId/projects',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Add developer contact
  Future<ApiResponse<Developer>> addDeveloperContact(
    String developerId,
    DeveloperContact contact,
  ) async {
    return await _apiService.post<Developer>(
      '/developers/$developerId/contacts',
      body: contact.toJson(),
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update developer contact
  Future<ApiResponse<Developer>> updateDeveloperContact(
    String developerId,
    String contactId,
    DeveloperContact contact,
  ) async {
    return await _apiService.put<Developer>(
      '/developers/$developerId/contacts/$contactId',
      body: contact.toJson(),
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete developer contact
  Future<ApiResponse<Developer>> deleteDeveloperContact(
    String developerId,
    String contactId,
  ) async {
    return await _apiService.delete<Developer>(
      '/developers/$developerId/contacts/$contactId',
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Set primary contact
  Future<ApiResponse<Developer>> setPrimaryContact(
    String developerId,
    String contactId,
  ) async {
    return await _apiService.post<Developer>(
      '/developers/$developerId/contacts/$contactId/primary',
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Upload developer document
  Future<ApiResponse<Map<String, dynamic>>> uploadDocument(
    String developerId,
    String documentType, // 'gstin', 'pan', 'aadhar', 'logo'
    String filePath,
  ) async {
    // This would typically use multipart/form-data upload
    // For now, returning a placeholder response
    return ApiResponse.success({
      'documentType': documentType,
      'filePath': filePath,
      'uploadedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get developer timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperTimeline(
    String developerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/developers/$developerId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Search developers by name or location
  Future<ApiResponse<List<Developer>>> searchDevelopers(String query) async {
    return await _apiService.get<List<Developer>>(
      '/developers/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Developer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get developers by city
  Future<ApiResponse<List<Developer>>> getDevelopersByCity(String city) async {
    return await _apiService.get<List<Developer>>(
      '/developers/by-city',
      queryParams: {'city': city},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Developer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get RERA registered developers
  Future<ApiResponse<List<Developer>>> getReraRegisteredDevelopers() async {
    return await _apiService.get<List<Developer>>(
      '/developers/rera-registered',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Developer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get developer performance metrics
  Future<ApiResponse<Map<String, dynamic>>> getDeveloperPerformance(
    String developerId,
  ) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/developers/$developerId/performance',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Merge duplicate developers
  Future<ApiResponse<Developer>> mergeDevelopers(
    String primaryDeveloperId,
    List<String> duplicateDeveloperIds,
  ) async {
    return await _apiService.post<Developer>(
      '/developers/merge',
      body: {
        'primaryDeveloperId': primaryDeveloperId,
        'duplicateDeveloperIds': duplicateDeveloperIds,
      },
      fromJson: (json) =>
          Developer.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get developer leads
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperLeads(
    String developerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/developers/$developerId/leads',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get developer bookings
  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperBookings(
    String developerId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/developers/$developerId/bookings',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }
}
