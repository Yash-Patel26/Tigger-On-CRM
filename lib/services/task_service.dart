import '../models/task_model.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all tasks with optional filters
  Future<ApiResponse<List<Task>>> getTasks({
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
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (priority != null) {
      queryParams['priority'] = priority.name;
    }
    if (type != null) {
      queryParams['type'] = type.name;
    }
    if (assignedTo != null) {
      queryParams['assignedTo'] = assignedTo;
    }
    if (createdBy != null) {
      queryParams['createdBy'] = createdBy;
    }
    if (leadId != null) {
      queryParams['leadId'] = leadId;
    }
    if (customerId != null) {
      queryParams['customerId'] = customerId;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }
    if (siteVisitId != null) {
      queryParams['siteVisitId'] = siteVisitId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (dueDateFrom != null) {
      queryParams['dueDateFrom'] = dueDateFrom.toIso8601String();
    }
    if (dueDateTo != null) {
      queryParams['dueDateTo'] = dueDateTo.toIso8601String();
    }

    return await _apiService.get<List<Task>>(
      '/tasks',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get task by ID
  Future<ApiResponse<Task>> getTask(String id) async {
    return await _apiService.get<Task>(
      '/tasks/$id',
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new task
  Future<ApiResponse<Task>> createTask(Task task) async {
    return await _apiService.post<Task>(
      '/tasks',
      body: task.toJson(),
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update task
  Future<ApiResponse<Task>> updateTask(String id, Task task) async {
    return await _apiService.put<Task>(
      '/tasks/$id',
      body: task.toJson(),
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete task
  Future<ApiResponse<void>> deleteTask(String id) async {
    return await _apiService.delete<void>('/tasks/$id');
  }

  // Update task status
  Future<ApiResponse<Task>> updateTaskStatus(
    String taskId,
    TaskStatus status,
    String? notes,
  ) async {
    return await _apiService.patch<Task>(
      '/tasks/$taskId/status',
      body: {'status': status.name, if (notes != null) 'notes': notes},
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Assign task
  Future<ApiResponse<Task>> assignTask(
    String taskId,
    String assignedTo,
    String? notes,
  ) async {
    return await _apiService.post<Task>(
      '/tasks/$taskId/assign',
      body: {'assignedTo': assignedTo, if (notes != null) 'notes': notes},
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Complete task
  Future<ApiResponse<Task>> completeTask(String taskId, String? notes) async {
    return await _apiService.post<Task>(
      '/tasks/$taskId/complete',
      body: {if (notes != null) 'notes': notes},
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Cancel task
  Future<ApiResponse<Task>> cancelTask(
    String taskId,
    String reason,
    String? notes,
  ) async {
    return await _apiService.post<Task>(
      '/tasks/$taskId/cancel',
      body: {'reason': reason, if (notes != null) 'notes': notes},
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get task statistics
  Future<ApiResponse<Map<String, dynamic>>> getTaskStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
    String? createdBy,
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
    if (createdBy != null) {
      queryParams['createdBy'] = createdBy;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/tasks/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's tasks
  Future<ApiResponse<List<Task>>> getTodaysTasks() async {
    return await _apiService.get<List<Task>>(
      '/tasks/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get overdue tasks
  Future<ApiResponse<List<Task>>> getOverdueTasks() async {
    return await _apiService.get<List<Task>>(
      '/tasks/overdue',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get my tasks
  Future<ApiResponse<List<Task>>> getMyTasks() async {
    return await _apiService.get<List<Task>>(
      '/tasks/my-tasks',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by lead
  Future<ApiResponse<List<Task>>> getTasksByLead(String leadId) async {
    return await _apiService.get<List<Task>>(
      '/leads/$leadId/tasks',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by customer
  Future<ApiResponse<List<Task>>> getTasksByCustomer(String customerId) async {
    return await _apiService.get<List<Task>>(
      '/customers/$customerId/tasks',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by project
  Future<ApiResponse<List<Task>>> getTasksByProject(String projectId) async {
    return await _apiService.get<List<Task>>(
      '/projects/$projectId/tasks',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by site visit
  Future<ApiResponse<List<Task>>> getTasksBySiteVisit(
    String siteVisitId,
  ) async {
    return await _apiService.get<List<Task>>(
      '/site-visits/$siteVisitId/tasks',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get task timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getTaskTimeline(
    String taskId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/tasks/$taskId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Add task comment
  Future<ApiResponse<Task>> addComment(
    String taskId,
    String comment,
    List<String>? attachments,
  ) async {
    return await _apiService.post<Task>(
      '/tasks/$taskId/comments',
      body: {
        'comment': comment,
        if (attachments != null) 'attachments': attachments,
      },
      fromJson: (json) => Task.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get task comments
  Future<ApiResponse<List<Map<String, dynamic>>>> getTaskComments(
    String taskId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/tasks/$taskId/comments',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Search tasks
  Future<ApiResponse<List<Task>>> searchTasks(String query) async {
    return await _apiService.get<List<Task>>(
      '/tasks/search',
      queryParams: {'q': query},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get upcoming tasks
  Future<ApiResponse<List<Task>>> getUpcomingTasks({int days = 7}) async {
    return await _apiService.get<List<Task>>(
      '/tasks/upcoming',
      queryParams: {'days': days.toString()},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by priority
  Future<ApiResponse<List<Task>>> getTasksByPriority(
    TaskPriority priority,
  ) async {
    return await _apiService.get<List<Task>>(
      '/tasks/by-priority',
      queryParams: {'priority': priority.name},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get tasks by type
  Future<ApiResponse<List<Task>>> getTasksByType(TaskType type) async {
    return await _apiService.get<List<Task>>(
      '/tasks/by-type',
      queryParams: {'type': type.name},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
