import 'package:flutter/material.dart';
import '../../data/services/database_service.dart';
import '../../data/models/models.dart';
import '../../shared/utils/role_aware_data.dart';
import '../../shared/utils/helpers.dart';

class ActiveTasksScreen extends StatefulWidget {
  const ActiveTasksScreen({super.key});

  @override
  State<ActiveTasksScreen> createState() => _ActiveTasksScreenState();
}

class _ActiveTasksScreenState extends State<ActiveTasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Task> allTasks = await RoleAwareData.getTasks(context);
      final List<Task> activeTasks = allTasks
          .where(
            (t) =>
                t.status == TaskStatus.pending ||
                t.status == TaskStatus.inProgress,
          )
          .toList();

      if (mounted) {
        setState(() {
          _tasks = activeTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading tasks: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active tasks found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Task task = _tasks[index];
                  return _card(context, task);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Create Task'),
      ),
    );
  }

  Future<void> _openCreateTask() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController descriptionCtrl = TextEditingController();
    String? selectedProjectId;
    String? selectedAssigneeId;
    TaskPriority selectedPriority = TaskPriority.medium;
    TaskType selectedType = TaskType.followUp;
    DateTime? dueDate;

    // Load projects and users for dropdowns
    List<Project> projects = [];
    List<Map<String, dynamic>> users = [];
    try {
      projects = await DatabaseService.getProjects(limit: 100);
      users = await DatabaseServiceUsersAndDisposition.getAssignableUsers();
    } catch (e) {
      // Handle error
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Create Task',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (String? v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProjectId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No Project'),
                        ),
                        ...projects.map(
                          (Project p) => DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        ),
                      ],
                      onChanged: (String? v) =>
                          setModal(() => selectedProjectId = v),
                      decoration: const InputDecoration(
                        labelText: 'Project (Optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAssigneeId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...users.map(
                          (Map<String, dynamic> u) => DropdownMenuItem<String>(
                            value: u['id'] as String,
                            child: Text(
                              u['name'] as String? ??
                                  u['email'] as String? ??
                                  'Unknown',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? v) =>
                          setModal(() => selectedAssigneeId = v),
                      decoration: const InputDecoration(labelText: 'Assignee'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      items: TaskPriority.values
                          .map(
                            (TaskPriority p) => DropdownMenuItem<TaskPriority>(
                              value: p,
                              child: Text(p.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (TaskPriority? v) => setModal(
                        () => selectedPriority = v ?? TaskPriority.medium,
                      ),
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskType>(
                      initialValue: selectedType,
                      items: TaskType.values
                          .map(
                            (TaskType t) => DropdownMenuItem<TaskType>(
                              value: t,
                              child: Text(t.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (TaskType? v) =>
                          setModal(() => selectedType = v ?? TaskType.followUp),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              dueDate ?? now.add(const Duration(days: 1)),
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (picked != null) setModal(() => dueDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date (Optional)',
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.event,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dueDate != null
                                  ? '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
                                  : 'Select date',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              try {
                                final String? assigneeName =
                                    selectedAssigneeId != null
                                    ? users.firstWhere(
                                            (u) =>
                                                u['id'] == selectedAssigneeId,
                                            orElse: () => <String, dynamic>{},
                                          )['name']
                                          as String?
                                    : null;

                                // Note: createTask requires leadId, but we can pass empty string for standalone tasks
                                await DatabaseService.createTask(
                                  leadId: '', // Empty for standalone tasks
                                  title: titleCtrl.text.trim(),
                                  description: descriptionCtrl.text.trim(),
                                  type: selectedType,
                                  priority: selectedPriority,
                                  status: TaskStatus.pending,
                                  assignedTo: selectedAssigneeId,
                                  assignedToName: assigneeName,
                                  dueDate: dueDate,
                                );

                                Navigator.of(ctx).pop();
                                _loadTasks();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Task created successfully',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to create task: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Create'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _card(BuildContext context, Task task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(task.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _statusColor(task.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  task.status.displayName,
                  style: TextStyle(
                    color: _statusColor(task.status),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.person_outline, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Assignee: ${task.assignedToName ?? 'Unassigned'}'),
              ),
            ],
          ),
          if (task.dueDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                const Icon(Icons.event, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Due: ${Helpers.formatDate(task.dueDate!, pattern: 'dd MMM yyyy')}',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(Icons.flag, size: 14),
              const SizedBox(width: 6),
              Text(
                'Priority: ${task.priority.displayName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.category, size: 14),
              const SizedBox(width: 6),
              Text(
                task.type.displayName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _viewTask(context, task),
                child: const Text('View'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _changeStatus(context, task),
                child: const Text('Change Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return const Color(0xFFE55934);
      case TaskStatus.onHold:
        return Colors.grey;
      case TaskStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }

  void _viewTask(BuildContext context, Task task) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Task Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _detailRow(context, 'Title', task.title),
                if (task.description.isNotEmpty)
                  _detailRow(context, 'Description', task.description),
                _detailRow(context, 'Status', task.status.displayName),
                _detailRow(context, 'Priority', task.priority.displayName),
                _detailRow(context, 'Type', task.type.displayName),
                _detailRow(
                  context,
                  'Assignee',
                  task.assignedToName ?? 'Unassigned',
                ),
                if (task.dueDate != null)
                  _detailRow(
                    context,
                    'Due Date',
                    Helpers.formatDate(task.dueDate!, pattern: 'dd MMM yyyy'),
                  ),
                if (task.createdByName != null &&
                    task.createdByName!.isNotEmpty)
                  _detailRow(context, 'Created By', task.createdByName!),
                _detailRow(
                  context,
                  'Created At',
                  Helpers.formatDate(
                    task.createdAt,
                    pattern: 'dd MMM yyyy HH:mm',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeStatus(BuildContext context, Task task) async {
    TaskStatus selectedStatus = task.status;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Change Status',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TaskStatus>(
                      initialValue: selectedStatus,
                      items: TaskStatus.values
                          .map(
                            (TaskStatus s) => DropdownMenuItem<TaskStatus>(
                              value: s,
                              child: Text(s.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (TaskStatus? v) =>
                          setModal(() => selectedStatus = v ?? task.status),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            await DatabaseService.updateTaskStatus(
                              task.id,
                              selectedStatus,
                            );
                            Navigator.of(ctx).pop();
                            _loadTasks();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Status updated successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update status: $e'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
