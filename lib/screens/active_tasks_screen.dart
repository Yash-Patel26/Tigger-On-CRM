import 'package:flutter/material.dart';

class ActiveTasksScreen extends StatefulWidget {
  const ActiveTasksScreen({super.key});

  @override
  State<ActiveTasksScreen> createState() => _ActiveTasksScreenState();
}

class _ActiveTasksScreenState extends State<ActiveTasksScreen> {
  final List<Map<String, String>> _tasks = List<Map<String, String>>.generate(
    8,
    (int i) => <String, String>{
      'title': 'Task #${i + 1} - Follow up with client',
      'project': 'Project ${(i % 5) + 1}',
      'assignee': i % 2 == 0 ? 'Anita' : 'Chetan',
      'due': '2025-09-${(10 + i).toString().padLeft(2, '0')}',
      'status': 'Active',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Tasks')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> t = _tasks[index];
          return _card(context, t);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTask,
        icon: const Icon(Icons.add_task),
        label: const Text('Create Task'),
      ),
    );
  }

  void _openCreateTask() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleCtrl = TextEditingController();
    String project = 'Project 1';
    String assignee = 'Anita';
    DateTime due = DateTime.now().add(const Duration(days: 1));

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
                    DropdownButtonFormField<String>(
                      initialValue: project,
                      items:
                          <String>[
                                'Project 1',
                                'Project 2',
                                'Project 3',
                                'Project 4',
                                'Project 5',
                              ]
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                      onChanged: (String? v) => setModal(() => project = v!),
                      decoration: const InputDecoration(labelText: 'Project'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: assignee,
                      items: const <String>['Anita', 'Chetan', 'Sample']
                          .map(
                            (String e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) => setModal(() => assignee = v!),
                      decoration: const InputDecoration(labelText: 'Assignee'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: due,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (picked != null) setModal(() => due = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.event,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
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
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              setState(() {
                                _tasks.insert(0, <String, String>{
                                  'title': titleCtrl.text.trim(),
                                  'project': project,
                                  'assignee': assignee,
                                  'due':
                                      '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
                                  'status': 'Active',
                                });
                              });
                              Navigator.of(ctx).pop();
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

  Widget _card(BuildContext context, Map<String, String> t) {
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
                  t['title'] ?? '-',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(t['status']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _statusColor(t['status']).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  t['status'] ?? '-',
                  style: TextStyle(
                    color: _statusColor(t['status']),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.folder_outlined, size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text(t['project'] ?? '-')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(Icons.person_outline, size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text('Assignee: ${t['assignee'] ?? '-'}')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              const Icon(Icons.event, size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text('Due: ${t['due'] ?? '-'}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _viewTask(context, t),
                child: const Text('View'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _changeStatus(context, t),
                child: const Text('Change Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return const Color(0xFFE55934);
      case 'on hold':
        return Colors.orange;
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return Colors.blueGrey;
    }
  }

  void _viewTask(BuildContext context, Map<String, String> t) {
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
                _detailRow(context, 'Title', t['title'] ?? '-'),
                _detailRow(context, 'Project', t['project'] ?? '-'),
                _detailRow(context, 'Assignee', t['assignee'] ?? '-'),
                _detailRow(context, 'Due', t['due'] ?? '-'),
                _detailRow(context, 'Status', t['status'] ?? '-'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeStatus(BuildContext context, Map<String, String> t) {
    String sel = t['status'] ?? 'Active';
    final List<String> statuses = <String>[
      'Active',
      'In Progress',
      'Completed',
      'On Hold',
      'Cancelled',
    ];
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
                    DropdownButtonFormField<String>(
                      initialValue: sel,
                      items: statuses
                          .map(
                            (String e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) => setModal(() => sel = v ?? sel),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            t['status'] = sel;
                          });
                          Navigator.of(ctx).pop();
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
