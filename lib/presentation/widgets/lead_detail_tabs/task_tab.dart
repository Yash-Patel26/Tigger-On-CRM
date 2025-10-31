import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/database_service_masters.dart' as masters;
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../data/services/task_service.dart';

class TaskTab extends StatefulWidget {
  const TaskTab({super.key, required this.leadId});

  final String leadId;

  @override
  State<TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future immediately to avoid LateInitializationError on first build
    _tasksFuture = Future.value(<Task>[]);
    _loadTasks();
  }

  // Load tasks from both database and sync with backend
  Future<void> _loadTasks() async {
    try {
      // First load from database for immediate display
      final tasks = await DatabaseService.getTasks(
        leadId: widget.leadId,
        limit: 200,
      );

      // Filter out disposition-related follow-up tasks
      final filteredTasks = tasks.where((task) {
        // Exclude tasks that are follow-up tasks created from disposition
        return !(task.title.toLowerCase().startsWith('follow-up:') &&
            task.description.toLowerCase().contains(
              'follow-up task created from disposition',
            ));
      }).toList();

      setState(() {
        _tasksFuture = Future.value(filteredTasks);
      });

      // Optionally sync with a custom backend here.
      // Skipped for Supabase REST to avoid 400s on unsupported query params.
    } catch (e) {
      print('Failed to load tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openCreateTaskSheet,
                    icon: const Icon(FontAwesomeIcons.plus),
                    label: const Text('Create Task'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadTasks,
                  icon: const Icon(FontAwesomeIcons.arrowsRotate),
                  tooltip: 'Refresh from Backend',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load tasks'),
                        );
                      }
                      final List<Task> tasks = snapshot.data ?? <Task>[];
                      if (tasks.isEmpty) {
                        return const Center(child: Text('No tasks yet'));
                      }
                      return ListView(
                        children: <Widget>[
                          ...tasks.asMap().entries.map(
                            (MapEntry<int, Task> e) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          e.value.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (String action) {
                                          if (action == 'change_status') {
                                            _showChangeStatusDialog(e.value);
                                          } else if (action == 'edit') {
                                            _showEditTaskDialog(e.value);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'change_status',
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.update,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Change Status'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(Icons.edit, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                        child: const Icon(Icons.more_vert),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Description: ${e.value.description}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: _buildInfoChip(
                                          'Assign To',
                                          e.value.assignedToName ?? '-',
                                          Icons.person,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInfoChip(
                                          'Priority',
                                          e.value.priority.displayName,
                                          Icons.flag,
                                          _getPriorityColor(e.value.priority),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: _buildInfoChip(
                                          'Status',
                                          e.value.status.displayName,
                                          Icons.circle,
                                          _getStatusColor(e.value.status),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (e.value.dueDate != null)
                                        Expanded(
                                          child: _buildInfoChip(
                                            'Due Date',
                                            _formatDate(e.value.dueDate!),
                                            Icons.calendar_today,
                                            Colors.orange,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for task display
  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
      case TaskStatus.onHold:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Show change status dialog
  void _showChangeStatusDialog(Task task) {
    TaskStatus selectedStatus = task.status;
    final TextEditingController commentController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return AlertDialog(
              title: const Text('Change Task Status'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Task: ${task.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TaskStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<TaskStatus>(
                            value: TaskStatus.pending,
                            child: Text('New'),
                          ),
                          DropdownMenuItem<TaskStatus>(
                            value: TaskStatus.inProgress,
                            child: Text('In Progress'),
                          ),
                          DropdownMenuItem<TaskStatus>(
                            value: TaskStatus.completed,
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: (TaskStatus? value) {
                          setModal(() => selectedStatus = value ?? task.status);
                        },
                        validator: (TaskStatus? value) =>
                            value == null ? 'Please select a status' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Comment (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Add a comment about the status change...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    try {
                      // Update in database
                      await DatabaseService.updateTaskStatus(
                        task.id,
                        selectedStatus,
                        notes: commentController.text.trim().isNotEmpty
                            ? commentController.text.trim()
                            : null,
                      );

                      // Also update via API service for backend storage
                      try {
                        final TaskService taskService = TaskService();
                        await taskService.updateTaskStatus(
                          task.id,
                          selectedStatus,
                          commentController.text.trim().isNotEmpty
                              ? commentController.text.trim()
                              : null,
                        );
                      } catch (apiError) {
                        // Log API error but don't fail the operation
                        print('API update failed: $apiError');
                      }
                      if (!mounted) return;
                      await _loadTasks();
                      Navigator.of(ctx).pop();
                      await Helpers.showSuccessDialog(
                        context,
                        title:
                            'Task status updated to ${selectedStatus.displayName}',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update task status: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.check),
                  label: const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show edit task dialog
  void _showEditTaskDialog(Task task) {
    final TextEditingController titleController = TextEditingController(
      text: task.title,
    );
    final TextEditingController descController = TextEditingController(
      text: task.description,
    );
    final TextEditingController notesController = TextEditingController(
      text: task.notes ?? '',
    );

    TaskPriority selectedPriority = task.priority;
    TaskStatus selectedStatus = task.status;
    TaskType selectedType = task.type;
    String? selectedAssignedTo = task.assignedTo;
    String selectedAssignedToName = task.assignedToName ?? '';
    DateTime? selectedDueDate = task.dueDate;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<TaskPriority>(
                              value: selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Priority *',
                                border: OutlineInputBorder(),
                              ),
                              items: TaskPriority.values
                                  .map(
                                    (TaskPriority priority) =>
                                        DropdownMenuItem<TaskPriority>(
                                          value: priority,
                                          child: Text(priority.displayName),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (TaskPriority? value) {
                                setModal(
                                  () =>
                                      selectedPriority = value ?? task.priority,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<TaskStatus>(
                              value: selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(),
                              ),
                              items: TaskStatus.values
                                  .map(
                                    (TaskStatus status) =>
                                        DropdownMenuItem<TaskStatus>(
                                          value: status,
                                          child: Text(status.displayName),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (TaskStatus? value) {
                                setModal(
                                  () => selectedStatus = value ?? task.status,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<TaskType>(
                              value: selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: TaskType.values
                                  .map(
                                    (TaskType type) =>
                                        DropdownMenuItem<TaskType>(
                                          value: type,
                                          child: Text(type.displayName),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (TaskType? value) {
                                setModal(
                                  () => selectedType = value ?? task.type,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future:
                                  DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                              builder:
                                  (
                                    BuildContext _,
                                    AsyncSnapshot<List<Map<String, dynamic>>>
                                    snap,
                                  ) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snap.hasError) {
                                      return const Text(
                                        'Failed to load assignees',
                                      );
                                    }
                                    final List<Map<String, dynamic>> users =
                                        snap.data ?? <Map<String, dynamic>>[];
                                    return DropdownButtonFormField<String>(
                                      value: selectedAssignedTo,
                                      decoration: const InputDecoration(
                                        labelText: 'Assign To',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: users
                                          .map(
                                            (
                                              Map<String, dynamic> u,
                                            ) => DropdownMenuItem<String>(
                                              value: (u['id'] ?? '') as String,
                                              child: Text(
                                                (u['name'] ?? '-') as String,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (String? value) {
                                        setModal(() {
                                          selectedAssignedTo = value;
                                          final Map<String, dynamic> user =
                                              users.firstWhere(
                                                (Map<String, dynamic> e) =>
                                                    e['id'] == value,
                                                orElse: () =>
                                                    <String, dynamic>{},
                                              );
                                          selectedAssignedToName =
                                              (user['name'] ?? '-') as String;
                                        });
                                      },
                                    );
                                  },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setModal(() => selectedDueDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedDueDate != null
                                ? _formatDate(selectedDueDate!)
                                : 'Select due date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    try {
                      final updatedTask = task.copyWith(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        priority: selectedPriority,
                        status: selectedStatus,
                        type: selectedType,
                        assignedTo: selectedAssignedTo,
                        assignedToName: selectedAssignedToName.isNotEmpty
                            ? selectedAssignedToName
                            : null,
                        dueDate: selectedDueDate,
                        notes: notesController.text.trim().isNotEmpty
                            ? notesController.text.trim()
                            : null,
                        updatedAt: DateTime.now(),
                      );

                      // Update in database
                      await DatabaseService.updateTask(task.id, updatedTask);

                      // Also update via API service for backend storage
                      try {
                        final TaskService taskService = TaskService();
                        await taskService.updateTask(task.id, updatedTask);
                      } catch (apiError) {
                        // Log API error but don't fail the operation
                        print('API update failed: $apiError');
                      }
                      if (!mounted) return;
                      await _loadTasks();
                      Navigator.of(ctx).pop();
                      await Helpers.showSuccessDialog(
                        context,
                        title: 'Task updated successfully',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update task: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.check),
                  label: const Text('Update Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openCreateTaskSheet() {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String assignTo = 'Me';
    String priority = 'Medium';
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return AlertDialog(
              title: const Text('Create Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _datePicker(
                              context,
                              'Start Date *',
                              startDate,
                              (DateTime d) => setModal(() => startDate = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _timePicker(
                              context,
                              'Start Time *',
                              startTime,
                              (TimeOfDay t) => setModal(() => startTime = t),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _datePicker(
                              context,
                              'End Date *',
                              endDate,
                              (DateTime d) => setModal(() => endDate = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _timePicker(
                              context,
                              'End Time *',
                              endTime,
                              (TimeOfDay t) => setModal(() => endTime = t),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future:
                                  DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                              builder:
                                  (
                                    BuildContext _,
                                    AsyncSnapshot<List<Map<String, dynamic>>>
                                    snap,
                                  ) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snap.hasError) {
                                      return const Text(
                                        'Failed to load assignees',
                                      );
                                    }
                                    final List<Map<String, dynamic>> users =
                                        snap.data ?? <Map<String, dynamic>>[];
                                    return DropdownButtonFormField<String>(
                                      initialValue:
                                          users.any(
                                            (Map<String, dynamic> u) =>
                                                u['name'] == assignTo,
                                          )
                                          ? users.firstWhere(
                                                  (Map<String, dynamic> u) =>
                                                      u['name'] == assignTo,
                                                )['id']
                                                as String
                                          : null,
                                      items: users
                                          .map(
                                            (
                                              Map<String, dynamic> u,
                                            ) => DropdownMenuItem<String>(
                                              value: (u['id'] ?? '') as String,
                                              child: Text(
                                                (u['name'] ?? '-') as String,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (String? v) => setModal(() {
                                        final Map<String, dynamic> user = users
                                            .firstWhere(
                                              (Map<String, dynamic> e) =>
                                                  e['id'] == v,
                                              orElse: () => <String, dynamic>{},
                                            );
                                        assignTo =
                                            (user['name'] ?? '-') as String;
                                      }),
                                      decoration: const InputDecoration(
                                        labelText: 'Assign To *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (String? v) =>
                                          (v == null || v.isEmpty)
                                          ? 'Required'
                                          : null,
                                    );
                                  },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: priority,
                              items: const <String>['Low', 'Medium', 'High']
                                  .map(
                                    (String e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? v) =>
                                  setModal(() => priority = v ?? priority),
                              decoration: const InputDecoration(
                                labelText: 'Priority *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    try {
                      // Use the lead id passed into this tab instead of waiting on parent
                      final String activeLeadId = widget.leadId;

                      // Create task in database
                      final Task createdTask = await DatabaseService.createTask(
                        leadId: activeLeadId,
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        priority: priority.toLowerCase() == 'high'
                            ? TaskPriority.high
                            : priority.toLowerCase() == 'low'
                            ? TaskPriority.low
                            : TaskPriority.medium,
                        status: TaskStatus.pending,
                        type: TaskType.other,
                        assignedToName: assignTo,
                        dueDate: DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        ),
                      );

                      // Also create via API service for backend storage
                      try {
                        final TaskService taskService = TaskService();
                        await taskService.createTask(createdTask);
                      } catch (apiError) {
                        // Log API error but don't fail the operation
                        print('API create failed: $apiError');
                      }

                      // Log the task creation activity
                      await masters.DatabaseServiceMasters.logTaskCreated(
                        leadId: activeLeadId,
                        taskId: createdTask.id,
                        taskTitle: titleCtrl.text.trim(),
                        performedBy: Helpers.getCurrentUserId() ?? 'system',
                        performedByName: await Helpers.getCurrentUserName(),
                      );
                      if (!mounted) return;
                      await _loadTasks();
                      Navigator.of(ctx).pop();
                      await Helpers.showSuccessDialog(
                        context,
                        title: 'Task created successfully',
                        message: 'Task has been assigned.',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create task: $e')),
                      );
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.check),
                  label: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _datePicker(
    BuildContext context,
    String label,
    DateTime initial,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final DateTime? date = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${initial.day}/${initial.month}/${initial.year}'),
          ),
        ),
      ],
    );
  }

  Widget _timePicker(
    BuildContext context,
    String label,
    TimeOfDay initial,
    Function(TimeOfDay) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: initial,
            );
            if (time != null) {
              onChanged(time);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${initial.hour.toString().padLeft(2, '0')}:${initial.minute.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    );
  }
}
