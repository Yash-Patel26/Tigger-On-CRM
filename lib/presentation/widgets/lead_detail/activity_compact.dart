import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:realtime_client/realtime_client.dart';
import '../../../data/repositories/lead_repository.dart';

class ActivityCompact extends StatefulWidget {
  const ActivityCompact({
    super.key,
    required this.leadId,
    this.enableRealtime = true,
  });
  final String leadId;
  final bool enableRealtime;

  @override
  State<ActivityCompact> createState() => _ActivityCompactState();
}

class _ActivityCompactState extends State<ActivityCompact> {
  supabase.RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.enableRealtime) {
      final client = supabase.Supabase.instance.client;
      _channel = client
          .channel('public:leads:${widget.leadId}:activity')
          .onPostgresChanges(
            event: supabase.PostgresChangeEvent.update,
            schema: 'public',
            table: 'leads',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: widget.leadId,
            ),
            callback: (payload) {
              if (!mounted) return;
              setState(() {});
            },
          )
          .subscribe();
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: LeadRepository().getLeadTimeline(widget.leadId).then((
                response,
              ) {
                final List<Map<String, dynamic>> raw =
                    response.data ?? <Map<String, dynamic>>[];
                // Normalize keys to match UI expectations
                final normalized = raw.map((e) {
                  final bool needsNormalization =
                      e.containsKey('activity_type') ||
                      e.containsKey('timestamp');
                  if (needsNormalization) {
                    return <String, dynamic>{
                      'type': (e['activity_type'] ?? e['type'] ?? '')
                          .toString(),
                      'created_at': (e['timestamp'] ?? e['created_at'] ?? '')
                          .toString(),
                      'description': e['description'],
                      'performed_by_name':
                          e['performed_by'] ?? e['performed_by_name'],
                      'metadata': e['metadata'],
                      'action': e['action'],
                      'id': e['id'],
                    };
                  }
                  return e;
                }).toList();

                // Filter to only show updates relevant to the requested sections
                final allowedTypes = <String>{
                  'status_change',
                  'assignment_change',
                };

                final filtered = normalized.where((a) {
                  final t = (a['type'] as String? ?? '').toLowerCase();
                  if (allowedTypes.contains(t)) return true;
                  final md = a['metadata'];
                  if (md is Map<String, dynamic>) {
                    // Show any activity that includes explicit old/new values
                    return md.containsKey('old_values') ||
                        md.containsKey('new_values') ||
                        md.containsKey('old_status') ||
                        md.containsKey('new_status') ||
                        md.containsKey('old_assignee') ||
                        md.containsKey('new_assignee');
                  }
                  return false;
                }).toList();

                // Sort newest first
                filtered.sort((a, b) {
                  final aTime =
                      DateTime.tryParse(a['created_at'] ?? '') ??
                      DateTime(1970);
                  final bTime =
                      DateTime.tryParse(b['created_at'] ?? '') ??
                      DateTime(1970);
                  return bTime.compareTo(aTime);
                });

                return filtered;
              }),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final List<Map<String, dynamic>> activities =
                        snapshot.data ?? <Map<String, dynamic>>[];
                    if (activities.isEmpty) {
                      return const Text('No recent activity');
                    }
                    return Column(
                      children: activities.take(8).map((activity) {
                        final meta = activity['metadata'];

                        // Build diff lines for known change types
                        final List<Widget> diffLines = [];
                        if (meta is Map<String, dynamic>) {
                          if (meta.containsKey('old_status') ||
                              meta.containsKey('new_status')) {
                            diffLines.add(
                              _diffLine(
                                context,
                                'Status',
                                '${meta['old_status'] ?? '-'}',
                                '${meta['new_status'] ?? '-'}',
                              ),
                            );
                          }
                          if (meta.containsKey('old_assignee') ||
                              meta.containsKey('new_assignee')) {
                            diffLines.add(
                              _diffLine(
                                context,
                                'Assignee',
                                '${meta['old_assignee'] ?? '-'}',
                                '${meta['new_assignee'] ?? '-'}',
                              ),
                            );
                          }
                          final oldVals = meta['old_values'];
                          final newVals = meta['new_values'];
                          if (oldVals is Map && newVals is Map) {
                            const fieldsOfInterest = <String>{
                              'name',
                              'customer_name',
                              'project_name',
                              'property_type',
                              'category_type',
                              'occupation',
                              'employment_type',
                              'address',
                              'city',
                              'state',
                              'pincode',
                            };
                            for (final key in fieldsOfInterest) {
                              if (oldVals[key] != newVals[key]) {
                                diffLines.add(
                                  _diffLine(
                                    context,
                                    _labelForField(key),
                                    '${oldVals[key] ?? '-'}',
                                    '${newVals[key] ?? '-'}',
                                  ),
                                );
                              }
                            }
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    _getActivityIcon(
                                      (activity['type'] as String?) ?? '',
                                    ),
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (activity['description'] as String?) ??
                                          'Updated details',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  Text(
                                    _formatActivityTime(
                                      (activity['created_at'] as String?) ?? '',
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              if (diffLines.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 4),
                                ...diffLines,
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call':
      case 'call_initiated':
        return FontAwesomeIcons.phone;
      case 'email':
        return FontAwesomeIcons.envelope;
      case 'sms':
        return FontAwesomeIcons.message;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'disposition_change':
        return FontAwesomeIcons.tags;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  Widget _diffLine(
    BuildContext context,
    String label,
    String oldValue,
    String newValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            '$oldValue → $newValue',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _labelForField(String key) {
    switch (key) {
      case 'customer_name':
      case 'name':
        return 'Name';
      case 'project_name':
        return 'Preferred Project';
      case 'property_type':
        return 'Property Type';
      case 'category_type':
        return 'Preference';
      case 'occupation':
        return 'Occupation';
      case 'employment_type':
        return 'Employment Type';
      case 'address':
        return 'Address';
      case 'city':
        return 'City';
      case 'state':
        return 'State';
      case 'pincode':
        return 'Pincode';
      default:
        return key;
    }
  }

  String _formatActivityTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return dateTimeString;
    }
  }
}
