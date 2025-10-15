import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showToday = true; // true=today, false=total

  // Demo data. Replace with real values wired from backend.
  final Map<String, int> _today = <String, int>{
    'Follow ups': 4,
    'Hot opportunity': 3,
    'Site visits': 2,
    'Booking': 1,
    'Customer': 2,
    'Disqualified': 1,
  };

  final Map<String, int> _total = <String, int>{
    'Follow ups': 86,
    'Hot opportunity': 24,
    'Site visits': 40,
    'Booking': 18,
    'Customer': 55,
    'Disqualified': 9,
  };

  @override
  Widget build(BuildContext context) {
    final Map<String, int> data = _showToday ? _today : _total;
    final int totalLeads = data.values.fold<int>(0, (int a, int b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: SegmentedButton<bool>(
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(value: true, label: Text('Today')),
                  ButtonSegment<bool>(value: false, label: Text('Total')),
                ],
                selected: <bool>{_showToday},
                showSelectedIcon: false,
                onSelectionChanged: (Set<bool> v) {
                  setState(() => _showToday = v.first);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    label: _showToday ? 'Today\'s Leads' : 'Total Leads',
                    value: totalLeads.toString(),
                    icon: Icons.leaderboard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Site Visits',
                    value: data['Site visits']?.toString() ?? '0',
                    icon: Icons.place_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DonutChartCard(data: data),
          ],
        ),
      ),
    );
  }
}

class _DonutChartCard extends StatelessWidget {
  const _DonutChartCard({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> entries = data.entries.toList();
    final int total = entries.fold<int>(
      0,
      (int a, MapEntry<String, int> b) => a + b.value,
    );
    final List<Color> colors = <Color>[
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.redAccent,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
          Text(
            'Lead Distribution',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double size = constraints.maxWidth.clamp(180.0, 420.0);
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _DonutChartPainter(
                      entries,
                      total,
                      colors,
                      Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              for (int i = 0; i < entries.length; i++)
                _LegendChip(
                  color: colors[i % colors.length],
                  label: entries[i].key,
                  value: entries[i].value,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: $value', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter(this.entries, this.total, this.colors, this.bgColor);

  final List<MapEntry<String, int>> entries;
  final int total;
  final List<Color> colors;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;
    final double thickness = radius * 0.35;

    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = bgColor.withOpacity(0.18)
      ..strokeCap = StrokeCap.round;

    // Base ring
    canvas.drawCircle(center, radius * 0.82, base);

    if (total <= 0) return;

    double startAngle = -3.14159 / 2; // start at top
    for (int i = 0; i < entries.length; i++) {
      final double sweep = (entries[i].value / total) * 6.28318;
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = colors[i % colors.length]
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.82),
        startAngle,
        sweep,
        false,
        p,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.04);
}

Color _panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.12) : const Color(0x22000000);
}
