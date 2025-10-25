import '../models/developer_model.dart';
import '../services/developer_service.dart';
import '../services/api_service.dart';

class DeveloperRepository {
  final DeveloperService _developerService;

  DeveloperRepository({DeveloperService? developerService})
    : _developerService = developerService ?? DeveloperService();

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
    return _developerService.getDevelopers(
      search: search,
      isActive: isActive,
      city: city,
      state: state,
      companyType: companyType,
      isReraRegistered: isReraRegistered,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Developer>> getDeveloperById(String id) async {
    return _developerService.getDeveloper(id);
  }

  Future<ApiResponse<Developer>> createDeveloper(Developer developer) async {
    return _developerService.createDeveloper(developer);
  }

  Future<ApiResponse<Developer>> updateDeveloper(
    String id,
    Developer developer,
  ) async {
    return _developerService.updateDeveloper(id, developer);
  }

  Future<ApiResponse<void>> deleteDeveloper(String id) async {
    return _developerService.deleteDeveloper(id);
  }

  Future<ApiResponse<Developer>> updateDeveloperStatus(
    String developerId,
    bool isActive,
  ) async {
    return _developerService.updateDeveloperStatus(developerId, isActive);
  }

  Future<ApiResponse<Map<String, dynamic>>> getDeveloperStats() async {
    return _developerService.getDeveloperStats();
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperProjects(
    String developerId,
  ) async {
    return _developerService.getDeveloperProjects(developerId);
  }

  Future<ApiResponse<Developer>> addDeveloperContact(
    String developerId,
    DeveloperContact contact,
  ) async {
    return _developerService.addDeveloperContact(developerId, contact);
  }

  Future<ApiResponse<Developer>> updateDeveloperContact(
    String developerId,
    String contactId,
    DeveloperContact contact,
  ) async {
    return _developerService.updateDeveloperContact(
      developerId,
      contactId,
      contact,
    );
  }

  Future<ApiResponse<Developer>> deleteDeveloperContact(
    String developerId,
    String contactId,
  ) async {
    return _developerService.deleteDeveloperContact(developerId, contactId);
  }

  Future<ApiResponse<Developer>> setPrimaryContact(
    String developerId,
    String contactId,
  ) async {
    return _developerService.setPrimaryContact(developerId, contactId);
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadDocument(
    String developerId,
    String documentType,
    String filePath,
  ) async {
    return _developerService.uploadDocument(
      developerId,
      documentType,
      filePath,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperTimeline(
    String developerId,
  ) async {
    return _developerService.getDeveloperTimeline(developerId);
  }

  Future<ApiResponse<List<Developer>>> searchDevelopers(String query) async {
    return _developerService.searchDevelopers(query);
  }

  Future<ApiResponse<List<Developer>>> getDevelopersByCity(String city) async {
    return _developerService.getDevelopersByCity(city);
  }

  Future<ApiResponse<List<Developer>>> getReraRegisteredDevelopers() async {
    return _developerService.getReraRegisteredDevelopers();
  }

  Future<ApiResponse<Map<String, dynamic>>> getDeveloperPerformance(
    String developerId,
  ) async {
    return _developerService.getDeveloperPerformance(developerId);
  }

  Future<ApiResponse<Developer>> mergeDevelopers(
    String primaryDeveloperId,
    List<String> duplicateDeveloperIds,
  ) async {
    return _developerService.mergeDevelopers(
      primaryDeveloperId,
      duplicateDeveloperIds,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperLeads(
    String developerId,
  ) async {
    return _developerService.getDeveloperLeads(developerId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getDeveloperBookings(
    String developerId,
  ) async {
    return _developerService.getDeveloperBookings(developerId);
  }
}
