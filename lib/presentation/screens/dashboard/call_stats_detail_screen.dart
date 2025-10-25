import 'package:flutter/material.dart';
import '../../../data/models/lead_activity_model.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/database_service_masters.dart' as masters;

class CallStatsDetailScreen extends StatefulWidget {
  const CallStatsDetailScreen({super.key, required this.summary});

  final Map<String, int>
  summary; // keys: total,incoming,outgoing,connected,notConnected,missed

  @override
  State<CallStatsDetailScreen> createState() => _CallStatsDetailScreenState();
}

class _CallStatsDetailScreenState extends State<CallStatsDetailScreen> {
  String _selectedUser = 'CRM User';
  String _selectedProject = 'All Projects';
  String _selectedStatus = 'Any';
  String _selectedRange = 'Today';

  // Real data from database
  List<LeadActivity> _callActivities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCallActivities();
  }

  Future<void> _loadCallActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get all leads first
      final List<Lead> leads = await DatabaseService.getLeads();

      // Get activities for all leads
      final List<LeadActivity> allActivities = [];
      for (final Lead lead in leads) {
        try {
          final List<LeadActivity> leadActivities =
              await masters.DatabaseServiceMasters.getLeadActivities(
                leadId: lead.id,
                limit: 100, // Get more activities per lead
              );
          allActivities.addAll(leadActivities);
        } catch (e) {
          // Skip if error getting activities for this lead
          print('Error getting activities for lead ${lead.id}: $e');
        }
      }

      // Filter for call-related activities
      final List<LeadActivity> callActivities = allActivities.where((activity) {
        return activity.type == ActivityType.callInitiated ||
            activity.type == ActivityType.emailInitiated ||
            activity.type == ActivityType.messageInitiated ||
            activity.type == ActivityType.whatsappInitiated;
      }).toList();

      setState(() {
        _callActivities = callActivities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Call Stats'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Filters',
              icon: const Icon(Icons.tune),
              onPressed: _openFilters,
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading call activities...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Call Stats'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Filters',
              icon: const Icon(Icons.tune),
              onPressed: _openFilters,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading call activities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadCallActivities,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, int> s = widget.summary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Stats'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildChart(context, s),
          const SizedBox(height: 16),
          _buildLegend(context, s),
          const SizedBox(height: 16),
          ..._callActivities.map(
            (LeadActivity activity) => _callCardFromActivity(context, activity),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, Map<String, int> s) {
    final List<_Bar> bars = <_Bar>[
      _Bar('Total', s['total'] ?? 0, Colors.indigo),
      _Bar('Connected', s['connected'] ?? 0, const Color(0xFFE55934)),
      _Bar('Not connected', s['notConnected'] ?? 0, const Color(0xFFC62828)),
      _Bar('Missed', s['missed'] ?? 0, Colors.orange),
    ];
    final int maxVal = bars.fold<int>(
      1,
      (int m, _Bar b) => b.value > m ? b.value : m,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: bars.map((_Bar b) {
          final double h = (b.value / maxVal) * 140.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                b.value.toString(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Container(
                width: 26,
                height: h.clamp(6, 140),
                decoration: BoxDecoration(
                  color: b.color.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 70,
                child: Text(
                  b.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Map<String, int> s) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: <Widget>[
        _legendChip(context, Colors.indigo, 'Total: ${(s['total'] ?? 0)}'),
        _legendChip(
          context,
          const Color(0xFFE55934),
          'Connected: ${(s['connected'] ?? 0)}',
        ),
        _legendChip(
          context,
          const Color(0xFFC62828),
          'Not connected: ${(s['notConnected'] ?? 0)}',
        ),
        _legendChip(context, Colors.orange, 'Missed: ${(s['missed'] ?? 0)}'),
      ],
    );
  }

  Widget _legendChip(BuildContext context, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        String user = _selectedUser;
        String project = _selectedProject;
        String status = _selectedStatus;
        String range = _selectedRange;
        final List<String> users = <String>[
          'CRM User',
          'Anita',
          'Chetan',
          'Sample',
        ];
        final List<String> projects = <String>[
          'All Projects',
          'Skyline Heights',
          'Tech Park',
          'Green Meadows',
        ];
        final List<String> statuses = <String>[
          'Any',
          'Connected',
          'Not connected',
          'Missed',
        ];
        final List<String> ranges = <String>[
          'Today',
          'Yesterday',
          'Weekly',
          'Quarterly',
          'Monthly',
        ];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Filters',
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
                  DropdownButtonFormField<String>(
                    initialValue: user,
                    items: users
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => user = v ?? 'CRM User'),
                    decoration: const InputDecoration(labelText: 'CRM User'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: project,
                    items: projects
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => project = v ?? 'All Projects'),
                    decoration: const InputDecoration(
                      labelText: 'Select Project',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: statuses
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => status = v ?? 'Any'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: range,
                    items: ranges
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => range = v ?? 'Today'),
                    decoration: const InputDecoration(labelText: 'Range'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedUser = 'CRM User';
                              _selectedProject = 'All Projects';
                              _selectedStatus = 'Any';
                              _selectedRange = 'Today';
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedUser = user;
                              _selectedProject = project;
                              _selectedStatus = status;
                              _selectedRange = range;
                            });
                            Navigator.of(ctx).pop();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _callCardFromActivity(BuildContext context, LeadActivity activity) {
    final String status = _getActivityStatus(activity.type);
    final String response = _getActivityResponse(activity);
    final String phone = _getActivityPhone(activity);
    final String callTime = _formatDateTime(activity.createdAt);
    final String duration = _getActivityDuration(activity);
    final String calledBy = activity.performedByName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  activity.description,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _statusPill(context, status),
            ],
          ),
          const SizedBox(height: 6),
          _kv(context, 'Response', response),
          _kv(context, 'Phone', phone),
          _kv(context, 'Call time', callTime),
          _kv(context, 'Call duration', duration),
          _kv(context, 'Called by', calledBy),
        ],
      ),
    );
  }

  String _getActivityStatus(ActivityType type) {
    switch (type) {
      case ActivityType.callInitiated:
        return 'Connected';
      case ActivityType.emailInitiated:
        return 'Email Sent';
      case ActivityType.messageInitiated:
        return 'Message Sent';
      case ActivityType.whatsappInitiated:
        return 'WhatsApp Sent';
      default:
        return 'Unknown';
    }
  }

  String _getActivityResponse(LeadActivity activity) {
    // Extract response from description or metadata
    if (activity.metadata != null && activity.metadata!['response'] != null) {
      return activity.metadata!['response'].toString();
    }
    return 'No response recorded';
  }

  String _getActivityPhone(LeadActivity activity) {
    // Extract phone from metadata
    if (activity.metadata != null && activity.metadata!['phone'] != null) {
      return activity.metadata!['phone'].toString();
    }
    return 'Phone not recorded';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getActivityDuration(LeadActivity activity) {
    // Extract duration from metadata
    if (activity.metadata != null && activity.metadata!['duration'] != null) {
      return activity.metadata!['duration'].toString();
    }
    return '00:00';
  }

  Widget _kv(BuildContext context, String k, String? v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(v ?? '—')),
        ],
      ),
    );
  }

  Widget _statusPill(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'connected':
        color = const Color(0xFFE55934);
        break;
      case 'missed':
        color = Colors.orange;
        break;
      default:
        color = const Color(0xFFC62828);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Bar {
  const _Bar(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}
