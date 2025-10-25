import '../models/project_model.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({ProjectService? projectService})
    : _projectService = projectService ?? ProjectService();

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
    return _projectService.getProjects(
      search: search,
      type: type,
      status: status,
      developerId: developerId,
      city: city,
      state: state,
      minPrice: minPrice,
      maxPrice: maxPrice,
      amenities: amenities,
      propertyTypes: propertyTypes,
      isActive: isActive,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Project>> getProjectById(String id) async {
    return _projectService.getProject(id);
  }

  Future<ApiResponse<Project>> createProject(Project project) async {
    return _projectService.createProject(project);
  }

  Future<ApiResponse<Project>> updateProject(String id, Project project) async {
    return _projectService.updateProject(id, project);
  }

  Future<ApiResponse<void>> deleteProject(String id) async {
    return _projectService.deleteProject(id);
  }

  Future<ApiResponse<Project>> updateProjectStatus(
    String projectId,
    ProjectStatus status,
    String? notes,
  ) async {
    return _projectService.updateProjectStatus(projectId, status, notes);
  }

  Future<ApiResponse<Project>> updateProjectPricing(
    String projectId,
    double? startingPrice,
    double? maxPrice,
    String? priceUnit,
  ) async {
    return _projectService.updateProjectPricing(
      projectId,
      startingPrice,
      maxPrice,
      priceUnit,
    );
  }

  Future<ApiResponse<Project>> updateProjectAvailability(
    String projectId,
    int? totalUnits,
    int? availableUnits,
  ) async {
    return _projectService.updateProjectAvailability(
      projectId,
      totalUnits,
      availableUnits,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProjectStats({
    String? developerId,
    String? city,
    String? state,
    ProjectType? type,
  }) async {
    return _projectService.getProjectStats(
      developerId: developerId,
      city: city,
      state: state,
      type: type,
    );
  }

  Future<ApiResponse<List<Project>>> getProjectsByDeveloper(
    String developerId,
  ) async {
    return _projectService.getProjectsByDeveloper(developerId);
  }

  Future<ApiResponse<List<Project>>> getProjectsByLocation(
    String city, {
    String? state,
  }) async {
    return _projectService.getProjectsByLocation(city, state: state);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectTimeline(
    String projectId,
  ) async {
    return _projectService.getProjectTimeline(projectId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectLeads(
    String projectId,
  ) async {
    return _projectService.getProjectLeads(projectId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectBookings(
    String projectId,
  ) async {
    return _projectService.getProjectBookings(projectId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectSiteVisits(
    String projectId,
  ) async {
    return _projectService.getProjectSiteVisits(projectId);
  }

  Future<ApiResponse<List<String>>> uploadProjectImages(
    String projectId,
    List<String> imagePaths,
  ) async {
    return _projectService.uploadProjectImages(projectId, imagePaths);
  }

  Future<ApiResponse<String>> uploadProjectBrochure(
    String projectId,
    String brochurePath,
  ) async {
    return _projectService.uploadProjectBrochure(projectId, brochurePath);
  }

  Future<ApiResponse<String>> uploadFloorPlan(
    String projectId,
    String floorPlanPath,
  ) async {
    return _projectService.uploadFloorPlan(projectId, floorPlanPath);
  }

  Future<ApiResponse<List<Project>>> searchProjects(String query) async {
    return _projectService.searchProjects(query);
  }

  Future<ApiResponse<List<Project>>> getFeaturedProjects() async {
    return _projectService.getFeaturedProjects();
  }

  Future<ApiResponse<List<Project>>> getUpcomingProjects() async {
    return _projectService.getUpcomingProjects();
  }

  Future<ApiResponse<Map<String, dynamic>>> getProjectPerformance(
    String projectId,
  ) async {
    return _projectService.getProjectPerformance(projectId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getProjectPriceHistory(
    String projectId,
  ) async {
    return _projectService.getProjectPriceHistory(projectId);
  }

  Future<ApiResponse<Project>> updateProjectAmenities(
    String projectId,
    List<String> amenities,
  ) async {
    return _projectService.updateProjectAmenities(projectId, amenities);
  }

  Future<ApiResponse<Project>> updateProjectPropertyTypes(
    String projectId,
    List<String> propertyTypes,
  ) async {
    return _projectService.updateProjectPropertyTypes(projectId, propertyTypes);
  }
}