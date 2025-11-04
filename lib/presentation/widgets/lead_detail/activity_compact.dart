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
              future: LeadRepository()
                  .getLeadTimeline(widget.leadId)
                  .then(
                    (response) => response.data ?? <Map<String, dynamic>>[],
                  ),
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
                      children: activities.take(5).map((
                        Map<String, dynamic> activity,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                _getActivityIcon(
                                  (activity['type'] as String?) ?? '',
                                ),
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  (activity['description'] as String?) ??
                                      'No description',
                                  style: Theme.of(context).textTheme.bodySmall,
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
