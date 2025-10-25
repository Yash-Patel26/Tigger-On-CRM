import 'package:flutter/material.dart';

class ProjectPriceLogsScreen extends StatelessWidget {
  const ProjectPriceLogsScreen({super.key, required this.project});

  final Map<String, dynamic> project;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> p = _mergeWithDefaults(project);
    final List<Map<String, dynamic>> logs =
        (p['priceLogs'] as List<Map<String, dynamic>>);

    return Scaffold(
      appBar: AppBar(title: const Text('Price Logs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _headerCard(context, p);
          }
          final Map<String, dynamic> log = logs[index - 1];
          return _logCard(context, p, log);
        },
      ),
    );
  }

  Map<String, dynamic> _mergeWithDefaults(Map<String, dynamic> input) {
    String? s(dynamic v) =>
        (v is String && v.trim().isEmpty) ? null : (v as String?);
    return <String, dynamic>{
      'name': s(input['name']) ?? 'Sample Project',
      'launchPrice': s(input['launchPrice']) ?? '₹ 30 L',
      'currentPrice':
          s(input['currentPrice']) ?? s(input['price']) ?? '₹ 45 L',
      'price': s(input['price']) ?? '₹ 45 L',
      'priceLogs':
          (input['priceLogs'] as List<Map<String, dynamic>>?) ??
          <Map<String, dynamic>>[
            <String, dynamic>{
              'projectPrice': '₹ 30 L',
              'createdAt': DateTime.now()
                  .subtract(const Duration(days: 300))
                  .toIso8601String(),
            },
            <String, dynamic>{
              'projectPrice': '₹ 38 L',
              'createdAt': DateTime.now()
                  .subtract(const Duration(days: 180))
                  .toIso8601String(),
            },
            <String, dynamic>{
              'projectPrice': '₹ 45 L',
              'createdAt': DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String(),
            },
          ],
    };
  }

  Widget _headerCard(BuildContext context, Map<String, dynamic> p) {
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
          Text(
            p['name'] as String,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _kv('Launch price', p['launchPrice']),
          _kv('Current market price', p['currentPrice']),
        ],
      ),
    );
  }

  Widget _logCard(
    BuildContext context,
    Map<String, dynamic> p,
    Map<String, dynamic> log,
  ) {
    final String projectName = p['name'] as String;
    final String launchPrice = p['launchPrice'] as String;
    final String currentPrice = p['currentPrice'] as String;
    final String projectPrice =
        (log['projectPrice'] as String?) ?? p['price'] as String;
    final DateTime createdAt =
        DateTime.tryParse((log['createdAt'] as String?) ?? '') ??
        DateTime.now();

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
          Text(
            projectName,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _kv('Launch price', launchPrice),
          _kv('Current market price', currentPrice),
          _kv('Project price', projectPrice),
          _kv('Created at', _formatDate(createdAt)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _kv(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('${value ?? '—'}')),
        ],
      ),
    );
  }
}
