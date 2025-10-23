import 'package:flutter/material.dart';
import '../repositories/dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'lead_screen.dart';
import 'site_visit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showToday = true; // true=today, false=total
  bool _isLoading = true;
  String? _error;

  // Data from API
  Map<String, int> _today = <String, int>{};
  Map<String, int> _total = <String, int>{};

  final DashboardRepository _dashboardRepository = DashboardRepository();
  supabase.RealtimeChannel? _statsChannel;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToStatsUpdates();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load both today and total data
      final todayResponse = await _dashboardRepository.getTodayStats();
      final totalResponse = await _dashboardRepository.getTotalStats();

      if (todayResponse.success && totalResponse.success) {
        if (mounted) {
          setState(() {
            _today = _parseStatsData(todayResponse.data!);
            _total = _parseStatsData(totalResponse.data!);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error =
                todayResponse.message ??
                totalResponse.message ??
                'Failed to load data';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading dashboard data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToStatsUpdates() {
    final supabase.SupabaseClient client = supabase.Supabase.instance.client;
    final supabase.RealtimeChannel statsCh = client.channel(
      'public:dashboard_stats',
    );

    // Listen to leads table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'leads',
      callback: (supabase.PostgresChangePayload payload) {
        _loadData(); // Refresh stats when leads change
      },
    );

    // Listen to site_visits table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'site_visits',
      callback: (supabase.PostgresChangePayload payload) {
        _loadData(); // Refresh stats when site visits change
      },
    );

    // Listen to bookings table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'bookings',
      callback: (supabase.PostgresChangePayload payload) {
        _loadData(); // Refresh stats when bookings change
      },
    );

    // Listen to customers table changes
    statsCh.onPostgresChanges(
      event: supabase.PostgresChangeEvent.all,
      schema: 'public',
      table: 'customers',
      callback: (supabase.PostgresChangePayload payload) {
        _loadData(); // Refresh stats when customers change
      },
    );

    _statsChannel = statsCh.subscribe();
  }

  @override
  void dispose() {
    _statsChannel?.unsubscribe();
    super.dispose();
  }

  Map<String, int> _parseStatsData(Map<String, dynamic> data) {
    return {
      'Follow ups': data['followUps'] ?? 0,
      'Hot opportunity': data['hotLeads'] ?? 0,
      'Site visits': data['siteVisits'] ?? 0,
      'Booking': data['bookings'] ?? 0,
      'Customer': data['customers'] ?? 0,
      'Disqualified': data['disqualified'] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          if (!_isLoading && _error == null)
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading dashboard',
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final Map<String, int> data = _showToday ? _today : _total;
    final int totalLeads = data.values.fold<int>(0, (int a, int b) => a + b);

    return SingleChildScrollView(
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LeadScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Site Visits',
                  value: data['Site visits']?.toString() ?? '0',
                  icon: Icons.place_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SiteVisitScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DonutChartCard(data: data),
        ],
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
