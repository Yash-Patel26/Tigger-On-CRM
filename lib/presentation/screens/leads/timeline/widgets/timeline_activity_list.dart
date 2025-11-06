import 'package:flutter/material.dart';
import '../../../../../shared/utils/helpers.dart';
import '../../../../../shared/utils/timezone.dart';

class TimelineActivityList extends StatelessWidget {
  const TimelineActivityList({super.key, required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text('No activities found'));
    }
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityCard(activity: activity);
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final Map<String, dynamic> activity;

  @override
  Widget build(BuildContext context) {
    final type = activity['type'] as String? ?? 'Unknown';
    final description = activity['description'] as String? ?? 'No description';
    final createdAt = activity['created_at'] as String? ?? '';
    final performedBy = activity['performed_by_name'] as String? ?? 'Unknown';
    final Map<String, dynamic>? metadata =
        activity['metadata'] as Map<String, dynamic>?;
    final String mainDisposition = (metadata != null
            ? (metadata['main_disposition'] as String?)
            : null)
        ?.toLowerCase() ??
        '';
    final bool isHotDisposition =
        type.toLowerCase() == 'disposition_change' &&
        (mainDisposition.contains('hot') || description.toLowerCase().contains('hot'));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text(type[0].toUpperCase())),
        title: Text(type.replaceAll('_', ' ').toUpperCase()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            if (isHotDisposition) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: const [
                  Chip(
                    label: Text('HOT'),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.red,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'By: $performedBy',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (createdAt.isNotEmpty)
              Text(
                _formatDateTime(createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final ist = TimezoneUtil.toIST(dateTime);
      return Helpers.formatDateTime(ist, pattern: 'dd/MM/yyyy HH:mm');
    } catch (_) {
      return dateTimeString;
    }
  }
}
