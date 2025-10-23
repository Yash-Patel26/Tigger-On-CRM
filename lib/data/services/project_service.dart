import '../models/project_model.dart';
import 'api_service.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all projects with optional filters
  Future<ApiResponse<List<Project>>> getProjects({
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
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (type != null) {
      queryParams['type'] = type.name;
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (developerId != null) {
      queryParams['developerId'] = developerId;
    }
    if (city != null) {
      queryParams['city'] = city;
    }
    if (state != null) {
      queryParams['state'] = state;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }
    if (amenities != null && amenities.isNotEmpty) {
      queryParams['amenities'] = amenities.join(',');
    }
    if (propertyTypes != null && propertyTypes.isNotEmpty) {
      queryParams['propertyTypes'] = propertyTypes.join(',');
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    return await _apiService.get<List<Project>>(
      '/projects',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get project by ID
  Future<ApiResponse<Project>> getProject(String id) async {
    return await _apiService.get<Project>(
      '/projects/$id',
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new project
  Future<ApiResponse<Project>> createProject(Project project) async {
    return await _apiService.post<Project>(
      '/projects',
      body: project.toJson(),
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update project
  Future<ApiResponse<Project>> updateProject(String id, Project project) async {
    return await _apiService.put<Project>(
      '/projects/$id',
      body: project.toJson(),
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete project
  Future<ApiResponse<void>> deleteProject(String id) async {
    return await _apiService.delete<void>('/projects/$id');
  }

  // Update project status
  Future<ApiResponse<Project>> updateProjectStatus(
    String projectId,
    ProjectStatus status,
    String? notes,
  ) async {
    return await _apiService.patch<Project>(
      '/projects/$projectId/status',
      body: {'status': status.name, if (notes != null) 'notes': notes},
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update project pricing
  Future<ApiResponse<Project>> updateProjectPricing(
    String projectId,
    double? startingPrice,
    double? maxPrice,
    String? priceUnit,
  ) async {
    return await _apiService.patch<Project>(
      '/projects/$projectId/pricing',
      body: {
        if (startingPrice != null) 'startingPrice': startingPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (priceUnit != null) 'priceUnit': priceUnit,
      },
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update project availability
  Future<ApiResponse<Project>> updateProjectAvailability(
    String projectId,
    int? totalUnits,
    int? availableUnits,
  ) async {
    return await _apiService.patch<Project>(
      '/projects/$projectId/availability',
      body: {
        if (totalUnits != null) 'totalUnits': totalUnits,
        if (availableUnits != null) 'availableUnits': availableUnits,
      },
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get project statistics
  Future<ApiResponse<Map<String, dynamic>>> getProjectStats({
    String? developerId,
    String? city,
    String? state,
    ProjectType? type,
  }) async {
    final queryParams = <String, String>{};

    if (developerId != null) {
      queryParams['developerId'] = developerId;
    }
    if (city != null) {
      queryParams['city'] = city;
    }
    if (state != null) {
      queryParams['state'] = state;
    }
    if (type != null) {
      queryParams['type'] = type.name;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/projects/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get projects by developer
  Future<ApiResponse<List<Project>>> getProjectsByDeveloper(
    String developerId,
  ) async {
    return await _apiService.get<List<Project>>(
      '/developers/$developerId/projects',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get projects by location
  Future<ApiResponse<List<Project>>> getProjectsByLocation(
    String city, {
    String? state,
  }) async {
    final queryParams = <String, String>{'city': city};
    if (state != null) {
      queryParams['state'] = state;
    }

    return await _apiService.get<List<Project>>(
      '/projects/by-location',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get project timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectTimeline(
    String projectId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/projects/$projectId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get project leads
  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectLeads(
    String projectId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/projects/$projectId/leads',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get project bookings
  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectBookings(
    String projectId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/projects/$projectId/bookings',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Get project site visits
  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectSiteVisits(
    String projectId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/projects/$projectId/site-visits',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Upload project images
  Future<ApiResponse<List<String>>> uploadProjectImages(
    String projectId,
    List<String> imagePaths,
  ) async {
    // This would typically use multipart/form-data upload
    // For now, returning a placeholder response
    return ApiResponse.success(imagePaths);
  }

  // Upload project brochure
  Future<ApiResponse<String>> uploadProjectBrochure(
    String projectId,
    String brochurePath,
  ) async {
    // This would typically use multipart/form-data upload
    // For now, returning a placeholder response
    return ApiResponse.success(brochurePath);
  }

  // Upload floor plan
  Future<ApiResponse<String>> uploadFloorPlan(
    String projectId,
    String floorPlanPath,
  ) async {
    // This would typically use multipart/form-data upload
    // For now, returning a placeholder response
    return ApiResponse.success(floorPlanPath);
  }

  // Search projects
  Future<ApiResponse<List<Project>>> searchProjects(String query) async {
    return await _apiService.get<List<Project>>(
      '/projects/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get featured projects
  Future<ApiResponse<List<Project>>> getFeaturedProjects() async {
    return await _apiService.get<List<Project>>(
      '/projects/featured',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get upcoming projects
  Future<ApiResponse<List<Project>>> getUpcomingProjects() async {
    return await _apiService.get<List<Project>>(
      '/projects/upcoming',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get project performance metrics
  Future<ApiResponse<Map<String, dynamic>>> getProjectPerformance(
    String projectId,
  ) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/projects/$projectId/performance',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get project price history
  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectPriceHistory(
    String projectId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/projects/$projectId/price-history',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Update project amenities
  Future<ApiResponse<Project>> updateProjectAmenities(
    String projectId,
    List<String> amenities,
  ) async {
    return await _apiService.patch<Project>(
      '/projects/$projectId/amenities',
      body: {'amenities': amenities},
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update project property types
  Future<ApiResponse<Project>> updateProjectPropertyTypes(
    String projectId,
    List<String> propertyTypes,
  ) async {
    return await _apiService.patch<Project>(
      '/projects/$projectId/property-types',
      body: {'propertyTypes': propertyTypes},
      fromJson: (json) =>
          Project.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
