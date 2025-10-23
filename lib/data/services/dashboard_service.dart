import '../services/database_service.dart';
import '../models/api_response_model.dart';
import '../models/task_model.dart';

class DashboardService {
  /// Get dashboard statistics
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    try {
      final stats = await DatabaseService.getDashboardStats();
      return ApiResponse.success(
        data: stats,
        message: 'Dashboard stats fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching dashboard stats: $e');
    }
  }

  /// Get today's statistics
  Future<ApiResponse<Map<String, dynamic>>> getTodayStats() async {
    try {
      final stats = await DatabaseService.getDashboardStats();
      return ApiResponse.success(
        data: stats['today'] as Map<String, dynamic>,
        message: 'Today stats fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching today stats: $e');
    }
  }

  /// Get total statistics
  Future<ApiResponse<Map<String, dynamic>>> getTotalStats() async {
    try {
      final stats = await DatabaseService.getDashboardStats();
      return ApiResponse.success(
        data: stats['total'] as Map<String, dynamic>,
        message: 'Total stats fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(error: 'Error fetching total stats: $e');
    }
  }

  /// Get lead conversion funnel data
  Future<ApiResponse<Map<String, dynamic>>> getLeadConversionFunnel() async {
    try {
      // This would be implemented with specific database queries
      return ApiResponse.success(
        data: {
          'leads': 100,
          'qualified': 80,
          'siteVisits': 60,
          'bookings': 20,
          'conversions': 15,
        },
        message: 'Lead conversion data fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching lead conversion data: $e',
      );
    }
  }

  /// Get sales performance data
  Future<ApiResponse<List<Map<String, dynamic>>>> getSalesPerformance() async {
    try {
      // This would be implemented with specific database queries
      return ApiResponse.success(
        data: [
          {'month': 'Jan', 'sales': 50000, 'leads': 100},
          {'month': 'Feb', 'sales': 75000, 'leads': 120},
          {'month': 'Mar', 'sales': 60000, 'leads': 90},
        ],
        message: 'Sales performance data fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching sales performance data: $e',
        statusCode: 500,
      );
    }
  }

  /// Get project performance data
  Future<ApiResponse<List<Map<String, dynamic>>>>
  getProjectPerformance() async {
    try {
      // This would be implemented with specific database queries
      return ApiResponse.success(
        data: [
          {
            'project': 'Project A',
            'leads': 50,
            'bookings': 10,
            'revenue': 2000000,
          },
          {
            'project': 'Project B',
            'leads': 30,
            'bookings': 8,
            'revenue': 1500000,
          },
          {
            'project': 'Project C',
            'leads': 40,
            'bookings': 12,
            'revenue': 1800000,
          },
        ],
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching project performance data: $e',
        statusCode: 500,
      );
    }
  }

  /// Get recent activities
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecentActivities({
    int limit = 10,
  }) async {
    try {
      // This would be implemented with specific database queries
      return ApiResponse.success(
        data: [
          {
            'id': '1',
            'type': 'lead_created',
            'description': 'New lead created for Project A',
            'timestamp': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
          },
          {
            'id': '2',
            'type': 'booking_made',
            'description': 'Booking confirmed for Unit 101',
            'timestamp': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
        ],
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching recent activities: $e',
        statusCode: 500,
      );
    }
  }

  /// Get upcoming tasks
  Future<ApiResponse<List<Map<String, dynamic>>>> getUpcomingTasks({
    int days = 7,
  }) async {
    try {
      final tasks = await DatabaseService.getTasks(
        dueDateFrom: DateTime.now(),
        dueDateTo: DateTime.now().add(Duration(days: days)),
        limit: 20,
      );

      return ApiResponse.success(
        data: tasks
            .map(
              (task) => {
                'id': task.id,
                'title': task.title,
                'dueDate': task.dueDate?.toIso8601String(),
                'priority': task.priority.name,
                'status': task.status.name,
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching upcoming tasks: $e',
        statusCode: 500,
      );
    }
  }

  /// Get overdue tasks
  Future<ApiResponse<List<Map<String, dynamic>>>> getOverdueTasks() async {
    try {
      final tasks = await DatabaseService.getTasks(
        dueDateTo: DateTime.now(),
        limit: 20,
      );

      // Filter for overdue tasks
      final overdueTasks = tasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isBefore(DateTime.now()) &&
                task.status != TaskStatus.completed,
          )
          .toList();

      return ApiResponse.success(
        data: overdueTasks
            .map(
              (task) => {
                'id': task.id,
                'title': task.title,
                'dueDate': task.dueDate?.toIso8601String(),
                'priority': task.priority.name,
                'status': task.status.name,
              },
            )
            .toList(),
        message: 'Overdue tasks fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching overdue tasks: $e',
        statusCode: 500,
      );
    }
  }

  /// Get today's site visits
  Future<ApiResponse<List<Map<String, dynamic>>>> getTodaysSiteVisits() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final siteVisits = await DatabaseService.getSiteVisits(
        fromDate: todayStart,
        toDate: todayEnd,
        limit: 20,
      );

      return ApiResponse.success(
        data: siteVisits
            .map(
              (visit) => {
                'id': visit.id,
                'purpose': visit.purpose,
                'scheduledTime': visit.meetingFrom?.toIso8601String(),
                'status': visit.status.name,
                'customerName': visit.customerName,
                'projectName': visit.projectName,
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching today site visits: $e',
        statusCode: 500,
      );
    }
  }

  /// Get today's follow-ups
  Future<ApiResponse<List<Map<String, dynamic>>>> getTodaysFollowUps() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final leads = await DatabaseService.getLeads(
        fromDate: todayStart,
        toDate: todayEnd,
        limit: 20,
      );

      return ApiResponse.success(
        data: leads
            .map(
              (lead) => {
                'id': lead.id,
                'leadId': lead.leadId,
                'customerName': lead.customerName,
                'phone': lead.phone,
                'lastFollowUpDate': lead.lastFollowUpDate?.toIso8601String(),
                'status': lead.status.name,
              },
            )
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching today follow-ups: $e',
        statusCode: 500,
      );
    }
  }

  /// Get notifications count
  Future<ApiResponse<Map<String, dynamic>>> getNotificationsCount() async {
    try {
      // This would be implemented with specific database queries
      return ApiResponse.success(
        data: {'unread': 5, 'total': 25, 'urgent': 2},
        message: 'Notifications count fetched successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        error: 'Error fetching notifications count: $e',
        statusCode: 500,
      );
    }
  }
}
