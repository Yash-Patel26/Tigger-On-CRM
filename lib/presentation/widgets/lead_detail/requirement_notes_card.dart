import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:realtime_client/realtime_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/lead_repository.dart';

class RequirementNotesCard extends StatefulWidget {
  const RequirementNotesCard({
    super.key,
    required this.leadId,
    this.enableRealtime = true,
  });
  final String leadId;
  final bool enableRealtime;

  @override
  State<RequirementNotesCard> createState() => _RequirementNotesCardState();
}

class _RequirementNotesCardState extends State<RequirementNotesCard> {
  supabase.RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (widget.enableRealtime) {
      final client = supabase.Supabase.instance.client;
      _channel = client
          .channel('public:leads:${widget.leadId}:requirements')
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
        if (response.success && response.data != null) {
          return response.data!;
        }
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
            if (lead.requirements != null &&
                lead.requirements!.isNotEmpty) ...<Widget>[
              Text(
                'Requirements:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(lead.requirements!),
              const SizedBox(height: 12),
            ],
            Text(
              'Notes:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'No additional notes available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }
}
