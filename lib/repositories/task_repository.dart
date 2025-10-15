import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/api_service.dart';

class TaskRepository {
  final TaskService _taskService;

  TaskRepository({TaskService? taskService})
    : _taskService = taskService ?? TaskService();

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
    return _taskService.getTasks(
      search: search,
      status: status,
      priority: priority,
      type: type,
      assignedTo: assignedTo,
      createdBy: createdBy,
      leadId: leadId,
      customerId: customerId,
      projectId: projectId,
      siteVisitId: siteVisitId,
      fromDate: fromDate,
      toDate: toDate,
      dueDateFrom: dueDateFrom,
      dueDateTo: dueDateTo,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Task>> getTaskById(String id) async {
    return _taskService.getTask(id);
  }

  Future<ApiResponse<Task>> createTask(Task task) async {
    return _taskService.createTask(task);
  }

  Future<ApiResponse<Task>> updateTask(String id, Task task) async {
    return _taskService.updateTask(id, task);
  }

  Future<ApiResponse<void>> deleteTask(String id) async {
    return _taskService.deleteTask(id);
  }

  Future<ApiResponse<Task>> updateTaskStatus(
    String taskId,
    TaskStatus status,
    String? notes,
  ) async {
    return _taskService.updateTaskStatus(taskId, status, notes);
  }

  Future<ApiResponse<Task>> assignTask(
    String taskId,
    String assignedTo,
    String? notes,
  ) async {
    return _taskService.assignTask(taskId, assignedTo, notes);
  }

  Future<ApiResponse<Task>> completeTask(String taskId, String? notes) async {
    return _taskService.completeTask(taskId, notes);
  }

  Future<ApiResponse<Task>> cancelTask(
    String taskId,
    String reason,
    String? notes,
  ) async {
    return _taskService.cancelTask(taskId, reason, notes);
  }

  Future<ApiResponse<Map<String, dynamic>>> getTaskStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? assignedTo,
    String? createdBy,
  }) async {
    return _taskService.getTaskStats(
      fromDate: fromDate,
      toDate: toDate,
      assignedTo: assignedTo,
      createdBy: createdBy,
    );
  }

  Future<ApiResponse<List<Task>>> getTodaysTasks() async {
    return _taskService.getTodaysTasks();
  }

  Future<ApiResponse<List<Task>>> getOverdueTasks() async {
    return _taskService.getOverdueTasks();
  }

  Future<ApiResponse<List<Task>>> getMyTasks() async {
    return _taskService.getMyTasks();
  }

  Future<ApiResponse<List<Task>>> getTasksByLead(String leadId) async {
    return _taskService.getTasksByLead(leadId);
  }

  Future<ApiResponse<List<Task>>> getTasksByCustomer(String customerId) async {
    return _taskService.getTasksByCustomer(customerId);
  }

  Future<ApiResponse<List<Task>>> getTasksByProject(String projectId) async {
    return _taskService.getTasksByProject(projectId);
  }

  Future<ApiResponse<List<Task>>> getTasksBySiteVisit(
    String siteVisitId,
  ) async {
    return _taskService.getTasksBySiteVisit(siteVisitId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTaskTimeline(
    String taskId,
  ) async {
    return _taskService.getTaskTimeline(taskId);
  }

  Future<ApiResponse<Task>> addComment(
    String taskId,
    String comment,
    List<String>? attachments,
  ) async {
    return _taskService.addComment(taskId, comment, attachments);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTaskComments(
    String taskId,
  ) async {
    return _taskService.getTaskComments(taskId);
  }

  Future<ApiResponse<List<Task>>> searchTasks(String query) async {
    return _taskService.searchTasks(query);
  }

  Future<ApiResponse<List<Task>>> getUpcomingTasks({int days = 7}) async {
    return _taskService.getUpcomingTasks(days: days);
  }

  Future<ApiResponse<List<Task>>> getTasksByPriority(
    TaskPriority priority,
  ) async {
    return _taskService.getTasksByPriority(priority);
  }

  Future<ApiResponse<List<Task>>> getTasksByType(TaskType type) async {
    return _taskService.getTasksByType(type);
  }
}
