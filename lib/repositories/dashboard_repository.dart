import '../services/dashboard_service.dart';
import '../models/api_response_model.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository({DashboardService? dashboardService})
    : _dashboardService = dashboardService ?? DashboardService();

  /// Get dashboard statistics
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    return _dashboardService.getDashboardStats();
  }

  /// Get today's statistics
  Future<ApiResponse<Map<String, dynamic>>> getTodayStats() async {
    return _dashboardService.getTodayStats();
  }

  /// Get total statistics
  Future<ApiResponse<Map<String, dynamic>>> getTotalStats() async {
    return _dashboardService.getTotalStats();
  }

  /// Get lead conversion funnel data
  Future<ApiResponse<Map<String, dynamic>>> getLeadConversionFunnel() async {
    return _dashboardService.getLeadConversionFunnel();
  }

  /// Get sales performance data
  Future<ApiResponse<List<Map<String, dynamic>>>> getSalesPerformance() async {
    return _dashboardService.getSalesPerformance();
  }

  /// Get project performance data
  Future<ApiResponse<List<Map<String, dynamic>>>>
  getProjectPerformance() async {
    return _dashboardService.getProjectPerformance();
  }

  /// Get recent activities
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecentActivities({
    int limit = 10,
  }) async {
    return _dashboardService.getRecentActivities(limit: limit);
  }

  /// Get upcoming tasks
  Future<ApiResponse<List<Map<String, dynamic>>>> getUpcomingTasks({
    int days = 7,
  }) async {
    return _dashboardService.getUpcomingTasks(days: days);
  }

  /// Get overdue tasks
  Future<ApiResponse<List<Map<String, dynamic>>>> getOverdueTasks() async {
    return _dashboardService.getOverdueTasks();
  }

  /// Get today's site visits
  Future<ApiResponse<List<Map<String, dynamic>>>> getTodaysSiteVisits() async {
    return _dashboardService.getTodaysSiteVisits();
  }

  /// Get today's follow-ups
  Future<ApiResponse<List<Map<String, dynamic>>>> getTodaysFollowUps() async {
    return _dashboardService.getTodaysFollowUps();
  }

  /// Get notifications count
  Future<ApiResponse<Map<String, dynamic>>> getNotificationsCount() async {
    return _dashboardService.getNotificationsCount();
  }
}
