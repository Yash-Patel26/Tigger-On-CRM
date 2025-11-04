import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:realtime_client/realtime_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/lead_repository.dart';

class ProjectLocationCompact extends StatefulWidget {
  const ProjectLocationCompact({
    super.key,
    required this.leadId,
    this.enableRealtime = true,
  });
  final String leadId;
  final bool enableRealtime;

  @override
  State<ProjectLocationCompact> createState() => _ProjectLocationCompactState();
}

class _ProjectLocationCompactState extends State<ProjectLocationCompact> {
  supabase.RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.enableRealtime) {
      final client = supabase.Supabase.instance.client;
      _channel = client
          .channel('public:leads:${widget.leadId}:project_location')
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
    return FutureBuilder<Lead>(
      future: LeadRepository().getLead(widget.leadId).then((response) {
        if (response.success && response.data != null) return response.data!;
        throw Exception(response.error ?? 'Failed to load lead');
      }),
      builder: (BuildContext context, AsyncSnapshot<Lead> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final Lead lead = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (lead.categoryType.toString().split('.').last.isNotEmpty)
              _buildInfoRow(
                context,
                'Category',
                lead.categoryType.toString().split('.').last.toUpperCase(),
              ),
            if (lead.propertyType.toString().split('.').last.isNotEmpty)
              _buildInfoRow(
                context,
                'Property Type',
                lead.propertyType
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map(
                      (String word) =>
                          word[0].toUpperCase() +
                          word.substring(1).toLowerCase(),
                    )
                    .join(' '),
              ),
            if (lead.stateName != null && lead.stateName!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.stateName!)
            else if (lead.state != null && lead.state!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.state!),
            if (lead.city != null && lead.city!.isNotEmpty)
              _buildInfoRow(context, 'City', lead.city!),
            if (lead.location != null && lead.location!.isNotEmpty)
              _buildInfoRow(context, 'Location', lead.location!),
            if (lead.projectName != null && lead.projectName!.isNotEmpty)
              _buildInfoRow(context, 'Project Name', lead.projectName!),
            if (lead.budgetRange != null && lead.budgetRange!.isNotEmpty)
              _buildInfoRow(context, 'Budget', lead.budgetRange!),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
