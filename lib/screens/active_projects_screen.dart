import 'package:flutter/material.dart';

class ActiveProjectsScreen extends StatelessWidget {
  const ActiveProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> projects =
        List<Map<String, String>>.generate(15, (int i) {
          return <String, String>{
            'id': 'PRJ-${1000 + i}',
            'name': 'Active Project ${i + 1}',
            'location': 'Sector ${10 + i}',
            'price': '₹ ${40 + i} L',
            'status': 'Active',
          };
        });

    return Scaffold(
      appBar: AppBar(title: const Text('Active Projects')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final Map<String, String> p = projects[index];
          return _card(context, p);
        },
      ),
    );
  }

  Widget _card(BuildContext context, Map<String, String> p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: const Icon(Icons.apartment, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  p['name'] ?? '-',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.tag, size: 14),
                    const SizedBox(width: 6),
                    Text(p['id'] ?? '-'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p['location'] ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.sell_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(p['price'] ?? '-'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE55934).withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFE55934).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Color(0xFFE55934),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
